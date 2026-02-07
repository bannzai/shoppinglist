import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/entity/memo_row.dart';

void main() {
  test('Memo entity smoke test', () {
    final memo = Memo(
      id: 'test-id',
      userID: 'user-id',
      ttlExpiresDateTime: null,
    );
    expect(memo.id, 'test-id');
    expect(memo.userID, 'user-id');
    expect(memo.name, '');
    expect(memo.status, MemoStatus.active);
  });

  test('MemoRow entity smoke test', () {
    final row = MemoRow.text(
      id: 'row-id',
      memoID: 'memo-id',
      message: 'Buy milk',
      order: 0,
    );
    expect(row.id, 'row-id');
    expect(row.order, 0);
  });

  test('MemoRows nextOrder', () {
    final rows = <MemoRow>[
      MemoRow.text(id: '1', memoID: 'memo-id', message: 'Item 1', order: 0),
      MemoRow.text(id: '2', memoID: 'memo-id', message: 'Item 2', order: 1),
    ];
    expect(rows.nextOrder, 2);
  });
}
