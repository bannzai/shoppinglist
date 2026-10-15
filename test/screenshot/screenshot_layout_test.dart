import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/screenshot/screenshot_app.dart';
import 'package:shoppinglist/screenshot/screenshot_copy.dart';
import 'package:shoppinglist/screenshot/screenshot_layout.dart';
import 'package:shoppinglist/screenshot/screenshot_pages.dart';
import 'package:shoppinglist/utils/config/environment.dart';

void main() {
  // issue #667: iPhone (6.9 インチ) 用の撮影と同じ組み立てで、提出する全ページが
  // 例外を出さずに組めることを検証する。撮影側が l10n の設定を持たない MaterialApp を使い、
  // 全ページが `Null check operator used on a null value` で落ちていたのを捕まえるためのもの。
  // 描画の見た目は scripts/generate_screenshots/generate_appstore_screenshots.sh の出力を目視で確認する。
  //
  // en-US を対象にしない理由は screenshot_iphone_duo_layout_test.dart と同じ (Ahem フォントで英語の行が overflow する)。
  Environment.flavor = Flavor.DEVELOP;

  // 撮影機 iPhone 16 Pro Max の論理サイズと倍率 (提出画像 1320x2868 を 3 で割った値)。
  const physicalSize = Size(1320, 2868);
  const devicePixelRatio = 3.0;

  for (final localeEntry in screenshotCopies.entries.where(
    (entry) => entry.key == 'ja',
  )) {
    for (var index = 0; index < screenshotPages.length; index++) {
      final page = screenshotPages[index];
      testWidgets('${localeEntry.key} / ${index + 1} ${page.name} が例外なく組める', (
        tester,
      ) async {
        tester.view.physicalSize = physicalSize;
        tester.view.devicePixelRatio = devicePixelRatio;
        addTearDown(tester.view.reset);

        SharedPreferences.setMockInitialValues({});
        final sharedPreferences = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          ProviderScope(
            overrides: previewProviderOverrides(
              sharedPreferences: sharedPreferences,
            ),
            child: screenshotApp(
              storeLocale: localeEntry.key,
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

        expect(tester.takeException(), isNull);
      });
    }
  }
}
