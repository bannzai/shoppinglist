import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MemoRowFilterPage extends HookConsumerWidget {
  final String memoID;
  final ValueNotifier<bool> showChecked;

  const MemoRowFilterPage({
    super.key,
    required this.memoID,
    required this.showChecked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showChecked = useState(this.showChecked.value);
    return Scaffold(
      appBar: AppBar(
        title: const Text('メモフィルター'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 32.0),
        child: Column(
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
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  this.showChecked.value = showChecked.value;
                },
                child: const Text('適用'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
