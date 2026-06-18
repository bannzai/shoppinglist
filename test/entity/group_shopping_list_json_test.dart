import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';

/// toJson は ServerCreatedTimestamp 等で FieldValue を埋めるため、
/// ラウンドトリップ用にサーバータイムスタンプ系を除外する。
Map<String, dynamic> _withoutTimestamps(Map<String, dynamic> json) =>
    json
      ..remove('createdDateTime')
      ..remove('updatedDateTime')
      ..remove('serverCreatedDateTime')
      ..remove('serverUpdatedDateTime');

void main() {
  group('GroupShoppingList JSON', () {
    test('autoNotifyEnabled フィールドが付与されていない既存データは false になる', () {
      final json = {
        'id': 'list1',
        'createUserID': 'user1',
        'groupID': 'group1',
        'ttlExpiresDateTime': null,
      };
      expect(GroupShoppingList.fromJson(json).autoNotifyEnabled, false);
    });

    test('autoNotifyEnabled=true のラウンドトリップ', () {
      const list = GroupShoppingList(
        id: 'list1',
        createUserID: 'user1',
        groupID: 'group1',
        autoNotifyEnabled: true,
        ttlExpiresDateTime: null,
        duplicatedFromGroupShoppingListID: null,
        shoppingLocationID: null,
      );
      final json = _withoutTimestamps(list.toJson());
      expect(json['autoNotifyEnabled'], true);
      expect(GroupShoppingList.fromJson(json).autoNotifyEnabled, true);
    });

    test('既存フィールド (status / name / createUserID) は保持される', () {
      const list = GroupShoppingList(
        id: 'list1',
        createUserID: 'user1',
        groupID: 'group1',
        name: '夕食',
        autoNotifyEnabled: true,
        ttlExpiresDateTime: null,
        duplicatedFromGroupShoppingListID: null,
        shoppingLocationID: null,
      );
      final round = GroupShoppingList.fromJson(
        _withoutTimestamps(list.toJson()),
      );
      expect(round.name, '夕食');
      expect(round.status, GroupShoppingListStatus.active);
    });
  });
}
