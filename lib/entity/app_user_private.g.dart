// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user_private.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUserPrivate _$AppUserPrivateFromJson(Map<String, dynamic> json) =>
    _AppUserPrivate(
      id: json['id'] as String,
      userID: json['userID'] as String,
      email: json['email'] as String?,
      fcmTokens:
          (json['fcmTokens'] as List<dynamic>).map((e) => e as String).toList(),
      createdDateTime: const ClientCreatedTimestamp()
          .fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp()
          .fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp()
          .fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp()
          .fromJson(json['serverUpdatedDateTime']),
    );

Map<String, dynamic> _$AppUserPrivateToJson(_AppUserPrivate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userID': instance.userID,
      'email': instance.email,
      'fcmTokens': instance.fcmTokens,
      'createdDateTime':
          const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime':
          const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime':
          const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime':
          const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
    };
