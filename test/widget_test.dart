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
    final item = GroupShoppingListItem.text(
      id: 'item-id',
      groupID: 'group-id',
      shoppingListID: 'shopping-list-id',
      message: 'Buy milk',
      order: 0,
    );
    expect(item.id, 'item-id');
    expect(item.order, 0);
  });

  test('ShoppingListItems nextOrder', () {
    final items = <GroupShoppingListItem>[
      GroupShoppingListItem.text(
          id: '1',
          groupID: 'group-id',
          shoppingListID: 'shopping-list-id',
          message: 'Item 1',
          order: 0),
      GroupShoppingListItem.text(
          id: '2',
          groupID: 'group-id',
          shoppingListID: 'shopping-list-id',
          message: 'Item 2',
          order: 1),
    ];
    expect(items.nextOrder, 2);
  });
}
