/// App Store へ提出する iPhone Duo (外側・内側ディスプレイ) のスクリーンショットを撮影する。
///
/// iPhone Duo の Simulator で画面を撮ると、内側ディスプレイでは右端のステータスバーの列が
/// 画像に入る。そのため画面は撮らず、レイアウトを iPhone Duo の論理サイズで描画して
/// `RepaintBoundary.toImage` で書き出す。描画はシミュレータの実エンジンで行うため、
/// 日本語フォント・影は既存の iPhone のスクリーンショットと同じに出る。
/// 実行は `scripts/generate_screenshots/generate_iphone_duo_screenshots.sh` から行う。
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/screenshot/screenshot_copy.dart';
import 'package:shoppinglist/screenshot/screenshot_iphone_duo_displays.dart';
import 'package:shoppinglist/screenshot/screenshot_pages.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/config/environment.dart';

/// 撮影結果の出力先。generate スクリプトが alpha を落として提出用の置き場へ整理する前の中間置き場。
const _outputDirectory = 'artifacts/appstore_screenshots_iphone_duo';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Firebase を初期化しないため、mock override 前提で動く環境として扱う。
  Environment.flavor = Flavor.DEVELOP;

  group('App Store iPhone Duo screenshots', () {
    // 撮影対象を絞り込まない理由は app_store_screenshots_test.dart と同じ。
    for (final display in screenshotIPhoneDuoDisplays) {
      for (final localeEntry in screenshotCopies.entries) {
        for (var index = 0; index < screenshotPages.length; index++) {
          final page = screenshotPages[index];
          testWidgets(
            '${display.name} / ${localeEntry.key} / ${index + 1} ${page.name}',
            (tester) async {
              // ignore: invalid_use_of_visible_for_testing_member
              SharedPreferences.setMockInitialValues({});
              final sharedPreferences = await SharedPreferences.getInstance();
              final boundaryKey = GlobalKey();

              await tester.pumpWidget(
                ProviderScope(
                  overrides: previewProviderOverrides(
                    sharedPreferences: sharedPreferences,
                  ),
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    locale: screenshotAppLocale(storeLocale: localeEntry.key),
                    theme: buildAppTheme(accent: AccentPreset.shu),
                    // 撮影機の画面より大きい内側ディスプレイも縮めずに描くため、
                    // 画面の制約を外して iPhone Duo の論理サイズで固定する。
                    home: OverflowBox(
                      alignment: Alignment.topLeft,
                      minWidth: display.size.width,
                      maxWidth: display.size.width,
                      minHeight: display.size.height,
                      maxHeight: display.size.height,
                      child: RepaintBoundary(
                        key: boundaryKey,
                        child: display.layout(
                          copy: localeEntry.value[index],
                          appScreen: page.appScreen(),
                        ),
                      ),
                    ),
                  ),
                ),
              );

              await tester.pumpAndSettle();
              // AI シートは postFrameCallback で開くため、表示しきるまで待つ。
              await tester.pumpAndSettle(const Duration(seconds: 3));

              final boundary =
                  boundaryKey.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final pngBytes = await tester.runAsync(() async {
                final image = await boundary.toImage(
                  pixelRatio: screenshotIPhoneDuoPixelRatio,
                );
                final byteData = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                image.dispose();
                return byteData!.buffer.asUint8List();
              });

              // takeScreenshot と同じ形で reportData に積むと、
              // test_driver/screenshot_test.dart の onScreenshot がホスト側に PNG を書き出す。
              binding.reportData ??= <String, dynamic>{};
              ((binding.reportData!['screenshots'] ??= <dynamic>[])
                      as List<dynamic>)
                  .add(<String, dynamic>{
                    'screenshotName':
                        '$_outputDirectory/${localeEntry.key}/${display.name}_${index + 1}_${page.name}',
                    'bytes': pngBytes!.toList(),
                  });
            },
          );
        }
      }
    }
  });
}
