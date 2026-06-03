import 'package:flutter/material.dart';
import 'package:shoppinglist/components/frame/app_dialog_shell.dart';
import 'package:shoppinglist/components/frame/app_pill.dart';
import 'package:shoppinglist/style/tokens.dart';

/// preview 用に sign out 確認 dialog を即時表示する pseudo page。
class SignOutDialogPreview extends StatefulWidget {
  const SignOutDialogPreview({super.key});

  @override
  State<SignOutDialogPreview> createState() => _SignOutDialogPreviewState();
}

class _SignOutDialogPreviewState extends State<SignOutDialogPreview> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await showGeneralDialog<void>(
        context: context,
        barrierLabel: 'サインアウト確認',
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 160),
        pageBuilder: (dialogContext, _, __) {
          final tokens = dialogContext.tokens;
          return AppDialogShell(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'サインアウトしますか?',
                  style: Theme.of(dialogContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  '再度サインインするまで端末からはリストにアクセスできなくなります。',
                  style: Theme.of(dialogContext)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: tokens.neutral.ink2),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppPill(
                          label: 'キャンセル',
                          variant: AppPillVariant.ghost,
                          expanded: true,
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: null),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppPill(
                          label: 'サインアウト',
                          variant: AppPillVariant.danger,
                          expanded: true,
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: null),
                    ),
                  ],
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
      backgroundColor: context.tokens.neutral.paper,
      appBar: AppBar(title: const Text('SignOut Dialog (Preview)')),
    );
  }
}
