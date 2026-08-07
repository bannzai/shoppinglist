import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// App Check を有効化する。バックエンド (Firestore / Functions / Storage 等) への
/// リクエストに正規アプリ由来であることの証明トークンを添付する。
///
/// プロバイダはビルド種別で分離する:
/// - debug ビルド: debug プロバイダ (Firebase Console に登録したデバッグトークンで検証)
/// - release ビルド: iOS は App Attest (非対応 OS は DeviceCheck へフォールバック)、
///   Android は Play Integrity
///
/// App Check のトークン添付は isolate ごとの設定のため、main() だけでなく
/// home_widget のバックグラウンド callback など別 entry-point の isolate でも
/// `Firebase.initializeApp()` の直後に呼ぶこと。
Future<void> activateAppCheck() async {
  await FirebaseAppCheck.instance.activate(
    providerAndroid:
        kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
    providerApple:
        kDebugMode
            ? const AppleDebugProvider()
            : const AppleAppAttestWithDeviceCheckFallbackProvider(),
  );
}
