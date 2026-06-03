import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_item_metrics.dart';

GroupShoppingListItem _item({
  required String id,
  required String message,
  GroupShoppingListItemStatus status = GroupShoppingListItemStatus.unchecked,
}) {
  return GroupShoppingListItem(
      id: id,
      groupID: 'group-id',
      shoppingListID: 'shopping-list-id',
      userID: 'user-id',
      message: message,
      order: 0,
      status: status,
      checkedByUserID: null,
      color: null,
      description: null,
      imageURL: null,
      lastEditedByUserID: null);
}

void main() {
  group('shoppingListItemMetrics', () {
    test('入力用の空行を totalCount に含めない', () {
      final metrics = shoppingListItemMetrics([
        _item(id: '1', message: '牛乳'),
        _item(id: '2', message: ''),
        _item(id: '3', message: '   '),
      ]);

      expect(metrics.totalCount, 1);
      expect(metrics.checkedCount, 0);
    });

    test('空行以外の checked 件数だけを数える', () {
      final metrics = shoppingListItemMetrics([
        _item(
          id: '1',
          message: '牛乳',
          status: GroupShoppingListItemStatus.checked,
        ),
        _item(
          id: '2',
          message: '',
          status: GroupShoppingListItemStatus.checked,
        ),
        _item(id: '3', message: '卵'),
      ]);

      expect(metrics.totalCount, 2);
      expect(metrics.checkedCount, 1);
    });
  });
}
