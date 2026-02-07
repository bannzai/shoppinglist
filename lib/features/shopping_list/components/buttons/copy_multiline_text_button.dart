import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/provider/memo_row.dart';

class CopyMultilineTextButton extends HookConsumerWidget {
  final String memoID;
  final List<MemoRow> memoRows;

  const CopyMultilineTextButton(
      {super.key, required this.memoID, required this.memoRows});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () async {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final text = data?.text;
        if (text != null) {
          final lines = text.split('\n').toSet();
          for (final (index, line) in lines.indexed) {
            if (memoRows.any((memoRow) =>
                memoRow is TextMemoRow && memoRow.message == line)) {
              continue;
            }
            await ref.read(addTextMemoRowProvider).call(
                  memoID: memoID,
                  message: line,
                  order: memoRows.nextOrder + index,
                );
          }
        }
      },
      child: const Icon(Icons.content_paste_go),
    );
  }
}
