import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/provider/memo.dart';

class MemoSettingPage extends HookConsumerWidget {
  final String memoID;
  final Memo memo;
  const MemoSettingPage({super.key, required this.memoID, required this.memo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memo = useState(this.memo);
    final textEditingController = useTextEditingController(text: memo.value.name);
    final memoDelete = ref.watch(memoDeleteProvider);
    final memoUpdate = ref.watch(memoUpdateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('メモ設定'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('メモを削除しますか？'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        memoDelete(memoID: memoID);
                        Navigator.pop(context);
                      },
                      child: const Text('削除'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('キャンセル'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete),
          ),
          IconButton(
            onPressed: () {
              memoUpdate(memoID: memoID, memo: memo.value);
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          Column(
            children: [
              const Text('メモ名', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 88,
                width: double.infinity,
                child: TextField(
                  controller: textEditingController,
                  onChanged: (value) {
                    memo.value = memo.value.copyWith(name: value);
                  },
                  onSubmitted: (value) {
                    memo.value = memo.value.copyWith(name: value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
