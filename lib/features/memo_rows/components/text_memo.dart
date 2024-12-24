import 'dart:collection';

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
    final focusNode = useFocusNode();
    final textEditingController = useTextEditingController(text: textMemoRow.message);
    final isEditing = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (textMemoRow.message.isEmpty) {
          focusNode.requestFocus();
        }
      });
      focusNode.addListener(() {
        isEditing.value = focusNode.hasFocus;
      });
      return null;
    }, []);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.scale(
            scale: 1.5,
            child: Checkbox(
              value: textMemoRow.status == MemoRowStatus.checked,
              onChanged: (value) {
                ref
                    .read(userDatabaseProvider)
                    .memoRowsReference(
                      memoID: textMemoRow.memoID,
                    )
                    .doc(textMemoRow.id)
                    .set(
                      textMemoRow.copyWith(
                        status: textMemoRow.status == MemoRowStatus.checked ? MemoRowStatus.unchecked : MemoRowStatus.checked,
                      ),
                      SetOptions(merge: true),
                    );
              },
            ),
          ),
          Expanded(
            child: Row(
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
                if (!isEditing.value) ...[
                  IconButton(
                    onPressed: () {
                      focusNode.requestFocus();
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      ref
                          .read(userDatabaseProvider)
                          .memoRowsReference(
                            memoID: textMemoRow.memoID,
                          )
                          .doc(textMemoRow.id)
                          .delete();
                    },
                    icon: const Icon(Icons.delete),
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
      style: TextStyle(
        color: TextColor.black,
        decoration: textMemoRow.status == MemoRowStatus.checked ? TextDecoration.lineThrough : TextDecoration.none,
      ),
      onSubmitted: (String v) {
        if (v.trim().isNotEmpty) {
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
        }
      },
    );
  }
}
