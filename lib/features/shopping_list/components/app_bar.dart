import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/toolbar/picker.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/memo_row_filter/page.dart';
import 'package:shoppinglist/features/memo_setting/page.dart';
import 'package:shoppinglist/provider/memo.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

class ShoppingListAppBar extends HookConsumerWidget implements PreferredSizeWidget {
  final ValueNotifier<String> memoID;
  final List<Memo> memos;
  final Memo? memo;
  final ValueNotifier<bool> showChecked;
  final List<MemoRow> memoRows;
  const ShoppingListAppBar({
    super.key,
    required this.memoID,
    required this.memos,
    required this.memo,
    required this.showChecked,
    required this.memoRows,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memo = this.memo;
    final memoAdd = ref.watch(memoAddProvider);
    final memoDelete = ref.watch(memoDeleteProvider);

    return AppBar(
      title: HookBuilder(
        builder: (context) {
          final selectedMemoID = useState<String>(memoID.value);
          return GestureDetector(
            onTap: () {
              selectedMemoID.value = memos.first.id;
              _showPicker(context, selectedMemoID);
            },
            child: Row(
              children: [
                Text(memo?.name ?? ''),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          );
        },
      ),
      actions: [
        if (memo != null)
          IconButton(
            onPressed: () {
              appShowModalBottomSheet(
                context: context,
                builder: (context) {
                  return MemoSettingPage(
                    memoID: memoID.value,
                    memo: memo,
                    onDelete: () {
                      memoDelete(memoID: memoID.value);
                      // pop alert
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
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
    );
  }

  void _showPicker(BuildContext context, ValueNotifier<String> selectedMemoID) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            PickerToolbar(
              done: () {
                Navigator.pop(context);
                memoID.value = selectedMemoID.value;
              },
              cancel: () {
                Navigator.pop(context);
              },
            ),
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
                    selectedMemoID.value = memos[value].id;
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
