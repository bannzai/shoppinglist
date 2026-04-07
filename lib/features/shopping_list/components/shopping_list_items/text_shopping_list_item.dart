import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item_detail_bottom_sheet.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

class TextShoppingListItemWidget extends HookConsumerWidget {
  final String groupID;
  final GroupShoppingListItem textShoppingListItem;
  final List<GroupShoppingListItem> shoppingListItems;
  final int? reorderIndex;

  const TextShoppingListItemWidget(
      {super.key,
      required this.groupID,
      required this.textShoppingListItem,
      required this.shoppingListItems,
      this.reorderIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusNode = useFocusNode();
    final textEditingController =
        useTextEditingController(text: textShoppingListItem.message);
    final isEditing = useState(false);

    // 初回ビルド時にテキストが空ならフォーカスを当て、フォーカス状態を監視して編集モードを切り替える
    // このeffectはマウント時に一度だけ実行したいため、依存配列は空にする
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

    final currentUserID = ref.watch(currentUserIDProvider)!;
    final isChecked =
        textShoppingListItem.status == GroupShoppingListItemStatus.checked;
    final colorScheme = Theme.of(context).colorScheme;
    final hasDescription = textShoppingListItem.description != null &&
        textShoppingListItem.description!.isNotEmpty;
    final backgroundColor = textShoppingListItem.color != null
        ? colorFromHex(textShoppingListItem.color!).withValues(alpha: 0.1)
        : isChecked
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.transparent;

    // NOTE: ReorderableListViewのDrag移動中に `No Material widget found` というエラーが出るので、Materialでラップする
    final content = Material(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              label: textShoppingListItem.message,
              child: Transform.scale(
                scale: 1.5,
                child: Checkbox(
                  shape: const CircleBorder(),
                  value: textShoppingListItem.status ==
                      GroupShoppingListItemStatus.checked,
                  onChanged: (value) {
                    analytics.logEvent(
                        name: 'tap_toggle_item_checkbox',
                        parameters: {
                          'groupID': groupID,
                          'shoppingListID': textShoppingListItem.shoppingListID,
                          'itemID': textShoppingListItem.id
                        });
                    ref
                        .read(toggleShoppingListItemCheckProvider(
                            groupID: groupID))
                        .call(
                          shoppingListID: textShoppingListItem.shoppingListID,
                          item: textShoppingListItem,
                          userID: currentUserID,
                        );
                  },
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 44,
                          width: double.infinity,
                          child: TextShoppingListItemTextField(
                            groupID: groupID,
                            textEditingController: textEditingController,
                            focusNode: focusNode,
                            textShoppingListItem: textShoppingListItem,
                            shoppingListItems: shoppingListItems,
                            isEditing: isEditing.value,
                          ),
                        ),
                        if (hasDescription)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              textShoppingListItem.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (textShoppingListItem.imageURL != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: textShoppingListItem.imageURL!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const SizedBox(
                            width: 32,
                            height: 32,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.broken_image, size: 20),
                        ),
                      ),
                    ),
                  IconButton(
                    tooltip: 'アイテム詳細',
                    onPressed: () {
                      analytics.logEvent(
                          name: 'tap_open_item_detail',
                          parameters: {
                            'groupID': groupID,
                            'itemID': textShoppingListItem.id
                          });
                      appShowModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return TextShoppingListItemDetailBottomSheet(
                            groupID: groupID,
                            textShoppingListItem: textShoppingListItem,
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: isChecked
                          ? colorScheme.onSurface.withValues(alpha: 0.35)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final widget = reorderIndex != null
        ? ReorderableDelayedDragStartListener(
            index: reorderIndex!, child: content)
        : content;

    return Dismissible(
      key: ValueKey(textShoppingListItem.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: colorScheme.error,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        try {
          await ref
              .read(groupDatabaseProvider(groupID: groupID))
              .shoppingListItemsReference(
                shoppingListID: textShoppingListItem.shoppingListID,
              )
              .doc(textShoppingListItem.id)
              .delete();
          return true;
        } catch (e, st) {
          debugPrint('アイテムの削除に失敗: $e\n$st');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('アイテムの削除に失敗しました。')),
            );
          }
          return false;
        }
      },
      child: widget,
    );
  }
}

class TextShoppingListItemTextField extends ConsumerWidget {
  final String groupID;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final GroupShoppingListItem textShoppingListItem;
  final List<GroupShoppingListItem> shoppingListItems;
  final bool isEditing;
  const TextShoppingListItemTextField({
    super.key,
    required this.groupID,
    required this.textEditingController,
    required this.focusNode,
    required this.textShoppingListItem,
    required this.shoppingListItems,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserID = ref.watch(currentUserIDProvider)!;
    final addShoppingListItem =
        ref.watch(addShoppingListItemProvider(groupID: groupID));

    // ignore: deprecated_member_use KeyboardListenerだとSimulatorでMacのハードウェアキーボードにしか反応しない
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (event.logicalKey == LogicalKeyboardKey.backspace) {
          if (textEditingController.text.isEmpty) {
            ref
                .read(groupDatabaseProvider(groupID: groupID))
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
        decoration: isEditing
            ? const InputDecoration()
            : const InputDecoration(border: InputBorder.none),
        style: () {
          final isChecked = textShoppingListItem.status ==
              GroupShoppingListItemStatus.checked;
          final colorScheme = Theme.of(context).colorScheme;
          return TextStyle(
            color: isChecked
                ? colorScheme.onSurface.withValues(alpha: 0.35)
                : colorScheme.onSurface,
            decoration:
                isChecked ? TextDecoration.lineThrough : TextDecoration.none,
            decorationColor:
                isChecked ? colorScheme.onSurface.withValues(alpha: 0.4) : null,
          );
        }(),
        onSubmitted: (String v) async {
          analytics.logEvent(name: 'submit_item_text', parameters: {
            'groupID': groupID,
            'itemID': textShoppingListItem.id
          });
          final value = v.trim();
          final itemID = textShoppingListItem.id;
          if (value.isEmpty) {
            if (shoppingListItems.length > 1) {
              ref
                  .read(groupDatabaseProvider(groupID: groupID))
                  .shoppingListItemReference(
                    shoppingListID: textShoppingListItem.shoppingListID,
                    itemID: itemID,
                  )
                  .delete();
            } else {
              ref
                  .read(groupDatabaseProvider(groupID: groupID))
                  .shoppingListItemReference(
                    shoppingListID: textShoppingListItem.shoppingListID,
                    itemID: itemID,
                  )
                  .delete();
            }
          } else {
            ref.read(updateShoppingListItemProvider(groupID: groupID)).call(
                  shoppingListID: textShoppingListItem.shoppingListID,
                  item: textShoppingListItem.copyWith(message: value),
                  editedByUserID: currentUserID,
                );

            addShoppingListItem.call(
              shoppingListID: textShoppingListItem.shoppingListID,
              userID: currentUserID,
              message: '',
              order: shoppingListItems.nextOrder,
              description: null,
              color: null,
            );
          }
        },
      ),
    );
  }
}
