import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/features/shopping_list/components/ai_categorize_button.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_matcher.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_section_header.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_item_metrics.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

part 'shopping_list_items.g.dart';

/// 入力行(空行)に割り当てる安定した GlobalKey を item.id ごとに保持するレジストリ。
///
/// 入力行で Enter を押すと確定テキストを別アイテムとして「入力行の上」に挿入するため、
/// 入力行の list index が 1 つ下にずれる。ValueKey だけだと SliverList が index ずれ時に
/// 要素を再生成して EditableText の入力接続(TextInputConnection)を破棄し、iOS の
/// ソフトキーボードが一瞬閉じる(fix-350 で実機計測)。GlobalKey を付けると Flutter は
/// 要素(と State=入力接続)を再生成せず移動して保持するため、キーボードが閉じない。
///
/// 確定行(非空)には付けない。ReorderableList のドラッグ中は対象行の proxy が複製され、
/// GlobalKey だと「Duplicate GlobalKey」でクラッシュするため。入力行はドラッグ対象外にする。
///
/// id(Firestore 自動 ID)は再利用されないため、一覧から消えた id の GlobalKey が
/// 別アイテムへ誤って再アタッチされることはない。GlobalKey を付けるのは実質「リストごとに
/// 1 つの入力行」だけなのでマップはほぼ増えず、不要 entry の掃除は行わない。
class ShoppingListItemRowKeys {
  final Map<String, GlobalKey> _keys = {};

  /// id に対応する GlobalKey を取得(なければ生成)する。
  GlobalKey of(String id) => _keys.putIfAbsent(id, () => GlobalKey());
}

/// 入力行 GlobalKey レジストリ。アプリ起動中ずっと同一インスタンスを保持する
/// (リビルドを跨いで GlobalKey を維持しキーボードを閉じさせないため keepAlive)。
@Riverpod(keepAlive: true)
ShoppingListItemRowKeys shoppingListItemRowKeys(Ref ref) =>
    ShoppingListItemRowKeys();

/// 買い物リストのスクロール末尾に確保する下方向パディング。
/// 画面外側の SafeArea が bottom:false（NavBar の帯を下端まで伸ばすため）なので、
/// ホームインジケータ/iPhone 下部バーの安全領域分を自前で確保し、さらに最終アイテムが
/// バーに張り付かないよう余白を上乗せして被りを防ぐ。
EdgeInsets _listBottomPadding(BuildContext context) => EdgeInsets.only(
      bottom: MediaQuery.of(context).padding.bottom + 200,
    );

/// 買い物リストのアイテム一覧。カテゴリ軸があればカテゴリ別グルーピング、無ければフラット表示する。
class ShoppingListItems extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final String? shoppingLocationID;

  const ShoppingListItems({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingLocationID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListItems = ref
            .watch(textShoppingListItemsProvider(
                groupID: groupID, shoppingListID: shoppingListID))
            .valueOrNull ??
        [];
    final axesAsync = ref.watch(groupCategoryAxesProvider(groupID: groupID));

    return axesAsync.when(
      data: (axes) {
        if (axes.isEmpty) {
          return _FlatShoppingListItems(
            groupID: groupID,
            shoppingListID: shoppingListID,
            shoppingListItems: shoppingListItems,
            // 軸が無いときは、AIにカテゴリ作成から任せるボタンを出す。
            showCategorizeButton: true,
            categoryAxisID: null,
            existingCategoryNames: const [],
          );
        }

        final axis = axes.first;
        return _CategorizedShoppingListItems(
          groupID: groupID,
          shoppingListID: shoppingListID,
          shoppingListItems: shoppingListItems,
          categoryAxisID: axis.id,
          shoppingLocationID: shoppingLocationID,
        );
      },
      error: (e, st) => Center(child: Text(e.toString())),
      loading: () => _FlatShoppingListItems(
        groupID: groupID,
        shoppingListID: shoppingListID,
        shoppingListItems: shoppingListItems,
      ),
    );
  }
}

/// カテゴリが存在しない場合のフラット表示（従来の表示）
class _FlatShoppingListItems extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;

  /// 未分類アイテムが全件である（＝カテゴリ未作成）ときに、AIカテゴリ分けボタンを上部に出すか。
  final bool showCategorizeButton;

  /// AIカテゴリ分けの登録先軸。null なら登録時に「デフォルト」軸を作成する。
  final String? categoryAxisID;

  /// AIに渡す既存カテゴリ名（フラット表示時は空）。
  final List<String> existingCategoryNames;

  const _FlatShoppingListItems({
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
    this.showCategorizeButton = false,
    this.categoryAxisID,
    this.existingCategoryNames = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowKeys = ref.watch(shoppingListItemRowKeysProvider);
    final list = ReorderableList(
      padding: _listBottomPadding(context),
      // アイテム編集中にリストをスクロール(ドラッグ)したらキーボードを閉じる
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      onReorder: (oldIndex, newIndex) {
        analytics.logEvent(
          name: 'reorder_shopping_list_item',
          parameters: {
            'groupID': groupID,
            'shoppingListID': shoppingListID,
          },
        );
        // ドラッグ時にリストから要素を一時的に削除するため newIndex がずれるのを調整
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final changedItems = [...shoppingListItems];
        final movedItem = changedItems.removeAt(oldIndex);
        changedItems.insert(newIndex, movedItem);
        final orderedItems = changedItems
            .asMap()
            .entries
            .map((entry) => entry.value.copyWith(order: entry.key))
            .toList();
        ref.read(shoppingListItemBatchUpdateProvider(groupID: groupID)).call(
              shoppingListID: shoppingListID,
              shoppingListItems: orderedItems,
            );
      },
      itemCount: shoppingListItems.length,
      itemBuilder: (context, index) {
        final item = shoppingListItems[index];
        // 入力行(空行)は、確定アイテムを上に挿入して index がずれても要素(= EditableText の
        // 入力接続)を保持してキーボードを閉じないよう GlobalKey で固定する。確定行は ValueKey
        // (ドラッグ並べ替え時に proxy と GlobalKey が二重化してクラッシュするのを避ける)。
        final isInputRow = item.message.isEmpty;
        return TextShoppingListItemWidget(
          key: isInputRow ? rowKeys.of(item.id) : ValueKey(item.id),
          groupID: groupID,
          textShoppingListItem: item,
          shoppingListItems: shoppingListItems,
          // 空の入力行はドラッグ対象外にする(GlobalKey の proxy 二重化回避 + 空行の並べ替えは無意味)。
          reorderIndex: isInputRow ? null : index,
        );
      },
    );

    // 入力中の空行(message が空) や空白のみのアイテムはカテゴリ分け対象にならないため、
    // ボタンの表示判定と件数から除外する。
    final categorizableItems = shoppingListItems
        .where((item) => item.message.trim().isNotEmpty)
        .toList();
    if (!showCategorizeButton || categorizableItems.isEmpty) {
      return list;
    }
    // カテゴリ未作成のフラット表示では全アイテムが未分類。自動カテゴリ分けボタンを上部に出す。
    return Column(
      children: [
        AICategorizeButton(
          groupID: groupID,
          shoppingListID: shoppingListID,
          categoryAxisID: categoryAxisID,
          uncategorizedItems: categorizableItems,
          existingCategoryNames: existingCategoryNames,
        ),
        Expanded(child: list),
      ],
    );
  }
}

/// カテゴリが存在する場合のグルーピング表示
class _CategorizedShoppingListItems extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;
  final String categoryAxisID;
  final String? shoppingLocationID;

  const _CategorizedShoppingListItems({
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
    required this.categoryAxisID,
    required this.shoppingLocationID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
    final rowKeys = ref.watch(shoppingListItemRowKeysProvider);
    final categoriesAsync = ref.watch(groupCategoriesProvider(
        groupID: groupID, categoryAxisID: categoryAxisID));

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          // 軸はあるがカテゴリが無い → 全アイテムが未分類。AIにカテゴリ作成から任せる。
          return _FlatShoppingListItems(
            groupID: groupID,
            shoppingListID: shoppingListID,
            shoppingListItems: shoppingListItems,
            showCategorizeButton: true,
            categoryAxisID: categoryAxisID,
            existingCategoryNames: const [],
          );
        }

        final grouped = groupItemsByCategory(
          items: shoppingListItems,
          categories: categories,
        );

        // 入力中の空行(message が空) や空白のみのアイテムはカテゴリ分け対象にならないため、
        // ボタンの表示判定と件数から除外する。
        final uncategorizedItems =
            (grouped[uncategorizedCategoryID] ?? const [])
                .where((item) => item.message.trim().isNotEmpty)
                .toList();
        final groupedListView = _GroupedListView(
          groupID: groupID,
          shoppingListID: shoppingListID,
          categoryAxisID: categoryAxisID,
          categories: categories,
          grouped: grouped,
          shoppingLocationID: isPremium ? shoppingLocationID : null,
          rowKeys: rowKeys,
        );
        if (uncategorizedItems.isEmpty) {
          return groupedListView;
        }
        // 未分類セクションがあるときは、リスト上部に自動カテゴリ分けボタンを出す。
        return Column(
          children: [
            AICategorizeButton(
              groupID: groupID,
              shoppingListID: shoppingListID,
              categoryAxisID: categoryAxisID,
              uncategorizedItems: uncategorizedItems,
              existingCategoryNames:
                  categories.map((category) => category.name).toList(),
            ),
            Expanded(child: groupedListView),
          ],
        );
      },
      error: (e, st) => Center(child: Text(e.toString())),
      loading: () => _FlatShoppingListItems(
        groupID: groupID,
        shoppingListID: shoppingListID,
        shoppingListItems: shoppingListItems,
      ),
    );
  }
}

/// カテゴリヘッダー付きのグルーピング表示。
/// ヘッダーとアイテムを 1 つの [ReorderableListView] にフラットに並べ、長押しドラッグで
/// 「同一カテゴリ内の並び替え」と「別カテゴリへの移動」の両方を許可する。
///
/// ヘッダーはドラッグ対象外にする(`buildDefaultDragHandles: false` + アイテム行のみ
/// [ReorderableDelayedDragStartListener] でラップ)。別カテゴリへドロップした場合は、移動先
/// カテゴリへ message を完全一致キーワードとして付け替えて分類を変更する。order は移動後の
/// 表示順で全体を 0..N-1 に正規化して永続化する。
class _GroupedListView extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final String categoryAxisID;
  final List<GroupCategory> categories;
  final Map<String, List<GroupShoppingListItem>> grouped;
  final String? shoppingLocationID;

  /// 入力行に安定した GlobalKey を割り当てるためのレジストリ。
  final ShoppingListItemRowKeys rowKeys;

  const _GroupedListView({
    required this.groupID,
    required this.shoppingListID,
    required this.categoryAxisID,
    required this.categories,
    required this.grouped,
    required this.shoppingLocationID,
    required this.rowKeys,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortedCategories = sortCategoriesByLocation(
      categories: categories,
      shoppingLocationID: shoppingLocationID,
    );
    final categoryMap = {for (final c in categories) c.id: c};
    final rows = buildGroupedRows(
      sortedCategories: sortedCategories,
      grouped: grouped,
    );

    return ReorderableListView.builder(
      padding: _listBottomPadding(context),
      // アイテム編集中にリストをスクロール(ドラッグ)したらキーボードを閉じる
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      // ヘッダーをドラッグ不可にするため既定のドラッグハンドルを無効化し、アイテム行のみ
      // ReorderableDelayedDragStartListener でラップして長押しドラッグを有効にする。
      buildDefaultDragHandles: false,
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        switch (row) {
          case GroupedHeaderRow(:final categoryID):
            return KeyedSubtree(
              key: ValueKey('header_${categoryID ?? uncategorizedCategoryID}'),
              child: _header(categoryMap, categoryID),
            );
          case GroupedItemRow(:final item, :final categoryID):
            final isInputRow = item.message.isEmpty;
            final tile = TextShoppingListItemWidget(
              // 入力行(空行)は確定アイテム挿入で index がずれてもフォーカスを保つため GlobalKey。
              // 確定行はドラッグ中の proxy 複製で GlobalKey が二重化しクラッシュするため ValueKey。
              key: isInputRow ? rowKeys.of(item.id) : ValueKey(item.id),
              groupID: groupID,
              textShoppingListItem: item,
              // 同一カテゴリのアイテム列(Enter 確定の nextOrder 計算に使う)。
              shoppingListItems:
                  grouped[categoryID ?? uncategorizedCategoryID] ?? const [],
              // 統合リストでは行自身は listener を持たず、外側でラップする。
              reorderIndex: null,
            );
            // 入力行はドラッグ対象外。確定行のみ長押しドラッグでラップする。
            if (isInputRow) {
              return KeyedSubtree(
                  key: ValueKey('item_${item.id}'), child: tile);
            }
            return ReorderableDelayedDragStartListener(
              key: ValueKey('item_${item.id}'),
              index: index,
              child: tile,
            );
        }
      },
      onReorder: (oldIndex, newIndex) {
        // [調査ログ] カテゴリまたぎ D&D の切り分け用。onReorder 発火と来た index(ヘッダー込み)。
        debugPrint(
            '[reorder] onReorder oldIndex=$oldIndex newIndex=$newIndex rows=${rows.length}');
        final moved = rows[oldIndex];
        if (moved is! GroupedItemRow) {
          debugPrint('[reorder] moved がヘッダー → 中断');
          return; // ヘッダーはドラッグ不可。通常起き得ないが防御。
        }
        analytics.logEvent(
          name: 'reorder_shopping_list_item',
          parameters: {
            'groupID': groupID,
            'shoppingListID': shoppingListID,
          },
        );
        final toCategoryID = categoryIDForDropPosition(
          rows: rows,
          oldIndex: oldIndex,
          newIndex: newIndex,
        );
        // [調査ログ] 移動元/移動先。同じだと「移動」にならず並び替え扱い。
        debugPrint(
            '[reorder] message="${moved.item.message}" from=${moved.categoryID} '
            'to=$toCategoryID crossCategory=${toCategoryID != moved.categoryID}');
        final orderedItems = itemsAfterMove(
          sortedCategories: sortedCategories,
          grouped: grouped,
          movedItem: moved.item,
          fromCategoryID: moved.categoryID,
          toCategoryID: toCategoryID,
          dropIndexInTargetValue: dropIndexInTarget(
            rows: rows,
            oldIndex: oldIndex,
            newIndex: newIndex,
            toCategoryID: toCategoryID,
          ),
        );
        // 別カテゴリへ移動した場合のみ、完全一致キーワードを付け替えて分類を変更する。
        if (toCategoryID != moved.categoryID) {
          ref
              .read(moveItemCategoryKeywordProvider(groupID: groupID))
              .call(
                categoryAxisID: categoryAxisID,
                itemMessage: moved.item.message,
                destinationCategoryID: toCategoryID,
                categories: categories,
              )
              // [調査ログ] fire-and-forget で握り潰していた成否を拾う。
              .then((_) => debugPrint('[reorder] キーワード付け替え成功 to=$toCategoryID'))
              .catchError((Object error, StackTrace stackTrace) {
            debugPrint('[reorder] キーワード付け替え失敗: $error\n$stackTrace');
          });
        }
        ref
            .read(shoppingListItemBatchUpdateProvider(groupID: groupID))
            .call(
              shoppingListID: shoppingListID,
              shoppingListItems: orderedItems,
            )
            .then((_) =>
                debugPrint('[reorder] order 永続化成功 (${orderedItems.length}件)'))
            .catchError((Object error, StackTrace stackTrace) {
          debugPrint('[reorder] order 永続化失敗: $error\n$stackTrace');
        });
      },
    );
  }

  /// カテゴリID(null=未分類)から見出し行を生成する。
  Widget _header(Map<String, GroupCategory> categoryMap, String? categoryID) {
    final items = grouped[categoryID ?? uncategorizedCategoryID] ?? const [];
    final metrics = shoppingListItemMetrics(items);
    final category = categoryID == null ? null : categoryMap[categoryID];
    return CategorySectionHeader(
      name: category?.name ?? '未分類',
      colorHex: category?.color,
      doneCount: metrics.checkedCount,
      totalCount: metrics.totalCount,
    );
  }
}
