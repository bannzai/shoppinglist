import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';

void main() {
  group('GroupShoppingListItem imageURL', () {
    test('imageURL付きのJSONからデシリアライズできる', () {
      final json = {
        'id': 'item-1',
        'groupID': 'group-1',
        'shoppingListID': 'list-1',
        'userID': 'user-1',
        'message': '牛乳',
        'order': 0,
        'status': 'unchecked',
        'imageURL': 'https://example.com/photo.jpg',
      };
      final item = GroupShoppingListItem.fromJson(json);
      expect(item.imageURL, 'https://example.com/photo.jpg');
    });

    test('imageURLなしのJSONからデシリアライズするとnullになる', () {
      final json = {
        'id': 'item-1',
        'groupID': 'group-1',
        'shoppingListID': 'list-1',
        'userID': 'user-1',
        'message': '卵',
        'order': 1,
        'status': 'unchecked',
      };
      final item = GroupShoppingListItem.fromJson(json);
      expect(item.imageURL, isNull);
    });

    test('imageURL付きアイテムがJSONにシリアライズされる', () {
      const item = GroupShoppingListItem(
        id: 'item-1',
        groupID: 'group-1',
        shoppingListID: 'list-1',
        userID: 'user-1',
        message: '牛乳',
        order: 0,
        imageURL: 'https://example.com/photo.jpg',
        checkedByUserID: null,
        color: null,
        description: null,
        lastEditedByUserID: null,
      );
      final json = item.toJson();
      expect(json['imageURL'], 'https://example.com/photo.jpg');
    });

    test('copyWithでimageURLを更新できる', () {
      const item = GroupShoppingListItem(
        id: 'item-1',
        groupID: 'group-1',
        shoppingListID: 'list-1',
        userID: 'user-1',
        message: '牛乳',
        order: 0,
        checkedByUserID: null,
        color: null,
        description: null,
        imageURL: null,
        lastEditedByUserID: null,
      );
      final updated = item.copyWith(imageURL: 'https://example.com/photo.jpg');
      expect(updated.imageURL, 'https://example.com/photo.jpg');
    });

    test('copyWithでimageURLをnullにできる', () {
      const item = GroupShoppingListItem(
        id: 'item-1',
        groupID: 'group-1',
        shoppingListID: 'list-1',
        userID: 'user-1',
        message: '牛乳',
        order: 0,
        imageURL: 'https://example.com/photo.jpg',
        checkedByUserID: null,
        color: null,
        description: null,
        lastEditedByUserID: null,
      );
      final updated = item.copyWith(imageURL: null);
      expect(updated.imageURL, isNull);
    });
  });
}
