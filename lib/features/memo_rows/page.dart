import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/provider/memo_rows.dart';

class MemoRowsPage extends HookConsumerWidget {
  final String memoID;
  const MemoRowsPage({super.key, required this.memoID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoRows = ref.watch(memoRowsProvider(memoID: memoID));

    return Retry(
      retry: () => ref.invalidate(memoRowsProvider(memoID: memoID)),
      child: memoRows.when(
        data: (memoRows) => _Body(memoRows: memoRows),
        error: (e, st) => RetryPage(exception: e),
        loading: () => const Loading(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final List<MemoRow> memoRows;
  const _Body({required this.memoRows});

  @override
  Widget build(BuildContext context) {
    return const Text('メモ行');
  }
}
