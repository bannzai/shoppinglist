import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/auth/apple.dart';
import 'package:shoppinglist/components/auth/google.dart';
import 'package:shoppinglist/components/primitives/app_cell.dart';
import 'package:shoppinglist/components/primitives/app_dialog_shell.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/components/primitives/app_setting_section.dart';
import 'package:shoppinglist/features/resolver/auth.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// 設定画面の「アカウント」セクション（issue #548）。
/// ゲスト（匿名）ユーザーには説明行と Apple / Google のリンク導線を表示し、
/// リンク済みの provider はサインイン方法として表示する。
/// リンクは `User.linkWithCredential` で行うため UID が維持され、
/// それまでに作ったリスト・グループはそのまま引き継がれる。
class AccountLinkSection extends HookConsumerWidget {
  const AccountLinkSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseUserChangesProvider).valueOrNull;
    if (user == null) {
      return const SizedBox.shrink();
    }
    final isAppleLinked = user.providerData.any(
      (userInfo) => userInfo.providerId == AppleAuthProvider.PROVIDER_ID,
    );
    final isGoogleLinked = user.providerData.any(
      (userInfo) => userInfo.providerId == GoogleAuthProvider.PROVIDER_ID,
    );

    // ネイティブのリンクフロー実行中の多重起動を防ぐ。
    final isLinking = useState(false);

    // Apple / Google 共通のリンク実行。キャンセルは各 provider の例外型で
    // 個別に握り、credential-already-in-use は既存アカウントへのサインイン
    // し直し導線を出す。それ以外の失敗は SnackBar でそのまま表示する。
    Future<void> runLink({
      required Future<UserCredential> Function() link,
    }) async {
      if (isLinking.value) {
        return;
      }
      isLinking.value = true;
      try {
        await link();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('アカウントをリンクしました')));
        }
      } on SignInWithAppleAuthorizationException catch (e, st) {
        if (e.code == AuthorizationErrorCode.canceled) {
          analytics.logEvent(name: 'cancel_link_with_apple', parameters: null);
          return;
        }
        if (context.mounted) {
          showErrorSnackBar(context, e, st);
        }
      } on GoogleSignInException catch (e, st) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          analytics.logEvent(name: 'cancel_link_with_google', parameters: null);
          return;
        }
        if (context.mounted) {
          showErrorSnackBar(context, e, st);
        }
      } on FirebaseAuthException catch (e, st) {
        if (e.code == 'credential-already-in-use' && context.mounted) {
          await _showSignInWithExistingAccountDialog(
            context: context,
            exception: e,
          );
          return;
        }
        if (context.mounted) {
          showErrorSnackBar(context, e, st);
        }
      } catch (e, st) {
        if (context.mounted) {
          showErrorSnackBar(context, e, st);
        }
      } finally {
        isLinking.value = false;
      }
    }

    return AppSettingSection(
      title: 'アカウント',
      children: [
        if (user.isAnonymous) const GuestAccountDescriptionCell(),
        if (isAppleLinked)
          const LinkedAccountCell(providerName: 'Apple')
        else
          AppleAccountLinkCell(
            onTap: () {
              analytics.logEvent(name: 'tap_link_with_apple', parameters: null);
              runLink(link: () => linkWithApple(user: user));
            },
          ),
        if (isGoogleLinked)
          const LinkedAccountCell(providerName: 'Google')
        else
          GoogleAccountLinkCell(
            onTap: () {
              analytics.logEvent(
                name: 'tap_link_with_google',
                parameters: null,
              );
              runLink(link: () => linkWithGoogle(user: user));
            },
          ),
      ],
    );
  }
}

/// ゲスト（匿名）利用中であることと、リンクの利点を説明する行。
class GuestAccountDescriptionCell extends StatelessWidget {
  const GuestAccountDescriptionCell({super.key});

  @override
  Widget build(BuildContext context) {
    final neutral = context.appTheme.neutral;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Text(
        'ゲストとして利用中です。アカウントをリンクすると、機種変更後や他の端末でも同じリストとグループを使えます。',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: neutral.ink2, height: 1.6),
      ),
    );
  }
}

/// Apple アカウントのリンク導線 Cell。
class AppleAccountLinkCell extends StatelessWidget {
  /// タップでリンクフローを開始する。
  final VoidCallback onTap;

  const AppleAccountLinkCell({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCell(
      icon: Icons.apple,
      title: 'Apple でアカウントをリンク',
      onTap: onTap,
      detail: null,
      onSwitch: null,
      subtitle: null,
      switchValue: null,
    );
  }
}

/// Google アカウントのリンク導線 Cell。
class GoogleAccountLinkCell extends StatelessWidget {
  /// タップでリンクフローを開始する。
  final VoidCallback onTap;

  const GoogleAccountLinkCell({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCell(
      icon: Icons.link,
      title: 'Google でアカウントをリンク',
      onTap: onTap,
      detail: null,
      onSwitch: null,
      subtitle: null,
      switchValue: null,
    );
  }
}

/// リンク済みの provider を表示する Cell（タップ不可）。
class LinkedAccountCell extends StatelessWidget {
  /// 表示する provider 名（'Apple' / 'Google'）。
  final String providerName;

  const LinkedAccountCell({super.key, required this.providerName});

  @override
  Widget build(BuildContext context) {
    return AppCell(
      icon: Icons.check_circle_outline,
      title: '$providerName でサインイン済み',
      onTap: null,
      detail: null,
      onSwitch: null,
      subtitle: null,
      switchValue: null,
    );
  }
}

/// credential-already-in-use（その Apple / Google アカウントが別のユーザーで
/// 使用済み）時の復帰導線。issue #548 の実装時判断として、匿名データを暗黙に
/// 諦めさせず「既存アカウントでサインインし直すか」をユーザーに確認する。
/// サインインし直すと現在のゲストデータ（リスト・グループ）は引き継がれない。
Future<void> _showSignInWithExistingAccountDialog({
  required BuildContext context,
  required FirebaseAuthException exception,
}) async {
  // Apple の ID token は単回利用のため、リンクに使った credential ではなく
  // 例外に含まれる updatedCredential（exception.credential）でサインインし直す。
  final credential = exception.credential;
  if (credential == null) {
    // サインインし直しに使える credential が無い場合は状況の説明
    // （describeError の title）だけを表示する。
    showErrorSnackBar(context, exception);
    return;
  }
  final tokens = context.appTheme;
  final confirmed = await showGeneralDialog<bool>(
    context: context,
    barrierLabel: 'サインインし直し確認',
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (dialogContext, _, __) {
      return AppDialogShell(
        barrierDismissible: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'このアカウントは別のユーザーで使用されています',
              style: Theme.of(dialogContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'このアカウントでサインインし直しますか?\n'
              'サインインし直すと、今のゲストデータ（リスト・グループ）は引き継がれません。',
              style: Theme.of(
                dialogContext,
              ).textTheme.bodyMedium?.copyWith(color: tokens.neutral.ink2),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppPill(
                    label: 'キャンセル',
                    variant: AppPillVariant.ghost,
                    expanded: true,
                    onPressed: () => Navigator.pop(dialogContext, false),
                    icon: null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppPill(
                    label: 'サインインし直す',
                    variant: AppPillVariant.danger,
                    expanded: true,
                    onPressed: () => Navigator.pop(dialogContext, true),
                    icon: null,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  if (confirmed != true) {
    analytics.logEvent(
      name: 'cancel_sign_in_existing_account',
      parameters: null,
    );
    return;
  }
  analytics.logEvent(
    name: 'confirm_sign_in_existing_account',
    parameters: null,
  );
  try {
    await FirebaseAuth.instance.signInWithCredential(credential);
    if (context.mounted) {
      // 設定画面はリゾルバ配下に push されたルートのため、ユーザー切替後の
      // ツリー再構築に追従できない。ルートまで戻して新しいユーザーで再構築させる。
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  } catch (e, st) {
    if (context.mounted) {
      showErrorSnackBar(context, e, st);
    }
  }
}
