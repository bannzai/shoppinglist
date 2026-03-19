import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'group_invitation.g.dart';
part 'group_invitation.freezed.dart';

/// [GroupInvitation] のステータス。
enum GroupInvitationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('expired')
  expired,
}

/// [Group] へのユーザー招待を管理するエンティティ。
///
/// 招待者（[AppUser]）が招待コードを発行し、被招待者がそのコードを入力して
/// グループに参加する。招待には有効期限があり、期限切れは [GroupInvitationStatus.expired] となる。
///
/// ## ユースケース
/// - グループのオーナーが招待コードを生成し、他ユーザーに共有する
/// - 被招待者が招待コードを入力してグループに参加する
@freezed
abstract class GroupInvitation with _$GroupInvitation {
  const GroupInvitation._();

  @JsonSerializable(explicitToJson: true)
  const factory GroupInvitation({
    required String id,
    required String groupID,
    required String inviterUserID,
    required String invitationCode,
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
