import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group.dart';

void main() {
  group('Group JSON', () {
    test('iconName フィールドが付与されていない既存データは home になる', () {
      final json = {
        'id': 'group1',
        'memberUserIDs': <String>['user1'],
        'name': '家族',
      };
      expect(Group.fromJson(json).iconName, 'home');
    });

    test('iconName 指定データのラウンドトリップ', () {
      const group = Group(
        id: 'group1',
        memberUserIDs: ['user1', 'user2'],
        name: '家族',
        iconName: 'cart',
      );
      // toJson は ServerCreatedTimestamp / ServerUpdatedTimestamp によって
      // FieldValue を埋めるため、ラウンドトリップ用に server* / client* を除外する。
      final json =
          group.toJson()
            ..remove('createdDateTime')
            ..remove('updatedDateTime')
            ..remove('serverCreatedDateTime')
            ..remove('serverUpdatedDateTime');
      expect(json['iconName'], 'cart');
      expect(Group.fromJson(json).iconName, 'cart');
    });

    test('iconName は home / cart / fork / cookie / pets / bag を受け取れる', () {
      for (final iconName in const [
        'home',
        'cart',
        'fork',
        'cookie',
        'pets',
        'bag',
      ]) {
        final group = Group(
          id: 'group1',
          memberUserIDs: const ['user1'],
          name: '家族',
          iconName: iconName,
        );
        expect(group.iconName, iconName);
      }
    });
  });
}
