// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RemoteConfigParameter _$RemoteConfigParameterFromJson(
  Map<String, dynamic> json,
) => _RemoteConfigParameter(
  releasedVersion:
      json['releasedVersion'] as String? ??
      RemoteConfigParameterDefaultValues.releasedVersion,
  minimumAppVersion:
      json['minimumAppVersion'] as String? ??
      RemoteConfigParameterDefaultValues.minimumAppVersion,
);

Map<String, dynamic> _$RemoteConfigParameterToJson(
  _RemoteConfigParameter instance,
) => <String, dynamic>{
  'releasedVersion': instance.releasedVersion,
  'minimumAppVersion': instance.minimumAppVersion,
};
