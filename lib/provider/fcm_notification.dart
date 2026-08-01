import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';

/// FCM通知の受信ハンドリングを初期化する。
/// アプリ起動後に一度呼び出す。
class FcmNotificationHandler {
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    // フォアグラウンド通知: グローバルトーストで表示（モーダルの上にも出る）
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
        '[FCM] onMessage 受信: messageId=${message.messageId} '
        'notification=${message.notification?.title}/${message.notification?.body}',
      );
      final notification = message.notification;
      if (notification == null) {
        return;
      }
      showGlobalToast(notification.body ?? '', title: notification.title);
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
