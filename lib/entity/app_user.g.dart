// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) => _$AppUserImpl(
      id: json['id'] as String?,
      remainingFreeAIFunction: (json['remainingFreeAIFunction'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) => <String, dynamic>{
      'id': instance.id,
      'remainingFreeAIFunction': instance.remainingFreeAIFunction,
    };
