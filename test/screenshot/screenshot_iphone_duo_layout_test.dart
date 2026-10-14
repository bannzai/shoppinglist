import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/screenshot/screenshot_copy.dart';
import 'package:shoppinglist/screenshot/screenshot_iphone_duo_displays.dart';
import 'package:shoppinglist/screenshot/screenshot_pages.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/config/environment.dart';

void main() {
  // issue #660: iPhone Duo の外側・内側ディスプレイの寸法で、提出する全ページの
  // レイアウトが overflow などの例外を出さずに組めることを検証する。描画の見た目は
  // scripts/generate_screenshots/generate_iphone_duo_screenshots.sh の出力を目視で確認する。
  //
  // en-US は対象にしない。flutter test は ASCII を「フォントサイズの正方形」で描く Ahem を使い
  // (flutter_test の binding.dart の LiveTestWidgetsFlutterBinding の説明)、外側の AI シートの英語の行が
  // 42px・117px の overflow を出した。同じ en-US の画面は、実フォントで描く
  // integration_test/app_store_screenshots_iphone_duo_test.dart を Simulator で実行して
  // 全件 pass し、生成画像にも見切れが無いことを目視で確認している。
  Environment.flavor = Flavor.DEVELOP;

  for (final display in screenshotIPhoneDuoDisplays) {
    for (final localeEntry in screenshotCopies.entries.where(
      (entry) => entry.key == 'ja',
    )) {
      for (var index = 0; index < screenshotPages.length; index++) {
        final page = screenshotPages[index];
        testWidgets(
          '${display.name} / ${localeEntry.key} / ${index + 1} ${page.name} が例外なく組める',
          (tester) async {
            tester.view.physicalSize =
                display.size * screenshotIPhoneDuoPixelRatio;
            tester.view.devicePixelRatio = screenshotIPhoneDuoPixelRatio;
            addTearDown(tester.view.reset);

            SharedPreferences.setMockInitialValues({});
            final sharedPreferences = await SharedPreferences.getInstance();

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
                  home: display.layout(
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
          },
        );
      }
    }
  }
}
