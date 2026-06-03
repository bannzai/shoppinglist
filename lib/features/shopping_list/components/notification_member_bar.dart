import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';

/// 買い物リスト更新時に SnackBar 内に表示するメンバーアイコンバー。
/// `design_handoff_shoppinglist/preview/screens-list.jsx#NotifySnack` 相当。
/// 仕様: アバター 26×26、-6px overlap、accent 全員 pill、2 段テキスト。
class NotificationMemberBar extends HookConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final String? shoppingListName;
  final String currentUserID;
  final List<GroupUserProfile> memberProfiles;

  const NotificationMemberBar({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListName,
    required this.currentUserID,
    required this.memberProfiles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherMembers =
        memberProfiles.where((p) => p.userID != currentUserID).toList();

    if (otherMembers.isEmpty) {
      return const SizedBox.shrink();
    }

    final sendingUserIDs = useState<Set<String>>({});
    final sentUserIDs = useState<Set<String>>({});
    final tokens = context.tokens;

    final titleText = (shoppingListName != null && shoppingListName!.isNotEmpty)
        ? '「$shoppingListName」が更新されました'
        : 'リストが更新されました';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titleText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                // SSOT: screens-list.jsx#NotifySnack
                '家族に通知しますか?',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      height: 1.3,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _SendAllButton(
          accent: tokens.accent,
          otherMembers: otherMembers,
          sendingUserIDs: sendingUserIDs,
          sentUserIDs: sentUserIDs,
          onSendAll: () => _sendNotification(
            context: context,
            targetUserIDs: otherMembers.map((m) => m.userID).toList(),
            sendingUserIDs: sendingUserIDs,
            sentUserIDs: sentUserIDs,
          ),
        ),
        const SizedBox(width: 8),
        _MemberAvatarStack(
          accent: tokens.accent,
          members: otherMembers,
          sendingUserIDs: sendingUserIDs.value,
          sentUserIDs: sentUserIDs.value,
          onTap: (userID) => _sendNotification(
            context: context,
            targetUserIDs: [userID],
            sendingUserIDs: sendingUserIDs,
            sentUserIDs: sentUserIDs,
          ),
        ),
      ],
    );
  }

  Future<void> _sendNotification({
    required BuildContext context,
    required List<String> targetUserIDs,
    required ValueNotifier<Set<String>> sendingUserIDs,
    required ValueNotifier<Set<String>> sentUserIDs,
  }) async {
    sendingUserIDs.value = {...sendingUserIDs.value, ...targetUserIDs};
    try {
      await functions.sendShoppingListUpdateNotification(
        groupID: groupID,
        shoppingListID: shoppingListID,
        shoppingListName: shoppingListName,
        targetUserIDs: targetUserIDs,
      );
      sentUserIDs.value = {...sentUserIDs.value, ...targetUserIDs};
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      sendingUserIDs.value = Set.from(sendingUserIDs.value)
        ..removeAll(targetUserIDs);
    }
  }
}

/// 全員に通知する pill ボタン。accent solid 背景に白文字。
class _SendAllButton extends StatelessWidget {
  final Color accent;
  final List<GroupUserProfile> otherMembers;
  final ValueNotifier<Set<String>> sendingUserIDs;
  final ValueNotifier<Set<String>> sentUserIDs;
  final VoidCallback onSendAll;

  const _SendAllButton({
    required this.accent,
    required this.otherMembers,
    required this.sendingUserIDs,
    required this.sentUserIDs,
    required this.onSendAll,
  });

  @override
  Widget build(BuildContext context) {
    final allSent =
        otherMembers.every((m) => sentUserIDs.value.contains(m.userID));
    final anySending =
        otherMembers.any((m) => sendingUserIDs.value.contains(m.userID));

    return InkWell(
      onTap: allSent || anySending ? null : onSendAll,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: allSent ? Colors.green.withValues(alpha: 0.45) : accent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (anySending)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else if (allSent)
              const Icon(Icons.check, size: 14, color: Colors.white)
            else
              const Icon(Icons.notifications, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              // `design_handoff_shoppinglist/preview/screens-list.jsx#NotifySnack`
              // のラベル「全員に通知」を SSOT として採用 (短縮形「全員」から移行)。
              allSent ? '送信済み' : '全員に通知',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// メンバーアバターの -6px overlap スタック。最大 3 名表示。
class _MemberAvatarStack extends StatelessWidget {
  final Color accent;
  final List<GroupUserProfile> members;
  final Set<String> sendingUserIDs;
  final Set<String> sentUserIDs;
  final void Function(String userID) onTap;

  const _MemberAvatarStack({
    required this.accent,
    required this.members,
    required this.sendingUserIDs,
    required this.sentUserIDs,
    required this.onTap,
  });

  static const _size = 26.0;
  static const _step = 20.0; // 26 - 6 overlap

  @override
  Widget build(BuildContext context) {
    final shown = members.take(3).toList();
    if (shown.isEmpty) {
      return const SizedBox.shrink();
    }
    final width = (shown.length - 1) * _step + _size;
    return SizedBox(
      width: width,
      height: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(shown.length, (i) {
          final profile = shown[i];
          return Positioned(
            left: i * _step,
            child: _MemberAvatar(
              profile: profile,
              isSending: sendingUserIDs.contains(profile.userID),
              isSent: sentUserIDs.contains(profile.userID),
              onTap: () => onTap(profile.userID),
            ),
          );
        }),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  final GroupUserProfile profile;
  final bool isSending;
  final bool isSent;
  final VoidCallback onTap;

  const _MemberAvatar({
    required this.profile,
    required this.isSending,
    required this.isSent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = (profile.displayName?.isNotEmpty == true)
        ? profile.displayName![0].toUpperCase()
        : '?';

    return GestureDetector(
      onTap: isSending || isSent ? null : onTap,
      child: Tooltip(
        message: profile.displayName ?? '名前未設定',
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSent
                ? Colors.green.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.3),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          alignment: Alignment.center,
          child: isSending
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : isSent
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      initial,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
        ),
      ),
    );
  }
}

/// 通知送信用トーストを表示する。ソログループ（自分のみ）の場合は表示しない。
/// `design_handoff_shoppinglist/preview/screens-list.jsx#NotifySnack` 相当。
/// モーダル表示中でも最前面に出すため、グローバルトースト経由で表示する。
/// ink 背景 + 角丸 14 は `ToastOverlay` の `_ToastFrame` が付与する。5 秒で自動消滅。
void showNotificationToast({
  required String groupID,
  required String shoppingListID,
  required String? shoppingListName,
  required String currentUserID,
  required List<GroupUserProfile> memberProfiles,
}) {
  if (memberProfiles.where((p) => p.userID != currentUserID).isEmpty) {
    return;
  }

  showGlobalToastWidget(
    NotificationMemberBar(
      groupID: groupID,
      shoppingListID: shoppingListID,
      shoppingListName: shoppingListName,
      currentUserID: currentUserID,
      memberProfiles: memberProfiles,
    ),
  );
}
