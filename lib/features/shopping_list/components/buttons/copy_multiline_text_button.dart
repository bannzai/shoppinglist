import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/memo_row.dart';

class CopyMultilineTextButton extends HookConsumerWidget {
  final String memoID;
  final List<MemoRow> memoRows;

  const CopyMultilineTextButton({super.key, required this.memoID, required this.memoRows});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () {
        // TODO: マルチラインテキストをコピー
      },
      child: const Icon(Icons.content_paste_go),
    );
  }
}
