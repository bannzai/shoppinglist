import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LinkMemoRowCreatePage extends HookConsumerWidget {
  const LinkMemoRowCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textEditingController = useTextEditingController();
    final focusNode = useFocusNode();
    return Scaffold(
      body: Column(
        children: [
          const Text('LinkMemoRowCreatePage'),
          TextField(
            controller: textEditingController,
            focusNode: focusNode,
          ),
        ],
      ),
    );
  }
}
