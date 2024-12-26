import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MemoRowFilterPage extends HookConsumerWidget {
  final String memoID;
  final ValueNotifier<bool> showChecked;
  final ValueNotifier<bool> showDeleted;

  const MemoRowFilterPage({super.key, required this.memoID, required this.showChecked, required this.showDeleted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showChecked = useState(this.showChecked.value);
    final showDeleted = useState(this.showDeleted.value);
    return Scaffold(
      appBar: AppBar(
        title: const Text('メモフィルター'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                SwitchListTile(
                  title: const Text('チェック済みを表示する'),
                  value: showChecked.value,
                  onChanged: (value) {
                    showChecked.value = value;
                  },
                ),
                SwitchListTile(
                  title: const Text('削除済みを表示する'),
                  subtitle: const Text('削除済みの内容も30日間保存されます'),
                  value: showDeleted.value,
                  onChanged: (value) {
                    showDeleted.value = value;
                  },
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              this.showChecked.value = showChecked.value;
              this.showDeleted.value = showDeleted.value;
            },
            child: const Text('適用'),
          ),
        ],
      ),
    );
  }
}
