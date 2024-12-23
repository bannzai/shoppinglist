import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/features/memo_rows/page.dart';
import 'package:shoppinglist/provider/memo.dart';
import 'package:shoppinglist/provider/memo_row.dart';
import 'package:shoppinglist/style/button.dart';

class MemosPage extends HookConsumerWidget {
  const MemosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memos = ref.watch(memosProvider);

    return Retry(
      retry: () => ref.invalidate(memosProvider),
      child: memos.when(
        data: (memos) {
          if (memos.isEmpty) {
            return const EmptyMemos();
          } else {
            return _Body(memos: memos);
          }
        },
        error: (e, st) => RetryPage(exception: e),
        loading: () => const Loading(),
      ),
    );
  }
}

class _Body extends HookConsumerWidget {
  final List<Memo> memos;

  const _Body({required this.memos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoID = useState(memos.first.id);
    final retry = Retry.of(context).retry;
    final memoRows = ref.watch(memoRowsProvider(memoID: memoID.value));

    return Retry(
      retry: () {
        retry();
        ref.invalidate(memosProvider);
      },
      child: memoRows.when(
        data: (memoRows) => MemoRowsPageBody(memoRows: memoRows),
        error: (e, st) => RetryPage(exception: e),
        loading: () => const Loading(),
      ),
    );
  }
}

class EmptyMemos extends HookConsumerWidget {
  const EmptyMemos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('買い物メモ'),
      ),
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
                  // ref.read(userDatabaseProvider).shoppingMemoRowsReference().add(MemoRow.text(message: message)
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
