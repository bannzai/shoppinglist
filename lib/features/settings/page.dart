import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shoppinglist/components/button/user_delete.dart';
import 'package:shoppinglist/components/primitives/app_cell.dart';
import 'package:shoppinglist/components/primitives/app_dialog_shell.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/components/primitives/app_setting_section.dart';
import 'package:shoppinglist/features/developer_options/page.dart';
import 'package:shoppinglist/features/group_invitation/page.dart';
import 'package:shoppinglist/features/group_list/page.dart';
import 'package:shoppinglist/features/inquiry/page.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/settings/components/location_reminder_toggle.dart';
import 'package:shoppinglist/features/settings/components/theme_color_tile.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/config/feature_flags.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends HookConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);
    final appUser = appUserAsync.asData?.value;
    final groupID = appUser?.defaultGroupID;
    final currentUserID = ref.watch(currentUserIDProvider);

    final displayNameController = useTextEditingController();

    // プロフィールのdisplayNameをTextFieldに反映
    final groupUserProfilesAsync =
        groupID != null
            ? ref.watch(groupUserProfilesProvider(groupID: groupID))
            : null;
    final myGroupUserProfile =
        groupUserProfilesAsync?.asData?.value
            .where((p) => p.userID == currentUserID)
            .firstOrNull;

    // Firestoreからプロフィールデータが初回読み込みされた時にTextFieldへ反映する。
    // displayNameController.textが空の場合のみ設定することで、ユーザーが入力中の値を上書きしない。
    useEffect(() {
      if (myGroupUserProfile != null && displayNameController.text.isEmpty) {
        displayNameController.text = myGroupUserProfile.displayName ?? '';
      }
      return null;
    }, [myGroupUserProfile]);

    // 表示名を保存する。保存ボタンは廃止し、TextFieldのフォーカスが外れた時(blur)に
    // この関数を呼んで自動保存する。保存済みの値と同じ場合は書き込みをスキップし、
    // 不要な更新を避けて冪等にする。
    Future<void> saveDisplayName() async {
      if (groupID == null || currentUserID == null) {
        return;
      }
      final displayName = displayNameController.text;
      if (displayName == (myGroupUserProfile?.displayName ?? '')) {
        return;
      }
      analytics.logEvent(
        name: 'submit_profile_display_name',
        parameters: {'groupID': groupID},
      );
      try {
        await ref
            .read(groupUserProfileUpdateProvider(groupID: groupID))
            .call(userID: currentUserID, displayName: displayName);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('表示名を更新しました')));
        }
      } catch (e, st) {
        if (context.mounted) {
          showErrorSnackBar(context, e, st);
        }
      }
    }

    final tokens = context.appTheme;

    return Scaffold(
      backgroundColor: tokens.neutral.paper,
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: tokens.neutral.paper,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            analytics.logEvent(name: 'tap_close_app_setting', parameters: null);
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSettingSection(
                title: 'プロフィール',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    // ラベル「表示名」と入力欄を横並び(Row)にする。ラベルを左、
                    // 入力欄を右のExpandedに置き、値はTextAlign.endで右寄せにして
                    // 他の設定行(値が右側)とトンマナを揃える。
                    child: Row(
                      children: [
                        const Text('自分の表示名'),
                        const SizedBox(width: 16),
                        Expanded(
                          // フォーカスが外れた時(hasFocus=false)に自動保存する。
                          // canRequestFocus=false でこのFocus自体は入力対象にならず、
                          // 子のTextFieldのフォーカス変化の検知だけに使う。
                          child: Focus(
                            canRequestFocus: false,
                            onFocusChange: (hasFocus) async {
                              if (hasFocus) {
                                return;
                              }
                              await saveDisplayName();
                            },
                            child: TextField(
                              controller: displayNameController,
                              textAlign: TextAlign.end,
                              decoration: const InputDecoration(
                                hintText: '表示名を入力',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSettingSection(
                title: 'グループ',
                children: [
                  AppCell(
                    icon: Icons.groups,
                    title: 'グループ管理',
                    onTap: () {
                      analytics.logEvent(
                        name: 'tap_navigate_group_list',
                        parameters: {},
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GroupListPage(),
                        ),
                      );
                    },
                    detail: null,
                    onSwitch: null,
                    subtitle: null,
                    switchValue: null,
                  ),
                  AppCell(
                    icon: Icons.group_add,
                    title: '招待コードでグループに参加',
                    onTap: () {
                      analytics.logEvent(
                        name: 'tap_navigate_invitation',
                        parameters: {},
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const GroupInvitationAcceptPage(),
                        ),
                      );
                    },
                    detail: null,
                    onSwitch: null,
                    subtitle: null,
                    switchValue: null,
                  ),
                ],
              ),
              AppSettingSection(
                title: '外観',
                children: [const ThemeColorTile()],
              ),
              // 位置情報リマインダーはファーストリリースでは非表示 (issue #465)。
              if (shoppingLocationFeatureEnabled)
                AppSettingSection(
                  title: '通知',
                  children: [const LocationReminderToggle()],
                ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _PremiumCard(),
              ),
              AppSettingSection(
                title: 'アプリについて',
                children: [
                  AppCell(
                    icon: Icons.description_outlined,
                    title: '利用規約',
                    onTap: () {
                      analytics.logEvent(
                        name: 'did_select_terms_of_service',
                        parameters: {},
                      );
                      launchUrl(
                        Uri.parse(
                          'https://bannzai.github.io/shoppinglist/Terms',
                        ),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    detail: null,
                    onSwitch: null,
                    subtitle: null,
                    switchValue: null,
                  ),
                  const _Divider(),
                  AppCell(
                    icon: Icons.shield_outlined,
                    title: 'プライバシーポリシー',
                    onTap: () {
                      analytics.logEvent(
                        name: 'did_select_privacy_policy',
                        parameters: {},
                      );
                      launchUrl(
                        Uri.parse(
                          'https://bannzai.github.io/shoppinglist/PrivacyPolicy',
                        ),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    detail: null,
                    onSwitch: null,
                    subtitle: null,
                    switchValue: null,
                  ),
                  const _Divider(),
                  AppCell(
                    icon: Icons.gavel_outlined,
                    title: '特定商法取引法に基づく表記',
                    onTap: () {
                      analytics.logEvent(
                        name: 'did_select_specified_commercial_transaction_act',
                        parameters: {},
                      );
                      launchUrl(
                        Uri.parse(
                          'https://bannzai.github.io/shoppinglist/SpecifiedCommercialTransactionAct-ja',
                        ),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    detail: null,
                    onSwitch: null,
                    subtitle: null,
                    switchValue: null,
                  ),
                  const _Divider(),
                  AppCell(
                    icon: Icons.mail_outline,
                    title: 'お問い合わせ',
                    onTap: () {
                      analytics.logEvent(
                        name: 'tap_open_inquiry',
                        parameters: {},
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InquiryPage(),
                        ),
                      );
                    },
                    detail: null,
                    onSwitch: null,
                    subtitle: null,
                    switchValue: null,
                  ),
                ],
              ),
              // E2Eテストでシェイクが使えないSimulator向けの代替入口
              if (kDebugMode)
                AppSettingSection(
                  title: 'デバッグ',
                  children: [
                    AppCell(
                      icon: Icons.developer_mode,
                      title: '開発者オプション',
                      onTap: () {
                        navigateToDeveloperOptionsPage(context);
                      },
                      detail: null,
                      onSwitch: null,
                      subtitle: null,
                      switchValue: null,
                    ),
                  ],
                ),
              // サインアウト: `design_handoff_shoppinglist/preview/screens-settings.jsx`
              // 準拠で破壊的操作扱い (danger 色 + 確認ダイアログ)。
              const _SignOutButton(),
              const DeleteUserButton(),
              const _VersionLabel(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// プレミアム会員カード。free=surface2 / premium=accent→#7C2A07 グラデ。
/// `design_handoff_shoppinglist/preview/screens-settings.jsx#SettingPage` 相当。
class _PremiumCard extends ConsumerWidget {
  const _PremiumCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            isPremium
                ? LinearGradient(
                  colors: [tokens.accent, const Color(0xFF7C2A07)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        color: isPremium ? null : neutral.surface2,
        borderRadius: BorderRadius.circular(14),
        border:
            isPremium ? null : Border.all(color: neutral.divider, width: 0.5),
        boxShadow: isPremium ? tokens.cardShadow : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isPremium
                      ? Colors.white.withValues(alpha: 0.2)
                      : tokens.accentSoft,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.workspace_premium,
              color: isPremium ? Colors.white : tokens.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPremium ? 'プレミアム会員' : 'プレミアムにアップグレード',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isPremium ? Colors.white : neutral.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPremium ? 'すべての機能が利用できます' : '5 色テーマ・画像/URL読み取り回数アップなど',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                        isPremium
                            ? Colors.white.withValues(alpha: 0.85)
                            : neutral.ink2,
                  ),
                ),
              ],
            ),
          ),
          if (!isPremium)
            AppPill(
              label: 'はじめる',
              variant: AppPillVariant.accent,
              onPressed: () {
                analytics.logEvent(
                  name: 'tap_premium_membership_tile',
                  parameters: {},
                );
                showPaywall(context: context);
              },
              icon: null,
            ),
        ],
      ),
    );
  }
}

/// アプリバージョンを mono フォントで表示。`package_info_plus` から取得。
class _VersionLabel extends StatefulWidget {
  const _VersionLabel();

  @override
  State<_VersionLabel> createState() => _VersionLabelState();
}

class _VersionLabelState extends State<_VersionLabel> {
  String? _label;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (!mounted) {
        return;
      }
      setState(() {
        _label = 'v${info.version} (build ${info.buildNumber})';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        _label ?? '',
        textAlign: TextAlign.center,
        style: monoTextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: tokens.neutral.ink3,
          letterSpacing: null,
        ),
      ),
    );
  }
}

/// サインアウトボタン。
/// `design_handoff_shoppinglist/preview/screens-settings.jsx` 準拠の確認ダイアログ
/// 経由で `FirebaseAuth.instance.signOut()` を実行する。
class _SignOutButton extends ConsumerWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          icon: Icon(Icons.logout, color: tokens.neutral.danger, size: 18),
          label: Text(
            'サインアウト',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: tokens.neutral.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            analytics.logEvent(name: 'tap_sign_out', parameters: null);
            // `design_handoff_shoppinglist/preview/screens-list-settings.jsx`
            // の DialogShell 準拠 (overlay + blur + 上から 32% に paper card)。
            final confirmed = await showGeneralDialog<bool>(
              context: context,
              barrierLabel: 'サインアウト確認',
              barrierDismissible: true,
              barrierColor: Colors.transparent,
              transitionDuration: const Duration(milliseconds: 160),
              pageBuilder: (dialogContext, _, __) {
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
                        style: Theme.of(dialogContext).textTheme.bodyMedium
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
                              onPressed:
                                  () => Navigator.pop(dialogContext, false),
                              icon: null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppPill(
                              label: 'サインアウト',
                              variant: AppPillVariant.danger,
                              expanded: true,
                              onPressed:
                                  () => Navigator.pop(dialogContext, true),
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
              return;
            }
            analytics.logEvent(name: 'confirm_sign_out', parameters: null);
            await FirebaseAuth.instance.signOut();
            // debug 時は exit(0) すると Hot Restart の手間が増えるため、終了アラートを
            // 出さず終了もしない（開発者が手動で Hot Restart する想定）。
            // release/profile 時のみ、サインアウト完了を伝えてアプリを終了する。
            // アカウント削除フロー(user_delete.dart の _CompletedDialog)と同方針。
            if (kDebugMode) {
              return;
            }
            if (!context.mounted) {
              return;
            }
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const _SignOutCompletedDialog(),
            );
          },
        ),
      ),
    );
  }
}

/// サインアウト完了アラート。
/// release/profile ビルドで `FirebaseAuth.instance.signOut()` 後に表示し、
/// 「終了する」タップで `exit(0)` する。アカウント削除フローの `_CompletedDialog` と同方針。
class _SignOutCompletedDialog extends StatelessWidget {
  const _SignOutCompletedDialog();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'サインアウトしました',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'アプリを終了します',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 180,
            child: TextButton(
              onPressed: () async {
                analytics.logEvent(
                  name: 'tap_exit_app_after_sign_out',
                  parameters: null,
                );
                exit(0);
              },
              child: Text(
                '終了する',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(indent: 15, endIndent: 15);
  }
}
