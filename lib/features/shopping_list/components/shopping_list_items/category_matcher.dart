import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';

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
