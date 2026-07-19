import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/components/primitives/app_dialog_shell.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 通知許可が未決定 (notDetermined) の場合のみ、プリパーミッションダイアログを表示し、
/// 同意されたら OS の通知許可ダイアログを表示する。既に許可・拒否済みの場合は何もしない
/// ため、任意のタイミングで繰り返し呼んでも安全 (冪等)。
///
/// グループに招待した・招待された直後 = プッシュ通知を受け取る動機が最も高いタイミングで
/// 呼び出す想定 (Issue #500)。起動時の一律要求は説明なしに OS ダイアログが出て
/// 拒否されやすいため廃止した。
///
/// [trigger] はどの導線から呼ばれたかを analytics に記録するための識別子。
///
/// 通知許可は招待・参加フローの補助であり、ここでの例外が呼び出し元のフローを
/// 失敗扱いにしないよう、例外は握りつぶしてログのみ残す。
Future<void> maybeRequestNotificationPermission(
  BuildContext context, {
  required String trigger,
}) async {
  final NotificationSettings settings;
  try {
    settings = await FirebaseMessaging.instance.getNotificationSettings();
  } catch (e) {
    debugPrint('[NotificationPermission] 通知許可状態の取得エラー: $e');
    return;
  }
  if (settings.authorizationStatus != AuthorizationStatus.notDetermined) {
    return;
  }
  if (!context.mounted) {
    return;
  }

  analytics.logEvent(
    name: 'show_notification_pre_permission',
    parameters: {'trigger': trigger},
  );
  final accepted = await showGeneralDialog<bool>(
    context: context,
    barrierLabel: 'プッシュ通知の許可',
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (_, _, _) => const NotificationPrePermissionDialog(),
  );

  switch (accepted) {
    case true:
      analytics.logEvent(
        name: 'tap_notification_permission_allow',
        parameters: {'trigger': trigger},
      );
      try {
        final result = await FirebaseMessaging.instance.requestPermission();
        analytics.logEvent(
          name: 'notification_permission_result',
          parameters: {
            'trigger': trigger,
            'authorizationStatus': result.authorizationStatus.name,
          },
        );
      } catch (e) {
        debugPrint('[NotificationPermission] 通知許可リクエストエラー: $e');
      }
    case false:
      analytics.logEvent(
        name: 'tap_notification_permission_later',
        parameters: {'trigger': trigger},
      );
    case null:
      analytics.logEvent(
        name: 'dismiss_notification_pre_permission',
        parameters: {'trigger': trigger},
      );
  }
}

/// プッシュ通知の有用性を説明してから OS の許可ダイアログへ誘導するプリパーミッション
/// ダイアログ。[通知を許可] で true、[あとで] で false を pop して返すだけで、
/// OS への許可要求自体は呼び出し元 ([maybeRequestNotificationPermission]) が行う。
class NotificationPrePermissionDialog extends StatelessWidget {
  const NotificationPrePermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return AppDialogShell(
      barrierDismissible: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'プッシュ通知を受け取ろう',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: tokens.neutral.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'グループのメンバーが買い物リストを更新して知らせたときに、'
            'プッシュ通知ですぐに気づけます。'
            '次に表示される確認で通知を許可してください。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: tokens.neutral.ink2,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppPill(
                  key: const ValueKey('notification_pre_permission_later'),
                  label: 'あとで',
                  icon: null,
                  variant: AppPillVariant.neutral,
                  expanded: true,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppPill(
                  key: const ValueKey('notification_pre_permission_allow'),
                  label: '通知を許可',
                  icon: Icons.notifications,
                  variant: AppPillVariant.accent,
                  expanded: true,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
