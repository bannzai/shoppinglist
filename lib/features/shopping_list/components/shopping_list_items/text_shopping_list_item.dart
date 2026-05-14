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
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/stdlib/show_modal_bottom_sheet.dart';

/// 買い物リストの 1 行。
/// `design_handoff_shopping_list/source/screens-list.jsx#ItemRow` 相当。
///
/// 構造:
/// - 円形 Checkbox（22px stroke 1.5px、チェック ON で pop アニメ scale 1→1.2→1）
/// - TextField（編集中フォーカス枠なし）
/// - description / imageURL（任意）
/// - 詳細アイコン
///
/// focused 中は左端に 2px の accent ボーダーと accentSoft 0.4 の背景を出す。
/// checked 時はテキスト色 `t.checked` + 取り消し線、Checkbox 内 accent 塗り。
class TextShoppingListItemWidget extends HookConsumerWidget {
  final String groupID;
  final GroupShoppingListItem textShoppingListItem;
  final List<GroupShoppingListItem> shoppingListItems;
  final int? reorderIndex;

  const TextShoppingListItemWidget({
    super.key,
    required this.groupID,
    required this.textShoppingListItem,
    required this.shoppingListItems,
    this.reorderIndex,
  });

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
      void listener() {
        isEditing.value = focusNode.hasFocus;
      }

      focusNode.addListener(listener);
      return () => focusNode.removeListener(listener);
    }, []);

    final currentUserID = ref.watch(currentUserIDProvider)!;
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final isChecked =
        textShoppingListItem.status == GroupShoppingListItemStatus.checked;
    final hasDescription = textShoppingListItem.description != null &&
        textShoppingListItem.description!.isNotEmpty;
    final itemColor = textShoppingListItem.color != null
        ? colorFromHex(textShoppingListItem.color!).withValues(alpha: 0.1)
        : null;
    final focused = isEditing.value;
    final backgroundColor = focused
        ? tokens.accentSoft.withValues(alpha: 0.6)
        : itemColor ??
            (isChecked
                ? neutral.divider2.withValues(alpha: 0.5)
                : Colors.transparent);

    // ReorderableListView のドラッグ移動中に Material が必要
    final content = Material(
      color: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: focused ? tokens.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              label: textShoppingListItem.message,
              child: _CircleCheckbox(
                checked: isChecked,
                color: textShoppingListItem.color != null
                    ? colorFromHex(textShoppingListItem.color!)
                    : tokens.accent,
                onChanged: (_) {
                  analytics
                      .logEvent(name: 'tap_toggle_item_checkbox', parameters: {
                    'groupID': groupID,
                    'shoppingListID': textShoppingListItem.shoppingListID,
                    'itemID': textShoppingListItem.id,
                  });
                  ref
                      .read(
                          toggleShoppingListItemCheckProvider(groupID: groupID))
                      .call(
                        shoppingListID: textShoppingListItem.shoppingListID,
                        item: textShoppingListItem,
                        userID: currentUserID,
                      );
                },
              ),
            ),
            const SizedBox(width: 12),
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
                          color: neutral.ink3,
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
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: textShoppingListItem.imageURL!,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(tokens.accent),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.broken_image, size: 18, color: neutral.ink3),
                  ),
                ),
              ),
            IconButton(
              tooltip: 'アイテム詳細',
              onPressed: () {
                analytics.logEvent(name: 'tap_open_item_detail', parameters: {
                  'groupID': groupID,
                  'itemID': textShoppingListItem.id,
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
                Icons.more_horiz,
                size: 20,
                color: isChecked ? neutral.ink4 : neutral.ink3,
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
      direction: DismissDirection.horizontal,
      // i-8 右スワイプでチェックトグル: `design_handoff_shopping_list/README.md` §8
      background: Container(
        color: neutral.ok,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      // i-7 左スワイプ削除
      secondaryBackground: Container(
        color: neutral.danger,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // 右スワイプ: チェック状態をトグルし、行は残す
          final wasChecked = textShoppingListItem.status ==
              GroupShoppingListItemStatus.checked;
          analytics.logEvent(
            name: 'swipe_toggle_shopping_list_item',
            parameters: {
              'groupShoppingListItemID': textShoppingListItem.id,
              'before': wasChecked.toString(),
            },
          );
          try {
            await ref
                .read(groupDatabaseProvider(groupID: groupID))
                .shoppingListItemsReference(
                  shoppingListID: textShoppingListItem.shoppingListID,
                )
                .doc(textShoppingListItem.id)
                .update({
              GroupShoppingListItemFirestoreKeys.status: wasChecked
                  ? GroupShoppingListItemStatus.unchecked.name
                  : GroupShoppingListItemStatus.checked.name,
            });
          } catch (e, st) {
            debugPrint('アイテムのチェック切替に失敗: $e\n$st');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
          return false;
        }
        // 左スワイプ: 削除
        analytics.logEvent(
          name: 'swipe_delete_shopping_list_item',
          parameters: {
            'groupShoppingListItemID': textShoppingListItem.id,
          },
        );
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
              SnackBar(content: Text(e.toString())),
            );
          }
          return false;
        }
      },
      child: widget,
    );
  }
}

/// 円形チェックボックス。`AppCheckbox` を ItemRow 用にラップしたもの。
/// チェック ON 時の pop アニメ + チェック中はカテゴリ色（指定があれば）で塗る。
class _CircleCheckbox extends StatefulWidget {
  final bool checked;
  final Color color;
  final ValueChanged<bool> onChanged;
  const _CircleCheckbox({
    required this.checked,
    required this.color,
    required this.onChanged,
  });

  @override
  State<_CircleCheckbox> createState() => _CircleCheckboxState();
}

class _CircleCheckboxState extends State<_CircleCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 220),
    vsync: this,
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 60),
  ]).animate(_controller);

  @override
  void didUpdateWidget(covariant _CircleCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.checked && widget.checked) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onChanged(!widget.checked),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.checked ? widget.color : Colors.transparent,
            border: Border.all(
              color: widget.checked ? widget.color : tokens.neutral.ink4,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: widget.checked
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
      ),
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
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final isChecked =
        textShoppingListItem.status == GroupShoppingListItemStatus.checked;

    // KeyboardListener は Mac ハードウェアキーボードにしか反応せず、
    // iOS / Android のソフトキーボードの Backspace を拾えない。
    // 代替 SDK API が安定するまでは RawKeyboardListener を維持する。
    // ignore: deprecated_member_use
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (event.logicalKey == LogicalKeyboardKey.backspace &&
            textEditingController.text.isEmpty) {
          ref
              .read(groupDatabaseProvider(groupID: groupID))
              .shoppingListItemsReference(
                  shoppingListID: textShoppingListItem.shoppingListID)
              .doc(textShoppingListItem.id)
              .delete();
        }
      },
      child: TextField(
        controller: textEditingController,
        focusNode: focusNode,
        minLines: 1,
        maxLines: 7,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isCollapsed: true,
          hintText: 'メモを書く...',
        ),
        cursorColor: tokens.accent,
        cursorWidth: 1.5,
        cursorOpacityAnimates: true,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.16,
          color: isChecked ? neutral.checked : neutral.ink,
          decoration:
              isChecked ? TextDecoration.lineThrough : TextDecoration.none,
          decorationColor: neutral.ink4,
          decorationThickness: 1.2,
        ),
        onSubmitted: (String v) async {
          analytics.logEvent(name: 'submit_item_text', parameters: {
            'groupID': groupID,
            'itemID': textShoppingListItem.id,
          });
          final value = v.trim();
          if (value.isEmpty) {
            // 空のまま確定 → このアイテムを削除（最後の 1 件であっても削除し、
            // 0 件の状態は EmptyShoppingListHint に任せる）
            await ref
                .read(groupDatabaseProvider(groupID: groupID))
                .shoppingListItemReference(
                  shoppingListID: textShoppingListItem.shoppingListID,
                  itemID: textShoppingListItem.id,
                )
                .delete();
            return;
          }
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
        },
      ),
    );
  }
}
