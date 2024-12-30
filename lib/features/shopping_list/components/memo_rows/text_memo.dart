import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/memo_row.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/memo_row.dart';
import 'package:shoppinglist/style/color.dart';

class TextMemo extends HookConsumerWidget {
  final TextMemoRow textMemoRow;
  final List<MemoRow> memoRows;

  const TextMemo({super.key, required this.textMemoRow, required this.memoRows});

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
                      memoRows: memoRows,
                    ),
                  ),
                ),
                if (!isEditing.value) ...[
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
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final TextMemoRow textMemoRow;
  final List<MemoRow> memoRows;
  const TextMemoTextField({
    super.key,
    required this.textEditingController,
    required this.focusNode,
    required this.textMemoRow,
    required this.memoRows,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = useState(textMemoRow.message);

    // ignore: deprecated_member_use KeyboardListenerだとSimulatorでMacのハードウェアキーボードにしか反応しない
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (event.logicalKey == LogicalKeyboardKey.backspace) {
          if (text.value.isEmpty) {
            ref.read(userDatabaseProvider).memoRowsReference(memoID: textMemoRow.memoID).doc(textMemoRow.id).delete();
          }
        }
      },
      child: TextField(
        controller: textEditingController,
        focusNode: focusNode,
        minLines: 1,
        maxLines: 7,
        textInputAction: TextInputAction.next,
        style: TextStyle(
          color: TextColor.black,
          decoration: textMemoRow.status == MemoRowStatus.checked ? TextDecoration.lineThrough : TextDecoration.none,
        ),
        onChanged: (value) {
          text.value = value;
        },
        onSubmitted: (String v) async {
          final value = v.trim();
          final textMemoRowID = textMemoRow.id;
          if (value.isEmpty) {
            if (memoRows.length > 1) {
              ref
                  .read(userDatabaseProvider)
                  .memoRowReference(
                    memoID: textMemoRow.memoID,
                    memoRowID: textMemoRowID,
                  )
                  .delete();
            } else {
              ref
                  .read(userDatabaseProvider)
                  .memoRowReference(
                    memoID: textMemoRow.memoID,
                    memoRowID: textMemoRowID,
                  )
                  .delete();
            }
          } else {
            ref
                .read(userDatabaseProvider)
                .memoRowsReference(
                  memoID: textMemoRow.memoID,
                )
                .doc(textMemoRow.id)
                .set(
                  textMemoRow.copyWith(message: value),
                  SetOptions(merge: true),
                );

            ref.read(addTextMemoRowProvider).call(
                  memoID: textMemoRow.memoID,
                  message: '',
                  order: memoRows.length,
                );
          }
        },
      ),
    );
  }
}
