import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/provider/memo_row.dart';

class MemoRowAddButton extends HookConsumerWidget {
  final String memoID;
  final List<MemoRow> memoRows;

  const MemoRowAddButton(
      {super.key, required this.memoID, required this.memoRows});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () {
        ref.read(addTextMemoRowProvider).call(
              memoID: memoID,
              message: '',
              order: memoRows.nextOrder,
            );
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Icon(Icons.add),
      ),
    );
  }
}
