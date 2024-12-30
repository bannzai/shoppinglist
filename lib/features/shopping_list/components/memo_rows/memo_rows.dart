import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/link_memo.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/text_memo.dart';
import 'package:shoppinglist/provider/memo_row.dart';

class MemoRows extends HookConsumerWidget {
  final String memoID;
  final List<MemoRow> memoRows;
  final AsyncValue<List<MemoRow>> memoRowsAsync;

  const MemoRows({
    super.key,
    required this.memoID,
    required this.memoRows,
    required this.memoRowsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoRows = useState(this.memoRows);

    useEffect(() {
      memoRows.value = memoRowsAsync.asData?.value ?? [];
      return null;
    }, [memoRowsAsync]);

    return ReorderableList(
      onReorder: (oldIndex, newIndex) {
        debugPrint('oldIndex: $oldIndex, newIndex: $newIndex');
        final changedMemoRows = [...memoRows.value];
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

        final orderedMemoRows = changedMemoRows..sort((a, b) => a.order.compareTo(b.order));

        memoRows.value = [...orderedMemoRows];

        ref.read(memoRowBatchUpdateProvider).call(
              memoID: memoID,
              memoRows: orderedMemoRows,
            );
      },
      itemCount: memoRows.value.length,
      itemBuilder: (context, index) {
        final memoRow = memoRows.value[index];

        return switch (memoRow) {
          TextMemoRow textMemoRow => TextMemo(key: ValueKey(memoRow.id), textMemoRow: textMemoRow, memoRows: memoRows.value),
          LinkMemoRow linkMemoRow => LinkMemo(key: ValueKey(memoRow.id), linkMemoRow: linkMemoRow, memoRows: memoRows.value),
        };
      },
    );
  }
}
