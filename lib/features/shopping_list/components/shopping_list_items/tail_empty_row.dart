import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/frame/app_checkbox.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/blinking_caret.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 買い物リストの末尾に常設する「ItemRow (isEmpty + focused)」相当の行。
/// `design_handoff_shopping_list/source/screens-list.jsx#ShoppingListFlat` 末尾の連続入力 UX を支える。
/// タップで空文字メッセージの新規アイテムを 1 件追加し、`TextShoppingListItemWidget.useEffect`
/// が新規行の TextField に自動フォーカスを移すことで「return → 次の行」フローと一致する。
class TailEmptyRow extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final int nextOrder;

  const TailEmptyRow({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.nextOrder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final currentUserID = ref.watch(currentUserIDProvider);
    return InkWell(
      onTap: currentUserID == null
          ? null
          : () async {
              analytics.logEvent(
                  name: 'tap_tail_empty_row',
                  parameters: {
                    'groupID': groupID,
                    'shoppingListID': shoppingListID,
                  });
              await ref
                  .read(addShoppingListItemProvider(groupID: groupID))
                  .call(
                    shoppingListID: shoppingListID,
                    userID: currentUserID,
                    message: '',
                    order: nextOrder,
                    description: null,
                    color: null,
                  );
            },
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          // screens-list.jsx#ItemRow(isEmpty + focused): accentSoft 0x40 (= 64/255 ≒ 0.251) 背景 + 左 2px accent。
          color: tokens.accentSoft.withValues(alpha: 0x40 / 0xFF),
          border: Border(left: BorderSide(color: tokens.accent, width: 2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppCheckbox(checked: false, onChanged: null),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'アイテムを入力…',
                style: TextStyle(fontSize: 16, color: tokens.neutral.ink3),
              ),
            ),
            BlinkingCaret(color: tokens.accent),
          ],
        ),
      ),
    );
  }
}
