import 'package:flutter/material.dart';
import 'package:shoppinglist/components/primitives/app_dialog_shell.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 買い物リスト削除確認ダイアログ。
/// `design_handoff_shopping_list/preview/screens-list-settings.jsx#DeleteConfirmDialog` 準拠。
class DeleteConfirmDialog extends StatelessWidget {
  /// 削除対象のリスト名（dialog body 文に埋め込む）。
  final String shoppingListName;

  /// 削除対象のリスト内アイテム件数（dialog body 文に埋め込む）。
  final int itemCount;

  /// analytics 用パラメータ。
  final String groupID;

  /// analytics 用パラメータ。
  final String shoppingListID;

  /// 「削除」ボタン押下時のコールバック。実削除処理は呼び出し元 (`onDelete`) に委譲する。
  final VoidCallback onConfirm;

  const DeleteConfirmDialog({
    super.key,
    required this.shoppingListName,
    required this.itemCount,
    required this.groupID,
    required this.shoppingListID,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final neutral = context.tokens.neutral;
    return AppDialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'このリストを削除しますか?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: neutral.ink,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '「$shoppingListName」とその中の $itemCount件 のアイテムが削除されます。元に戻せません。',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: neutral.ink2,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppPill(
                    label: 'キャンセル',
                    variant: AppPillVariant.ghost,
                    large: true,
                    expanded: true,
                    onPressed: () {
                      analytics.logEvent(
                        name: 'cancel_delete_list',
                        parameters: {
                          'groupID': groupID,
                          'shoppingListID': shoppingListID,
                        },
                      );
                      Navigator.pop(context);
                    },
                    icon: null),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppPill(
                    label: '削除',
                    variant: AppPillVariant.dangerSolid,
                    large: true,
                    expanded: true,
                    onPressed: () {
                      analytics.logEvent(
                        name: 'tap_confirm_delete_list',
                        parameters: {
                          'groupID': groupID,
                          'shoppingListID': shoppingListID,
                        },
                      );
                      onConfirm();
                    },
                    icon: null),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
