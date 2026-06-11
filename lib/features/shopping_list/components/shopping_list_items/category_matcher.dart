import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_item_metrics.dart';

/// 未分類アイテムのカテゴリIDとして使用する定数
const uncategorizedCategoryID = '__uncategorized__';

/// カテゴリリストをロケーション別順序でソートして返す。
/// [shoppingLocationID] が指定されている場合、各カテゴリの [GroupCategory.locationOrders] から
/// そのロケーションの順序を取得する。エントリがないカテゴリはデフォルトの [GroupCategory.order] にフォールバック。
List<GroupCategory> sortCategoriesByLocation({
  required List<GroupCategory> categories,
  required String? shoppingLocationID,
}) {
  if (shoppingLocationID == null) {
    return [...categories]..sort((a, b) => a.order.compareTo(b.order));
  }
  return [...categories]..sort((a, b) {
      final aOrder = a.locationOrders[shoppingLocationID] ?? a.order;
      final bOrder = b.locationOrders[shoppingLocationID] ?? b.order;
      return aOrder.compareTo(bOrder);
    });
}

/// アイテムのmessageとカテゴリのキーワードをマッチングし、
/// カテゴリIDごとにアイテムをグルーピングする。
/// 複数カテゴリにマッチした場合はorderが小さい（先頭の）カテゴリに分類。
/// マッチしないアイテムは「未分類」（key=uncategorizedCategoryID）グループに入る。
Map<String, List<GroupShoppingListItem>> groupItemsByCategory({
  required List<GroupShoppingListItem> items,
  required List<GroupCategory> categories,
}) {
  final Map<String, List<GroupShoppingListItem>> grouped = {};

  for (final item in items) {
    final categoryID = findMatchingCategoryID(
      item: item,
      categories: categories,
    );
    grouped.putIfAbsent(categoryID, () => []).add(item);
  }

  return grouped;
}

/// アイテムにマッチするカテゴリのIDを返す。マッチしない場合はuncategorizedCategoryID。
/// 複数カテゴリにマッチした場合はcategories先頭（order最小）のカテゴリを優先する。
String findMatchingCategoryID({
  required GroupShoppingListItem item,
  required List<GroupCategory> categories,
}) {
  final messageLower = item.message.toLowerCase();

  for (final category in categories) {
    for (final keyword in category.keywords) {
      final keywordLower = keyword.keyword.toLowerCase();

      switch (keyword.matchingType) {
        case GroupCategoryKeywordMatchingType.exact:
          if (messageLower == keywordLower) {
            return category.id;
          }
        case GroupCategoryKeywordMatchingType.partial:
          if (messageLower.contains(keywordLower)) {
            return category.id;
          }
        case GroupCategoryKeywordMatchingType.regex:
          // FormatException (不正な regex 文字列) のときはマッチさせない。
          try {
            if (RegExp(keyword.keyword, caseSensitive: false)
                .hasMatch(item.message)) {
              return category.id;
            }
          } on FormatException {
            // ignore: regex 文字列が不正な場合は次のキーワードへ進む。
          }
      }
    }
  }

  return uncategorizedCategoryID;
}

/// セクション(カテゴリ/未分類)内の並び替えを、そのセクションのアイテムが持つ
/// order 値の多重集合を保ったまま反映した新しいアイテム列を返す。
///
/// [oldIndex]/[newIndex] は [SliverReorderableList.onReorder] が渡す生のインデックス。
/// order 値の多重集合を保つことで、他セクション(カテゴリ)のアイテムが占める order
/// スロットは変えず、このセクション内の並びだけを変更できる。
/// (カテゴリ表示は「全アイテムを order 昇順にソート → カテゴリでバケツ分け」して
///  描画されるため、多重集合を保てば他カテゴリの位置は不変のまま当該カテゴリ内のみ
///  並びが変わる。)
List<GroupShoppingListItem> reorderedSectionItems({
  required List<GroupShoppingListItem> sectionItems,
  required int oldIndex,
  required int newIndex,
}) {
  // onReorder の仕様: 下方向への移動では一時的に要素が抜けるため newIndex が 1 ずれる。
  final adjustedNewIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
  final reordered = [...sectionItems];
  reordered.insert(adjustedNewIndex, reordered.removeAt(oldIndex));
  // 既存の order 値を昇順に保ち、新しい並び順へ先頭から再割り当てする。
  final orderValues = sectionItems.map((item) => item.order).toList()..sort();
  return [
    for (final (index, item) in reordered.indexed)
      item.copyWith(order: orderValues[index]),
  ];
}

/// カテゴリ表示(グルーピング)の 1 行。ヘッダーかアイテムのいずれか。
///
/// カテゴリをまたぐ D&D のため、ヘッダーとアイテムを 1 つの reorderable リストに
/// フラットに並べる。ヘッダーはドラッグ対象外、アイテムのみドラッグ可能にする。
sealed class GroupedRow {
  const GroupedRow();
}

/// カテゴリ(または未分類)の見出し行。
class GroupedHeaderRow extends GroupedRow {
  /// 見出しのカテゴリID。null は「未分類」セクション。
  final String? categoryID;
  const GroupedHeaderRow({required this.categoryID});
}

/// アイテム 1 件の行。
class GroupedItemRow extends GroupedRow {
  final GroupShoppingListItem item;

  /// 現在の表示上の所属カテゴリID。null は「未分類」。
  final String? categoryID;
  const GroupedItemRow({required this.item, required this.categoryID});
}

/// カテゴリ表示の行(ヘッダー + アイテム)を表示順にフラット化して返す。
///
/// [sortedCategories] は表示順(order/location 考慮済み)のカテゴリ。
/// [grouped] は categoryID -> items(各カテゴリ内は order 昇順)。未分類は末尾に置く。
/// 空メッセージ行を除いた件数([shoppingListItemMetrics])が 0 のセクションはヘッダーを
/// 出さない(が、入力中の空行アイテムは行として出す。従来の _GroupedListView 挙動に合わせる)。
List<GroupedRow> buildGroupedRows({
  required List<GroupCategory> sortedCategories,
  required Map<String, List<GroupShoppingListItem>> grouped,
}) {
  final rows = <GroupedRow>[];

  void addSection(String? categoryID, List<GroupShoppingListItem>? items) {
    if (items == null || items.isEmpty) {
      return;
    }
    if (shoppingListItemMetrics(items).totalCount > 0) {
      rows.add(GroupedHeaderRow(categoryID: categoryID));
    }
    for (final item in items) {
      rows.add(GroupedItemRow(item: item, categoryID: categoryID));
    }
  }

  for (final category in sortedCategories) {
    addSection(category.id, grouped[category.id]);
  }
  addSection(null, grouped[uncategorizedCategoryID]);
  return rows;
}

/// [ReorderableListView.onReorder] の (oldIndex,newIndex) から、ドロップ先が属する
/// カテゴリID(null=未分類)を返す。
///
/// ドロップ位置(挿入位置)より上にある最後のヘッダーのカテゴリを採用する。
/// 先頭ヘッダーより上にドロップした場合は先頭ヘッダーのカテゴリに吸着する。
String? categoryIDForDropPosition({
  required List<GroupedRow> rows,
  required int oldIndex,
  required int newIndex,
}) {
  final working = [...rows]..removeAt(oldIndex);
  final insertAt = oldIndex < newIndex ? newIndex - 1 : newIndex;

  String? category;
  var sawHeader = false;
  for (var i = 0; i < insertAt && i < working.length; i++) {
    final row = working[i];
    if (row is GroupedHeaderRow) {
      category = row.categoryID;
      sawHeader = true;
    }
  }
  if (!sawHeader) {
    // 先頭ヘッダーより上 → 先頭セクションに吸着。
    final firstHeader = working.whereType<GroupedHeaderRow>().firstOrNull;
    return firstHeader?.categoryID;
  }
  return category;
}

/// 移動先カテゴリ内での挿入位置(そのカテゴリのアイテム列に対する index)を返す。
///
/// ドロップ位置(挿入位置)より上にある「移動先カテゴリのアイテム」の個数。
int dropIndexInTarget({
  required List<GroupedRow> rows,
  required int oldIndex,
  required int newIndex,
  required String? toCategoryID,
}) {
  final working = [...rows]..removeAt(oldIndex);
  final insertAt = oldIndex < newIndex ? newIndex - 1 : newIndex;

  var count = 0;
  for (var i = 0; i < insertAt && i < working.length; i++) {
    final row = working[i];
    if (row is GroupedItemRow && row.categoryID == toCategoryID) {
      count++;
    }
  }
  return count;
}

/// 移動後の全アイテムを「表示順」に並べ、order を 0..N-1 に正規化して返す。
///
/// [movedItem] を [fromCategoryID] から取り除き、[toCategoryID] の
/// [dropIndexInTargetValue] 番目に挿入したうえで、[sortedCategories]→未分類 の順に
/// flatten して order を振り直す。カテゴリをまたぐ移動でも order 空間が一意になる。
List<GroupShoppingListItem> itemsAfterMove({
  required List<GroupCategory> sortedCategories,
  required Map<String, List<GroupShoppingListItem>> grouped,
  required GroupShoppingListItem movedItem,
  required String? fromCategoryID,
  required String? toCategoryID,
  required int dropIndexInTargetValue,
}) {
  String key(String? id) => id ?? uncategorizedCategoryID;
  final next = {
    for (final entry in grouped.entries) entry.key: [...entry.value],
  };
  next[key(fromCategoryID)]?.removeWhere((it) => it.id == movedItem.id);
  final target = next.putIfAbsent(key(toCategoryID), () => []);
  target.insert(dropIndexInTargetValue.clamp(0, target.length), movedItem);

  final ordered = <GroupShoppingListItem>[];
  for (final category in sortedCategories) {
    ordered.addAll(next[category.id] ?? const []);
  }
  ordered.addAll(next[uncategorizedCategoryID] ?? const []);
  return [
    for (final (index, item) in ordered.indexed) item.copyWith(order: index),
  ];
}
