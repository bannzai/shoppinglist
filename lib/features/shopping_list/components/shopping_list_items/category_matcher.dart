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

/// セクション並び替えの結果を全カテゴリに反映した並び順のリストを返す。
/// [visibleCategories] は表示中(アイテムが存在する)カテゴリのみからなる [sortedCategories] の部分列。
/// [oldVisibleIndex] の visible カテゴリを、visible リストから取り除いた後の
/// [newVisibleIndex] の位置(末尾なら visible 最後尾の直後)へ移動する。
/// アイテム0件で非表示のカテゴリは、移動先の前後関係を保ったまま元の相対順序を維持する。
List<GroupCategory> reorderCategorySections({
  required List<GroupCategory> sortedCategories,
  required List<GroupCategory> visibleCategories,
  required int oldVisibleIndex,
  required int newVisibleIndex,
}) {
  final movedCategory = visibleCategories[oldVisibleIndex];
  final reordered = [...sortedCategories]
    ..removeWhere((category) => category.id == movedCategory.id);
  final visibleWithoutMoved = [...visibleCategories]
    ..removeWhere((category) => category.id == movedCategory.id);
  // 移動先の visible カテゴリの直前に挿入する。visible 末尾へ移動した場合は
  // 最後の visible カテゴリの直後(その後ろの非表示カテゴリより前)に挿入する。
  final insertIndex = newVisibleIndex < visibleWithoutMoved.length
      ? reordered.indexWhere(
          (category) => category.id == visibleWithoutMoved[newVisibleIndex].id)
      : reordered.indexWhere(
              (category) => category.id == visibleWithoutMoved.last.id) +
          1;
  return reordered..insert(insertIndex, movedCategory);
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
