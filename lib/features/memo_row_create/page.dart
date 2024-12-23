import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MemoRowCreatePage extends HookConsumerWidget {
  final String memoID;

  const MemoRowCreatePage({super.key, required this.memoID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('メモを作成')),
    );
  }
}
