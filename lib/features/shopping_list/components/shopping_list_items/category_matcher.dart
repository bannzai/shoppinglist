import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';

/// 未分類アイテムのカテゴリIDとして使用する定数
const uncategorizedCategoryID = '__uncategorized__';

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
    final categoryID = _findMatchingCategoryID(
      item: item,
      categories: categories,
    );
    grouped.putIfAbsent(categoryID, () => []).add(item);
  }

  return grouped;
}

/// アイテムにマッチするカテゴリのIDを返す。マッチしない場合はuncategorizedCategoryID。
String _findMatchingCategoryID({
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
      }
    }
  }

  return uncategorizedCategoryID;
}
