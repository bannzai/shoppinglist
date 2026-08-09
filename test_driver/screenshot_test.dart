/// `integration_test/app_store_screenshots_test.dart` を driver 経由で実行し、
/// 撮影結果を PNG としてホスト側に書き出す。
///
/// `binding.takeScreenshot(name)` の name をそのままファイルパスとして扱う。
library;

import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    driver: await FlutterDriver.connect(),
    onScreenshot: (
      String screenshotName,
      List<int> screenshotBytes, [
      Map<String, Object?>? args,
    ]) async {
      await (await File(
        '$screenshotName.png',
      ).create(recursive: true)).writeAsBytes(screenshotBytes);
      return true;
    },
  );
}
