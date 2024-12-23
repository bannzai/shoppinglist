import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/provider/memo.dart';
import 'package:shoppinglist/style/button.dart';

class MemosPage extends HookConsumerWidget {
  const MemosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memos = ref.watch(memosProvider);

    return Retry(
      retry: () => ref.invalidate(shoppingListMemoProvider),
      child: memos.when(
        data: (memos) {
          if (memos.isEmpty) {
            return const EmptyShoppingList();
          } else {
            return _Body(shoppingListMemoRows: memos);
          }
        },
        error: (e, st) => RetryPage(exception: e),
        loading: () => const Loading(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final List<MemoRow> shoppingListMemoRows;

  const _Body({required this.shoppingListMemoRows});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('買い物メモ'),
      ),
    );
  }
}

class EmptyShoppingList extends HookConsumerWidget {
  const EmptyShoppingList({super.key});

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
