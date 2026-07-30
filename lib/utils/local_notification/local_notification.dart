import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// flutter_local_notifications のプラグインインスタンス。
///
/// 状態を持たない native への glue のため Provider でラップせず直接参照する
/// （`functions` と同じ扱い。参照: .claude/rules/firebase-functions-call-rules.md）。
final localNotifications = FlutterLocalNotificationsPlugin();

/// アプリ起動時にローカル通知プラグインを初期化する。
Future<void> localNotificationsInitialize() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  await localNotifications.initialize(
    settings: const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    ),
  );
}
