import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/entity/remote_config_parameter.dart';
import 'package:shoppinglist/utils/config/version.dart';
import 'package:shoppinglist/utils/logger/error.dart';

part './remote_config.g.dart';

final remoteConfig = FirebaseRemoteConfig.instance;

Future<void> setupRemoteConfig() async {
  try {
    await (
      remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      )),
      remoteConfig.setDefaults({
        RemoteConfigKeys.releasedVersion: RemoteConfigParameterDefaultValues.releasedVersion,
      }),
      remoteConfig.fetchAndActivate()
    ).wait;

    debugPrintRemoteConfig();

    remoteConfig.onConfigUpdated.listen((event) {
      remoteConfig.activate();
    });
  } catch (error, st) {
    // ignore error
    // ParallelWaitErrorとentrypointでRemoteConfigを導入してからエラーが出るようになった。RemoteConfigの設定は失敗しても最悪どうにかなるだろう。ということでエラーは無視する
    debugPrint(error.toString());
    errorLogger.recordError(error, st);
  }
}

@Riverpod()
Future<bool> appIsReleased(AppIsReleasedRef ref) async {
  final releasedVersion = Version.parse(remoteConfig.getString(RemoteConfigKeys.releasedVersion));
  final packageInfo = await PackageInfo.fromPlatform();
  final appVersion = Version.parse(packageInfo.version);
  return !appVersion.isGreaterThan(releasedVersion);
}

void debugPrintRemoteConfig() {
  for (final entry in remoteConfig.getAll().entries) {
    debugPrint('RemoteConfig: ${entry.key} ${entry.value.asString()}');
  }
}
