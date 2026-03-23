import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'app_user_private.g.dart';
part 'app_user_private.freezed.dart';

/// [AppUser] の非公開情報を保持するエンティティ。
///
/// メールアドレスなど、他ユーザーに公開しないデータを分離して管理する。
/// Firestore 上では `/users/{userID}/privates/` サブコレクションに保存される。
///
/// ## ユースケース
/// - ユーザーのメールアドレスをセキュアに保存・取得する
@freezed
abstract class AppUserPrivate with _$AppUserPrivate {
  const AppUserPrivate._();

  @JsonSerializable(explicitToJson: true)
  const factory AppUserPrivate({
    required String id,
    required String userID,
    String? email,
    required List<String> fcmTokens,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _AppUserPrivate;

  factory AppUserPrivate.fromJson(Map<String, dynamic> json) =>
      _$AppUserPrivateFromJson(json);

  static AppUserPrivate fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      AppUserPrivate.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
          AppUserPrivate private, SetOptions? options) =>
      private.toJson();

  /// composite ID: user_{userID}_private_{userID}
  static String documentID({required String userID}) =>
      'user_${userID}_private_$userID';
}
