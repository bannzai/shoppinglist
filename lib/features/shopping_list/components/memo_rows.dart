import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/features/memo_rows/page.dart';
import 'package:shoppinglist/provider/memo_row.dart';

class MemoRows extends HookConsumerWidget {
  final String memoID;

  const MemoRows({super.key, required this.memoID});

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
