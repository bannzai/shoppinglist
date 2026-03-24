import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shoppinglist/features/resolver/database.dart';

/// FCMトークンをFirestoreに登録する。
/// アプリ起動後、認証済みユーザーのprivatesドキュメントにトークンを保存する。
class FcmTokenRegistration {
  final UserDatabase userDatabase;

  FcmTokenRegistration({required this.userDatabase});

  Future<void> registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _saveToken(token);
      }
    } catch (e) {
      debugPrint('[FCM] トークン取得エラー: $e');
    }
  }

  void listenTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      try {
        await _saveToken(token);
      } catch (e) {
        debugPrint('[FCM] トークン更新保存エラー: $e');
      }
    });
  }

  Future<void> _saveToken(String token) async {
    await userDatabase.privateReference().update({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'updatedDateTime': FieldValue.serverTimestamp(),
      'serverUpdatedDateTime': FieldValue.serverTimestamp(),
    });
    debugPrint('[FCM] トークン保存完了: ${token.substring(0, 10)}...');
  }
}
