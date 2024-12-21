import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_config_parameter.freezed.dart';
part 'remote_config_parameter.g.dart';

abstract class RemoteConfigKeys {
  static const releasedVersion = 'releasedVersion';
  static const minimumAppVersion = 'minimumAppVersion';
}

abstract class RemoteConfigParameterDefaultValues {
  static const releasedVersion = '1.0.0';
  static const minimumAppVersion = '1.0.0';
}

@freezed
class RemoteConfigParameter with _$RemoteConfigParameter {
  factory RemoteConfigParameter({
    @Default(RemoteConfigParameterDefaultValues.releasedVersion) String releasedVersion,
    @Default(RemoteConfigParameterDefaultValues.minimumAppVersion) String minimumAppVersion,
  }) = _RemoteConfigParameter;

  RemoteConfigParameter._();
  factory RemoteConfigParameter.fromJson(Map<String, dynamic> json) => _$RemoteConfigParameterFromJson(json);
}
