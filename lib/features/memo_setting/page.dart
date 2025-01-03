import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/provider/memo.dart';
import 'package:shoppinglist/style/button.dart';
import 'package:shoppinglist/style/color.dart';

class MemoSettingPage extends HookConsumerWidget {
  final String memoID;
  final Memo memo;
  final VoidCallback onDelete;
  const MemoSettingPage({
    super.key,
    required this.memoID,
    required this.memo,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memo = useState(this.memo);
    final textEditingController = useTextEditingController(text: memo.value.name);
    final memoUpdate = ref.watch(memoUpdateProvider);
    final ttlExpiresDateTime = useState(memo.value.ttlExpiresDateTime);
    final ttlExpiresDateTimeValue = ttlExpiresDateTime.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('メモ設定'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('メモ名', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(
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
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('メモの保存期間', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            icon: const Icon(Icons.calendar_month),
                            iconAlignment: IconAlignment.start,
                            label: () {
                              if (ttlExpiresDateTimeValue != null) {
                                return Text(
                                  '${DateFormat.MEd().format(ttlExpiresDateTimeValue)}まで保存されてます',
                                  style: const TextStyle(),
                                );
                              } else {
                                return const Text('有効期限を設定');
                              }
                            }(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        memoUpdate(memoID: memoID, memo: memo.value);
                        Navigator.pop(context);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text('変更を保存'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: elevatedButtonStyle.merge(
                        const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('メモを削除しますか？'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  onDelete();
                                },
                                child: const Text(
                                  '削除',
                                  style: TextStyle(
                                    color: TextColor.danger,
                                  ),
                                ),
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 8),
                          Text('メモを削除'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
