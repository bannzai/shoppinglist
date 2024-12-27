import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/features/shopping_list/components/empty_text_memo.dart';
import 'package:shoppinglist/features/memo_rows/page.dart';
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
    final memoRowsAsync = ref.watch(textMemoRowsProvider(
      memoID: memoID.value,
      showChecked: showChecked.value,
    ));
    final memoRows = useState(memoRowsAsync.valueOrNull ?? []);

    useEffect(() {
      ref.invalidate(textMemoRowsProvider(memoID: memoID.value, showChecked: showChecked.value));
      return null;
    }, [memoID.value, showChecked.value]);

    useEffect(() {
      // 改行等でデータが追加された場合はasyncのデータで更新した後に末日にmemoRowsの内容を追加する
      if (memoRows.value.length > (memoRowsAsync.valueOrNull?.length ?? 0)) {
        final copied = [...memoRows.value];
        memoRows.value = memoRowsAsync.valueOrNull ?? [];
        memoRows.value.add(copied.last);
      } else {
        memoRows.value = memoRowsAsync.valueOrNull ?? [];
      }
      return null;
    }, [memoRowsAsync]);

    return Retry(
      retry: () {
        retry();
        ref.invalidate(textMemoRowsProvider(memoID: memoID.value, showChecked: showChecked.value));
      },
      child: memoRowsAsync.when(
        data: (data) {
          // EmptyTextMemoRowsから登録された時は Databaseは空でmemoRows.value.isNotEmptyとなっている。そのため、条件を追加
          if (showChecked.value && data.isEmpty && memoRows.value.isEmpty) {
            return EmptyTextMemoRows(memoID: memoID.value, memoRows: memoRows);
          } else {
            return __Body(memoID: memoID.value, memoRows: memoRows, showChecked: showChecked);
          }
        },
        error: (e, st) => RetryPage(exception: e),
        loading: () => const Loading(),
      ),
    );
  }
}

class __Body extends StatelessWidget {
  final String memoID;
  final ValueNotifier<bool> showChecked;
  final ValueNotifier<List<MemoRow>> memoRows;
  const __Body({
    super.key,
    required this.memoID,
    required this.showChecked,
    required this.memoRows,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('買い物リスト'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => MemoRowFilterPage(
                  memoID: memoID,
                  showChecked: showChecked,
                ),
              );
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
