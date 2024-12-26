import 'package:flutter/material.dart';

import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/memo_rows/components/link_memo.dart';
import 'package:shoppinglist/features/memo_rows/components/text_memo.dart';

class MemoRowsPageBody extends StatelessWidget {
  final ValueNotifier<List<MemoRow>> memoRows;
  const MemoRowsPageBody({super.key, required this.memoRows});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('買い物リスト'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LinkMemoRowAddPage()));
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
