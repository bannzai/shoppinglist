import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/memo_rows/components/link_memo.dart';
import 'package:shoppinglist/features/memo_rows/components/text_memo.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/memo_row.dart';
import 'package:shoppinglist/style/button.dart';

class MemoRowsPage extends HookConsumerWidget {
  final String memoID;

  const MemoRowsPage({super.key, required this.memoID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoRows = ref.watch(textMemoRowsProvider(memoID: memoID));

    return Retry(
      retry: () => ref.invalidate(textMemoRowsProvider(memoID: memoID)),
      child: memoRows.when(
        data: (memoRows) => MemoRowsPageBody(memoRows: memoRows),
        error: (e, st) => RetryPage(exception: e),
        loading: () => const Loading(),
      ),
    );
  }
}

class MemoRowsPageBody extends StatelessWidget {
  final List<MemoRow> memoRows;
  const MemoRowsPageBody({super.key, required this.memoRows});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: memoRows.length,
      itemBuilder: (context, index) {
        final memoRow = memoRows[index];
        switch (memoRow) {
          case TextMemoRow textMemoRow:
            return TextMemo(textMemoRow: textMemoRow);
          case LinkMemoRow linkMemoRow:
            return LinkMemo(linkMemoRow: linkMemoRow);
        }
      },
    );
  }
}

class EmptyMemoRows extends HookConsumerWidget {
  final String memoID;
  const EmptyMemoRows({super.key, required this.memoID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Column(
            children: [
              const Center(
                child: Text('買い物メモが空です'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: outlinedButtonStyle,
                child: const Text('最初の買い物メモを作成しましょう！'),
                onPressed: () {
                  ref.read(userDatabaseProvider).memoRowsReference(memoID: memoID).add(const MemoRow.text(message: ''));
                },
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
