import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/components/primitives/app_dialog_shell.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

/// 通知許可がまだ要求されていない場合のみ、プリパーミッションダイアログを表示し、
/// 同意されたら OS の通知許可ダイアログを表示する。既に許可・拒否済みの場合は何もしない
/// ため、任意のタイミングで繰り返し呼んでも安全 (冪等)。
///
/// 「まだ要求されていない」の判定は iOS では notDetermined で行う。Android は
/// firebase_messaging が authorizationStatus を authorized / denied にしかマップせず
/// 未要求でも denied を返すため、requestPermission を一度でも実行したかを
/// SharedPreferences ([BoolKey.hasRequestedNotificationPermission]) で追跡し、
/// 「未要求の denied」だけを要求対象に含める。
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
  // Android は未要求でも denied になる (firebase_messaging Android 実装の
  // getPermissions は authorized=1 / denied=0 の 2 値しか返さない) ため、
  // 要求済みフラグが立っていない denied は「未要求」とみなして要求対象に含める。
  // iOS の denied はユーザーが OS ダイアログで拒否を確定した状態なので対象外。
  final sharedPreferences = await SharedPreferences.getInstance();
  final shouldRequest = switch (settings.authorizationStatus) {
    AuthorizationStatus.notDetermined => true,
    AuthorizationStatus.denied =>
      Platform.isAndroid &&
          !(sharedPreferences.getBool(
                BoolKey.hasRequestedNotificationPermission,
              ) ??
              false),
    _ => false,
  };
  if (!shouldRequest) {
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
    barrierLabel: context.l10n.notificationPermissionBarrierLabel,
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
        // 拒否されても「要求は実行済み」なので、結果に関わらず記録する。
        // 例外時は記録せず、次の導線で再試行できるようにする。
        await sharedPreferences.setBool(
          BoolKey.hasRequestedNotificationPermission,
          true,
        );
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
            context.l10n.notificationPermissionTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: tokens.neutral.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.notificationPermissionMessage,
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
                  label: context.l10n.notificationPermissionLater,
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
                  label: context.l10n.notificationPermissionAllow,
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
