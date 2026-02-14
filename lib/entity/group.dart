import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group.g.dart';
part 'group.freezed.dart';

@freezed
abstract class Group with _$Group {
  const Group._();

  @JsonSerializable(explicitToJson: true)
  const factory Group({
    required String id,

    /// グループに所属するユーザーのAppUser.idの配列
    required List<String> memberUserIDs,

    /// グループ名
    required String? name,

    /// グループを作成したユーザーのAppUser.id
    /// NOTE: 既存のグループドキュメントにはこのフィールドが存在しない場合があるためnullable
    String? ownerUserID,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  static Group fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      Group.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(Group group, SetOptions? options) =>
      group.toJson();
}
