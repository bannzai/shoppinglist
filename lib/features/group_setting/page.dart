import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:shoppinglist/provider/group_invitation.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/features/group_shopping_list_item_category/page.dart';
import 'package:shoppinglist/features/shopping_location/page.dart';
import 'package:shoppinglist/style/color.dart';

class GroupSettingPage extends HookConsumerWidget {
  final String groupID;

  const GroupSettingPage({
    super.key,
    required this.groupID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupProvider(groupID: groupID));
    final profilesAsync =
        ref.watch(groupUserProfilesProvider(groupID: groupID));

    return groupAsync.when(
      data: (group) => profilesAsync.when(
        data: (profiles) => _GroupSettingBody(
          groupID: groupID,
          group: group,
          profiles: profiles,
        ),
        error: (e, st) => Scaffold(
          appBar: AppBar(title: const Text('グループ設定')),
          body: Center(child: Text(e.toString())),
        ),
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('グループ設定')),
          body: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('グループ設定')),
        body: Center(child: Text(e.toString())),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('グループ設定')),
        body: const Center(child: CircularProgressIndicator()),
      ),
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
    final currentUserID = FirebaseAuth.instance.currentUser?.uid;
    final isOwner =
        group.ownerUserID != null && group.ownerUserID == currentUserID;
    final groupNameController =
        useTextEditingController(text: group.name ?? '');
    final isCreatingInvitation = useState(false);
    final isUpdatingName = useState(false);
    final isRemovingMember = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('グループ設定'),
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
                      const Text('グループ名',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: groupNameController,
                        readOnly: !isOwner,
                        decoration: InputDecoration(
                          hintText: 'グループ名を入力',
                          enabled: isOwner,
                        ),
                      ),
                      if (isOwner) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isUpdatingName.value
                                ? null
                                : () async {
                                    isUpdatingName.value = true;
                                    try {
                                      await functions.updateGroupName(
                                        groupID: groupID,
                                        name: groupNameController.text,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('グループ名を更新しました')),
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
                                      isUpdatingName.value = false;
                                    }
                                  },
                            icon: isUpdatingName.value
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.save),
                            label: const Text('変更を保存'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 32),

                // メンバー一覧セクション
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text('メンバー一覧',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                            icon: const Icon(Icons.remove_circle,
                                color: TextColor.danger),
                            onPressed: isRemovingMember.value
                                ? null
                                : () {
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

                // 買い物する場所セクション
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('買い物する場所',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShoppingLocationPage(
                                  groupID: groupID,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.store),
                          label: const Text('場所を管理'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),

                // カテゴリセクション
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('カテゴリ',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GroupShoppingListItemCategoryPage(
                                  groupID: groupID,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.category),
                          label: const Text('カテゴリを管理'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),

                // グループ招待セクション
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('グループ招待',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isCreatingInvitation.value
                              ? null
                              : () async {
                                  isCreatingInvitation.value = true;
                                  try {
                                    final invitationCode = await ref
                                        .read(createGroupInvitationProvider)
                                        .call(groupID: groupID);
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            _InvitationCodeDialog(
                                                invitationCode: invitationCode),
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
                                    isCreatingInvitation.value = false;
                                  }
                                },
                          icon: isCreatingInvitation.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.person_add),
                          label: const Text('グループに招待'),
                        ),
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
            child: const Text(
              '削除',
              style: TextStyle(color: TextColor.danger),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}

class _InvitationCodeDialog extends StatelessWidget {
  final String invitationCode;

  const _InvitationCodeDialog({required this.invitationCode});

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
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '有効期限: 7日間',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
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
            Navigator.pop(context);
          },
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}
