import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/utils/config/environment.dart';

part 'user_developer_token_sync.g.dart';

/// dart-define で注入された [Environment.developerToken] を
/// users/{userID}.developerToken に同期する操作を提供する。
///
/// Cloud Functions の dev only 関数 (grantPromotionalPremium 等) は
/// Secret Manager の SHOPPINGLIST_DEVELOPER_TOKEN と users/{uid}.developerToken の一致比較で
/// 認可するため、開発者ビルドの起動時にこの同期を行う必要がある。
class UserDeveloperTokenSync {
  /// users/{userID} ドキュメントへの参照を提供する Database wrapper。
  final UserDatabase userDatabase;

  UserDeveloperTokenSync({required this.userDatabase});

  /// [Environment.developerToken] が空でなく、現在の users/{userID}.developerToken
  /// と異なる場合のみ Firestore を更新する。
  ///
  /// - dart-define が空文字（本番ユーザービルド）→ 何もしない
  /// - 既存値が一致 → 書き込みスキップ（無駄な write を避ける）
  /// - 不一致 / 未設定 → update する
  Future<void> call() async {
    if (Environment.developerToken.isEmpty) {
      return;
    }
    final appUserSnapshot = await userDatabase.userReference().get();
    if (appUserSnapshot.data()?.developerToken == Environment.developerToken) {
      return;
    }
    await userDatabase.userReference().update({
      'developerToken': Environment.developerToken,
      'updatedDateTime': FieldValue.serverTimestamp(),
      'serverUpdatedDateTime': FieldValue.serverTimestamp(),
    });
  }
}

/// [UserDeveloperTokenSync] を提供する Provider。
@Riverpod(dependencies: [userDatabase])
UserDeveloperTokenSync userDeveloperTokenSync(Ref ref) {
  return UserDeveloperTokenSync(userDatabase: ref.read(userDatabaseProvider));
}
