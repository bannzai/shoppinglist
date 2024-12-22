import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/provider/memos.dart';

class MemosPage extends HookConsumerWidget {
  const MemosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memos = ref.watch(memosProvider);

    return Retry(
      retry: () => ref.invalidate(memosProvider),
      child: memos.when(
        data: (memos) => _Body(memos: memos),
        error: (e, st) => RetryPage(exception: e),
        loading: () => const Loading(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final List<Memo> memos;

  const _Body({required this.memos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: memos.length,
      itemBuilder: (context, index) {
        return Text(memos[index].name);
      },
    );
  }
}
