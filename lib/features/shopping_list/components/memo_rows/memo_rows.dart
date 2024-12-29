import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/memo_row_filter/page.dart';
import 'package:shoppinglist/features/memo_setting/page.dart';
import 'package:shoppinglist/features/resolver/app.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/link_memo.dart';
import 'package:shoppinglist/features/shopping_list/components/memo_rows/text_memo.dart';
import 'package:shoppinglist/provider/memo.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

class MemoRows extends HookConsumerWidget {
  final ValueNotifier<String> memoID;
  final List<Memo> memos;
  final ValueNotifier<bool> showChecked;
  final ValueNotifier<List<MemoRow>> memoRows;
  const MemoRows({
    super.key,
    required this.memoID,
    required this.memos,
    required this.showChecked,
    required this.memoRows,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memo = memos.firstWhere((memo) => memo.id == memoID.value);
    final memoAdd = ref.watch(memoAddProvider);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _showPicker(context);
          },
          child: Row(
            children: [
              Text(memo.name),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              appShowModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(
                    height: 800,
                    child: MemoSettingPage(
                      memoID: memoID.value,
                      memo: memo,
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () async {
              final memo = await memoAdd();
              memoID.value = memo.id;
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              appShowModalBottomSheet(
                context: context,
                builder: (context) {
                  return MemoRowFilterPage(
                    memoID: memoID.value,
                    showChecked: showChecked,
                  );
                },
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

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 200,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: CupertinoPicker(
                  itemExtent: 40,
                  children: memos.map((memo) => Text(memo.name)).toList(),
                  onSelectedItemChanged: (int value) {
                    memoID.value = memos[value].id;
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
