import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// FCM通知の受信ハンドリングを初期化する。
/// アプリ起動後に一度呼び出す。
class FcmNotificationHandler {
  final GlobalKey<NavigatorState> navigatorKey;

  FcmNotificationHandler({required this.navigatorKey});

  void initialize() {
    // フォアグラウンド通知: SnackBarで表示
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      final context = navigatorKey.currentContext;
      if (context == null) return;

      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      scaffoldMessenger?.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notification.title != null)
                Text(
                  notification.title!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (notification.body != null) Text(notification.body!),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    });

    // バックグラウンド通知タップ: アプリ復帰
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] 通知タップでアプリ復帰: ${message.data}');
    });

    // 初回起動通知チェック
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('[FCM] 初回起動通知: ${message.data}');
      }
    });
  }
}
