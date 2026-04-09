import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'app_user.g.dart';
part 'app_user.freezed.dart';

/// アプリのユーザーを表すエンティティ。
///
/// Firebase Authentication のユーザー情報と紐づき、
/// [Group] への所属や [GroupUserProfile] を通じたグループ内表示名の管理に使用される。
///
/// ## ユースケース
/// - サインアップ時に作成され、Firebase Auth の displayName・photoURL をマッピングする
/// - [defaultGroupID] でアプリ起動時に表示するグループを決定する
@freezed
abstract class AppUser with _$AppUser {
  const AppUser._();

  @JsonSerializable(explicitToJson: true)
  const factory AppUser({
    required String id,
    // NOTE: アプリ開始時に作られるデータであり、その時にはdefaultGroupIDができてない。作成されるパターンはこのケースのみなので required はつけない。テストの時とかに簡単に使えるようにするため
    String? defaultGroupID,
    // NOTE: Firebase Auth の displayName からマッピング。匿名ユーザーや既存ユーザーでは null になりうる
    String? name,
    // NOTE: Firebase Auth の photoURL からマッピング。匿名ユーザーや既存ユーザーでは null になりうる
    String? iconImageURL,
    // NOTE: テーマカラーのHEX値。プレミアムユーザーのみ変更可能。nullの場合はデフォルト(deepPurple=#673AB7)を使用する
    String? themeColorHex,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  static AppUser fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      AppUser.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(AppUser user, SetOptions? options) =>
      user.toJson();
}
