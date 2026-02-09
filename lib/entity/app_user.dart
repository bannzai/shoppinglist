import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'app_user.g.dart';
part 'app_user.freezed.dart';

@freezed
abstract class AppUser with _$AppUser {
  const AppUser._();

  @JsonSerializable(explicitToJson: true)
  const factory AppUser({
    required String id,
    String? defaultGroupID,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  /// ユーザー専用の1人用グループID。合成IDなのでDBに保持せず算出する
  String get ownGroupID => appUserGroupID(id);

  // TODO: Group Entityができたらそちらに移動する
  // GroupのIDには2パターンある:
  // - 合成ID: ユーザー専用の1人グループ。`group_{appUserID}` の形式で、AppUser作成時に自動的に割り当てられる
  // - 自動生成ID: 複数人で共有するグループ。Firestoreの自動生成IDを使用する
  static String appUserGroupID(String appUserID) => 'group_$appUserID';
}
