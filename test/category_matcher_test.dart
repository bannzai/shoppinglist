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

  group('reorderedSectionItems', () {
    GroupShoppingListItem item(String id, int order) => GroupShoppingListItem(
          id: id,
          groupID: 'group1',
          shoppingListID: 'list1',
          userID: 'user1',
          message: id,
          order: order,
          checkedByUserID: null,
          color: null,
          description: null,
          imageURL: null,
          lastEditedByUserID: null,
        );

    test('先頭→末尾の移動で order 多重集合を保ったまま並びが入れ替わる', () {
      // カテゴリのアイテムが order {0,2,4} を持つ状態を再現
      final section = [item('A', 0), item('C', 2), item('E', 4)];

      // 末尾 E(index2) を先頭(index0)へ移動
      final result = reorderedSectionItems(
        sectionItems: section,
        oldIndex: 2,
        newIndex: 0,
      );

      // 並び順は [E, A, C]
      expect(result.map((e) => e.id).toList(), ['E', 'A', 'C']);
      // order の多重集合は {0,2,4} のまま（昇順に再割り当て）
      expect(result.map((e) => e.order).toList(), [0, 2, 4]);
    });

    test('下方向移動は newIndex を 1 補正して反映する', () {
      final section = [item('A', 0), item('B', 1), item('C', 2)];

      // A(index0) を C の下(onReorder の newIndex=3)へ移動
      final result = reorderedSectionItems(
        sectionItems: section,
        oldIndex: 0,
        newIndex: 3,
      );

      expect(result.map((e) => e.id).toList(), ['B', 'C', 'A']);
      expect(result.map((e) => e.order).toList(), [0, 1, 2]);
    });

    test('order に飛び・重複があっても多重集合をそのまま保つ', () {
      // 0,1,3 と飛ぶ / 重複もあり得る前提（group_shopping_list_item.dart の NOTE）
      final section = [item('A', 1), item('B', 3), item('C', 3)];

      final result = reorderedSectionItems(
        sectionItems: section,
        oldIndex: 2,
        newIndex: 0,
      );

      expect(result.map((e) => e.id).toList(), ['C', 'A', 'B']);
      expect(result.map((e) => e.order).toList(), [1, 3, 3]);
    });
  });
}
