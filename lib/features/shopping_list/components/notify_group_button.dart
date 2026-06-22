import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_dialog_shell.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/provider/bool_shared_preferences.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

/// 表示中の買い物リストの更新を、グループの他メンバーへプッシュ通知で知らせる手動ボタン。
/// グループに他メンバーが居るときだけ表示する(ソロでは非表示)。
/// 初回タップ時のみ機能説明ダイアログを出し、確定で送信＋説明済みフラグを永続化する。
/// 2回目以降のタップは確認なしで他メンバー全員へ一括送信する。
///
/// 自動検知による通知バー(旧 FamilyNotificationTrigger / NotificationMemberBar)を廃止し、
/// 手動ボタンへ一本化した(Issue #449)。
class NotifyGroupButton extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final String? shoppingListName;

  const NotifyGroupButton({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserID = ref.watch(currentUserIDProvider);
    final memberProfiles =
        ref.watch(groupUserProfilesProvider(groupID: groupID)).asData?.value ??
        [];
    final otherMemberIDs =
        memberProfiles
            .where((p) => p.userID != currentUserID)
            .map((p) => p.userID)
            .toList();

    // 他メンバーが居ないグループ(ソロ)では通知導線を出さない。
    if (otherMemberIDs.isEmpty) {
      return const SizedBox.shrink();
    }

    return IconButton(
      key: const Key('notify_group_button'),
      icon: const Icon(Icons.notifications_outlined),
      tooltip: 'グループに通知',
      onPressed: () => _onPressed(context, ref, otherMemberIDs),
    );
  }

  /// 初回のみ説明ダイアログを出し、確定されたら(または2回目以降は即)他メンバー全員へ送信する。
  Future<void> _onPressed(
    BuildContext context,
    WidgetRef ref,
    List<String> targetUserIDs,
  ) async {
    analytics.logEvent(
      name: 'tap_notify_group',
      parameters: {'groupID': groupID, 'shoppingListID': shoppingListID},
    );

    final hasSeen = ref.read(
      boolSharedPreferencesProvider(key: BoolKey.hasSeenManualNotifyGuide),
    );
    // 説明済みフラグの notifier を await の前に取得しておく。ダイアログ表示中にこの Widget が
    // 破棄(リスト再構築等)されても notifier(keepAlive)は生き続けるため、await 後に
    // ref を触って "Cannot use ref after the widget was disposed" になるのを避ける。
    final guideNotifier = ref.read(
      boolSharedPreferencesProvider(
        key: BoolKey.hasSeenManualNotifyGuide,
      ).notifier,
    );
    if (!hasSeen) {
      final confirmed = await _showGuideDialog(context);
      if (confirmed != true) {
        return;
      }
      await guideNotifier.set(value: true);
    }

    try {
      await functions.sendShoppingListUpdateNotification(
        groupID: groupID,
        shoppingListID: shoppingListID,
        shoppingListName: shoppingListName,
        targetUserIDs: targetUserIDs,
      );
      showGlobalToast('グループに通知しました', title: null);
    } catch (e, st) {
      showGlobalErrorToast(e, st);
    }
  }

  /// 初回タップ時の機能説明ダイアログ。[通知を送る]で true を返す。
  Future<bool?> _showGuideDialog(BuildContext context) {
    final tokens = context.appTheme;
    return showGeneralDialog<bool>(
      context: context,
      barrierLabel: 'グループ通知の説明',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (dialogContext, _, _) {
        return AppDialogShell(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'グループに通知',
                style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                  color: tokens.neutral.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'このボタンを押すと、買い物リストを更新したことを'
                'グループの他のメンバーにプッシュ通知でお知らせします。',
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                  color: tokens.neutral.ink2,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppPill(
                      label: 'キャンセル',
                      icon: null,
                      variant: AppPillVariant.neutral,
                      expanded: true,
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppPill(
                      label: '通知を送る',
                      icon: Icons.notifications,
                      variant: AppPillVariant.accent,
                      expanded: true,
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
