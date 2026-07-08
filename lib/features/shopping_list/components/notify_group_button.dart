import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
class NotifyGroupButton extends HookConsumerWidget {
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
    // 未ログイン時はボタンを出さない。currentUserID が null だと
    // `p.userID != currentUserID` が常に true になり自分自身を他メンバー扱いしてしまうため、
    // 防衛的に早期リターンする。
    if (currentUserID == null) {
      return const SizedBox.shrink();
    }

    final memberProfiles =
        ref.watch(groupUserProfilesProvider(groupID: groupID)).asData?.value ??
        [];
    final otherMemberIDs =
        memberProfiles
            .where((p) => p.userID != currentUserID)
            .map((p) => p.userID)
            .toList();

    // 説明済みフラグは状態 Provider のため build 内で watch し、callback へ値で渡す
    // (callback 内での ref.read による状態取得を避ける — Riverpod 規約)。
    final hasSeen = ref.watch(
      boolSharedPreferencesProvider(key: BoolKey.hasSeenManualNotifyGuide),
    );
    final guideNotifier = ref.watch(
      boolSharedPreferencesProvider(
        key: BoolKey.hasSeenManualNotifyGuide,
      ).notifier,
    );

    // 送信中フラグ。説明済みユーザーはタップ直後にダイアログが出ず送信完了までボタンが
    // 有効なままになるため、連打/ダブルタップで同じ通知が重複送信されるのを防ぐ。
    final isSending = useState(false);

    // 他メンバーが居ないグループ(ソロ)では通知導線を出さない。
    if (otherMemberIDs.isEmpty) {
      return const SizedBox.shrink();
    }

    return IconButton(
      key: const Key('notify_group_button'),
      icon: const Icon(Icons.notifications_outlined),
      tooltip: 'グループに通知',
      onPressed:
          isSending.value
              ? null
              : () => _onPressed(
                context,
                otherMemberIDs,
                hasSeen: hasSeen,
                isSending: isSending,
                guideNotifier: guideNotifier,
              ),
    );
  }

  /// 初回のみ説明ダイアログを出し、確定されたら(または2回目以降は即)他メンバー全員へ送信する。
  Future<void> _onPressed(
    BuildContext context,
    List<String> targetUserIDs, {
    required bool hasSeen,
    required ValueNotifier<bool> isSending,
    required BoolSharedPreferences guideNotifier,
  }) async {
    analytics.logEvent(
      name: 'tap_notify_group',
      parameters: {'groupID': groupID, 'shoppingListID': shoppingListID},
    );

    // 送信中はボタンを無効化する(二重送信防止)。タップ直後で Widget が生きているうちに立てる。
    isSending.value = true;
    try {
      if (!hasSeen) {
        final confirmed = await _showGuideDialog(context);
        if (confirmed != true) {
          return;
        }
        await guideNotifier.set(value: true);
      }

      await functions.sendShoppingListUpdateNotification(
        groupID: groupID,
        shoppingListID: shoppingListID,
        shoppingListName: shoppingListName,
        targetUserIDs: targetUserIDs,
      );
      showGlobalToast('グループに通知しました', title: null);
    } catch (e, st) {
      showGlobalErrorToast(e, st);
    } finally {
      // ダイアログ表示中に Widget が破棄されると useState の ValueNotifier も破棄されるため、
      // 生存している時だけフラグを戻す(破棄後の代入による例外を避ける)。
      if (context.mounted) {
        isSending.value = false;
      }
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
          barrierDismissible: true,
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
