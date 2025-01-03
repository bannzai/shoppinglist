import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/admob/banner.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/features/shopping_list/components/app_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/buttons/copy_multiline_text_button.dart';
import 'package:shoppinglist/features/shopping_list/components/buttons/image_picker_button.dart';
import 'package:shoppinglist/features/shopping_list/components/buttons/memo_row_add_button.dart';
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
    final memoRowsAsync = ref.watch(textMemoRowsProvider(
      memoID: memoID.value,
      showChecked: showChecked.value,
    ));
    final memo = memos.firstWhereOrNull((memo) => memo.id == memoID.value);

    // 削除した時にmemoIDを入れ替える
    useEffect(() {
      if (!memos.map((e) => e.id).contains(memoID.value)) {
        final firstMemoID = memos.firstOrNull?.id;
        if (firstMemoID != null) {
          memoID.value = firstMemoID;
        }
      }
      return null;
    }, [memos.length]);

    // memoIDが変わったらmemosProviderから更新してWidgetツリーを更新
    useEffect(() {
      ref.invalidate(memosProvider);
      return null;
    }, [memoID.value]);

    return Retry(
      retry: () {
        retry();
        ref.invalidate(textMemoRowsProvider(memoID: memoID.value, showChecked: showChecked.value));
      },
      child: Scaffold(
        appBar: ShoppingListAppBar(
          memoID: memoID,
          memos: memos,
          memo: memo,
          showChecked: showChecked,
          memoRows: memoRowsAsync.asData?.value ?? [],
        ),
        body: SafeArea(
          child: memoRowsAsync.when(
            data: (memoRows) {
              if (showChecked.value && memoRows.isEmpty) {
                return EmptyTextMemoRows(memoID: memoID.value, memoRows: memoRows);
              } else {
                return Column(
                  children: [
                    Expanded(child: MemoRows(memoID: memoID.value, memoRows: memoRows, memoRowsAsync: memoRowsAsync)),
                    const AdMobBanner(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: MemoRowAddButton(memoID: memoID.value, memoRows: memoRows),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ImagePickerButton(memoID: memoID.value, memoRows: memoRows),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CopyMultilineTextButton(memoID: memoID.value, memoRows: memoRows),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
            error: (e, st) => RetryPage(exception: e),
            loading: () => const Loading(),
          ),
        ),
      ),
    );
  }
}
