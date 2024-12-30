import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/provider/memo_row.dart';
import 'package:shoppinglist/style/button.dart';

class EmptyTextMemoRows extends HookConsumerWidget {
  final String memoID;
  final List<MemoRow> memoRows;
  const EmptyTextMemoRows({super.key, required this.memoID, required this.memoRows});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
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
                  ref.read(addTextMemoRowProvider).call(
                        memoID: memoID,
                        message: '',
                        order: memoRows.nextOrder,
                      );
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
