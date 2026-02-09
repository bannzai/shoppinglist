import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/shopping_list.dart';
import 'package:shoppinglist/entity/shopping_list_item.dart';

void main() {
  test('ShoppingList entity smoke test', () {
    final shoppingList = ShoppingList(
      id: 'test-id',
      createUserID: 'user-id',
      groupID: 'group-id',
      ttlExpiresDateTime: null,
    );
    expect(shoppingList.id, 'test-id');
    expect(shoppingList.createUserID, 'user-id');
    expect(shoppingList.groupID, 'group-id');
    expect(shoppingList.name, '');
    expect(shoppingList.status, ShoppingListStatus.active);
  });

  test('ShoppingListItem entity smoke test', () {
    final item = ShoppingListItem.text(
      id: 'item-id',
      shoppingListID: 'shopping-list-id',
      message: 'Buy milk',
      order: 0,
    );
    expect(item.id, 'item-id');
    expect(item.order, 0);
  });

  test('ShoppingListItems nextOrder', () {
    final items = <ShoppingListItem>[
      ShoppingListItem.text(
          id: '1',
          shoppingListID: 'shopping-list-id',
          message: 'Item 1',
          order: 0),
      ShoppingListItem.text(
          id: '2',
          shoppingListID: 'shopping-list-id',
          message: 'Item 2',
          order: 1),
    ];
    expect(items.nextOrder, 2);
  });
}
