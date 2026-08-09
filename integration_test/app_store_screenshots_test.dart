/// App Store / Google Play へ提出するスクリーンショットを撮影する。
///
/// widget test のオフスクリーン描画ではなくシミュレータの実描画で撮るため、
/// 日本語フォント・影・実際のレイアウトがそのまま反映される。
/// 実行は `scripts/generate_screenshots/generate_appstore_screenshots.sh` から行う。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/screenshot/screenshot_copy.dart';
import 'package:shoppinglist/screenshot/screenshot_layout.dart';
import 'package:shoppinglist/screenshot/screenshot_pages.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/config/environment.dart';

/// 撮影結果の出力先。generate スクリプトが fastlane 形式へ整理する前の中間置き場。
const _outputDirectory = 'artifacts/appstore_screenshots';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Firebase を初期化しないため、mock override 前提で動く環境として扱う。
  Environment.flavor = Flavor.DEVELOP;

  group('App Store screenshots', () {
    // 撮影対象は絞り込まず常に全件撮る。`--dart-define` による絞り込みは、
    // flutter drive が前回ビルドを再利用したときに古い条件のまま実行され、
    // 撮れたつもりで枚数が足りない事故になるため採らない。
    for (final localeEntry in screenshotCopies.entries) {
      for (var index = 0; index < screenshotPages.length; index++) {
        final page = screenshotPages[index];
        testWidgets('${localeEntry.key} / ${index + 1} ${page.name}', (
          tester,
        ) async {
          // ignore: invalid_use_of_visible_for_testing_member
          SharedPreferences.setMockInitialValues({});
          final sharedPreferences = await SharedPreferences.getInstance();

          await tester.pumpWidget(
            ProviderScope(
              overrides: previewProviderOverrides(
                sharedPreferences: sharedPreferences,
              ),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: buildAppTheme(accent: AccentPreset.shu),
                home: ScreenshotLayout(
                  copy: localeEntry.value[index],
                  appScreen: page.appScreen(),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
          // AI シートは postFrameCallback で開くため、表示しきるまで待つ。
          await tester.pumpAndSettle(const Duration(seconds: 3));

          await binding.convertFlutterSurfaceToImage();
          await tester.pumpAndSettle();
          await binding.takeScreenshot(
            '$_outputDirectory/${localeEntry.key}/${index + 1}_${page.name}',
          );
        });
      }
    }
  });
}
