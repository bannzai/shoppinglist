import 'package:cloud_firestore/cloud_firestore.dart';

/// アプリ全体で使う Firestore インスタンス。
///
/// `FirebaseFirestore.instance` を直接使わずこれを使うことで、接続先の一元管理を保つ。
/// 接続先プロジェクト(dev/prod)はネイティブ設定ファイル
/// (GoogleService-Info.plist / google-services.json) を build configuration で
/// 出し分けることで切り替わるため、ここでの DB 切替は行わない(Issue #410 / ADR 0030)。
FirebaseFirestore get firestore => FirebaseFirestore.instance;
