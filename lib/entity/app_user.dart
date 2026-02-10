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
    // NOTE: アプリ開始時に作られるデータであり、その時にはdefaultGroupIDができてない。作成されるパターンはこのケースのみなので required はつけない。テストの時とかに簡単に使えるようにするため
    String? defaultGroupID,
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
