import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/color.dart';

class TextShoppingListItemWidget extends HookConsumerWidget {
  final TextGroupShoppingListItem textShoppingListItem;
  final List<GroupShoppingListItem> shoppingListItems;

  const TextShoppingListItemWidget(
      {super.key,
      required this.textShoppingListItem,
      required this.shoppingListItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusNode = useFocusNode();
    final textEditingController =
        useTextEditingController(text: textShoppingListItem.message);
    final isEditing = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (textShoppingListItem.message.isEmpty) {
          focusNode.requestFocus();
        }
      });
      focusNode.addListener(() {
        isEditing.value = focusNode.hasFocus;
      });
      return null;
    }, []);

    // NOTE: ReorderableListViewのDrag移動中に `No Material widget found` というエラーが出るので、Materialでラップする
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 1.5,
              child: Checkbox(
                value: textShoppingListItem.status ==
                    GroupShoppingListItemStatus.checked,
                onChanged: (value) {
                  ref
                      .read(groupDatabaseProvider)
                      .shoppingListItemsReference(
                        shoppingListID: textShoppingListItem.shoppingListID,
                      )
                      .doc(textShoppingListItem.id)
                      .set(
                        textShoppingListItem.copyWith(
                          status: textShoppingListItem.status ==
                                  GroupShoppingListItemStatus.checked
                              ? GroupShoppingListItemStatus.unchecked
                              : GroupShoppingListItemStatus.checked,
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
                      child: TextShoppingListItemTextField(
                        textEditingController: textEditingController,
                        focusNode: focusNode,
                        textShoppingListItem: textShoppingListItem,
                        shoppingListItems: shoppingListItems,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref
                          .read(groupDatabaseProvider)
                          .shoppingListItemsReference(
                            shoppingListID: textShoppingListItem.shoppingListID,
                          )
                          .doc(textShoppingListItem.id)
                          .delete();
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  ReorderableDragStartListener(
                    index: textShoppingListItem.order,
                    child: const Icon(Icons.drag_handle),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextShoppingListItemTextField extends HookConsumerWidget {
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final TextGroupShoppingListItem textShoppingListItem;
  final List<GroupShoppingListItem> shoppingListItems;
  const TextShoppingListItemTextField({
    super.key,
    required this.textEditingController,
    required this.focusNode,
    required this.textShoppingListItem,
    required this.shoppingListItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = useState(textShoppingListItem.message);

    // ignore: deprecated_member_use KeyboardListenerだとSimulatorでMacのハードウェアキーボードにしか反応しない
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (event.logicalKey == LogicalKeyboardKey.backspace) {
          if (text.value.isEmpty) {
            ref
                .read(groupDatabaseProvider)
                .shoppingListItemsReference(
                    shoppingListID: textShoppingListItem.shoppingListID)
                .doc(textShoppingListItem.id)
                .delete();
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
          decoration:
              textShoppingListItem.status == GroupShoppingListItemStatus.checked
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
        ),
        onChanged: (value) {
          text.value = value;
        },
        onSubmitted: (String v) async {
          final value = v.trim();
          final itemID = textShoppingListItem.id;
          if (value.isEmpty) {
            if (shoppingListItems.length > 1) {
              ref
                  .read(groupDatabaseProvider)
                  .shoppingListItemReference(
                    shoppingListID: textShoppingListItem.shoppingListID,
                    itemID: itemID,
                  )
                  .delete();
            } else {
              ref
                  .read(groupDatabaseProvider)
                  .shoppingListItemReference(
                    shoppingListID: textShoppingListItem.shoppingListID,
                    itemID: itemID,
                  )
                  .delete();
            }
          } else {
            ref
                .read(groupDatabaseProvider)
                .shoppingListItemsReference(
                  shoppingListID: textShoppingListItem.shoppingListID,
                )
                .doc(textShoppingListItem.id)
                .set(
                  textShoppingListItem.copyWith(message: value),
                  SetOptions(merge: true),
                );

            ref.read(addTextShoppingListItemProvider).call(
                  shoppingListID: textShoppingListItem.shoppingListID,
                  message: '',
                  order: shoppingListItems.nextOrder,
                );
          }
        },
      ),
    );
  }
}
