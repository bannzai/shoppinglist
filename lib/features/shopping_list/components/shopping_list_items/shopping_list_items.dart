import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

/// 入力行(空行)に割り当てる安定した GlobalKey のマップ(item.id をキーにする)。
///
/// 入力行で Enter を押すと確定テキストを別アイテムとして「入力行の上」に挿入するため、
/// 入力行の list index が 1 つ下にずれる。ValueKey だけだと SliverList が index ずれ時に
/// 要素を再生成して EditableText の入力接続(TextInputConnection)を破棄し、iOS の
/// ソフトキーボードが一瞬閉じる(fix-350 で実機計測)。GlobalKey を付けると Flutter は
/// 要素(と State=入力接続)を再生成せず移動して保持するため、キーボードが閉じない。
///
/// 確定行(非空)には付けない。ReorderableList のドラッグ中は対象行の proxy が複製され、
/// GlobalKey だと「Duplicate GlobalKey」でクラッシュするため。入力行はドラッグ対象外にする。
final Map<String, GlobalKey> _shoppingListItemRowKeys = {};

/// [_shoppingListItemRowKeys] から id に対応する GlobalKey を取得(なければ生成)する。
GlobalKey _rowKey(String id) =>
    _shoppingListItemRowKeys.putIfAbsent(id, () => GlobalKey());

/// 一覧に存在しない id の GlobalKey を破棄してマップの肥大化を防ぐ。
void _pruneRowKeys(Iterable<String> currentIDs) {
  final keep = currentIDs.toSet();
  _shoppingListItemRowKeys.removeWhere((id, _) => !keep.contains(id));
}

/// 買い物リストのスクロール末尾に確保する下方向パディング。
/// 画面外側の SafeArea が bottom:false（NavBar の帯を下端まで伸ばすため）なので、
/// ホームインジケータ/iPhone 下部バーの安全領域分を自前で確保し、さらに最終アイテムが
/// バーに張り付かないよう余白を上乗せして被りを防ぐ。
EdgeInsets _listBottomPadding(BuildContext context) => EdgeInsets.only(
      bottom: MediaQuery.of(context).padding.bottom + 32,
    );

class ShoppingListItems extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final bool sortByCategory;

  /// チェック済みアイテムを一覧に表示するか。
  /// false のときは textShoppingListItemsProvider が status==unchecked に絞り込む。
  final bool showChecked;

  final String? shoppingLocationID;

  const ShoppingListItems({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.sortByCategory,
    required this.showChecked,
    required this.shoppingLocationID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListItems = ref
            .watch(textShoppingListItemsProvider(
                groupID: groupID,
                shoppingListID: shoppingListID,
                showChecked: showChecked))
            .valueOrNull ??
        [];
    // 入力行用 GlobalKey マップから、もう存在しない id を掃除する。
    _pruneRowKeys(shoppingListItems.map((item) => item.id));
    final axesAsync = ref.watch(groupCategoryAxesProvider(groupID: groupID));

    return axesAsync.when(
      data: (axes) {
        if (axes.isEmpty || !sortByCategory) {
          return _FlatShoppingListItems(
            groupID: groupID,
            shoppingListID: shoppingListID,
            shoppingListItems: shoppingListItems,
            // 軸が無くカテゴリ表示が有効なときだけ、AIにカテゴリ作成から任せるボタンを出す。
            showCategorizeButton: axes.isEmpty && sortByCategory,
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
          key: isInputRow ? _rowKey(item.id) : ValueKey(item.id),
          groupID: groupID,
          textShoppingListItem: item,
          shoppingListItems: shoppingListItems,
          // 空の入力行はドラッグ対象外にする(GlobalKey の proxy 二重化回避 + 空行の並べ替えは無意味)。
          reorderIndex: isInputRow ? null : index,
        );
      },
    );

    if (!showCategorizeButton || shoppingListItems.isEmpty) {
      return list;
    }
    // カテゴリ未作成のフラット表示では全アイテムが未分類。AIカテゴリ分けボタンを上部に出す。
    return Column(
      children: [
        AICategorizeButton(
          groupID: groupID,
          shoppingListID: shoppingListID,
          categoryAxisID: categoryAxisID,
          uncategorizedItems: shoppingListItems,
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

        final uncategorizedItems = grouped[uncategorizedCategoryID] ?? const [];
        final groupedListView = _GroupedListView(
          groupID: groupID,
          shoppingListID: shoppingListID,
          categories: categories,
          grouped: grouped,
          shoppingLocationID: isPremium ? shoppingLocationID : null,
        );
        if (uncategorizedItems.isEmpty) {
          return groupedListView;
        }
        // 未分類セクションがあるときは、リスト上部に AIカテゴリ分けボタンを出す。
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

/// カテゴリヘッダー付きのグルーピング表示。グルーピング表示時はドラッグ&ドロップを無効にする。
class _GroupedListView extends StatelessWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupCategory> categories;
  final Map<String, List<GroupShoppingListItem>> grouped;
  final String? shoppingLocationID;

  const _GroupedListView({
    required this.groupID,
    required this.shoppingListID,
    required this.categories,
    required this.grouped,
    required this.shoppingLocationID,
  });

  @override
  Widget build(BuildContext context) {
    final categoryMap = {for (final c in categories) c.id: c};
    final sortedCategories = sortCategoriesByLocation(
      categories: categories,
      shoppingLocationID: shoppingLocationID,
    );
    final sortedCategoryIDs = sortedCategories.map((c) => c.id).toList();

    final List<Widget> children = [];

    for (final categoryID in sortedCategoryIDs) {
      final items = grouped[categoryID];
      if (items == null || items.isEmpty) {
        continue;
      }

      final category = categoryMap[categoryID]!;
      final metrics = shoppingListItemMetrics(items);
      if (metrics.totalCount > 0) {
        children.add(CategorySectionHeader(
          name: category.name,
          colorHex: category.color,
          doneCount: metrics.checkedCount,
          totalCount: metrics.totalCount,
        ));
      }

      for (final item in items) {
        children.add(TextShoppingListItemWidget(
            // 入力行(空行)は確定アイテム挿入で index がずれてもフォーカスを保つため GlobalKey。
            key: item.message.isEmpty ? _rowKey(item.id) : ValueKey(item.id),
            groupID: groupID,
            textShoppingListItem: item,
            shoppingListItems: items,
            reorderIndex: null));
      }
    }

    final uncategorizedItems = grouped[uncategorizedCategoryID];
    if (uncategorizedItems != null && uncategorizedItems.isNotEmpty) {
      final metrics = shoppingListItemMetrics(uncategorizedItems);
      if (metrics.totalCount > 0) {
        children.add(CategorySectionHeader(
          name: '未分類',
          colorHex: null,
          doneCount: metrics.checkedCount,
          totalCount: metrics.totalCount,
        ));
      }
      for (final item in uncategorizedItems) {
        children.add(TextShoppingListItemWidget(
            // 入力行(空行)は確定アイテム挿入で index がずれてもフォーカスを保つため GlobalKey。
            key: item.message.isEmpty ? _rowKey(item.id) : ValueKey(item.id),
            groupID: groupID,
            textShoppingListItem: item,
            shoppingListItems: uncategorizedItems,
            reorderIndex: null));
      }
    }

    return ListView(
      padding: _listBottomPadding(context),
      // アイテム編集中にリストをスクロール(ドラッグ)したらキーボードを閉じる
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: children,
    );
  }
}
