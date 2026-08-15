import 'package:flutter/material.dart';
import 'package:shoppinglist/l10n/l10n.dart';

/// widget test 用の MaterialApp。
///
/// `context.l10n` を使う widget は Localizations を祖先に必要とするため、
/// アプリ本体 (lib/app.dart) と同じ delegates を設定する。
/// テストは日本語の文言を検証するのでロケールは ja に固定する。
MaterialApp localizedTestApp({
  required Widget home,
  ThemeData? theme,
  GlobalKey<NavigatorState>? navigatorKey,
  TransitionBuilder? builder,
}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('ja'),
  navigatorKey: navigatorKey,
  theme: theme,
  builder: builder,
  home: home,
);
