import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/style/button.dart';

class EmptyLinkMemoRows extends HookConsumerWidget {
  final String memoID;
  final ValueNotifier<List<MemoRow>> memoRows;
  const EmptyLinkMemoRows({super.key, required this.memoID, required this.memoRows});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Column(
            children: [
              const Center(
                child: Text('ECサイトメモが空です'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: outlinedButtonStyle,
                child: const Text('最初のECサイトメモを作成しましょう！'),
                onPressed: () {
                  memoRows.value = [...memoRows.value, MemoRow.link(memoID: memoID, url: '', createdDateTime: DateTime.now())];
                  // ref.read(userDatabaseProvider).memoRowsReference(memoID: memoID).add(const MemoRow.text(message: ''));
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
