import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/link_memo.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/text_memo.dart';
import 'package:shoppinglist/provider/memo_row.dart';

class MemoRows extends HookConsumerWidget {
  final String memoID;
  final List<MemoRow> memoRows;
  const MemoRows({
    super.key,
    required this.memoID,
    required this.memoRows,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableList(
      onReorder: (oldIndex, newIndex) async {
        debugPrint('oldIndex: $oldIndex, newIndex: $newIndex');
        final changedMemoRows = [...memoRows];
        if (oldIndex < newIndex) {
          for (var i = oldIndex; i < newIndex; i++) {
            final memoRow = changedMemoRows[i];
            changedMemoRows[i] = memoRow.copyWith(order: i - 1);
          }
        } else {
          for (var i = oldIndex; i > newIndex; i--) {
            final memoRow = changedMemoRows[i];
            changedMemoRows[i] = memoRow.copyWith(order: i + 1);
          }
        }
        changedMemoRows[oldIndex] = changedMemoRows[oldIndex].copyWith(order: newIndex);

        await ref.read(memoRowBatchUpdateProvider).call(
              memoID: memoID,
              memoRows: changedMemoRows,
            );
      },
      itemCount: memoRows.length,
      itemBuilder: (context, index) {
        final memoRow = memoRows[index];

        return switch (memoRow) {
          TextMemoRow textMemoRow => TextMemo(key: ValueKey(memoRow.id), textMemoRow: textMemoRow, memoRows: memoRows),
          LinkMemoRow linkMemoRow => LinkMemo(key: ValueKey(memoRow.id), linkMemoRow: linkMemoRow, memoRows: memoRows),
        };
      },
    );
  }
}
