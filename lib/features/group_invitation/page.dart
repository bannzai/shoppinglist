import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_dialog_shell.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/provider/group_invitation.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/invitation_code_validator.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class GroupInvitationAcceptPage extends HookConsumerWidget {
  const GroupInvitationAcceptPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAccepting = useState(false);
    final errorMessage = useState<String?>(null);
    final codeController = useTextEditingController();
    final isValidCode = useState(false);

    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final hasError = errorMessage.value != null;
    final borderColor = hasError
        ? neutral.danger
        : (isValidCode.value ? tokens.accent : neutral.divider);

    return Scaffold(
      backgroundColor: neutral.paper,
      appBar: AppBar(
        title: const Text('招待コードで参加'),
        backgroundColor: neutral.paper,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: tokens.accentSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.group_add, size: 32, color: tokens.accent),
              ),
              const SizedBox(height: 24),
              Text(
                '招待コードを入力してください',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'グループのメンバーから共有された8桁のコードを入力してください',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: neutral.ink2,
                      height: 1.6,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                maxLength: 8,
                style: monoTextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: neutral.ink,
                        letterSpacing: null)
                    .copyWith(letterSpacing: 6),
                decoration: InputDecoration(
                  hintText: 'ABCD3456',
                  hintStyle: monoTextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: neutral.ink4,
                          letterSpacing: null)
                      .copyWith(letterSpacing: 6),
                  counterText: '',
                  filled: true,
                  fillColor: neutral.card,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderColor, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  errorMessage.value = null;
                  isValidCode.value = isValidInvitationCode(value);
                },
              ),
              if (hasError) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage.value!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: neutral.danger),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: AppPill(
                    label: isAccepting.value ? '参加中...' : '参加する',
                    variant: AppPillVariant.accent,
                    large: true,
                    expanded: true,
                    onPressed: isAccepting.value || !isValidCode.value
                        ? null
                        : () async {
                            analytics.logEvent(
                                name: 'tap_join_group', parameters: null);
                            isAccepting.value = true;
                            errorMessage.value = null;
                            // i-invitation-verifying: AppDialogShell ベースで
                            // 「コードを確認中」のオーバレイを表示する。
                            // `design_handoff_shoppinglist/preview/screens-groups.jsx`
                            // 準拠で、サーバー応答中の手触りを伝える。
                            _showVerifyingDialog(context);
                            try {
                              await ref
                                  .read(acceptGroupInvitationProvider)
                                  .call(
                                      invitationCode:
                                          codeController.text.toUpperCase());
                              if (context.mounted) {
                                Navigator.of(context).pop(); // verifying dialog
                              }
                              if (context.mounted) {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              }
                            } catch (e) {
                              errorMessage.value = e.toString();
                              if (context.mounted) {
                                Navigator.of(context).pop(); // verifying dialog
                              }
                            } finally {
                              isAccepting.value = false;
                            }
                          },
                    icon: null),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: AppPill(
                    label: 'キャンセル',
                    variant: AppPillVariant.ghost,
                    large: true,
                    expanded: true,
                    onPressed: isAccepting.value
                        ? null
                        : () {
                            analytics.logEvent(
                                name: 'cancel_join_group', parameters: null);
                            Navigator.pop(context);
                          },
                    icon: null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 招待コード送信中の verifying オーバレイ。
/// `design_handoff_shoppinglist/preview/screens-groups.jsx` の Invitation Verifying
/// 状態を AppDialogShell ベースで実装する。barrierDismissible は false で誤閉じを防ぐ。
void _showVerifyingDialog(BuildContext context) {
  showGeneralDialog<void>(
    context: context,
    barrierLabel: '招待コードを確認中',
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (dialogContext, _, __) {
      final tokens = dialogContext.tokens;
      return AppDialogShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(tokens.accent),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '招待コードを確認中',
              style: Theme.of(dialogContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'サーバー側でグループへの参加を処理しています。',
              textAlign: TextAlign.center,
              style: Theme.of(dialogContext)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.neutral.ink3),
            ),
          ],
        ),
      );
    },
  );
}
