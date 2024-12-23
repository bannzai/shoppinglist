import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/button/buttons.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/provider/memo.dart';
import 'package:shoppinglist/style/button.dart';

class ShoppingListPage extends HookConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = ref.watch(shoppingListMemoProvider);

    return Retry(
      retry: () => ref.invalidate(shoppingListMemoProvider),
      child: shoppingList.when(
        data: (shoppingList) {
          if (shoppingList == null) {
            return const EmptyShoppingList();
          } else {
            return _Body(shoppingList: shoppingList);
          }
        },
        error: (e, st) => RetryPage(exception: e),
        loading: () => const Loading(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final Memo shoppingList;

  const _Body({required this.shoppingList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shoppingList.name),
      ),
    );
  }
}

class EmptyShoppingList extends StatelessWidget {
  const EmptyShoppingList({super.key});

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {},
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
