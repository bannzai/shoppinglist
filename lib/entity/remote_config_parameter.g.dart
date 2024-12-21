// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RemoteConfigParameterImpl _$$RemoteConfigParameterImplFromJson(Map<String, dynamic> json) => _$RemoteConfigParameterImpl(
      releasedVersion: json['releasedVersion'] as String? ?? RemoteConfigParameterDefaultValues.releasedVersion,
      minimumAppVersion: json['minimumAppVersion'] as String? ?? RemoteConfigParameterDefaultValues.minimumAppVersion,
    );

Map<String, dynamic> _$$RemoteConfigParameterImplToJson(_$RemoteConfigParameterImpl instance) => <String, dynamic>{
      'releasedVersion': instance.releasedVersion,
      'minimumAppVersion': instance.minimumAppVersion,
    };
