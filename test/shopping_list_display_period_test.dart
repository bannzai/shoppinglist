import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shopping list display period rule', () {
    test('無料ユーザーは30日前ちょうどを含み、31日前は除外する', () {
      final now = DateTime(2026, 1, 31, 12, 0, 0);
      final threshold = now.subtract(const Duration(days: 30));

      final oldList = GroupShoppingList(
        id: 'old-id',
        createUserID: 'user-id',
        groupID: 'group-id',
        ttlExpiresDateTime: null,
        createdDateTime: now.subtract(const Duration(days: 31)),
      );
      final boundaryList = GroupShoppingList(
        id: 'boundary-id',
        createUserID: 'user-id',
        groupID: 'group-id',
        ttlExpiresDateTime: null,
        createdDateTime: threshold,
      );
      final recentList = GroupShoppingList(
        id: 'recent-id',
        createUserID: 'user-id',
        groupID: 'group-id',
        ttlExpiresDateTime: null,
        createdDateTime: now.subtract(const Duration(days: 1)),
      );

      final freeUserLists = [oldList, boundaryList, recentList]
          .where((l) =>
              l.createdDateTime != null &&
              !l.createdDateTime!.isBefore(threshold))
          .toList();

      expect(freeUserLists.map((e) => e.id), ['boundary-id', 'recent-id']);
    });

    test('プレミアムユーザーは表示期間で除外しない', () {
      final lists = [
        GroupShoppingList(
          id: 'old-id',
          createUserID: 'user-id',
          groupID: 'group-id',
          ttlExpiresDateTime: null,
          createdDateTime: DateTime(2025, 1, 1),
        ),
        GroupShoppingList(
          id: 'recent-id',
          createUserID: 'user-id',
          groupID: 'group-id',
          ttlExpiresDateTime: null,
          createdDateTime: DateTime(2026, 1, 1),
        ),
      ];

      expect(lists.length, 2);
    });
  });
}
