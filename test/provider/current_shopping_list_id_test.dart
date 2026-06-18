import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/provider/current_shopping_list_id.dart';

GroupShoppingList _list(String id) => GroupShoppingList(
  id: id,
  createUserID: 'user-id',
  groupID: 'group-id',
  name: id,
  status: GroupShoppingListStatus.active,
  ttlExpiresDateTime: null,
  duplicatedFromGroupShoppingListID: null,
  shoppingLocationID: null,
);

void main() {
  group('resolveShoppingListID', () {
    test('一覧が空なら null', () {
      expect(resolveShoppingListID(selected: 'a', shoppingLists: []), isNull);
    });

    test('選択が一覧に存在すればその選択を返す', () {
      expect(
        resolveShoppingListID(
          selected: 'b',
          shoppingLists: [_list('a'), _list('b')],
        ),
        'b',
      );
    });

    test('選択が null なら先頭にフォールバックする', () {
      expect(
        resolveShoppingListID(
          selected: null,
          shoppingLists: [_list('a'), _list('b')],
        ),
        'a',
      );
    });

    test('選択が一覧に存在しなければ先頭にフォールバックする', () {
      expect(
        resolveShoppingListID(
          selected: 'z',
          shoppingLists: [_list('a'), _list('b')],
        ),
        'a',
      );
    });
  });
}
