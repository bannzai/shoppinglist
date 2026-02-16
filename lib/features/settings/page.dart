import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/button/inquiry.dart';
import 'package:shoppinglist/components/button/user_delete.dart';
import 'package:shoppinglist/features/group_invitation/page.dart';
import 'package:shoppinglist/features/group_list/page.dart';
import 'package:shoppinglist/features/settings/components/section.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends HookConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);
    final appUser = appUserAsync.asData?.value;
    final groupID = appUser?.defaultGroupID;
    final currentUserID = FirebaseAuth.instance.currentUser?.uid;

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
                      const Text(
                        '表示名',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                        ),
                      ),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                    ),
                  ),
                  leading: const Icon(Icons.groups),
                  onTap: () {
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
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                    ),
                  ),
                  leading: const Icon(Icons.group_add),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GroupInvitationAcceptPage(),
                      ),
                    );
                  },
                ),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                    ),
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
                    inquiry();
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Container(
        height: 1,
        color: AppColors.border,
      ),
    );
  }
}
