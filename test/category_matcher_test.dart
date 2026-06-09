import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_matcher.dart';

void main() {
  group('groupItemsByCategory', () {
    test('完全一致マッチング', () {
      final categories = [
        GroupCategory(
            id: 'cat1',
            groupID: 'group1',
            userID: 'user1',
            groupCategoryAxisID: 'axis1',
            name: '野菜',
            order: 0,
            locationOrders: {},
            keywords: [
              const GroupCategoryKeyword(
                keyword: 'にんじん',
                matchingType: GroupCategoryKeywordMatchingType.exact,
              ),
            ],
            color: null,
            iconName: null),
      ];

      final items = [
        const GroupShoppingListItem(
            id: 'item1',
            groupID: 'group1',
            shoppingListID: 'list1',
            userID: 'user1',
            message: 'にんじん',
            order: 0,
            checkedByUserID: null,
            color: null,
            description: null,
            imageURL: null,
            lastEditedByUserID: null),
        const GroupShoppingListItem(
            id: 'item2',
            groupID: 'group1',
            shoppingListID: 'list1',
            userID: 'user1',
            message: 'にんじんジュース',
            order: 1,
            checkedByUserID: null,
            color: null,
            description: null,
            imageURL: null,
            lastEditedByUserID: null),
      ];

      final result = groupItemsByCategory(
        items: items,
        categories: categories,
      );

      expect(result['cat1']?.length, 1);
      expect(result['cat1']?.first.id, 'item1');
      expect(result[uncategorizedCategoryID]?.length, 1);
      expect(result[uncategorizedCategoryID]?.first.id, 'item2');
    });

    test('部分一致マッチング', () {
      final categories = [
        GroupCategory(
            id: 'cat1',
            groupID: 'group1',
            userID: 'user1',
            groupCategoryAxisID: 'axis1',
            name: '野菜',
            order: 0,
            locationOrders: {},
            keywords: [
              const GroupCategoryKeyword(
                keyword: 'にんじん',
                matchingType: GroupCategoryKeywordMatchingType.partial,
              ),
            ],
            color: null,
            iconName: null),
      ];

      final items = [
        const GroupShoppingListItem(
            id: 'item1',
            groupID: 'group1',
            shoppingListID: 'list1',
            userID: 'user1',
            message: 'にんじんジュース',
            order: 0,
            checkedByUserID: null,
            color: null,
            description: null,
            imageURL: null,
            lastEditedByUserID: null),
      ];

      final result = groupItemsByCategory(
        items: items,
        categories: categories,
      );

      expect(result['cat1']?.length, 1);
      expect(result['cat1']?.first.id, 'item1');
    });

    test('大文字小文字の区別なし', () {
      final categories = [
        GroupCategory(
            id: 'cat1',
            groupID: 'group1',
            userID: 'user1',
            groupCategoryAxisID: 'axis1',
            name: 'Drinks',
            order: 0,
            locationOrders: {},
            keywords: [
              const GroupCategoryKeyword(
                keyword: 'Milk',
                matchingType: GroupCategoryKeywordMatchingType.exact,
              ),
            ],
            color: null,
            iconName: null),
      ];

      final items = [
        const GroupShoppingListItem(
            id: 'item1',
            groupID: 'group1',
            shoppingListID: 'list1',
            userID: 'user1',
            message: 'milk',
            order: 0,
            checkedByUserID: null,
            color: null,
            description: null,
            imageURL: null,
            lastEditedByUserID: null),
      ];

      final result = groupItemsByCategory(
        items: items,
        categories: categories,
      );

      expect(result['cat1']?.length, 1);
    });

    test('複数カテゴリにマッチ時は先頭カテゴリに分類', () {
      final categories = [
        GroupCategory(
            id: 'cat1',
            groupID: 'group1',
            userID: 'user1',
            groupCategoryAxisID: 'axis1',
            name: '野菜',
            order: 0,
            locationOrders: {},
            keywords: [
              const GroupCategoryKeyword(
                keyword: 'トマト',
                matchingType: GroupCategoryKeywordMatchingType.partial,
              ),
            ],
            color: null,
            iconName: null),
        GroupCategory(
            id: 'cat2',
            groupID: 'group1',
            userID: 'user1',
            groupCategoryAxisID: 'axis1',
            name: '果物',
            order: 1,
            locationOrders: {},
            keywords: [
              const GroupCategoryKeyword(
                keyword: 'トマト',
                matchingType: GroupCategoryKeywordMatchingType.partial,
              ),
            ],
            color: null,
            iconName: null),
      ];

      final items = [
        const GroupShoppingListItem(
            id: 'item1',
            groupID: 'group1',
            shoppingListID: 'list1',
            userID: 'user1',
            message: 'トマト',
            order: 0,
            checkedByUserID: null,
            color: null,
            description: null,
            imageURL: null,
            lastEditedByUserID: null),
      ];

      final result = groupItemsByCategory(
        items: items,
        categories: categories,
      );

      expect(result['cat1']?.length, 1);
      expect(result['cat2'], isNull);
    });

    test('マッチしないアイテムは未分類', () {
      final categories = [
        GroupCategory(
            id: 'cat1',
            groupID: 'group1',
            userID: 'user1',
            groupCategoryAxisID: 'axis1',
            name: '野菜',
            order: 0,
            locationOrders: {},
            keywords: [
              const GroupCategoryKeyword(
                keyword: 'にんじん',
                matchingType: GroupCategoryKeywordMatchingType.exact,
              ),
            ],
            color: null,
            iconName: null),
      ];

      final items = [
        const GroupShoppingListItem(
            id: 'item1',
            groupID: 'group1',
            shoppingListID: 'list1',
            userID: 'user1',
            message: '牛乳',
            order: 0,
            checkedByUserID: null,
            color: null,
            description: null,
            imageURL: null,
            lastEditedByUserID: null),
      ];

      final result = groupItemsByCategory(
        items: items,
        categories: categories,
      );

      expect(result[uncategorizedCategoryID]?.length, 1);
      expect(result['cat1'], isNull);
    });

    test('カテゴリが空の場合は全て未分類', () {
      final items = [
        const GroupShoppingListItem(
            id: 'item1',
            groupID: 'group1',
            shoppingListID: 'list1',
            userID: 'user1',
            message: 'にんじん',
            order: 0,
            checkedByUserID: null,
            color: null,
            description: null,
            imageURL: null,
            lastEditedByUserID: null),
        const GroupShoppingListItem(
            id: 'item2',
            groupID: 'group1',
            shoppingListID: 'list1',
            userID: 'user1',
            message: '牛乳',
            order: 1,
            checkedByUserID: null,
            color: null,
            description: null,
            imageURL: null,
            lastEditedByUserID: null),
      ];

      final result = groupItemsByCategory(
        items: items,
        categories: [],
      );

      expect(result[uncategorizedCategoryID]?.length, 2);
      expect(result.length, 1);
    });

    test('アイテムが空の場合は空マップ', () {
      final categories = [
        GroupCategory(
            id: 'cat1',
            groupID: 'group1',
            userID: 'user1',
            groupCategoryAxisID: 'axis1',
            name: '野菜',
            order: 0,
            locationOrders: {},
            keywords: [
              const GroupCategoryKeyword(
                keyword: 'にんじん',
                matchingType: GroupCategoryKeywordMatchingType.exact,
              ),
            ],
            color: null,
            iconName: null),
      ];

      final result = groupItemsByCategory(
        items: [],
        categories: categories,
      );

      expect(result.isEmpty, true);
    });
  });

  group('findMatchingCategoryID', () {
    GroupCategory category({
      required String id,
      required int order,
      required String keyword,
      required GroupCategoryKeywordMatchingType matchingType,
    }) =>
        GroupCategory(
            id: id,
            groupID: 'group1',
            userID: 'user1',
            groupCategoryAxisID: 'axis1',
            name: id,
            order: order,
            locationOrders: {},
            keywords: [
              GroupCategoryKeyword(
                  keyword: keyword, matchingType: matchingType),
            ],
            color: null,
            iconName: null);

    GroupShoppingListItem item(String message) => GroupShoppingListItem(
        id: 'item1',
        groupID: 'group1',
        shoppingListID: 'list1',
        userID: 'user1',
        message: message,
        order: 0,
        checkedByUserID: null,
        color: null,
        description: null,
        imageURL: null,
        lastEditedByUserID: null);

    test('マッチしたカテゴリIDを返す', () {
      expect(
        findMatchingCategoryID(
          item: item('にんじん'),
          categories: [
            category(
                id: 'cat1',
                order: 0,
                keyword: 'にんじん',
                matchingType: GroupCategoryKeywordMatchingType.exact),
          ],
        ),
        'cat1',
      );
    });

    test('マッチしない場合は uncategorizedCategoryID', () {
      expect(
        findMatchingCategoryID(
          item: item('牛乳'),
          categories: [
            category(
                id: 'cat1',
                order: 0,
                keyword: 'にんじん',
                matchingType: GroupCategoryKeywordMatchingType.exact),
          ],
        ),
        uncategorizedCategoryID,
      );
    });

    test('カテゴリが空なら uncategorizedCategoryID', () {
      expect(
        findMatchingCategoryID(item: item('にんじん'), categories: []),
        uncategorizedCategoryID,
      );
    });
  });
}
