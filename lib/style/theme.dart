import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// `palt`(プロポーショナル詰め組) を全テキストに適用する。
/// 日本語見出しの字面を詰めて密度を上げるための OpenType feature。
const _paltFeatures = <FontFeature>[FontFeature('palt')];

/// `tnum`(等幅数字)。`monoTextStyle` で進捗 `done/total`・価格・コードの桁を縦に揃える。
const _tabularFeatures = <FontFeature>[FontFeature.tabularFigures()];

/// 和紙テイストのデザイントークンから ThemeData を組み立てる。
/// `MaterialApp.theme` / `darkTheme` から呼び出す。
ThemeData buildAppTheme({
  required Brightness brightness,
  required AccentPreset accent,
}) {
  final tokens = AppTokens.of(brightness: brightness, accent: accent);
  final neutral = tokens.neutral;
  final isDark = brightness == Brightness.dark;

  /// fontFamily を指定せず OS 標準フォントを使う。
  /// iOS は San Francisco / Hiragino Sans、Android は Roboto / Noto Sans CJK JP で描画され、
  /// `google_fonts` のランタイム DL による起動後のフォント差し替わりが起きない。
  TextStyle sans(
    double size,
    FontWeight w, {
    double height = 1.5,
    double ls = -0.005,
    required Color? color,
  }) =>
      TextStyle(
        fontSize: size,
        fontWeight: w,
        height: height,
        letterSpacing: ls,
        fontFeatures: _paltFeatures,
        color: color ?? neutral.ink,
      );

  final base =
      (isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme).apply(
    bodyColor: neutral.ink,
    displayColor: neutral.ink,
  );

  final textTheme = base.copyWith(
    displayLarge:
        sans(34, FontWeight.w800, height: 1.15, ls: -0.02, color: null),
    displayMedium:
        sans(28, FontWeight.w800, height: 1.15, ls: -0.02, color: null),
    headlineSmall:
        sans(22, FontWeight.w700, height: 1.25, ls: -0.015, color: null),
    titleLarge: sans(17, FontWeight.w700, height: 1.3, ls: -0.01, color: null),
    titleMedium: sans(15, FontWeight.w600, height: 1.4, color: null),
    bodyLarge: sans(15, FontWeight.w400, height: 1.7, color: null),
    bodyMedium: sans(14, FontWeight.w400, height: 1.6, color: null),
    bodySmall: sans(12, FontWeight.w400, height: 1.4, color: null),
    labelLarge: sans(13.5, FontWeight.w600, height: 1.0, color: null),
    labelSmall: sans(11.5, FontWeight.w400, height: 1.4, color: null),
  );

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: tokens.accent,
    onPrimary: isDark ? neutral.ink : Colors.white,
    primaryContainer: tokens.accentSoft,
    onPrimaryContainer: tokens.accentInk,
    secondary: tokens.accent,
    onSecondary: isDark ? neutral.ink : Colors.white,
    error: neutral.danger,
    onError: Colors.white,
    errorContainer: neutral.dangerSoft,
    onErrorContainer: neutral.danger,
    surface: neutral.surface,
    onSurface: neutral.ink,
    surfaceContainerLowest: neutral.paper,
    surfaceContainerLow: neutral.surface,
    surfaceContainer: neutral.surface2,
    surfaceContainerHigh: neutral.card,
    surfaceContainerHighest: neutral.card,
    onSurfaceVariant: neutral.ink2,
    outline: neutral.divider,
    outlineVariant: neutral.divider2,
    shadow: const Color(0x141B1813),
    inverseSurface: neutral.ink,
    onInverseSurface: neutral.surface,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: neutral.surface,
    canvasColor: neutral.surface,
    textTheme: textTheme,
    extensions: [tokens],
    appBarTheme: AppBarTheme(
      backgroundColor: neutral.surface,
      foregroundColor: neutral.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: neutral.surface,
      selectedItemColor: tokens.accent,
      unselectedItemColor: neutral.ink3,
      type: BottomNavigationBarType.fixed,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: neutral.surface,
      side: BorderSide(color: neutral.divider),
      labelStyle: sans(12.5, FontWeight.w500, height: 1.0, color: null),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: const StadiumBorder(),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.accent,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: sans(15, FontWeight.w600, height: 1.0, color: null),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: neutral.ink,
        side: BorderSide(color: neutral.divider),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: tokens.accent),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: neutral.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSheet),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: neutral.ink,
      contentTextStyle: sans(13, FontWeight.w500, color: neutral.surface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusButton),
      ),
    ),
    dividerTheme:
        DividerThemeData(color: neutral.divider, thickness: 0.5, space: 0.5),
    splashFactory: NoSplash.splashFactory,
  );
}

/// 数値表示用のスタイル。
/// fontFamily は指定せず OS 標準フォントを使い、`tabularFigures` で done/total・価格・コードの桁を縦に揃える。
/// 旧 IBM Plex Mono のランタイム DL を廃止したため、見た目はプロポーショナル寄りになるが、数字は等幅を維持する。
TextStyle monoTextStyle({
  required double fontSize,
  required FontWeight fontWeight,
  required Color color,
  double height = 1.0,
  required double? letterSpacing,
}) =>
    TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      fontFeatures: _tabularFeatures,
      color: color,
    );
