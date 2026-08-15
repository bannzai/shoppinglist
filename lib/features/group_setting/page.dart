import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/error_view.dart';
import 'package:shoppinglist/components/primitives/app_cell.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/components/primitives/app_setting_section.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/features/notification_permission/pre_permission_dialog.dart';
import 'package:shoppinglist/features/shopping_location/page.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/config/feature_flags.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class GroupSettingPage extends ConsumerWidget {
  final String groupID;

  const GroupSettingPage({super.key, required this.groupID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupProvider(groupID: groupID));
    final groupUserProfilesAsync = ref.watch(
      groupUserProfilesProvider(groupID: groupID),
    );

    return groupAsync.when(
      data:
          (group) => groupUserProfilesAsync.when(
            data:
                (profiles) => _GroupSettingBody(
                  groupID: groupID,
                  group: group,
                  profiles: profiles,
                ),
            error:
                (e, st) =>
                    _PaperScaffold(child: ErrorView(error: e, stackTrace: st)),
            loading:
                () => const _PaperScaffold(
                  child: Center(child: CircularProgressIndicator()),
                ),
          ),
      error:
          (e, st) => _PaperScaffold(child: ErrorView(error: e, stackTrace: st)),
      loading:
          () => const _PaperScaffold(
            child: Center(child: CircularProgressIndicator()),
          ),
    );
  }
}

/// グループ設定画面の loading / error 用に paper bg + 共通 AppBar を持つ Scaffold。
class _PaperScaffold extends StatelessWidget {
  final Widget child;
  const _PaperScaffold({required this.child});
  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Scaffold(
      backgroundColor: tokens.neutral.paper,
      appBar: AppBar(
        title: Text(context.l10n.listSettingGroupSetting),
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
    final groupNameUpdate = ref.watch(
      groupNameUpdateProvider(groupID: groupID),
    );
    final isOwner =
        group.ownerUserID != null && group.ownerUserID == currentUserID;
    final groupNameController = useTextEditingController(
      text: group.name ?? '',
    );
    final isCreatingInvitation = useState(false);
    final isRemovingMember = useState(false);

    final tokens = context.appTheme;

    return Scaffold(
      backgroundColor: tokens.neutral.paper,
      appBar: AppBar(
        title: Text(context.l10n.listSettingGroupSetting),
        backgroundColor: tokens.neutral.paper,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 各セクションを白い card 面（AppSettingSection）に載せる。
              // 以前は全要素を paper 地へ直置きしており、入力欄を含め茶色く沈んで
              // 視認性が低かった。設定画面と同じ card ベース構造に統一する。
              AppSettingSection(
                title: context.l10n.groupNameLabel,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: TextField(
                      controller: groupNameController,
                      readOnly: !isOwner,
                      cursorColor: tokens.accent,
                      decoration: InputDecoration(
                        hintText: context.l10n.groupNameHint,
                        border: InputBorder.none,
                      ),
                      onSubmitted:
                          !isOwner
                              ? null
                              : (value) {
                                final newName = value.trim();
                                if (newName.isEmpty ||
                                    newName == (group.name ?? '')) {
                                  return;
                                }
                                groupNameUpdate.call(name: newName);
                              },
                    ),
                  ),
                ],
              ),
              AppSettingSection(
                title: context.l10n.groupSettingMembersSection,
                children: [
                  ...profiles.map((profile) {
                    final isProfileOwner = profile.userID == group.ownerUserID;
                    final isSelf = profile.userID == currentUserID;
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        profile.displayName ?? context.l10n.commonUnnamed,
                      ),
                      subtitle: () {
                        if (isProfileOwner) {
                          return Text(context.l10n.groupSettingMemberOwner);
                        } else if (isSelf) {
                          return Text(context.l10n.groupSettingMemberSelf);
                        }
                        return null;
                      }(),
                      trailing:
                          (isOwner && !isProfileOwner)
                              ? IconButton(
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: context.appTheme.neutral.danger,
                                ),
                                onPressed:
                                    isRemovingMember.value
                                        ? null
                                        : () {
                                          analytics.logEvent(
                                            name: 'tap_remove_member',
                                            parameters: {
                                              'groupID': groupID,
                                              'targetUserID': profile.userID,
                                            },
                                          );
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
                ],
              ),
              // 買い物する場所 / カテゴリは別画面遷移に統一する
              // (`design_handoff_shoppinglist/preview/screens-groups.jsx` 準拠で、
              // GroupSettingPage 内のインライン管理を外して詳細画面に集約する)
              AppSettingSection(
                children: [
                  // 買い物する場所はファーストリリースでは非表示 (issue #465)。
                  if (shoppingLocationFeatureEnabled)
                    AppCell(
                      icon: Icons.store_outlined,
                      title: context.l10n.listSettingShoppingLocationSection,
                      subtitle:
                          context.l10n.groupSettingShoppingLocationSubtitle,
                      onTap: () {
                        analytics.logEvent(
                          name: 'navigate_shopping_location_from_group_setting',
                          parameters: {'groupID': groupID},
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ShoppingLocationPage(groupID: groupID),
                          ),
                        );
                      },
                      detail: null,
                      onSwitch: null,
                      switchValue: null,
                    ),
                  AppCell(
                    icon: Icons.category_outlined,
                    title: context.l10n.commonCategory,
                    subtitle: context.l10n.listSettingCategorySubtitle,
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
                    switchValue: null,
                  ),
                ],
              ),
              AppSettingSection(
                title: context.l10n.groupSettingInvitationSection,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10,
                    ),
                    child: AppPill(
                      label:
                          isCreatingInvitation.value
                              ? context.l10n.groupSettingCreatingInvitation
                              : context.l10n.groupSettingCreateInvitation,
                      icon: Icons.person_add,
                      variant: AppPillVariant.soft,
                      onPressed:
                          isCreatingInvitation.value
                              ? null
                              : () async {
                                analytics.logEvent(
                                  name: 'tap_create_grp_invitation',
                                  parameters: {'groupID': groupID},
                                );
                                // Issue #432: グループ名未設定のまま招待すると、招待された側が
                                // 名称未設定のグループに参加することになり混乱を招く。招待前に
                                // グループ名の登録を必須化する。入力欄に名前が入っていれば
                                // （onSubmitted 未確定でも）それを採用し、未保存なら先に保存する。
                                final inputGroupName =
                                    groupNameController.text.trim();
                                if (inputGroupName.isEmpty) {
                                  showGlobalToast(
                                    context.l10n.listSettingGroupNameRequired,
                                    title: null,
                                  );
                                  return;
                                }
                                isCreatingInvitation.value = true;
                                try {
                                  if (inputGroupName != (group.name ?? '')) {
                                    await groupNameUpdate.call(
                                      name: inputGroupName,
                                    );
                                  }
                                  final invitation = await functions
                                      .createGroupInvitation(groupID: groupID);
                                  if (context.mounted) {
                                    await showDialog<void>(
                                      context: context,
                                      builder:
                                          (context) => _InvitationCodeDialog(
                                            groupID: groupID,
                                            invitationCode:
                                                invitation.invitationCode,
                                          ),
                                    );
                                  }
                                  // 招待した直後 = 相手の参加や更新をプッシュ通知で
                                  // 受け取る動機が最も高いタイミングのため、招待コード
                                  // dialog を閉じた後に通知許可を促す (Issue #500)。
                                  if (context.mounted) {
                                    await maybeRequestNotificationPermission(
                                      context,
                                      trigger: 'create_grp_invitation',
                                    );
                                  }
                                } catch (e, st) {
                                  if (context.mounted) {
                                    showErrorSnackBar(context, e, st);
                                  }
                                } finally {
                                  isCreatingInvitation.value = false;
                                }
                              },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
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
      builder:
          (dialogContext) => AlertDialog(
            title: Text(
              context.l10n.groupSettingRemoveMemberConfirmTitle(
                profile.displayName ?? context.l10n.commonUnnamed,
              ),
            ),
            content: Text(context.l10n.groupSettingRemoveMemberConfirmMessage),
            actions: [
              TextButton(
                onPressed: () async {
                  analytics.logEvent(
                    name: 'tap_confirm_remove_member',
                    parameters: {
                      'groupID': groupID,
                      'targetUserID': profile.userID,
                    },
                  );
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
                          content: Text(
                            context.l10n.groupSettingMemberRemoved(
                              profile.displayName ??
                                  context.l10n.groupSettingMemberFallbackName,
                            ),
                          ),
                        ),
                      );
                    }
                  } catch (e, st) {
                    if (context.mounted) {
                      showErrorSnackBar(context, e, st);
                    }
                  } finally {
                    isRemovingMember.value = false;
                  }
                },
                child: Text(
                  context.l10n.commonDelete,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appTheme.neutral.danger,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  analytics.logEvent(
                    name: 'cancel_remove_member',
                    parameters: {'groupID': groupID},
                  );
                  Navigator.pop(dialogContext);
                },
                child: Text(context.l10n.commonCancel),
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

  const _InvitationCodeDialog({
    required this.groupID,
    required this.invitationCode,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.listSettingInvitationCodeTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.groupSettingInvitationCodeMessage),
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
            context.l10n.groupSettingInvitationExpiry,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            analytics.logEvent(
              name: 'tap_copy_invitation_code',
              parameters: {'groupID': groupID},
            );
            final copiedMessage = context.l10n.listSettingInvitationCodeCopied;
            await Clipboard.setData(ClipboardData(text: invitationCode));
            // ダイアログ上の SnackBar は背後の Scaffold に描画されて
            // 見えないため、前面に出るグローバルトーストで通知する。
            showGlobalToast(copiedMessage, title: null);
          },
          child: Text(context.l10n.commonCopy),
        ),
        TextButton(
          onPressed: () {
            analytics.logEvent(
              name: 'cancel_invitation_dialog',
              parameters: {'groupID': groupID},
            );
            Navigator.pop(context);
          },
          child: Text(context.l10n.commonClose),
        ),
      ],
    );
  }
}
