import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/memo_row_filter/page.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/link_memo.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/text_memo.dart';
import 'package:shoppinglist/provider/memo.dart';

class MemoRows extends HookConsumerWidget {
  final ValueNotifier<String> memoID;
  final ValueNotifier<bool> showChecked;
  final ValueNotifier<List<MemoRow>> memoRows;
  const MemoRows({
    super.key,
    required this.memoID,
    required this.showChecked,
    required this.memoRows,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoAdd = ref.watch(memoAddProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('買い物リスト'),
        actions: [
          IconButton(
            onPressed: () async {
              final memo = await memoAdd();
              memoID.value = memo.id;
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => MemoRowFilterPage(
                  memoID: memoID.value,
                  showChecked: showChecked,
                ),
              );
            },
            icon: const Icon(Icons.filter_1_outlined),
          ),
        ],
      ),
      body: ListView.builder(
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
      ),
    );
  }
}
