import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'local_notification.g.dart';

final _localNotifications = FlutterLocalNotificationsPlugin();

/// flutter_local_notifications のプラグインインスタンスを提供するプロバイダー。
@Riverpod(keepAlive: true, dependencies: [])
FlutterLocalNotificationsPlugin localNotificationsPlugin(Ref ref) {
  return _localNotifications;
}

/// アプリ起動時にローカル通知プラグインを初期化する。
@Riverpod(keepAlive: true, dependencies: [localNotificationsPlugin])
Future<void> localNotificationsInitialized(Ref ref) async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  await ref.watch(localNotificationsPluginProvider).initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );
}
