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

  group('カテゴリまたぎ D&D', () {
    GroupCategory cat(String id, int order) => GroupCategory(
          id: id,
          groupID: 'group1',
          userID: 'user1',
          groupCategoryAxisID: 'axis1',
          name: id,
          order: order,
          locationOrders: {},
          keywords: [],
          color: null,
          iconName: null,
        );

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

    final sortedCategories = [cat('cat1', 0), cat('cat2', 1)];
    // cat1: [a, b], cat2: [c], 未分類: [d]
    Map<String, List<GroupShoppingListItem>> grouped() => {
          'cat1': [item('a', 0), item('b', 1)],
          'cat2': [item('c', 2)],
          uncategorizedCategoryID: [item('d', 3)],
        };

    test('buildGroupedRows はヘッダー+アイテムを表示順に並べ未分類を末尾に置く', () {
      final rows = buildGroupedRows(
          sortedCategories: sortedCategories, grouped: grouped());
      // 期待: H(cat1), a, b, H(cat2), c, H(未分類), d
      expect(rows.length, 7);
      expect((rows[0] as GroupedHeaderRow).categoryID, 'cat1');
      expect((rows[1] as GroupedItemRow).item.id, 'a');
      expect((rows[2] as GroupedItemRow).item.id, 'b');
      expect((rows[3] as GroupedHeaderRow).categoryID, 'cat2');
      expect((rows[4] as GroupedItemRow).item.id, 'c');
      expect((rows[5] as GroupedHeaderRow).categoryID, isNull); // 未分類
      expect((rows[6] as GroupedItemRow).item.id, 'd');
    });

    test('categoryIDForDropPosition: cat1の a を cat2 末尾へドロップすると cat2', () {
      final rows = buildGroupedRows(
          sortedCategories: sortedCategories, grouped: grouped());
      // a(index1) を cat2 の c の下(未分類ヘッダーの直前 index5)へ
      final dest =
          categoryIDForDropPosition(rows: rows, oldIndex: 1, newIndex: 5);
      expect(dest, 'cat2');
    });

    test('categoryIDForDropPosition: 末尾(未分類)へドロップすると null', () {
      final rows = buildGroupedRows(
          sortedCategories: sortedCategories, grouped: grouped());
      // a(index1) を末尾(未分類 d の下、newIndex=7)へ
      final dest =
          categoryIDForDropPosition(rows: rows, oldIndex: 1, newIndex: 7);
      expect(dest, isNull);
    });

    test('itemsAfterMove: a を cat2 へ移すと全体 order が 0..N-1 に正規化される', () {
      final g = grouped();
      final rows =
          buildGroupedRows(sortedCategories: sortedCategories, grouped: g);
      final dest =
          categoryIDForDropPosition(rows: rows, oldIndex: 1, newIndex: 5);
      final result = itemsAfterMove(
        sortedCategories: sortedCategories,
        grouped: g,
        movedItem: item('a', 0),
        fromCategoryID: 'cat1',
        toCategoryID: dest,
        dropIndexInTargetValue: dropIndexInTarget(
            rows: rows, oldIndex: 1, newIndex: 5, toCategoryID: dest),
      );
      // 表示順: cat1[b], cat2[c, a], 未分類[d] → b,c,a,d に order 0,1,2,3
      expect(result.map((e) => e.id).toList(), ['b', 'c', 'a', 'd']);
      expect(result.map((e) => e.order).toList(), [0, 1, 2, 3]);
    });

    test('itemsAfterMove: 未分類の d を cat1 先頭へ移す', () {
      final g = grouped();
      final rows =
          buildGroupedRows(sortedCategories: sortedCategories, grouped: g);
      // d(index6) を cat1 の a の上(newIndex=1)へ
      final dest =
          categoryIDForDropPosition(rows: rows, oldIndex: 6, newIndex: 1);
      final result = itemsAfterMove(
        sortedCategories: sortedCategories,
        grouped: g,
        movedItem: item('d', 3),
        fromCategoryID: null,
        toCategoryID: dest,
        dropIndexInTargetValue: dropIndexInTarget(
            rows: rows, oldIndex: 6, newIndex: 1, toCategoryID: dest),
      );
      expect(dest, 'cat1');
      // cat1[d, a, b], cat2[c], 未分類[] → d,a,b,c
      expect(result.map((e) => e.id).toList(), ['d', 'a', 'b', 'c']);
      expect(result.map((e) => e.order).toList(), [0, 1, 2, 3]);
    });
  });
}
