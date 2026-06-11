import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/provider/shopping_list.dart';

void main() {
  group('groupShoppingListName', () {
    final createdDate = DateTime(2026, 6, 11, 10, 30);

    test('同日に既存リストが無ければ連番を付けない', () {
      expect(
        groupShoppingListName(createdDate: createdDate, sameDateCount: 0),
        '2026-06-11',
      );
    });

    test('同日に既存リストが1つあれば (1) を付ける', () {
      expect(
        groupShoppingListName(createdDate: createdDate, sameDateCount: 1),
        '2026-06-11 (1)',
      );
    });

    test('同日に既存リストが複数あれば連番が件数になる', () {
      expect(
        groupShoppingListName(createdDate: createdDate, sameDateCount: 3),
        '2026-06-11 (3)',
      );
    });

    test('日付が違えば同じ件数でも連番は同日件数で決まる（日付をまたいで増え続けない）', () {
      // 別日に作成し、その日の既存数が 0 なら連番は付かない（Issue #388 の本質）。
      expect(
        groupShoppingListName(
          createdDate: DateTime(2026, 6, 12, 9, 0),
          sameDateCount: 0,
        ),
        '2026-06-12',
      );
    });
  });
}
