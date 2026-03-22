import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/category_matcher.dart';

GroupCategory _makeCategory({
  required String id,
  required int order,
  Map<String, int> locationOrders = const {},
}) {
  return GroupCategory(
    id: id,
    groupID: 'group1',
    userID: 'user1',
    groupCategoryAxisID: 'axis1',
    name: 'カテゴリ $id',
    order: order,
    locationOrders: locationOrders,
    keywords: [],
  );
}

void main() {
  group('sortCategoriesByLocation', () {
    test('shoppingLocationID が null の場合、デフォルトの order 順でソートされる', () {
      final categories = [
        _makeCategory(id: 'c3', order: 2),
        _makeCategory(id: 'c1', order: 0),
        _makeCategory(id: 'c2', order: 1),
      ];

      final sorted = sortCategoriesByLocation(
        categories: categories,
        shoppingLocationID: null,
      );

      expect(sorted.map((c) => c.id).toList(), ['c1', 'c2', 'c3']);
    });

    test('locationOrders にエントリがある場合、そのロケーションの順序でソートされる', () {
      final categories = [
        _makeCategory(
            id: 'vegetables', order: 0, locationOrders: {'storeA': 0}),
        _makeCategory(id: 'meat', order: 1, locationOrders: {'storeA': 2}),
        _makeCategory(id: 'fish', order: 2, locationOrders: {'storeA': 1}),
      ];

      final sorted = sortCategoriesByLocation(
        categories: categories,
        shoppingLocationID: 'storeA',
      );

      // storeA の順序: vegetables(0) → fish(1) → meat(2)
      expect(sorted.map((c) => c.id).toList(), ['vegetables', 'fish', 'meat']);
    });

    test('一部のカテゴリのみ locationOrders がある場合、ない分は order にフォールバック', () {
      final categories = [
        _makeCategory(
            id: 'vegetables', order: 0, locationOrders: {'storeA': 2}),
        _makeCategory(id: 'meat', order: 1), // locationOrders なし → order=1
        _makeCategory(id: 'fish', order: 2, locationOrders: {'storeA': 0}),
      ];

      final sorted = sortCategoriesByLocation(
        categories: categories,
        shoppingLocationID: 'storeA',
      );

      // fish(0) → meat(1, フォールバック) → vegetables(2)
      expect(sorted.map((c) => c.id).toList(), ['fish', 'meat', 'vegetables']);
    });

    test('存在しない shoppingLocationID の場合、全てデフォルトの order にフォールバック', () {
      final categories = [
        _makeCategory(id: 'c1', order: 2, locationOrders: {'storeA': 0}),
        _makeCategory(id: 'c2', order: 0, locationOrders: {'storeA': 2}),
        _makeCategory(id: 'c3', order: 1, locationOrders: {'storeA': 1}),
      ];

      final sorted = sortCategoriesByLocation(
        categories: categories,
        shoppingLocationID: 'storeB',
      );

      // storeB にエントリがないので全て order にフォールバック
      expect(sorted.map((c) => c.id).toList(), ['c2', 'c3', 'c1']);
    });

    test('ロケーションAとBで異なる順序が返される', () {
      final categories = [
        _makeCategory(
            id: 'vegetables',
            order: 0,
            locationOrders: {'storeA': 0, 'storeB': 2}),
        _makeCategory(
            id: 'meat', order: 1, locationOrders: {'storeA': 2, 'storeB': 0}),
        _makeCategory(
            id: 'fish', order: 2, locationOrders: {'storeA': 1, 'storeB': 1}),
      ];

      final sortedA = sortCategoriesByLocation(
        categories: categories,
        shoppingLocationID: 'storeA',
      );
      final sortedB = sortCategoriesByLocation(
        categories: categories,
        shoppingLocationID: 'storeB',
      );

      // storeA: vegetables(0) → fish(1) → meat(2)
      expect(sortedA.map((c) => c.id).toList(), ['vegetables', 'fish', 'meat']);
      // storeB: meat(0) → fish(1) → vegetables(2)
      expect(sortedB.map((c) => c.id).toList(), ['meat', 'fish', 'vegetables']);
    });

    test('空のカテゴリリストの場合、空リストが返される', () {
      final sorted = sortCategoriesByLocation(
        categories: [],
        shoppingLocationID: 'storeA',
      );

      expect(sorted, isEmpty);
    });

    test('元のリストは変更されない（イミュータブル）', () {
      final categories = [
        _makeCategory(id: 'c2', order: 1),
        _makeCategory(id: 'c1', order: 0),
      ];

      sortCategoriesByLocation(
        categories: categories,
        shoppingLocationID: null,
      );

      // 元のリストの順序は変わっていない
      expect(categories.map((c) => c.id).toList(), ['c2', 'c1']);
    });
  });
}
