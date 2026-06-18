// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupInvitation _$GroupInvitationFromJson(Map<String, dynamic> json) =>
    _GroupInvitation(
      id: json['id'] as String,
      groupID: json['groupID'] as String,
      inviterUserID: json['inviterUserID'] as String,
      invitationCode: json['invitationCode'] as String,
      status: $enumDecode(_$GroupInvitationStatusEnumMap, json['status']),
      expiresDateTime: const NullableTimestampConverter().fromJson(
        json['expiresDateTime'] as Timestamp?,
      ),
      createdDateTime: const ClientCreatedTimestamp().fromJson(
        json['createdDateTime'] as Timestamp?,
      ),
      updatedDateTime: const ClientUpdatedTimestamp().fromJson(
        json['updatedDateTime'] as Timestamp?,
      ),
      serverCreatedDateTime: const ServerCreatedTimestamp().fromJson(
        json['serverCreatedDateTime'],
      ),
      serverUpdatedDateTime: const ServerUpdatedTimestamp().fromJson(
        json['serverUpdatedDateTime'],
      ),
    );

Map<String, dynamic> _$GroupInvitationToJson(_GroupInvitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupID': instance.groupID,
      'inviterUserID': instance.inviterUserID,
      'invitationCode': instance.invitationCode,
      'status': _$GroupInvitationStatusEnumMap[instance.status]!,
      'expiresDateTime': const NullableTimestampConverter().toJson(
        instance.expiresDateTime,
      ),
      'createdDateTime': const ClientCreatedTimestamp().toJson(
        instance.createdDateTime,
      ),
      'updatedDateTime': const ClientUpdatedTimestamp().toJson(
        instance.updatedDateTime,
      ),
      'serverCreatedDateTime': const ServerCreatedTimestamp().toJson(
        instance.serverCreatedDateTime,
      ),
      'serverUpdatedDateTime': const ServerUpdatedTimestamp().toJson(
        instance.serverUpdatedDateTime,
      ),
    };

const _$GroupInvitationStatusEnumMap = {
  GroupInvitationStatus.pending: 'pending',
  GroupInvitationStatus.accepted: 'accepted',
  GroupInvitationStatus.expired: 'expired',
};
