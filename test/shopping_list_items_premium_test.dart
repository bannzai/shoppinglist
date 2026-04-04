import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_keyword.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_matcher.dart';

const _testGroupID = 'test-group-001';
const _testCategoryAxisID = 'test-axis-001';
const _testUserID = 'test-user-001';
const _testLocationID = 'test-location-001';

List<GroupCategory> _testCategories() => [
      GroupCategory(
        id: 'cat-vegetables',
        groupID: _testGroupID,
        userID: _testUserID,
        groupCategoryAxisID: _testCategoryAxisID,
        name: '野菜',
        order: 0,
        locationOrders: const {_testLocationID: 1},
        keywords: const [
          GroupCategoryKeyword(
              keyword: 'にんじん',
              matchingType: GroupCategoryKeywordMatchingType.partial),
        ],
      ),
      GroupCategory(
        id: 'cat-meat',
        groupID: _testGroupID,
        userID: _testUserID,
        groupCategoryAxisID: _testCategoryAxisID,
        name: '肉',
        order: 1,
        locationOrders: const {_testLocationID: 0},
        keywords: const [
          GroupCategoryKeyword(
              keyword: '鶏肉',
              matchingType: GroupCategoryKeywordMatchingType.partial),
        ],
      ),
    ];

void main() {
  group('ShoppingListItems プレミアムゲーティング', () {
    test('非プレミアムユーザーではshoppingLocationIDがnullになりデフォルト順が使用される', () {
      // 非プレミアムの場合、_CategorizedShoppingListItems.build で
      // shoppingLocationID は isPremium ? shoppingLocationID : null に変換される。
      // shoppingLocationID が null の場合、sortCategoriesByLocation は
      // デフォルトの order フィールドでソートする。

      final sorted = sortCategoriesByLocation(
        categories: _testCategories(),
        shoppingLocationID: null, // 非プレミアム → null
      );

      // デフォルト順: 野菜(order=0) → 肉(order=1)
      expect(sorted.map((c) => c.id).toList(), ['cat-vegetables', 'cat-meat']);
    });

    test('プレミアムユーザーではshoppingLocationIDが有効でロケーション別ソートが適用される', () {
      // プレミアムの場合、shoppingLocationID がそのまま渡される

      final sorted = sortCategoriesByLocation(
        categories: _testCategories(),
        shoppingLocationID: _testLocationID, // プレミアム → ロケーションID
      );

      // ロケーション別順: 肉(locationOrders[testLocation]=0) → 野菜(locationOrders[testLocation]=1)
      expect(sorted.map((c) => c.id).toList(), ['cat-meat', 'cat-vegetables']);
    });
  });
}
