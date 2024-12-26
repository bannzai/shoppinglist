// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TextMemoRowImpl _$$TextMemoRowImplFromJson(Map<String, dynamic> json) => _$TextMemoRowImpl(
      id: json['id'] as String?,
      memoID: json['memoID'] as String,
      message: json['message'] as String,
      status: $enumDecodeNullable(_$MemoRowStatusEnumMap, json['status']) ?? MemoRowStatus.unchecked,
      reminderDateTime: const NullableTimestampConverter().fromJson(json['reminderDateTime'] as Timestamp?),
      ttlExpiredDateTime: const NullableTimestampConverter().fromJson(json['ttlExpiredDateTime'] as Timestamp?),
      deletedDateTime: const NullableTimestampConverter().fromJson(json['deletedDateTime'] as Timestamp?),
      createdDateTime: const ClientCreatedTimestamp().fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp().fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp().fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp().fromJson(json['serverUpdatedDateTime']),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$TextMemoRowImplToJson(_$TextMemoRowImpl instance) => <String, dynamic>{
      'id': instance.id,
      'memoID': instance.memoID,
      'message': instance.message,
      'status': _$MemoRowStatusEnumMap[instance.status]!,
      'reminderDateTime': const NullableTimestampConverter().toJson(instance.reminderDateTime),
      'ttlExpiredDateTime': const NullableTimestampConverter().toJson(instance.ttlExpiredDateTime),
      'deletedDateTime': const NullableTimestampConverter().toJson(instance.deletedDateTime),
      'createdDateTime': const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime': const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime': const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime': const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
      'type': instance.$type,
    };

const _$MemoRowStatusEnumMap = {
  MemoRowStatus.checked: 'checked',
  MemoRowStatus.unchecked: 'unchecked',
};

_$LinkMemoRowImpl _$$LinkMemoRowImplFromJson(Map<String, dynamic> json) => _$LinkMemoRowImpl(
      id: json['id'] as String?,
      memoID: json['memoID'] as String,
      url: json['url'] as String,
      metadataTitle: json['metadataTitle'] as String?,
      metadataDescription: json['metadataDescription'] as String?,
      metadataImageURL: json['metadataImageURL'] as String?,
      status: $enumDecodeNullable(_$MemoRowStatusEnumMap, json['status']) ?? MemoRowStatus.unchecked,
      reminderDateTime: const NullableTimestampConverter().fromJson(json['reminderDateTime'] as Timestamp?),
      ttlExpiredDateTime: const NullableTimestampConverter().fromJson(json['ttlExpiredDateTime'] as Timestamp?),
      deletedDateTime: const NullableTimestampConverter().fromJson(json['deletedDateTime'] as Timestamp?),
      createdDateTime: const ClientCreatedTimestamp().fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp().fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp().fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp().fromJson(json['serverUpdatedDateTime']),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$LinkMemoRowImplToJson(_$LinkMemoRowImpl instance) => <String, dynamic>{
      'id': instance.id,
      'memoID': instance.memoID,
      'url': instance.url,
      'metadataTitle': instance.metadataTitle,
      'metadataDescription': instance.metadataDescription,
      'metadataImageURL': instance.metadataImageURL,
      'status': _$MemoRowStatusEnumMap[instance.status]!,
      'reminderDateTime': const NullableTimestampConverter().toJson(instance.reminderDateTime),
      'ttlExpiredDateTime': const NullableTimestampConverter().toJson(instance.ttlExpiredDateTime),
      'deletedDateTime': const NullableTimestampConverter().toJson(instance.deletedDateTime),
      'createdDateTime': const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime': const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime': const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime': const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
      'type': instance.$type,
    };
