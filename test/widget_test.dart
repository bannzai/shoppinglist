import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';

void main() {
  test('ShoppingList entity smoke test', () {
    final shoppingList = GroupShoppingList(
      id: 'test-id',
      createUserID: 'user-id',
      groupID: 'group-id',
      ttlExpiresDateTime: null,
    );
    expect(shoppingList.id, 'test-id');
    expect(shoppingList.createUserID, 'user-id');
    expect(shoppingList.groupID, 'group-id');
    expect(shoppingList.name, '');
    expect(shoppingList.status, GroupShoppingListStatus.active);
  });

  test('ShoppingListItem entity smoke test', () {
    final item = GroupShoppingListItem(
      id: 'item-id',
      groupID: 'group-id',
      shoppingListID: 'shopping-list-id',
      userID: 'user-id',
      message: 'Buy milk',
      order: 0,
    );
    expect(item.id, 'item-id');
    expect(item.order, 0);
  });

  test('ShoppingListItems nextOrder', () {
    final items = <GroupShoppingListItem>[
      GroupShoppingListItem(
          id: '1',
          groupID: 'group-id',
          shoppingListID: 'shopping-list-id',
          userID: 'user-id',
          message: 'Item 1',
          order: 0),
      GroupShoppingListItem(
          id: '2',
          groupID: 'group-id',
          shoppingListID: 'shopping-list-id',
          userID: 'user-id',
          message: 'Item 2',
          order: 1),
    ];
    expect(items.nextOrder, 2);
  });

  group('GroupShoppingListItem serialization', () {
    GroupShoppingListItem createTestItem() {
      return GroupShoppingListItem(
        id: 'item-1',
        groupID: 'group-1',
        shoppingListID: 'list-1',
        userID: 'user-1',
        message: 'Buy eggs',
        order: 0,
        status: GroupShoppingListItemStatus.unchecked,
        description: 'organic eggs',
        color: '#FF0000',
      );
    }

    test('toJson does not contain type field', () {
      final item = createTestItem();
      final json = item.toJson();
      expect(json.containsKey('type'), isFalse);
    });

    test('toFirestore does not contain type field', () {
      final item = createTestItem();
      final firestoreMap = GroupShoppingListItem.toFirestore(item, null);
      expect(firestoreMap.containsKey('type'), isFalse);
    });

    test('fromJson works without type field', () {
      final json = {
        'id': 'item-2',
        'groupID': 'group-1',
        'shoppingListID': 'list-1',
        'userID': 'user-1',
        'message': 'Buy bread',
        'order': 1,
        'status': 'unchecked',
      };
      final item = GroupShoppingListItem.fromJson(json);
      expect(item.id, 'item-2');
      expect(item.message, 'Buy bread');
      expect(item.order, 1);
      expect(item.status, GroupShoppingListItemStatus.unchecked);
    });

    test('fromJson works with legacy type field (backward compatibility)', () {
      final json = {
        'id': 'item-3',
        'groupID': 'group-1',
        'shoppingListID': 'list-1',
        'userID': 'user-1',
        'message': 'Buy butter',
        'order': 2,
        'status': 'checked',
        'type': 'text',
      };
      final item = GroupShoppingListItem.fromJson(json);
      expect(item.id, 'item-3');
      expect(item.message, 'Buy butter');
      expect(item.order, 2);
      expect(item.status, GroupShoppingListItemStatus.checked);
    });

    test('toJson → fromJson round-trip', () {
      final original = createTestItem();
      final json = original.toJson();
      // ServerTimestampのFieldValueはテスト環境でfromJsonに渡せないため除外
      json.remove('serverCreatedDateTime');
      json.remove('serverUpdatedDateTime');
      json.remove('createdDateTime');
      json.remove('updatedDateTime');
      final restored = GroupShoppingListItem.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.groupID, original.groupID);
      expect(restored.shoppingListID, original.shoppingListID);
      expect(restored.message, original.message);
      expect(restored.order, original.order);
      expect(restored.status, original.status);
      expect(restored.description, original.description);
      expect(restored.color, original.color);
    });
  });
}
