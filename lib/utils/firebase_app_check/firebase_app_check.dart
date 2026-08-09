import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// App Check を有効化する。バックエンド (Firestore / Functions / Storage 等) への
/// リクエストに正規アプリ由来であることの証明トークンを添付する。
///
/// プロバイダはビルド種別で分離する:
/// - debug ビルド: debug プロバイダ (Firebase Console に登録したデバッグトークンで検証)
/// - release ビルド: iOS は DeviceCheck、Android は Play Integrity
///
/// iOS で App Attest を使うには App ID に App Attest capability を有効化して
/// provisioning profile を再生成する必要があり、この操作は Apple Developer Portal
/// でしか行えない (App Store Connect API の capabilityType に App Attest は無い)。
/// 未対応のまま App Attest を指定すると、`com.apple.developer.devicecheck.appattest-environment`
/// entitlement が profile に含まれず archive が失敗する。
/// 1.0 は DeviceCheck で出し、profile を整備してから App Attest へ切り替える。
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
            : const AppleDeviceCheckProvider(),
  );
}
