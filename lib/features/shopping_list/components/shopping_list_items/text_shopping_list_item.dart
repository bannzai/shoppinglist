import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/frame/app_checkbox.dart';
import 'package:shoppinglist/components/frame/stripe_placeholder.dart';
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
/// focused 中は左端に 2px の accent ボーダーと accentSoft の透明度 0x60 (≒ 0.376) 背景を出す。
/// checked 時はテキスト色 `t.checked` + 取り消し線、Checkbox 内はカテゴリ色（指定があれば）で塗る。
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
    final categoryColor = textShoppingListItem.color != null
        ? colorFromHex(textShoppingListItem.color!)
        : null;
    final focused = isEditing.value;
    // screens-list.jsx#ItemRow: focused 時のみ accentSoft + 16進透明度 0x60 (= 96/255 ≒ 0.376)。
    // 非 focused は transparent。カテゴリ色や checked の薄塗りはしない（仕様外）。
    final backgroundColor = focused
        ? tokens.accentSoft.withValues(alpha: 0x60 / 0xFF)
        : Colors.transparent;

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
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 最初の行のテキストと Checkbox の上端を揃える微調整 (frame.jsx#ItemRow paddingTop:1)。
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Semantics(
                label: textShoppingListItem.message,
                child: AppCheckbox(
                  checked: isChecked,
                  size: 22,
                  color: categoryColor,
                  onChanged: (_) {
                    analytics.logEvent(
                        name: 'tap_toggle_item_checkbox',
                        parameters: {
                          'groupID': groupID,
                          'shoppingListID':
                              textShoppingListItem.shoppingListID,
                          'itemID': textShoppingListItem.id,
                        });
                    ref
                        .read(toggleShoppingListItemCheckProvider(
                            groupID: groupID))
                        .call(
                          shoppingListID:
                              textShoppingListItem.shoppingListID,
                          item: textShoppingListItem,
                          userID: currentUserID,
                        );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextShoppingListItemTextField(
                    groupID: groupID,
                    textEditingController: textEditingController,
                    focusNode: focusNode,
                    textShoppingListItem: textShoppingListItem,
                    shoppingListItems: shoppingListItems,
                    isEditing: isEditing.value,
                  ),
                  if (hasDescription)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Opacity(
                        opacity: isChecked ? 0.5 : 1.0,
                        child: Text(
                          textShoppingListItem.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: neutral.ink3,
                            height: 1.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // サムネ: 40×40, radius 10, カテゴリ色 0x30 (≒ 0.188) 背景 + divider border + stripe placeholder。
            if (textShoppingListItem.imageURL != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: categoryColor != null
                        ? categoryColor.withValues(alpha: 0x30 / 0xFF)
                        : neutral.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: neutral.divider, width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: StripePlaceholderPainter(color: neutral.ink),
                      ),
                      CachedNetworkImage(
                        imageUrl: textShoppingListItem.imageURL!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox.shrink(),
                        errorWidget: (context, url, error) => Icon(
                            Icons.broken_image,
                            size: 18,
                            color: neutral.ink3),
                      ),
                    ],
                  ),
                ),
              ),
            // more icon: size 16 / padding 4 / InkResponse (IconButton の自動 48dp tap-target を避ける)。
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: InkResponse(
                onTap: () {
                  analytics.logEvent(
                      name: 'tap_open_item_detail',
                      parameters: {
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
                radius: 16,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz,
                    size: 16,
                    color: isChecked ? neutral.ink4 : neutral.ink3,
                    semanticLabel: 'アイテム詳細',
                  ),
                ),
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
        color: neutral.danger,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.delete, color: Colors.white),
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
        // styles.css#.fake-caret の 1.5px キャレットに合わせる。
        cursorWidth: 1.5,
        cursorRadius: const Radius.circular(0.75),
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
