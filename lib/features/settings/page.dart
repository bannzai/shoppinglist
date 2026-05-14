import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shoppinglist/components/button/inquiry.dart';
import 'package:shoppinglist/components/button/user_delete.dart';
import 'package:shoppinglist/components/frame/app_pill.dart';
import 'package:shoppinglist/features/developer_options/page.dart';
import 'package:shoppinglist/features/group_invitation/page.dart';
import 'package:shoppinglist/features/group_list/page.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/settings/components/section.dart';
import 'package:shoppinglist/features/settings/theme_color_selection_page.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/geofence.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/local_notification.dart';
import 'package:shoppinglist/provider/notification_setting.dart';
import 'package:shoppinglist/provider/theme_color.dart';
import 'package:shoppinglist/style/tokens.dart';
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
    final isSavingProfile = useState(false);

    // プロフィールのdisplayNameをTextFieldに反映
    final profilesAsync = groupID != null
        ? ref.watch(groupUserProfilesProvider(groupID: groupID))
        : null;
    final myProfile = profilesAsync?.asData?.value
        .where((p) => p.userID == currentUserID)
        .firstOrNull;

    // Firestoreからプロフィールデータが初回読み込みされた時にTextFieldへ反映する。
    // displayNameController.textが空の場合のみ設定することで、ユーザーが入力中の値を上書きしない。
    useEffect(() {
      if (myProfile != null && displayNameController.text.isEmpty) {
        displayNameController.text = myProfile.displayName ?? '';
      }
      return null;
    }, [myProfile]);

    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.neutral.paper,
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  '設定',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              SettingSectionTitle(text: 'プロフィール', children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('表示名'),
                      const SizedBox(height: 4),
                      TextField(
                        controller: displayNameController,
                        decoration: const InputDecoration(
                          hintText: '表示名を入力',
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: (isSavingProfile.value ||
                                  groupID == null ||
                                  currentUserID == null)
                              ? null
                              : () async {
                                  analytics.logEvent(
                                      name: 'tap_save_profile',
                                      parameters: {'groupID': groupID});
                                  isSavingProfile.value = true;
                                  try {
                                    await ref
                                        .read(groupUserProfileUpdateProvider(
                                            groupID: groupID))
                                        .call(
                                          userID: currentUserID,
                                          displayName:
                                              displayNameController.text,
                                        );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('表示名を更新しました')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  } finally {
                                    isSavingProfile.value = false;
                                  }
                                },
                          icon: isSavingProfile.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: const Text('保存'),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              SettingSectionTitle(text: 'グループ', children: [
                ListTile(
                  title: const Text(
                    'グループ管理',
                  ),
                  leading: const Icon(Icons.groups),
                  onTap: () {
                    analytics.logEvent(
                        name: 'tap_navigate_group_list', parameters: {});
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GroupListPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text(
                    '招待コードでグループに参加',
                  ),
                  leading: const Icon(Icons.group_add),
                  onTap: () {
                    analytics.logEvent(
                        name: 'tap_navigate_invitation', parameters: {});
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GroupInvitationAcceptPage(),
                      ),
                    );
                  },
                ),
              ]),
              SettingSectionTitle(text: '外観', children: [
                _ThemeColorTile(),
              ]),
              SettingSectionTitle(text: '通知', children: [
                _AutoNotifyToggle(),
                _LocationReminderToggle(),
              ]),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _PremiumCard(),
              ),
              SettingSectionTitle(text: 'アプリについて', children: [
                ListTile(
                    title: const Text(
                      '利用規約',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      analytics.logEvent(
                          name: 'did_select_terms_of_service', parameters: {});
                      launchUrl(
                          Uri.parse(
                              'https://bannzai.github.io/shoppinglist/TermsOfService'),
                          mode: LaunchMode.externalApplication);
                    }),
                const _Divider(),
                ListTile(
                  title: const Text(
                    'プライバシーポリシー',
                  ),
                  onTap: () {
                    analytics.logEvent(
                        name: 'did_select_privacy_policy', parameters: {});
                    launchUrl(
                        Uri.parse(
                            'https://bannzai.github.io/shoppinglist/PrivacyPolicy'),
                        mode: LaunchMode.externalApplication);
                  },
                ),
                const _Divider(),
                ListTile(
                    title: const Text(
                      '特定商法取引法に基づく表記',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      analytics.logEvent(
                          name:
                              'did_select_specified_commercial_transaction_act',
                          parameters: {});
                      launchUrl(
                          Uri.parse(
                              'https://bannzai.github.io/shoppinglist/SpecifiedCommercialTransactionAct'),
                          mode: LaunchMode.externalApplication);
                    }),
                const _Divider(),
                ListTile(
                  title: const Text('お問い合わせ'),
                  onTap: () {
                    analytics
                        .logEvent(name: 'tap_open_inquiry', parameters: {});
                    inquiry();
                  },
                ),
              ]),
              // E2Eテストでシェイクが使えないSimulator向けの代替入口
              if (kDebugMode)
                SettingSectionTitle(text: 'デバッグ', children: [
                  ListTile(
                    title: const Text('開発者オプション'),
                    leading: const Icon(Icons.developer_mode),
                    onTap: () {
                      navigateToDeveloperOptionsPage(context);
                    },
                  ),
                ]),
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
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPremium
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
              color: isPremium
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isPremium ? Colors.white : neutral.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPremium ? 'すべての機能が利用できます' : '5 色テーマ・AI 無制限など',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isPremium
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
      if (!mounted) return;
      setState(() {
        _label = 'v${info.version} (build ${info.buildNumber})';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        _label ?? '',
        textAlign: TextAlign.center,
        style: GoogleFonts.ibmPlexMono(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: tokens.neutral.ink3,
        ),
      ),
    );
  }
}

/// テーマカラー設定のListTile。プレミアムユーザーのみ選択画面へ遷移可能。
class _ThemeColorTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;

    return ListTile(
      title: const Text('テーマカラー'),
      leading: const Icon(Icons.palette),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: resolveAccentPreset(
                      ref.watch(appUserProvider).asData?.value.themeColorHex)
                  .light,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          if (!isPremium)
            Icon(
              Icons.lock,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        ],
      ),
      onTap: () {
        analytics.logEvent(
          name: 'tap_theme_color_setting',
          parameters: {'isPremium': isPremium.toString()},
        );
        if (isPremium) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ThemeColorSelectionPage(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('テーマカラーの変更はプレミアム機能です'),
              action: SnackBarAction(
                label: 'アップグレード',
                onPressed: () => showPaywall(context: context),
              ),
            ),
          );
        }
      },
    );
  }
}

class _AutoNotifyToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(autoNotifyShoppingListUpdateProvider);

    return SwitchListTile(
      title: const Text('買い物リストの更新を通知する'),
      subtitle: const Text('画面を離れた時にグループメンバーへ自動通知'),
      value: isEnabled,
      onChanged: (_) {
        analytics.logEvent(
          name: 'tap_toggle_auto_notify',
          parameters: {'enabled': (!isEnabled).toString()},
        );
        ref.read(autoNotifyShoppingListUpdateProvider.notifier).toggle();
      },
    );
  }
}

/// 位置情報リマインダーの有効/無効を切り替えるトグル。
class _LocationReminderToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
    final isEnabled = ref.watch(locationReminderEnabledProvider);

    return SwitchListTile(
      title: const Text('位置情報リマインダー'),
      subtitle: const Text('店舗の近くに来たら買い物リストを通知'),
      secondary: Icon(
        Icons.location_on,
        color:
            !isPremium ? Theme.of(context).colorScheme.onSurfaceVariant : null,
      ),
      value: isPremium && isEnabled,
      onChanged: isPremium
          ? (value) async {
              analytics.logEvent(
                name: 'tap_toggle_location_remind',
                parameters: {
                  'enabled': value.toString(),
                  'isPremium': isPremium.toString(),
                },
              );

              if (value) {
                // Android通知権限の確認
                final androidNotifications = ref
                    .read(localNotificationsPluginProvider)
                    .resolvePlatformSpecificImplementation<
                        AndroidFlutterLocalNotificationsPlugin>();
                if (await androidNotifications
                        ?.requestNotificationsPermission() ==
                    false) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('通知権限を許可すると利用できます'),
                      ),
                    );
                  }
                  return;
                }

                // 「常に許可」が必要
                var permission = await Geolocator.checkPermission();
                if (permission == LocationPermission.denied ||
                    permission == LocationPermission.deniedForever) {
                  permission = await Geolocator.requestPermission();
                }
                if (permission == LocationPermission.whileInUse) {
                  permission = await Geolocator.requestPermission();
                }
                if (permission != LocationPermission.always) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'バックグラウンドの位置情報を「常に許可」にすると利用できます',
                        ),
                      ),
                    );
                  }
                  return;
                }
              }

              await ref
                  .read(locationReminderEnabledProvider.notifier)
                  .setEnabled(enabled: value);
            }
          : (value) {
              analytics.logEvent(
                name: 'tap_toggle_location_remind',
                parameters: {
                  'enabled': value.toString(),
                  'isPremium': isPremium.toString(),
                },
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('位置情報リマインダーはプレミアム機能です'),
                  action: SnackBarAction(
                    label: 'アップグレード',
                    onPressed: () => showPaywall(context: context),
                  ),
                ),
              );
            },
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
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          icon: Icon(Icons.logout, color: tokens.neutral.danger, size: 18),
          label: Text(
            'サインアウト',
            style: TextStyle(
              color: tokens.neutral.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            analytics.logEvent(name: 'tap_sign_out');
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('サインアウトしますか?'),
                content: const Text('再度サインインするまで端末からはリストにアクセスできなくなります。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('キャンセル'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: TextButton.styleFrom(
                      foregroundColor: tokens.neutral.danger,
                    ),
                    child: const Text('サインアウト'),
                  ),
                ],
              ),
            );
            if (confirmed != true) return;
            analytics.logEvent(name: 'confirm_sign_out');
            await FirebaseAuth.instance.signOut();
          },
        ),
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
