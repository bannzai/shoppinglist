// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TextMemoRowImpl _$$TextMemoRowImplFromJson(Map<String, dynamic> json) => _$TextMemoRowImpl(
      id: json['id'] as String?,
      message: json['message'] as String,
      reminderDateTime: const NullableTimestampConverter().fromJson(json['reminderDateTime'] as Timestamp?),
      createdDateTime: const ClientCreatedTimestamp().fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp().fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp().fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp().fromJson(json['serverUpdatedDateTime']),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$TextMemoRowImplToJson(_$TextMemoRowImpl instance) => <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'reminderDateTime': const NullableTimestampConverter().toJson(instance.reminderDateTime),
      'createdDateTime': const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime': const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime': const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime': const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
      'type': instance.$type,
    };

_$LinkMemoRowImpl _$$LinkMemoRowImplFromJson(Map<String, dynamic> json) => _$LinkMemoRowImpl(
      id: json['id'] as String?,
      url: json['url'] as String,
      reminderDateTime: const NullableTimestampConverter().fromJson(json['reminderDateTime'] as Timestamp?),
      createdDateTime: const ClientCreatedTimestamp().fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp().fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp().fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp().fromJson(json['serverUpdatedDateTime']),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$LinkMemoRowImplToJson(_$LinkMemoRowImpl instance) => <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'reminderDateTime': const NullableTimestampConverter().toJson(instance.reminderDateTime),
      'createdDateTime': const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime': const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime': const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime': const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
      'type': instance.$type,
    };
