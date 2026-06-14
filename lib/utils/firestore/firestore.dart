import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// 接続先 Firestore データベース ID。dart-define `FIRESTORE_DATABASE_ID` で指定する。
///
/// 未指定(空文字)の場合は本番の `(default)` データベースに接続する。
/// `development` を指定すると、お問い合わせスナップショットを復元した dev 用
/// named database に接続し、不具合を手元で再現できる
/// (復元先は firebase/functions/src/script/restoreInquirySnapshot.ts と対応)。
const _firestoreDatabaseId = String.fromEnvironment('FIRESTORE_DATABASE_ID');

/// アプリ全体で使う Firestore インスタンス。
///
/// `FirebaseFirestore.instance` を直接使わずこれを使うことで、dart-define による
/// 接続先データベース((default) / development)の切り替えを一元化する。
/// `instanceFor` は app+databaseId 単位でキャッシュされるため getter で都度呼んでよい。
FirebaseFirestore get firestore => _firestoreDatabaseId.isEmpty
    ? FirebaseFirestore.instance
    : FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: _firestoreDatabaseId,
      );
