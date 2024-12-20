import 'package:freezed_annotation/freezed_annotation.dart';

abstract class RemoteConfigKeys {
  static const releasedVersion = 'releasedVersion';
}

abstract class RemoteConfigParameterDefaultValues {
  static const releasedVersion = '1.0.0';
}

@freezed
class RemoteConfigParameter with _$RemoteConfigParameter {
  factory RemoteConfigParameter({
    @Default(RemoteConfigParameterDefaultValues.releasedVersion) String releasedVersion,
  }) = _RemoteConfigParameter;
  RemoteConfigParameter._();
  factory RemoteConfigParameter.fromJson(Map<String, dynamic> json) => _$RemoteConfigParameterFromJson(json);
}
