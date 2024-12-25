import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/features/memo_rows/components/empty_link_memo.dart';
import 'package:shoppinglist/features/memo_rows/components/empty_text_memo.dart';
import 'package:shoppinglist/features/memo_rows/page.dart';
import 'package:shoppinglist/provider/memo.dart';
import 'package:shoppinglist/provider/memo_row.dart';

class ECItemsPage extends HookConsumerWidget {
  const ECItemsPage({super.key});

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
    final memoRowsAsync = ref.watch(linkMemoRowsProvider(memoID: memoID.value));

    return Retry(
      retry: () {
        retry();
        ref.invalidate(linkMemoRowsProvider(memoID: memoID.value));
      },
      child: memoRowsAsync.when(
        data: (data) {
          return HookBuilder(builder: (context) {
            final memoRows = useState(data);

            // EmptyLinkMemoRowsから登録された時は Databaseは空でmemoRows.value.isNotEmptyとなっている。そのため、条件を追加
            if (data.isEmpty && memoRows.value.isEmpty) {
              return EmptyLinkMemoRows(memoID: memoID.value, memoRows: memoRows);
            } else {
              return MemoRowsPageBody(memoRows: memoRows);
            }
          });
        },
        error: (e, st) => RetryPage(exception: e),
        loading: () => const Loading(),
      ),
    );
  }
}
