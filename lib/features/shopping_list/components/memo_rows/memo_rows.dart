import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/toolbar/picker.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/memo_row_filter/page.dart';
import 'package:shoppinglist/features/memo_setting/page.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/link_memo.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/text_memo.dart';
import 'package:shoppinglist/provider/memo.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

class MemoRows extends HookConsumerWidget {
  final ValueNotifier<List<MemoRow>> memoRows;
  const MemoRows({
    super.key,
    required this.memoRows,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: memoRows.value.length,
      itemBuilder: (context, index) {
        final memoRow = memoRows.value[index];

        return Column(
          children: [
            switch (memoRow) {
              TextMemoRow textMemoRow => TextMemo(key: ValueKey(memoRow.id), textMemoRow: textMemoRow, memoRows: memoRows),
              LinkMemoRow linkMemoRow => LinkMemo(key: ValueKey(memoRow.id), linkMemoRow: linkMemoRow, memoRows: memoRows),
            },
          ],
        );
      },
    );
  }
}
