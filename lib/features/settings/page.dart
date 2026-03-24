import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/button/inquiry.dart';
import 'package:shoppinglist/components/button/user_delete.dart';
import 'package:shoppinglist/features/group_invitation/page.dart';
import 'package:shoppinglist/features/developer_options/page.dart';
import 'package:shoppinglist/features/group_list/page.dart';
import 'package:shoppinglist/features/settings/components/section.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/notification_setting.dart';

import 'package:shoppinglist/utils/logger/analytics.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
              SettingSectionTitle(text: '通知', children: [
                _AutoNotifyToggle(),
              ]),
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
              const DeleteUserButton(),
            ],
          ),
        ),
      ),
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
        ref
            .read(autoNotifyShoppingListUpdateProvider.notifier)
            .toggle();
      },
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
