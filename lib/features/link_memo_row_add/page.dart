import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/alert.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/style/color.dart';

class LinkMemoRowAddPage extends HookConsumerWidget {
  final String memoID;
  final LinkMemoRow linkMemoRow;
  const LinkMemoRowAddPage({
    super.key,
    required this.memoID,
    required this.linkMemoRow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textEditingController = useTextEditingController();
    final focusNode = useFocusNode();
    final url = useState(linkMemoRow.url);
    final isEditing = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (linkMemoRow.url.isEmpty) {
          focusNode.requestFocus();
        }
      });
      focusNode.addListener(() {
        isEditing.value = focusNode.hasFocus;
      });
      return null;
    }, []);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('ECサイトメモを作成しましょう！', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('URL:'),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: 'https://www.example.com',
                      hintStyle: TextStyle(color: TextColor.lightGray),
                    ),
                    onChanged: (value) {
                      url.value = value;
                    },
                    onSubmitted: (v) async {
                      final value = v.trim();
                      if (value.isEmpty) {
                        return;
                      }
                      if (!value.startsWith('https://') && !value.startsWith('http://')) {
                        return;
                      }
                      try {
                        await ref.read(userDatabaseProvider).memoRowsReference(memoID: memoID).add(linkMemoRow.copyWith(url: value));
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showErrorAlert(context, e);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
