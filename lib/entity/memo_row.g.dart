// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextMemoRow _$TextMemoRowFromJson(Map<String, dynamic> json) => TextMemoRow(
      id: json['id'] as String,
      memoID: json['memoID'] as String,
      message: json['message'] as String,
      order: (json['order'] as num).toInt(),
      status: $enumDecodeNullable(_$MemoRowStatusEnumMap, json['status']) ??
          MemoRowStatus.unchecked,
      reminderDateTime: const NullableTimestampConverter()
          .fromJson(json['reminderDateTime'] as Timestamp?),
      createdDateTime: const ClientCreatedTimestamp()
          .fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp()
          .fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp()
          .fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp()
          .fromJson(json['serverUpdatedDateTime']),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$TextMemoRowToJson(TextMemoRow instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memoID': instance.memoID,
      'message': instance.message,
      'order': instance.order,
      'status': _$MemoRowStatusEnumMap[instance.status]!,
      'reminderDateTime':
          const NullableTimestampConverter().toJson(instance.reminderDateTime),
      'createdDateTime':
          const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime':
          const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime':
          const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime':
          const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
      'type': instance.$type,
    };

const _$MemoRowStatusEnumMap = {
  MemoRowStatus.checked: 'checked',
  MemoRowStatus.unchecked: 'unchecked',
};

LinkMemoRow _$LinkMemoRowFromJson(Map<String, dynamic> json) => LinkMemoRow(
      id: json['id'] as String,
      memoID: json['memoID'] as String,
      url: json['url'] as String,
      order: (json['order'] as num).toInt(),
      metadataTitle: json['metadataTitle'] as String?,
      metadataDescription: json['metadataDescription'] as String?,
      metadataImageURL: json['metadataImageURL'] as String?,
      status: $enumDecodeNullable(_$MemoRowStatusEnumMap, json['status']) ??
          MemoRowStatus.unchecked,
      reminderDateTime: const NullableTimestampConverter()
          .fromJson(json['reminderDateTime'] as Timestamp?),
      createdDateTime: const ClientCreatedTimestamp()
          .fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp()
          .fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp()
          .fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp()
          .fromJson(json['serverUpdatedDateTime']),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$LinkMemoRowToJson(LinkMemoRow instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memoID': instance.memoID,
      'url': instance.url,
      'order': instance.order,
      'metadataTitle': instance.metadataTitle,
      'metadataDescription': instance.metadataDescription,
      'metadataImageURL': instance.metadataImageURL,
      'status': _$MemoRowStatusEnumMap[instance.status]!,
      'reminderDateTime':
          const NullableTimestampConverter().toJson(instance.reminderDateTime),
      'createdDateTime':
          const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime':
          const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime':
          const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime':
          const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
      'type': instance.$type,
    };
