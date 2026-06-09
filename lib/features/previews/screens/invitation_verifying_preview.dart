import 'package:flutter/material.dart';
import 'package:shoppinglist/components/primitives/app_dialog_shell.dart';
import 'package:shoppinglist/style/tokens.dart';

/// preview 用に GroupInvitation の verifying 状態を即時表示する pseudo page。
class GroupInvitationVerifyingPreview extends StatefulWidget {
  const GroupInvitationVerifyingPreview({super.key});

  @override
  State<GroupInvitationVerifyingPreview> createState() =>
      _GroupInvitationVerifyingPreviewState();
}

class _GroupInvitationVerifyingPreviewState
    extends State<GroupInvitationVerifyingPreview> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await showGeneralDialog<void>(
        context: context,
        barrierLabel: '招待コードを確認中',
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 160),
        pageBuilder: (dialogContext, _, __) {
          final tokens = dialogContext.appTheme;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.neutral.paper,
      appBar: AppBar(title: const Text('Invitation Verifying (Preview)')),
    );
  }
}
