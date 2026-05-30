import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'local_notification.g.dart';

final localNotifications = FlutterLocalNotificationsPlugin();

/// flutter_local_notifications のプラグインインスタンスを提供するプロバイダー。
@Riverpod(keepAlive: true, dependencies: [])
FlutterLocalNotificationsPlugin localNotificationsPlugin(Ref ref) {
  return localNotifications;
}

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
