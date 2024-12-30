import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/features/shopping_list/components/app_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/empty_text_memo.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/memo_rows.dart';
import 'package:shoppinglist/provider/memo.dart';
import 'package:shoppinglist/provider/memo_row.dart';

class ShoppingListPage extends HookConsumerWidget {
  const ShoppingListPage({super.key});

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

class _Body extends HookConsumerWidget {
  final List<Memo> memos;

  const _Body({required this.memos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoID = useState(memos.first.id);
    final retry = Retry.of(context).retry;
    final showChecked = useState(true);
    final memoRows = ref.watch(textMemoRowsProvider(
      memoID: memoID.value,
      showChecked: showChecked.value,
    ));

    return Retry(
      retry: () {
        retry();
        ref.invalidate(textMemoRowsProvider(memoID: memoID.value, showChecked: showChecked.value));
      },
      child: Scaffold(
        appBar: ShoppingListAppBar(
          memoID: memoID,
          memos: memos,
          showChecked: showChecked,
          memoRows: memoRows.asData?.value ?? [],
        ),
        body: memoRows.when(
          data: (memoRows) {
            if (showChecked.value && memoRows.isEmpty) {
              return EmptyTextMemoRows(memoID: memoID.value, memoRows: memoRows);
            } else {
              return MemoRows(memoRows: memoRows);
            }
          },
          error: (e, st) => RetryPage(exception: e),
          loading: () => const Loading(),
        ),
      ),
    );
  }
}
