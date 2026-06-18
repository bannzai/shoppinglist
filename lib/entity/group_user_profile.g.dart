// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupUserProfile _$GroupUserProfileFromJson(Map<String, dynamic> json) =>
    _GroupUserProfile(
      id: json['id'] as String,
      groupID: json['groupID'] as String,
      userID: json['userID'] as String,
      displayName: json['displayName'] as String?,
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

Map<String, dynamic> _$GroupUserProfileToJson(_GroupUserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupID': instance.groupID,
      'userID': instance.userID,
      'displayName': instance.displayName,
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
