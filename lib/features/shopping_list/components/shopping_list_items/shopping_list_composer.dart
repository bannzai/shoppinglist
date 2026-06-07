import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_composer_state.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 買い物リストの唯一のテキスト入力欄(永続コンポーザー)。
///
/// スクロール領域の外(直下)に常設し、アイテムの「追加」と「編集」の両方をここで行う。
/// フィールドが常に 1 つだけ存在するため、行から行へのフォーカス移譲(H2)が発生しない。
/// さらに Enter は [TextInputAction.newline] で改行を挿入させ onChanged で検知して確定する。
/// これにより EditableText.performAction を経由せず、`_scheduleRestartConnection`
/// (接続 close→reopen = キーボードリセット, flutter/flutter#84240) も起きない(H1 回避)。
/// 結果として連続追加・編集の間ソフトキーボードが一度も閉じない。
///
/// 状態:
/// - [editingShoppingListItemIDProvider] が非null ならそのアイテムを編集中(テキスト読込)。
///   null なら新規追加モード。
/// - [composerFocusRequestProvider] の変化で外部(FAB 等)からフォーカス要求を受ける。
class ShoppingListComposer extends HookConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;

  const ShoppingListComposer({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    final currentUserID = ref.watch(currentUserIDProvider)!;
    final editingID = ref.watch(editingShoppingListItemIDProvider);
    final focusRequest = ref.watch(composerFocusRequestProvider);

    // 入力内容を確定する。追加モード(targetID==null)なら add、編集モードなら update。
    // 編集モードで空文字なら delete(現状の「空行 delete」を踏襲)。追加モードで空は無視。
    // DB 操作 Provider はコールバック内で ref.read する(規約: 操作 Provider は read)。
    void commit({required String rawText, required String? targetID}) {
      final text = rawText.trim();
      if (targetID == null) {
        if (text.isEmpty) {
          return;
        }
        analytics.logEvent(name: 'composer_add_item', parameters: {
          'groupID': groupID,
          'shoppingListID': shoppingListID,
        });
        ref.read(addShoppingListItemProvider(groupID: groupID)).call(
              shoppingListID: shoppingListID,
              userID: currentUserID,
              message: text,
              order: shoppingListItems.nextOrder,
              description: null,
              color: null,
            );
        return;
      }
      final item = shoppingListItems.firstWhereOrNull((e) => e.id == targetID);
      if (item == null) {
        return;
      }
      if (text.isEmpty) {
        analytics.logEvent(name: 'composer_delete_empty_item', parameters: {
          'groupID': groupID,
          'itemID': targetID,
        });
        ref.read(deleteShoppingListItemProvider(groupID: groupID)).call(
              shoppingListID: shoppingListID,
              itemID: targetID,
            );
        return;
      }
      analytics.logEvent(name: 'composer_edit_item', parameters: {
        'groupID': groupID,
        'itemID': targetID,
      });
      ref.read(updateShoppingListItemProvider(groupID: groupID)).call(
            shoppingListID: shoppingListID,
            item: item.copyWith(message: text),
            editedByUserID: currentUserID,
          );
    }

    // 編集対象が変わったら対象アイテムのテキストを読み込みフォーカスする。
    // null(追加モード)への変化は確定/clear 側で controller を空にするのでここでは触らない。
    // 依存配列は editingID のみ = 編集対象の切替イベントだけに反応する。
    useEffect(() {
      if (editingID != null) {
        final item =
            shoppingListItems.firstWhereOrNull((e) => e.id == editingID);
        controller.text = item?.message ?? '';
        controller.selection =
            TextSelection.collapsed(offset: controller.text.length);
        WidgetsBinding.instance
            .addPostFrameCallback((_) => focusNode.requestFocus());
      }
      return null;
    }, [editingID]);

    // 外部(FAB 等)からのフォーカス要求。カウンタが増えたらフォーカスを当てる。
    // 初期値 0 の時は何もしない。依存配列は focusRequest のみ。
    useEffect(() {
      if (focusRequest > 0) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => focusNode.requestFocus());
      }
      return null;
    }, [focusRequest]);

    // フォーカス喪失(キーボードが離れた)時に内容を反映する。
    // Enter 確定時は事前に controller を空にしてから clear するため、ここでの二重保存は
    // 空文字となり無害化される。確定対象IDは ref.read で最新を読む。
    // 依存配列は空 = リスナを一度だけ張る。
    useEffect(() {
      void onFocusChange() {
        if (!focusNode.hasFocus) {
          commit(
            rawText: controller.text,
            targetID: ref.read(editingShoppingListItemIDProvider),
          );
          controller.clear();
          ref.read(editingShoppingListItemIDProvider.notifier).clear();
        }
      }

      focusNode.addListener(onFocusChange);
      return () => focusNode.removeListener(onFocusChange);
    }, []);

    final isEditing = editingID != null;
    return Material(
      color: neutral.surface2,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: neutral.divider2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isEditing ? Icons.edit_outlined : Icons.add,
                size: 22,
                color: tokens.accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 5,
                  // Enter で改行を挿入させ onChanged で検知する(performAction 非経由 = H1 回避)。
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: isEditing ? 'アイテムを編集...' : 'アイテムを追加...',
                  ),
                  cursorColor: tokens.accent,
                  cursorWidth: 1.5,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.16,
                        color: neutral.ink,
                      ),
                  onChanged: (value) {
                    if (!value.contains('\n')) {
                      return;
                    }
                    final text = value.replaceAll('\n', '');
                    final targetID =
                        ref.read(editingShoppingListItemIDProvider);
                    // 確定 → 空に戻す → 追加モードへ。フォーカスは保持(キーボード維持)。
                    controller.value = const TextEditingValue(text: '');
                    commit(rawText: text, targetID: targetID);
                    ref
                        .read(editingShoppingListItemIDProvider.notifier)
                        .clear();
                    focusNode.requestFocus();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
