// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemoImpl _$$MemoImplFromJson(Map<String, dynamic> json) => _$MemoImpl(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      status: $enumDecodeNullable(_$MemoStatusEnumMap, json['status']) ?? MemoStatus.active,
    );

Map<String, dynamic> _$$MemoImplToJson(_$MemoImpl instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': _$MemoStatusEnumMap[instance.status]!,
    };

const _$MemoStatusEnumMap = {
  MemoStatus.active: 'active',
  MemoStatus.done: 'done',
  MemoStatus.archived: 'archived',
};
