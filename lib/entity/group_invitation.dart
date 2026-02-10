import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_invitation.g.dart';
part 'group_invitation.freezed.dart';

enum GroupInvitationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('expired')
  expired,
}

@freezed
abstract class GroupInvitation with _$GroupInvitation {
  const GroupInvitation._();

  @JsonSerializable(explicitToJson: true)
  const factory GroupInvitation({
    required String id,
    required String groupID,
    required String inviterUserID,
    required String token,
    required GroupInvitationStatus status,
    @NullableTimestampConverter() DateTime? expiresDateTime,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _GroupInvitation;

  factory GroupInvitation.fromJson(Map<String, dynamic> json) =>
      _$GroupInvitationFromJson(json);

  static GroupInvitation fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      GroupInvitation.fromJson(snapshot.data()!..['id'] = snapshot.id);

  static Map<String, dynamic> toFirestore(
          GroupInvitation invitation, SetOptions? options) =>
      invitation.toJson();
}
