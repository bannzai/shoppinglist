import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/memo_row.dart';
import 'package:shoppinglist/style/color.dart';

class TextMemo extends HookConsumerWidget {
  final TextMemoRow textMemoRow;

  const TextMemo({super.key, required this.textMemoRow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createdDateTime = textMemoRow.createdDateTime;
    final focusNode = useFocusNode();
    final textEditingController = useTextEditingController(text: textMemoRow.message);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (textMemoRow.message.isEmpty) {
          focusNode.requestFocus();
        }
      });
      return null;
    }, []);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        width: double.infinity,
                        child: TextMemoTextField(
                          textEditingController: textEditingController,
                          focusNode: focusNode,
                          textMemoRow: textMemoRow,
                        ),
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                  ],
                ),
                if (createdDateTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '作成日: ${DateFormat('yyyy/MM/dd HH:mm').format(createdDateTime)}',
                    style: const TextStyle(color: Colors.black54, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TextMemoTextField extends HookConsumerWidget {
  const TextMemoTextField({
    super.key,
    required this.textEditingController,
    required this.focusNode,
    required this.textMemoRow,
  });

  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final TextMemoRow textMemoRow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: textEditingController,
      focusNode: focusNode,
      minLines: 1,
      maxLines: 7,
      textInputAction: TextInputAction.done,
      style: const TextStyle(
        color: TextColor.black,
      ),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintStyle: TextStyle(
          color: TextColor.black.withOpacity(.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onSubmitted: (String v) {
        ref
            .read(userDatabaseProvider)
            .memoRowsReference(
              memoID: textMemoRow.memoID,
            )
            .doc(textMemoRow.id)
            .set(
              textMemoRow.copyWith(message: v),
              SetOptions(merge: true),
            );
      },
    );
  }
}
