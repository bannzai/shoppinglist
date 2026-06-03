import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_cell.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/features/shopping_location/page.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:shoppinglist/provider/group_invitation.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class GroupSettingPage extends ConsumerWidget {
  final String groupID;

  const GroupSettingPage({
    super.key,
    required this.groupID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupProvider(groupID: groupID));
    final groupUserProfilesAsync =
        ref.watch(groupUserProfilesProvider(groupID: groupID));

    return groupAsync.when(
      data: (group) => groupUserProfilesAsync.when(
        data: (profiles) => _GroupSettingBody(
          groupID: groupID,
          group: group,
          profiles: profiles,
        ),
        error: (e, st) =>
            _PaperScaffold(child: Center(child: Text(e.toString()))),
        loading: () => const _PaperScaffold(
            child: Center(child: CircularProgressIndicator())),
      ),
      error: (e, st) =>
          _PaperScaffold(child: Center(child: Text(e.toString()))),
      loading: () => const _PaperScaffold(
          child: Center(child: CircularProgressIndicator())),
    );
  }
}

/// グループ設定画面の loading / error 用に paper bg + 共通 AppBar を持つ Scaffold。
class _PaperScaffold extends StatelessWidget {
  final Widget child;
  const _PaperScaffold({required this.child});
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      backgroundColor: tokens.neutral.paper,
      appBar: AppBar(
        title: const Text('グループ設定'),
        backgroundColor: tokens.neutral.paper,
      ),
      body: child,
    );
  }
}

class _GroupSettingBody extends HookConsumerWidget {
  final String groupID;
  final Group group;
  final List<GroupUserProfile> profiles;

  const _GroupSettingBody({
    required this.groupID,
    required this.group,
    required this.profiles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserID = ref.watch(currentUserIDProvider);
    final isOwner =
        group.ownerUserID != null && group.ownerUserID == currentUserID;
    final groupNameController =
        useTextEditingController(text: group.name ?? '');
    final isCreatingInvitation = useState(false);
    final isRemovingMember = useState(false);

    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.neutral.paper,
      appBar: AppBar(
        title: const Text('グループ設定'),
        backgroundColor: tokens.neutral.paper,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // グループ名セクション
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('グループ名',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: groupNameController,
                        readOnly: !isOwner,
                        decoration: const InputDecoration(
                          hintText: 'グループ名を入力',
                        ),
                        onSubmitted: !isOwner
                            ? null
                            : (value) {
                                final newName = value.trim();
                                if (newName.isEmpty ||
                                    newName == (group.name ?? '')) {
                                  return;
                                }
                                ref
                                    .read(groupNameUpdateProvider(
                                        groupID: groupID))
                                    .call(name: newName);
                              },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),

                // メンバー一覧セクション
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('メンバー一覧',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                ...profiles.map((profile) {
                  final isProfileOwner = profile.userID == group.ownerUserID;
                  final isSelf = profile.userID == currentUserID;
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(profile.displayName ?? '名前未設定'),
                    subtitle: () {
                      if (isProfileOwner) {
                        return const Text('オーナー');
                      } else if (isSelf) {
                        return const Text('自分');
                      }
                      return null;
                    }(),
                    trailing: (isOwner && !isProfileOwner)
                        ? IconButton(
                            icon: Icon(Icons.remove_circle,
                                color: context.tokens.neutral.danger),
                            onPressed: isRemovingMember.value
                                ? null
                                : () {
                                    analytics.logEvent(
                                        name: 'tap_remove_member',
                                        parameters: {
                                          'groupID': groupID,
                                          'targetUserID': profile.userID
                                        });
                                    _showRemoveMemberDialog(
                                      context: context,
                                      ref: ref,
                                      profile: profile,
                                      isRemovingMember: isRemovingMember,
                                    );
                                  },
                          )
                        : null,
                  );
                }),
                const Divider(height: 32),

                // 買い物する場所 / カテゴリは別画面遷移に統一する
                // (`design_handoff_shoppinglist/preview/screens-groups.jsx` 準拠で、
                // GroupSettingPage 内のインライン管理を外して詳細画面に集約する)
                AppCell(
                    icon: Icons.store_outlined,
                    title: '買い物する場所',
                    subtitle: '店舗の登録・編集',
                    onTap: () {
                      analytics.logEvent(
                        name: 'navigate_shopping_location_from_group_setting',
                        parameters: {'groupID': groupID},
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ShoppingLocationPage(groupID: groupID),
                        ),
                      );
                    },
                    detail: null,
                    onSwitch: null,
                    switchValue: null),
                AppCell(
                    icon: Icons.category_outlined,
                    title: 'カテゴリ',
                    subtitle: '自動分類のキーワード管理',
                    onTap: () {
                      analytics.logEvent(
                        name: 'navigate_group_category_from_group_setting',
                        parameters: {'groupID': groupID},
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupCategoryPage(groupID: groupID),
                        ),
                      );
                    },
                    detail: null,
                    onSwitch: null,
                    switchValue: null),
                const Divider(height: 32),

                // グループ招待セクション
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('グループ招待',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      AppPill(
                        label: isCreatingInvitation.value
                            ? '招待コードを発行中...'
                            : '招待コードを発行',
                        icon: Icons.person_add,
                        variant: AppPillVariant.soft,
                        onPressed: isCreatingInvitation.value
                            ? null
                            : () async {
                                analytics.logEvent(
                                    name: 'tap_create_grp_invitation',
                                    parameters: {'groupID': groupID});
                                isCreatingInvitation.value = true;
                                try {
                                  final invitation = await ref
                                      .read(createGroupInvitationProvider)
                                      .call(groupID: groupID);
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          _InvitationCodeDialog(
                                              groupID: groupID,
                                              invitationCode:
                                                  invitation.invitationCode),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                } finally {
                                  isCreatingInvitation.value = false;
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRemoveMemberDialog({
    required BuildContext context,
    required WidgetRef ref,
    required GroupUserProfile profile,
    required ValueNotifier<bool> isRemovingMember,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${profile.displayName ?? '名前未設定'}をグループから削除しますか？'),
        content: const Text('削除されたメンバーはこのグループにアクセスできなくなります'),
        actions: [
          TextButton(
            onPressed: () async {
              analytics.logEvent(
                  name: 'tap_confirm_remove_member',
                  parameters: {
                    'groupID': groupID,
                    'targetUserID': profile.userID
                  });
              Navigator.pop(dialogContext);
              isRemovingMember.value = true;
              try {
                await functions.removeGroupMember(
                  groupID: groupID,
                  targetUserID: profile.userID,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${profile.displayName ?? 'メンバー'}を削除しました')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              } finally {
                isRemovingMember.value = false;
              }
            },
            child: Text(
              '削除',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: context.tokens.neutral.danger),
            ),
          ),
          TextButton(
            onPressed: () {
              analytics.logEvent(
                  name: 'cancel_remove_member',
                  parameters: {'groupID': groupID});
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}

// --- 招待コードダイアログ ---

class _InvitationCodeDialog extends StatelessWidget {
  final String groupID;
  final String invitationCode;

  const _InvitationCodeDialog(
      {required this.groupID, required this.invitationCode});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('招待コード'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('以下のコードを共有してください'),
          const SizedBox(height: 16),
          SelectableText(
            invitationCode,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '有効期限: 7日間',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            analytics.logEvent(
                name: 'tap_copy_invitation_code',
                parameters: {'groupID': groupID});
            await Clipboard.setData(ClipboardData(text: invitationCode));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('招待コードをコピーしました')),
              );
            }
          },
          child: const Text('コピー'),
        ),
        TextButton(
          onPressed: () {
            analytics.logEvent(
                name: 'cancel_invitation_dialog',
                parameters: {'groupID': groupID});
            Navigator.pop(context);
          },
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}
