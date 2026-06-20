import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group.dart';

void main() {
  group('Group.nameIsNotEmpty', () {
    Group buildGroup(String? name) =>
        Group(id: 'group1', memberUserIDs: const ['user1'], name: name);

    test('name が null なら false', () {
      expect(buildGroup(null).nameIsNotEmpty, false);
    });
    test('name が空文字なら false', () {
      expect(buildGroup('').nameIsNotEmpty, false);
    });
    test('name が空白のみなら false', () {
      expect(buildGroup('   ').nameIsNotEmpty, false);
    });
    test('name に文字があれば true', () {
      expect(buildGroup('家族').nameIsNotEmpty, true);
    });
    test('前後に空白があっても中身があれば true', () {
      expect(buildGroup('  家族  ').nameIsNotEmpty, true);
    });
  });
}
