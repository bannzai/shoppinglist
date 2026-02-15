import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_shopping_list_item_category.dart';
import 'package:shoppinglist/entity/group_shopping_list_item_category_keyword.dart';

/// Text型アイテムのmessageとカテゴリのキーワードをマッチングし、
/// カテゴリIDごとにアイテムをグルーピングする。
/// 複数カテゴリにマッチした場合はorderが小さい（先頭の）カテゴリに分類。
/// マッチしないアイテム・Link型アイテムは「未分類」（key=null）グループに入る。
Map<String?, List<GroupShoppingListItem>> groupItemsByCategory({
  required List<GroupShoppingListItem> items,
  required List<GroupShoppingListItemCategory> categories,
}) {
  final Map<String?, List<GroupShoppingListItem>> grouped = {};

  for (final item in items) {
    final categoryID = _findMatchingCategoryID(
      item: item,
      categories: categories,
    );
    grouped.putIfAbsent(categoryID, () => []).add(item);
  }

  return grouped;
}

/// アイテムにマッチするカテゴリのIDを返す。マッチしない場合はnull。
String? _findMatchingCategoryID({
  required GroupShoppingListItem item,
  required List<GroupShoppingListItemCategory> categories,
}) {
  // Link型はカテゴリ分類対象外
  if (item is LinkGroupShoppingListItem) {
    return null;
  }

  final textItem = item as TextGroupShoppingListItem;
  final messageLower = textItem.message.toLowerCase();

  for (final category in categories) {
    for (final keyword in category.keywords) {
      final keywordLower = keyword.keyword.toLowerCase();

      switch (keyword.matchingType) {
        case GroupShoppingListItemCategoryKeywordMatchingType.exact:
          if (messageLower == keywordLower) {
            return category.id;
          }
        case GroupShoppingListItemCategoryKeywordMatchingType.partial:
          if (messageLower.contains(keywordLower)) {
            return category.id;
          }
      }
    }
  }

  return null;
}
