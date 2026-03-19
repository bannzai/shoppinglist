import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_config_parameter.freezed.dart';
part 'remote_config_parameter.g.dart';

/// Firebase Remote Config のキー名定数。
abstract class RemoteConfigKeys {
  static const releasedVersion = 'releasedVersion';
  static const minimumAppVersion = 'minimumAppVersion';
}

/// [RemoteConfigParameter] のデフォルト値定数。
abstract class RemoteConfigParameterDefaultValues {
  static const releasedVersion = '1.0.0';
  static const minimumAppVersion = '1.0.0';
}

/// Firebase Remote Config のパラメータを表すエンティティ。
///
/// アプリのバージョン管理に使用され、強制アップデートの判定に利用する。
///
/// ## ユースケース
/// - [minimumAppVersion] を更新し、古いバージョンのアプリに強制アップデートを促す
/// - [releasedVersion] でアプリの最新バージョンを管理する
@freezed
abstract class RemoteConfigParameter with _$RemoteConfigParameter {
  factory RemoteConfigParameter({
    @Default(RemoteConfigParameterDefaultValues.releasedVersion)
    String releasedVersion,
    @Default(RemoteConfigParameterDefaultValues.minimumAppVersion)
    String minimumAppVersion,
  }) = _RemoteConfigParameter;

  RemoteConfigParameter._();
  factory RemoteConfigParameter.fromJson(Map<String, dynamic> json) =>
      _$RemoteConfigParameterFromJson(json);
}
