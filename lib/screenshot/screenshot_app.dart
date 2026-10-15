/// ストアのスクリーンショットの撮影 (`integration_test/`) と、レイアウトが組めることの検証 (`test/screenshot/`) が
/// 共通で使う MaterialApp。
///
/// アプリ画面の Page は `context.l10n` を使うため、Localizations を祖先に持たないと
/// `Null check operator used on a null value` で描画に失敗する (issue #667)。撮影と検証の全経路が
/// ここを通ることで、l10n の設定漏れを 1 か所で防ぐ。
library;

import 'package:flutter/material.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/screenshot/screenshot_copy.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// ストアのロケール ([screenshotCopies] のキー) の表示言語で `home` を描く MaterialApp。
MaterialApp screenshotApp({
  required String storeLocale,
  required Widget home,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: screenshotAppLocale(storeLocale: storeLocale),
  // 撮影済みの既存画像と同じ配色にそろえるため、アクセントは shu に固定する。
  theme: buildAppTheme(accent: AccentPreset.shu),
  home: home,
);
