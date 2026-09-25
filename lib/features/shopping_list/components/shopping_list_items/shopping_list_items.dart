import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/components/error/error_view.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/features/shopping_list/components/ai_categorize_button.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_matcher.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_section_header.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_item_metrics.dart';
import 'package:shoppinglist/l10n/l10n.dart';
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
EdgeInsets _listBottomPadding(BuildContext context) =>
    EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 200);

/// 買い物リストのアイテム一覧。カテゴリ軸があればカテゴリ別グルーピング、無ければフラット表示する。
class ShoppingListItems extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final String? shoppingLocationID;

  /// リストの最後（最終アイテムの下）に表示する footer（レシートセクション等）。
  /// スクロールに追従し、並び替え対象には含まれない。
  final Widget? footer;

  const ShoppingListItems({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingLocationID,
    this.footer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListItems =
        ref
            .watch(
              textShoppingListItemsProvider(
                groupID: groupID,
                shoppingListID: shoppingListID,
              ),
            )
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
            footer: footer,
          );
        }

        final axis = axes.first;
        return _CategorizedShoppingListItems(
          groupID: groupID,
          shoppingListID: shoppingListID,
          shoppingListItems: shoppingListItems,
          categoryAxisID: axis.id,
          shoppingLocationID: shoppingLocationID,
          footer: footer,
        );
      },
      error: (e, st) => ErrorView(error: e, stackTrace: st),
      loading:
          () => _FlatShoppingListItems(
            groupID: groupID,
            shoppingListID: shoppingListID,
            shoppingListItems: shoppingListItems,
            footer: footer,
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

  /// リスト末尾に表示する footer（レシートセクション等）。
  final Widget? footer;

  const _FlatShoppingListItems({
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
    this.showCategorizeButton = false,
    this.categoryAxisID,
    this.existingCategoryNames = const [],
    this.footer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowKeys = ref.watch(shoppingListItemRowKeysProvider);
    final shoppingListItemBatchUpdate = ref.watch(
      shoppingListItemBatchUpdateProvider(groupID: groupID),
    );
    final list = ReorderableListView.builder(
      padding: _listBottomPadding(context),
      // 最終アイテムの下に表示する footer（レシートセクション等）。並び替え対象外。
      footer: footer,
      // 行ごとに ReorderableDelayedDragStartListener を自前で付けるため既定ハンドルは無効化。
      buildDefaultDragHandles: false,
      // アイテム編集中にリストをスクロール(ドラッグ)したらキーボードを閉じる
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      onReorder: (oldIndex, newIndex) {
        analytics.logEvent(
          name: 'reorder_shopping_list_item',
          parameters: {'groupID': groupID, 'shoppingListID': shoppingListID},
        );
        // ドラッグ時にリストから要素を一時的に削除するため newIndex がずれるのを調整
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final changedItems = [...shoppingListItems];
        final movedItem = changedItems.removeAt(oldIndex);
        changedItems.insert(newIndex, movedItem);
        final orderedItems =
            changedItems
                .asMap()
                .entries
                .map((entry) => entry.value.copyWith(order: entry.key))
                .toList();
        shoppingListItemBatchUpdate.call(
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
          // 「カテゴリ +」はカテゴリ不在が確定したフラット表示(showCategorizeButton=true)
          // でのみ出す。カテゴリ軸/一覧のロード中フォールバックでは出さない — 既存カテゴリが
          // あるリストでも一時的に全行がフラット表示されるため、その間に分類済みアイテムへ
          // チップを出すと誤って別カテゴリへ割り当てられてしまう。
          showAddCategoryButton:
              showCategorizeButton && item.message.trim().isNotEmpty,
        );
      },
    );

    // 入力中の空行(message が空) や空白のみのアイテムはカテゴリ分け対象にならないため、
    // ボタンの表示判定と件数から除外する。
    final categorizableItems =
        shoppingListItems
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

  /// リスト末尾に表示する footer（レシートセクション等）。
  final Widget? footer;

  const _CategorizedShoppingListItems({
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
    required this.categoryAxisID,
    required this.shoppingLocationID,
    this.footer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
    final rowKeys = ref.watch(shoppingListItemRowKeysProvider);
    final categoriesAsync = ref.watch(
      groupCategoriesProvider(groupID: groupID, categoryAxisID: categoryAxisID),
    );

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
            footer: footer,
          );
        }

        // 入力中の空行(message が空) や空白のみのアイテムはカテゴリ分け対象にならないため、
        // ボタンの表示判定と件数から除外する。グルーピング自体は楽観状態を持つ
        // [_GroupedListView] 側で行うため、ここでは未分類件数だけを直接算出する。
        final uncategorizedItems =
            shoppingListItems
                .where(
                  (item) =>
                      item.message.trim().isNotEmpty &&
                      findMatchingCategoryID(
                            item: item,
                            categories: categories,
                          ) ==
                          uncategorizedCategoryID,
                )
                .toList();
        final groupedListView = _GroupedListView(
          groupID: groupID,
          shoppingListID: shoppingListID,
          categoryAxisID: categoryAxisID,
          categories: categories,
          shoppingListItems: shoppingListItems,
          shoppingLocationID: isPremium ? shoppingLocationID : null,
          rowKeys: rowKeys,
          footer: footer,
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
      error: (e, st) => ErrorView(error: e, stackTrace: st),
      loading:
          () => _FlatShoppingListItems(
            groupID: groupID,
            shoppingListID: shoppingListID,
            shoppingListItems: shoppingListItems,
            footer: footer,
          ),
    );
  }
}

/// カテゴリ表示の D&D 直後に同期適用するローカルな並び・分類の楽観状態。
///
/// `ReorderableListView.onReorder` は本来コールバック内で表示元データを同期更新する前提だが、
/// 本アプリは onReorder で Firestore に書くだけで表示元(stream)はその場で変わらない。そのため
/// ドロップ完了後に一旦古い並びで再描画され、直後に stream 反映で新並びへ切り替わってチラつく。
/// この楽観状態を onReorder で同期セットして即座に新並び・新分類で描画し、stream が追いついたら破棄する。
class _OptimisticReorder {
  /// 移動後の全アイテムの新しい order(item.id → order)。
  final Map<String, int> orderByItemID;

  /// 移動アイテム(と同 message のアイテム)の所属カテゴリ上書き(item.id → categoryID, null=未分類)。
  /// 分類はカテゴリの keyword で決まり stream 反映が遅れる(transaction=サーバ往復)ため、
  /// 追いつくまで分類を上書きして二段反映によるチラつきを防ぐ。
  final Map<String, String?> categoryOverrideByItemID;

  const _OptimisticReorder({
    required this.orderByItemID,
    required this.categoryOverrideByItemID,
  });
}

/// 楽観状態が Firestore stream に反映され切ったかを判定する。
///
/// order(全アイテム)と分類上書き(移動アイテム)の両方が stream と一致したら true。
/// order(batch=ローカルキャッシュ即時)が先に一致しても分類(keyword)が未反映の間は false を返すため、
/// 分類上書きを維持し続けてチラつきを防ぐ。stream に存在しない id(他端末の削除等)は無視する。
bool _optimisticReflected({
  required _OptimisticReorder pending,
  required List<GroupShoppingListItem> streamItems,
  required List<GroupCategory> categories,
}) {
  final byID = {for (final it in streamItems) it.id: it};
  for (final entry in pending.orderByItemID.entries) {
    final streamItem = byID[entry.key];
    if (streamItem == null) {
      continue;
    }
    if (streamItem.order != entry.value) {
      return false;
    }
  }
  for (final entry in pending.categoryOverrideByItemID.entries) {
    final streamItem = byID[entry.key];
    if (streamItem == null) {
      continue;
    }
    final matched = findMatchingCategoryID(
      item: streamItem,
      categories: categories,
    );
    if (matched != (entry.value ?? uncategorizedCategoryID)) {
      return false;
    }
  }
  return true;
}

/// セクション並び替えの楽観の表示順が Firestore stream に反映され切ったかを判定する。
///
/// [pendingCategoryIDOrder](楽観の表示順) と stream 由来の表示順 [sortedStreamCategories] を、
/// 双方に存在するカテゴリだけで比較し、順序が一致したら true。片方にしか無いカテゴリ
/// (楽観窓中の他端末でのカテゴリ追加・削除等)は比較対象外にして、クリア漏れで固まるのを防ぐ。
bool _sectionOrderReflected({
  required List<String> pendingCategoryIDOrder,
  required List<GroupCategory> sortedStreamCategories,
}) {
  final pendingIDSet = pendingCategoryIDOrder.toSet();
  final streamIDs = [
    for (final category in sortedStreamCategories)
      if (pendingIDSet.contains(category.id)) category.id,
  ];
  final streamIDSet = streamIDs.toSet();
  return listEquals([
    for (final categoryID in pendingCategoryIDOrder)
      if (streamIDSet.contains(categoryID)) categoryID,
  ], streamIDs);
}

/// カテゴリヘッダー付きのグルーピング表示。
/// ヘッダーとアイテムを 1 つの [ReorderableListView] にフラットに並べ、長押しドラッグで
/// 「同一カテゴリ内の並び替え」「別カテゴリへの移動」(アイテム行)と「セクション(カテゴリ)単位の
/// 並び替え」(ヘッダー行、Issue #386)を行える。セクション単位の並び替えは、ヘッダー右端の
/// 上下ボタンで隣のセクションと入れ替えることでも行える(Issue #622)。
///
/// 既定のドラッグハンドルは無効化し(`buildDefaultDragHandles: false`)、確定アイテム行と
/// カテゴリヘッダー行のみ [ReorderableDelayedDragStartListener] でラップする(入力行と
/// 「未分類」ヘッダーはドラッグ対象外)。アイテムを別カテゴリへドロップした場合は、移動先
/// カテゴリへ message を完全一致キーワードとして付け替えて分類を変更し、order は移動後の
/// 表示順で全体を 0..N-1 に正規化して永続化する。セクション並び替えは GroupCategory.order
/// (買い物場所選択時は locationOrders)へ永続化され、カテゴリ管理画面の並び順とも共有される。
class _GroupedListView extends HookConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final String categoryAxisID;
  final List<GroupCategory> categories;
  final List<GroupShoppingListItem> shoppingListItems;
  final String? shoppingLocationID;

  /// 入力行に安定した GlobalKey を割り当てるためのレジストリ。
  final ShoppingListItemRowKeys rowKeys;

  /// リスト末尾に表示する footer（レシートセクション等）。
  final Widget? footer;

  const _GroupedListView({
    required this.groupID,
    required this.shoppingListID,
    required this.categoryAxisID,
    required this.categories,
    required this.shoppingListItems,
    required this.shoppingLocationID,
    required this.rowKeys,
    this.footer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupCategoryBatchUpdate = ref.watch(
      groupCategoryBatchUpdateProvider(groupID: groupID),
    );
    final moveItemCategoryKeyword = ref.watch(
      moveItemCategoryKeywordProvider(groupID: groupID),
    );
    final shoppingListItemBatchUpdate = ref.watch(
      shoppingListItemBatchUpdateProvider(groupID: groupID),
    );

    // カテゴリ表示の D&D 直後に同期適用する楽観状態。ドロップ後に新しい並び・分類で即描画し、
    // Firestore stream が追いつくまでの一瞬を覆ってチラつきを防ぐ。
    final optimistic = useState<_OptimisticReorder?>(null);
    final pending = optimistic.value;

    // セクション並び替え(Issue #386)直後に同期適用する楽観の表示順(全カテゴリのID列)。
    // GroupCategory.order(または locationOrders)の stream 反映が追いつくまでの一瞬を覆う。
    final optimisticSectionOrder = useState<List<String>?>(null);
    final pendingSectionOrder = optimisticSectionOrder.value;

    // ヘッダードラッグ中に畳む(アイテム行をリストから隠す)セクションのカテゴリID。
    // ドラッグ proxy 側にヘッダー+先頭アイテムのプレビューを出すため、リスト側との
    // 二重表示を防ぎ「セクションごと持ち上げた」見た目にする。
    final collapsedDraggingCategoryID = useState<String?>(null);

    // ヘッダードラッグの開始 index(SliverReorderableList の _dragIndex と同値。ドラッグ中は
    // 不変)。onReorderEnd の「同位置ドロップ」判定を、framework が onReorder を呼ぶ条件
    // (fromIndex != toIndex)の正確な補集合にするために保持する。rows から再計算すると
    // ドラッグ中の stream emit で index がずれた場合に framework 側の判定と食い違い、
    // どちらの経路でも畳みが解除されない恐れがあるため、開始時の値をそのまま使う。
    final draggingHeaderRowIndex = useRef<int?>(null);

    // 楽観 order を stream に重ねて再ソートする（order を指定されていないアイテムは自分の order）。
    final effectiveItems =
        pending == null
            ? shoppingListItems
            : ([...shoppingListItems]..sort(
              (a, b) => (pending.orderByItemID[a.id] ?? a.order).compareTo(
                pending.orderByItemID[b.id] ?? b.order,
              ),
            ));

    final streamSortedCategories = sortCategoriesByLocation(
      categories: categories,
      shoppingLocationID: shoppingLocationID,
    );

    // 楽観状態が Firestore stream に反映され切ったら破棄して通常表示へ戻す。
    // 依存配列は stream（shoppingListItems / categories）。onReorder での楽観セットでは
    // 依存が変わらず再実行されないため、stream emit のタイミングでのみ整合判定する。
    useEffect(() {
      if (pending != null &&
          _optimisticReflected(
            pending: pending,
            streamItems: shoppingListItems,
            categories: categories,
          )) {
        optimistic.value = null;
      }
      if (pendingSectionOrder != null &&
          _sectionOrderReflected(
            pendingCategoryIDOrder: pendingSectionOrder,
            sortedStreamCategories: streamSortedCategories,
          )) {
        optimisticSectionOrder.value = null;
      }
      return null;
    }, [shoppingListItems, categories]);
    // セクション並び替えの楽観の表示順を stream 由来の表示順に重ねる。
    // 楽観に無いカテゴリ(楽観窓中に追加された等)は末尾に元の表示順のまま置く。
    final List<GroupCategory> sortedCategories;
    if (pendingSectionOrder == null) {
      sortedCategories = streamSortedCategories;
    } else {
      final streamCategoryByID = {
        for (final category in streamSortedCategories) category.id: category,
      };
      sortedCategories = [
        for (final categoryID in pendingSectionOrder)
          if (streamCategoryByID.containsKey(categoryID))
            streamCategoryByID[categoryID]!,
        ...streamSortedCategories.where(
          (category) => !pendingSectionOrder.contains(category.id),
        ),
      ];
    }
    final categoryMap = {for (final c in categories) c.id: c};
    final grouped = groupItemsByCategory(
      items: effectiveItems,
      categories: categories,
      categoryOverrideByItemID: pending?.categoryOverrideByItemID,
    );
    final rows = buildGroupedRows(
      sortedCategories: sortedCategories,
      grouped: grouped,
    );
    // ヘッダー行を持つ(=セクションとして見えている)カテゴリ列。ヘッダードラッグの
    // 移動元・移動先 index はこの列に対するものとして解釈する。
    final headerCategories = [
      for (final category in sortedCategories)
        if ((grouped[category.id] ?? const []).isNotEmpty &&
            shoppingListItemMetrics(grouped[category.id]!).totalCount > 0)
          category,
    ];

    // セクションの新しい並び順を楽観の表示順として同期セットし、GroupCategory.order
    // (買い物場所選択時は locationOrders)へ永続化する。ヘッダーの長押しドラッグ(Issue #386)と
    // ヘッダーの上下ボタン(Issue #622)の両方から使う。
    void applySectionOrder(List<GroupCategory> reordered) {
      // 楽観の表示順を同期セットし、操作直後から新しいセクション順で描画する。
      final appliedSectionOrder =
          reordered.map((category) => category.id).toList();
      optimisticSectionOrder.value = appliedSectionOrder;

      // 永続化失敗時は楽観の表示順を破棄し stream の実状態へ戻す(ロールバック)。
      // 後続の別操作で楽観状態が差し替わっている場合は消さない。
      void rollbackIfCurrent(Object error, StackTrace stackTrace) {
        debugPrint('[reorder] セクション並び永続化失敗: $error\n$stackTrace');
        if (optimisticSectionOrder.value == appliedSectionOrder) {
          optimisticSectionOrder.value = null;
        }
      }

      final locationID = shoppingLocationID;
      if (locationID == null) {
        groupCategoryBatchUpdate
            .call(
              categoryAxisID: categoryAxisID,
              categories:
                  reordered
                      .asMap()
                      .entries
                      .map((entry) => entry.value.copyWith(order: entry.key))
                      .toList(),
            )
            .catchError(rollbackIfCurrent);
      } else {
        // 買い物場所選択時(プレミアム限定で渡される)はその場所専用の並び順だけを更新する。
        groupCategoryBatchUpdate
            .call(
              categoryAxisID: categoryAxisID,
              categories:
                  reordered.asMap().entries.map((entry) {
                    final updatedLocationOrders = Map<String, int>.from(
                      entry.value.locationOrders,
                    );
                    updatedLocationOrders[locationID] = entry.key;
                    return entry.value.copyWith(
                      locationOrders: updatedLocationOrders,
                    );
                  }).toList(),
            )
            .catchError(rollbackIfCurrent);
      }
    }

    return Listener(
      // ドラッグ中のポインタキャンセル(システム割り込み等)では onReorderEnd / onReorder の
      // どちらも呼ばれない(SliverReorderableList は内部リセットのみ)ため、畳んだセクションが
      // 戻らなくなるのを防ぐ保険としてここで解除する。
      onPointerCancel: (_) {
        if (collapsedDraggingCategoryID.value != null) {
          collapsedDraggingCategoryID.value = null;
        }
      },
      child: ReorderableListView.builder(
        padding: _listBottomPadding(context),
        // 最終アイテムの下に表示する footer（レシートセクション等）。並び替え対象外。
        footer: footer,
        // アイテム編集中にリストをスクロール(ドラッグ)したらキーボードを閉じる
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        // 既定のドラッグハンドルを無効化し、確定アイテム行とカテゴリヘッダー行のみ
        // ReorderableDelayedDragStartListener でラップして長押しドラッグを有効にする。
        buildDefaultDragHandles: false,
        // ヘッダーを掴んだ瞬間にそのセクションを畳み、アイテムは proxy 側のプレビューだけに
        // 表示する(セクションごと持ち上げた見た目にする)。アイテム行のドラッグでは何もしない。
        onReorderStart: (index) {
          final row = rows[index];
          if (row is GroupedHeaderRow && row.categoryID != null) {
            // 畳むとセクション内の行が unmount され、編集中(Enter 未確定)の行はフォーカス
            // 喪失保存が走らないまま入力テキストが破棄され得る。先に unfocus して行側の
            // フォーカス喪失保存(text_shopping_list_item.dart の FocusNode listener)を
            // 発火させてから畳む。フォーカス変更の listener 通知は microtask で行われ、
            // 次フレームの unmount より先に実行される。
            FocusManager.instance.primaryFocus?.unfocus();
            collapsedDraggingCategoryID.value = row.categoryID;
            draggingHeaderRowIndex.value = index;
          }
        },
        // 同位置ドロップでは onReorder が呼ばれない(SliverReorderableList は
        // fromIndex != toIndex のときだけ呼ぶ)ため、その補集合にあたる
        // 「開始 index == ドロップ index」のときここで畳みを解除する。比較する両 index は
        // framework が onReorder の要否判定に使う _dragIndex / _insertIndex と同値のため、
        // すべてのドロップ経路で onReorder とここのどちらかが必ず畳みを解除する
        // (ポインタキャンセルのみ外側の Listener が受け持つ)。移動を伴うドロップを
        // ここで解除しないのは、ドロップアニメーション中に旧位置でセクションが
        // 一瞬再展開されるチラつきを防ぎ、楽観順の適用と同一フレームで戻すため。
        onReorderEnd: (insertIndex) {
          if (collapsedDraggingCategoryID.value == null) {
            return;
          }
          if (insertIndex == draggingHeaderRowIndex.value) {
            collapsedDraggingCategoryID.value = null;
          }
        },
        // ヘッダー行の proxy はヘッダーの下に先頭アイテム(最大2件、表示専用)をぶら下げて
        // 「セクションごと持ち上げている」見た目にする。proxy は元の行サイズの SizedBox +
        // OverflowBox(縦方向 unbounded)で描画されるため、行より背の高い proxy も描ける。
        // アイテム行は既定の proxyDecorator と同じ Material の elevation アニメーションのみ。
        proxyDecorator: (child, index, animation) {
          final row = rows[index];
          final previewItems =
              row is GroupedHeaderRow && row.categoryID != null
                  ? (grouped[row.categoryID] ?? const <GroupShoppingListItem>[])
                      .where((item) => item.message.isNotEmpty)
                      .take(2)
                      .toList()
                  : const <GroupShoppingListItem>[];
          return AnimatedBuilder(
            animation: animation,
            builder:
                (context, animatedChild) => Material(
                  elevation: 6 * Curves.easeInOut.transform(animation.value),
                  child: animatedChild,
                ),
            child:
                previewItems.isEmpty
                    ? child
                    : IgnorePointer(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          child,
                          for (final item in previewItems)
                            TextShoppingListItemWidget(
                              key: ValueKey('drag_preview_${item.id}'),
                              groupID: groupID,
                              textShoppingListItem: item,
                              // proxy は表示専用(IgnorePointer)のため、Enter確定等で使う
                              // 同一カテゴリのアイテム列は不要。
                              shoppingListItems: const [],
                              reorderIndex: null,
                            ),
                        ],
                      ),
                    ),
          );
        },
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];
          switch (row) {
            case GroupedHeaderRow(:final categoryID):
              // 未分類はカテゴリ実体が無く並び順を持たないため、ドラッグ対象外で常に末尾。
              if (categoryID == null) {
                return KeyedSubtree(
                  key: ValueKey('header_$uncategorizedCategoryID'),
                  child: _header(
                    context,
                    categoryMap,
                    grouped,
                    categoryID,
                    onMoveUp: null,
                    onMoveDown: null,
                  ),
                );
              }
              // 上下ボタン(Issue #622)は、ヘッダーを持つセクション列の中で隣のセクションと
              // 入れ替える。先頭の上・末尾の下は入れ替え先が無いため無効にする。
              final visibleIndex = headerCategories.indexWhere(
                (category) => category.id == categoryID,
              );
              final sectionMoveParameters = {
                'groupID': groupID,
                'shoppingListID': shoppingListID,
                'categoryAxisID': categoryAxisID,
              };
              // カテゴリヘッダーは長押しでセクション(カテゴリ)単位の並び替えを開始する(Issue #386)。
              return ReorderableDelayedDragStartListener(
                key: ValueKey('header_$categoryID'),
                index: index,
                child: _header(
                  context,
                  categoryMap,
                  grouped,
                  categoryID,
                  onMoveUp:
                      visibleIndex > 0
                          ? () {
                            analytics.logEvent(
                              name: 'tap_move_category_section_up',
                              parameters: sectionMoveParameters,
                            );
                            applySectionOrder(
                              reorderCategorySections(
                                sortedCategories: sortedCategories,
                                visibleCategories: headerCategories,
                                oldVisibleIndex: visibleIndex,
                                newVisibleIndex: visibleIndex - 1,
                              ),
                            );
                          }
                          : null,
                  onMoveDown:
                      visibleIndex >= 0 &&
                              visibleIndex < headerCategories.length - 1
                          ? () {
                            analytics.logEvent(
                              name: 'tap_move_category_section_down',
                              parameters: sectionMoveParameters,
                            );
                            applySectionOrder(
                              reorderCategorySections(
                                sortedCategories: sortedCategories,
                                visibleCategories: headerCategories,
                                oldVisibleIndex: visibleIndex,
                                newVisibleIndex: visibleIndex + 1,
                              ),
                            );
                          }
                          : null,
                ),
              );
            case GroupedItemRow(:final item, :final categoryID):
              // ヘッダードラッグ中のセクションのアイテム行はゼロ高さに畳む(アイテムは
              // ドラッグ proxy 側のプレビューにだけ表示する)。行の削除で index をずらすと
              // ReorderableListView が子を包む GlobalKey が別 index で二重インフレートされ
              // クラッシュするため、同じ key のまま中身だけ差し替えて index を保つ。
              if (categoryID != null &&
                  categoryID == collapsedDraggingCategoryID.value) {
                return SizedBox.shrink(key: ValueKey('item_${item.id}'));
              }
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
                // 未分類セクション(categoryID == null)の確定済み行にのみ「カテゴリ +」を出す。
                // 入力行(空メッセージ)・分類済み行では出さない。
                showAddCategoryButton:
                    categoryID == null && item.message.trim().isNotEmpty,
              );
              // 入力行はドラッグ対象外。確定行のみ長押しドラッグでラップする。
              if (isInputRow) {
                return KeyedSubtree(
                  key: ValueKey('item_${item.id}'),
                  child: tile,
                );
              }
              return ReorderableDelayedDragStartListener(
                key: ValueKey('item_${item.id}'),
                index: index,
                child: tile,
              );
          }
        },
        onReorder: (oldIndex, newIndex) {
          // 掴んだ行がヘッダーならセクション(カテゴリ)単位の並び替え、アイテムなら
          // アイテムの並び替え・カテゴリ間移動として扱う。
          switch (rows[oldIndex]) {
            case GroupedHeaderRow(:final categoryID):
              {
                // ドロップ確定。畳んでいたセクションを戻す。楽観順の適用と同一フレームで
                // 反映されるため、旧位置で一瞬展開されてからのチラつきは起きない。
                collapsedDraggingCategoryID.value = null;
                if (categoryID == null) {
                  return; // 未分類ヘッダーはドラッグ不可。通常起き得ないが防御。
                }
                analytics.logEvent(
                  name: 'reorder_category_section',
                  parameters: {
                    'groupID': groupID,
                    'shoppingListID': shoppingListID,
                    'categoryAxisID': categoryAxisID,
                  },
                );
                final oldVisibleIndex = headerCategories.indexWhere(
                  (category) => category.id == categoryID,
                );
                final newVisibleIndex = sectionInsertIndexForHeaderDrop(
                  rows: rows,
                  oldIndex: oldIndex,
                  newIndex: newIndex,
                );
                if (oldVisibleIndex < 0 || newVisibleIndex == oldVisibleIndex) {
                  return; // 位置が変わらないドロップは書き込まない(冪等)。
                }
                applySectionOrder(
                  reorderCategorySections(
                    sortedCategories: sortedCategories,
                    visibleCategories: headerCategories,
                    oldVisibleIndex: oldVisibleIndex,
                    newVisibleIndex: newVisibleIndex,
                  ),
                );
              }
            case final GroupedItemRow moved:
              {
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

                // 楽観状態を同期セットし、ドロップ直後から新しい並び・分類で描画する
                // (ReorderableListView は onReorder 内で表示元データを同期更新する前提のため)。
                // 分類上書きは同 message の全アイテムに広げる(キーワード方式で連動して移動するため)。
                final applied = _OptimisticReorder(
                  orderByItemID: {
                    for (final it in orderedItems) it.id: it.order,
                  },
                  categoryOverrideByItemID: {
                    for (final it in effectiveItems)
                      if (it.message == moved.item.message) it.id: toCategoryID,
                  },
                );
                optimistic.value = applied;

                // 永続化失敗時は楽観状態を破棄し、実際に永続化された stream の状態を表示する
                // (= ロールバック)。後続の別操作で楽観状態が差し替わっている場合は消さない。
                void rollbackIfCurrent(Object error, StackTrace stackTrace) {
                  debugPrint('[reorder] 永続化失敗: $error\n$stackTrace');
                  if (optimistic.value == applied) {
                    optimistic.value = null;
                  }
                }

                // 別カテゴリへ移動した場合のみ、完全一致キーワードを付け替えて分類を変更する。
                if (toCategoryID != moved.categoryID) {
                  moveItemCategoryKeyword
                      .call(
                        categoryAxisID: categoryAxisID,
                        itemMessage: moved.item.message,
                        destinationCategoryID: toCategoryID,
                        categories: categories,
                      )
                      .catchError(rollbackIfCurrent);
                }
                shoppingListItemBatchUpdate
                    .call(
                      shoppingListID: shoppingListID,
                      shoppingListItems: orderedItems,
                    )
                    .catchError(rollbackIfCurrent);
              }
          }
        },
      ),
    );
  }

  /// カテゴリID(null=未分類)から見出し行を生成する。
  /// [onMoveUp] / [onMoveDown] は見出しの上下ボタンの処理([CategorySectionHeader] に渡す)。
  Widget _header(
    BuildContext context,
    Map<String, GroupCategory> categoryMap,
    Map<String, List<GroupShoppingListItem>> grouped,
    String? categoryID, {
    required VoidCallback? onMoveUp,
    required VoidCallback? onMoveDown,
  }) {
    final items = grouped[categoryID ?? uncategorizedCategoryID] ?? const [];
    final metrics = shoppingListItemMetrics(items);
    final category = categoryID == null ? null : categoryMap[categoryID];
    return CategorySectionHeader(
      name: category?.name ?? context.l10n.commonUncategorized,
      colorHex: category?.color,
      doneCount: metrics.checkedCount,
      totalCount: metrics.totalCount,
      onMoveUp: onMoveUp,
      onMoveDown: onMoveDown,
    );
  }
}
