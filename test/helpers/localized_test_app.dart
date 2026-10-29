import 'package:flutter/material.dart';
import 'package:shoppinglist/l10n/l10n.dart';

/// widget test 用の MaterialApp。
///
/// `context.l10n` を使う widget は Localizations を祖先に必要とするため、
/// アプリ本体 (lib/app.dart) と同じ delegates を設定する。
/// [locale] の既定は ja。テストの大半は日本語の文言を検証するため。
/// 文言の長さが言語で変わるレイアウトの検証では、各言語を渡す。
MaterialApp localizedTestApp({
  required Widget home,
  ThemeData? theme,
  GlobalKey<NavigatorState>? navigatorKey,
  TransitionBuilder? builder,
  Locale locale = const Locale('ja'),
}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: locale,
  navigatorKey: navigatorKey,
  theme: theme,
  builder: builder,
  home: home,
);
