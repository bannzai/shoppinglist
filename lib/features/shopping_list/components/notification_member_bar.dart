import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';

/// 買い物リスト更新時に SnackBar 内に表示するメンバー通知バー。
/// `design_handoff_shopping_list/source/screens-list.jsx#NotifySnack` 相当。
///
/// 構造 (横方向):
///  bell (16, surface) → 2 段テキスト (Expanded) → 重なりアバター (-6 marginLeft) → accent pill「全員に通知」
class NotificationMemberBar extends HookConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final String? shoppingListName;

  /// 直近で追加された非空メッセージ。null の場合は「リストが更新されました」表記にフォールバック。
  final String? addedItemMessage;
  final String currentUserID;
  final List<GroupUserProfile> memberProfiles;

  const NotificationMemberBar({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListName,
    required this.addedItemMessage,
    required this.currentUserID,
    required this.memberProfiles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherMembers =
        memberProfiles.where((p) => p.userID != currentUserID).toList();
    if (otherMembers.isEmpty) return const SizedBox.shrink();

    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final sendingUserIDs = useState<Set<String>>({});
    final sentUserIDs = useState<Set<String>>({});

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.notifications_outlined, size: 16, color: neutral.surface),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                addedItemMessage != null
                    ? '『$addedItemMessage』を追加'
                    : 'リストが更新されました',
                style: TextStyle(
                  color: neutral.surface,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '家族に通知しますか?',
                style: TextStyle(
                  color: neutral.surface.withValues(alpha: 0.7),
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _StackedMemberAvatars(
          otherMembers: otherMembers,
          sendingUserIDs: sendingUserIDs,
          sentUserIDs: sentUserIDs,
          inkColor: neutral.ink,
          fallbackBg: tokens.accent,
          onTapAvatar: (profile) => _sendNotification(
            context: context,
            targetUserIDs: [profile.userID],
            sendingUserIDs: sendingUserIDs,
            sentUserIDs: sentUserIDs,
          ),
        ),
        const SizedBox(width: 10),
        _SendAllButton(
          otherMembers: otherMembers,
          sendingUserIDs: sendingUserIDs,
          sentUserIDs: sentUserIDs,
          accent: tokens.accent,
          onSendAll: () => _sendNotification(
            context: context,
            targetUserIDs: otherMembers.map((m) => m.userID).toList(),
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

/// `screens-list.jsx#NotifySnack` のメンバーアバター: 26×26 円 + 1.5px ink ボーダー、
/// 配色循環 ['#C2410C','#1F6B4E','#0F4C81']、Stack で -6 marginLeft の重なり、
/// 4 件目以降は "+N" バッジでまとめる。
class _StackedMemberAvatars extends StatelessWidget {
  static const _palette = <Color>[
    Color(0xFFC2410C),
    Color(0xFF1F6B4E),
    Color(0xFF0F4C81),
  ];
  static const _avatarSize = 26.0;
  static const _overlap = 6.0;
  static const _maxVisible = 3;

  final List<GroupUserProfile> otherMembers;
  final ValueNotifier<Set<String>> sendingUserIDs;
  final ValueNotifier<Set<String>> sentUserIDs;
  final Color inkColor;
  final Color fallbackBg;
  final void Function(GroupUserProfile profile) onTapAvatar;

  const _StackedMemberAvatars({
    required this.otherMembers,
    required this.sendingUserIDs,
    required this.sentUserIDs,
    required this.inkColor,
    required this.fallbackBg,
    required this.onTapAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final visible = otherMembers.take(_maxVisible).toList();
    final overflow = otherMembers.length - visible.length;
    final slotCount = visible.length + (overflow > 0 ? 1 : 0);
    final width =
        _avatarSize + (slotCount - 1) * (_avatarSize - _overlap);

    return SizedBox(
      width: width,
      height: _avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * (_avatarSize - _overlap),
              child: _NotifyAvatar(
                profile: visible[i],
                bg: _palette[i % _palette.length],
                borderColor: inkColor,
                isSending:
                    sendingUserIDs.value.contains(visible[i].userID),
                isSent: sentUserIDs.value.contains(visible[i].userID),
                onTap: () => onTapAvatar(visible[i]),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: visible.length * (_avatarSize - _overlap),
              child: _OverflowAvatar(
                count: overflow,
                bg: fallbackBg,
                borderColor: inkColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _NotifyAvatar extends StatelessWidget {
  final GroupUserProfile profile;
  final Color bg;
  final Color borderColor;
  final bool isSending;
  final bool isSent;
  final VoidCallback onTap;

  const _NotifyAvatar({
    required this.profile,
    required this.bg,
    required this.borderColor,
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
            color: bg,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: isSending
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white,
                  ),
                )
              : isSent
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
        ),
      ),
    );
  }
}

class _OverflowAvatar extends StatelessWidget {
  final int count;
  final Color bg;
  final Color borderColor;
  const _OverflowAvatar({
    required this.count,
    required this.bg,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SendAllButton extends StatelessWidget {
  final List<GroupUserProfile> otherMembers;
  final ValueNotifier<Set<String>> sendingUserIDs;
  final ValueNotifier<Set<String>> sentUserIDs;
  final Color accent;
  final VoidCallback onSendAll;

  const _SendAllButton({
    required this.otherMembers,
    required this.sendingUserIDs,
    required this.sentUserIDs,
    required this.accent,
    required this.onSendAll,
  });

  @override
  Widget build(BuildContext context) {
    final allSent =
        otherMembers.every((m) => sentUserIDs.value.contains(m.userID));
    final anySending =
        otherMembers.any((m) => sendingUserIDs.value.contains(m.userID));
    final disabled = allSent || anySending;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onSendAll,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: disabled ? accent.withValues(alpha: 0.5) : accent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            allSent ? '送信済み' : '全員に通知',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// 通知送信用 SnackBar を表示する。ソログループ（自分のみ）の場合は表示しない。
/// `design_handoff_shopping_list/source/screens-list.jsx#NotifySnack` 相当。
/// ink 背景 + 角丸 14、左スワイプ dismiss、5 秒で自動消滅。
/// `addedItemMessage` を渡すと 1 段目を「『XXX』を追加」表記に切り替える。
void showNotificationSnackBar({
  required BuildContext context,
  required String groupID,
  required String shoppingListID,
  required String? shoppingListName,
  required String? addedItemMessage,
  required String currentUserID,
  required List<GroupUserProfile> memberProfiles,
}) {
  final otherMembers =
      memberProfiles.where((p) => p.userID != currentUserID).toList();
  if (otherMembers.isEmpty) return;

  final tokens = Theme.of(context).extension<AppTokens>();
  final background = tokens?.neutral.ink ?? const Color(0xFF1B1813);

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: NotificationMemberBar(
        groupID: groupID,
        shoppingListID: shoppingListID,
        shoppingListName: shoppingListName,
        addedItemMessage: addedItemMessage,
        currentUserID: currentUserID,
        memberProfiles: memberProfiles,
      ),
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      backgroundColor: background,
      // 仕様: FAB(56) + bottom margin(90) の上に乗せるため bottom 156。
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 156),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      dismissDirection: DismissDirection.startToEnd,
      elevation: 6,
    ),
  );
}
