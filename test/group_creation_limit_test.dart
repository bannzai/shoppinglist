import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group.dart';

void main() {
  group('グループ作成数上限', () {
    test('無料ユーザーの追加グループ上限は1個', () {
      expect(freeAdditionalGroupCreationLimit, 1);
    });

    test('ソログループを含む合計上限は2個', () {
      // ソログループ(1) + 追加グループ上限(1) = 2
      expect(freeAdditionalGroupCreationLimit + 1, 2);
    });
  });
}
