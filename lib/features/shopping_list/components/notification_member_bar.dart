import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';

/// 買い物リスト更新時にSnackBar内に表示するメンバーアイコンバー。
/// メンバーアイコンをタップすると、そのメンバーに通知を送信する。
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
    final otherMembers = memberProfiles
        .where((p) => p.userID != currentUserID)
        .toList();

    if (otherMembers.isEmpty) {
      return const SizedBox.shrink();
    }

    // 全員に一括送信するか、個別に送信するかの状態管理
    final sendingUserIDs = useState<Set<String>>({});
    final sentUserIDs = useState<Set<String>>({});

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.notifications_none, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        const Text(
          '通知:',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        const SizedBox(width: 8),
        // 全員送信ボタン
        _SendAllButton(
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
        const SizedBox(width: 4),
        // 個別メンバーアイコン
        ...otherMembers.map((profile) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _MemberAvatar(
              profile: profile,
              isSending: sendingUserIDs.value.contains(profile.userID),
              isSent: sentUserIDs.value.contains(profile.userID),
              onTap: () => _sendNotification(
                context: context,
                targetUserIDs: [profile.userID],
                sendingUserIDs: sendingUserIDs,
                sentUserIDs: sentUserIDs,
              ),
            ),
          );
        }),
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

class _SendAllButton extends StatelessWidget {
  final List<GroupUserProfile> otherMembers;
  final ValueNotifier<Set<String>> sendingUserIDs;
  final ValueNotifier<Set<String>> sentUserIDs;
  final VoidCallback onSendAll;

  const _SendAllButton({
    required this.otherMembers,
    required this.sendingUserIDs,
    required this.sentUserIDs,
    required this.onSendAll,
  });

  @override
  Widget build(BuildContext context) {
    final allSent = otherMembers.every(
        (m) => sentUserIDs.value.contains(m.userID));
    final anySending = otherMembers.any(
        (m) => sendingUserIDs.value.contains(m.userID));

    return InkWell(
      onTap: allSent || anySending ? null : onSendAll,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: allSent
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (anySending)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else if (allSent)
              const Icon(Icons.check, size: 14, color: Colors.greenAccent)
            else
              const Icon(Icons.send, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              allSent ? '送信済み' : '全員',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isSent
                  ? Colors.green.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.3),
              child: isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : isSent
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 通知送信用SnackBarを表示する。ソログループ（自分のみ）の場合は表示しない。
void showNotificationSnackBar({
  required BuildContext context,
  required String groupID,
  required String shoppingListID,
  required String? shoppingListName,
  required String currentUserID,
  required List<GroupUserProfile> memberProfiles,
}) {
  final otherMembers = memberProfiles
      .where((p) => p.userID != currentUserID)
      .toList();

  if (otherMembers.isEmpty) return;

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: NotificationMemberBar(
        groupID: groupID,
        shoppingListID: shoppingListID,
        shoppingListName: shoppingListName,
        currentUserID: currentUserID,
        memberProfiles: memberProfiles,
      ),
      duration: const Duration(seconds: 10),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
