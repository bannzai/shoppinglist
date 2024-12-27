import 'package:flutter/material.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/memo_row_filter/page.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/link_memo.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/text_memo.dart';

class MemoRows extends StatelessWidget {
  final String memoID;
  final ValueNotifier<bool> showChecked;
  final ValueNotifier<List<MemoRow>> memoRows;
  const MemoRows({
    super.key,
    required this.memoID,
    required this.showChecked,
    required this.memoRows,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('買い物リスト'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => MemoRowFilterPage(
                  memoID: memoID,
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
