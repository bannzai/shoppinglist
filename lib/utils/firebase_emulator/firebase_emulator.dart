import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// `--dart-define=USE_FIREBASE_EMULATOR=true` を付けたビルドかどうか。
/// 未指定(デフォルト)は false で、本番 Firebase に接続する。
const useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

/// ローカルの Firebase Emulator に各 Firebase SDK を接続する開発用ゲート。
/// [useFirebaseEmulator] が false の場合は何もしない(挙動不変)。
///
/// Emulator 接続は isolate ごとの設定のため、main() だけでなく home_widget の
/// バックグラウンド callback など別 entry-point の isolate でも
/// `Firebase.initializeApp()` の直後に呼ぶこと。
Future<void> connectFirebaseEmulatorIfEnabled() async {
  if (!useFirebaseEmulator) {
    return;
  }
  // Android (Emulator) では localhost が端末自身を指すため、ホストマシンへの
  // ループバックである 10.0.2.2 を既定にする。Android 実機などホストマシンに
  // 別アドレスで到達する構成では FIREBASE_EMULATOR_HOST で明示的に上書きする。
  const overrideHost = String.fromEnvironment('FIREBASE_EMULATOR_HOST');
  final emulatorHost =
      overrideHost.isNotEmpty
          ? overrideHost
          : (defaultTargetPlatform == TargetPlatform.android
              ? '10.0.2.2'
              : 'localhost');
  // 過去に実プロジェクトへ接続した際や前回の Emulator 実行時のディスクキャッシュが
  // Emulator の空データより優先して返り、E2E が本番非接触・再現可能でなくなるのを防ぐため、
  // Emulator 接続時は Firestore の永続キャッシュを無効化する (メモリキャッシュのみ)。
  // useFirestoreEmulator は settings を copyWith で上書きするため、先に設定する。
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );
  // ポートは firebase/firebase.json の emulators セクションと一致させる。
  await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
  // Cloud Functions は instanceFor(region:) が (app, region) 単位でインスタンスを
  // キャッシュするため、ここで接続したインスタンスは
  // utils/functions/firebase_function.dart のグローバル functions と同一で、そちらにも効く。
  FirebaseFunctions.instanceFor(
    region: 'asia-northeast1',
  ).useFunctionsEmulator(emulatorHost, 5001);
  // レシート画像 (receipt_image.dart の FirebaseStorage.instance / Functions の
  // admin.storage()) も本番非接触にするため Storage も Emulator に向ける。
  await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
}
