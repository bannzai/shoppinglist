// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemoImpl _$$MemoImplFromJson(Map<String, dynamic> json) => _$MemoImpl(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      status: $enumDecodeNullable(_$MemoStatusEnumMap, json['status']) ?? MemoStatus.active,
      createdDateTime: const ClientCreatedTimestamp().fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp().fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp().fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp().fromJson(json['serverUpdatedDateTime']),
    );

Map<String, dynamic> _$$MemoImplToJson(_$MemoImpl instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': _$MemoStatusEnumMap[instance.status]!,
      'createdDateTime': const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime': const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime': const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime': const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
    };

const _$MemoStatusEnumMap = {
  MemoStatus.active: 'active',
  MemoStatus.done: 'done',
  MemoStatus.archived: 'archived',
};
