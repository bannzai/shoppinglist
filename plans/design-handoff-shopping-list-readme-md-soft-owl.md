# 買い物リスト UI 全面再設計（design_handoff_shopping_list 実装）

## Context

`design_handoff_shopping_list/` に Anthropic Labs の Claude Design 経由で生成された High-fidelity デザインバンドルが入っている（issue #250 / #251 の指示書を経て生成された成果物）。これを Flutter 側で再現する。

- 参照 issue: #250 / #251
- 参照デザイン: `design_handoff_shopping_list/README.md`、`source/screens-*.jsx`、`source/tokens.jsx`、`source/styles.css`、`source/frame.jsx`、`source/widgets-and-micro.jsx`
- アプリは未リリース。UI/UX を大胆に作り直せる最後のタイミングという位置づけ
- ドメイン機能の追加・廃止はなし（認証 / グループ / カテゴリ / 店舗 / ホームウィジェット / AI / 課金は現状の境界を維持）。**今回は UI/UX 再構築のみ**

### ユーザー確定事項

| 項目 | 決定 |
|---|---|
| スコープ | 全 17 画面 + 共通基盤 + ホームウィジェットを 1 プランに統合（実装は段階 PR 推奨） |
| テーマカラー | 既存 10 色プリセットを廃止 → デザイン側 5 色（朱 / 抹茶 / 藍 / 墨 / 朽葉）に置換。既存値は朱に移行（読み取り時 fallback、書き戻しはしない） |
| ホームウィジェット | iOS WidgetKit / Android Glance とも今回スコープに含める |
| OnboardingPage | 新規追加。新規ユーザーのみ初回 1 回。SharedPreferences の `hasSeenOnboarding` で抑止 |

---

## 全体方針

### A. デザイントークンを ThemeExtension で SSOT 化

- `Theme.of(context).extension<AppTokens>()!` で `paper / surface / surface2 / card / ink / ink2 / ink3 / ink4 / divider / divider2 / accent / accentSoft / accentInk / ok / okSoft / warn / danger / dangerSoft / checked / cardShadow / brightness` を参照
- 既存の `ColorScheme` には Material 互換マッピングのみ載せ、`ColorScheme.primary = tokens.accent` で揃える（既存 `Theme.of(context).colorScheme.primary` 参照箇所が壊れない）
- `lib/style/color.dart` の `colorFromHex` は廃止せず、カテゴリ色など個別 HEX を扱う場面でそのまま使う

### B. 5 色プリセット移行は読み取り fallback のみ

- `users/{uid}.themeColorHex` の Firestore フィールドはそのまま（マイグレーション不要 / Rules 変更不要）
- 読み取り時に旧 10 色 HEX (`#673AB7` 等) や `null` は `AccentPreset.shu` (`#C2410C`) にフォールバック
- 書き戻しはしない（「テーマカラーが勝手に変わった」と感じさせないため）。次にユーザーが設定画面で色変更したタイミングで新 HEX が永続化される

### C. 段階的 PR 分割

このプランは 1 つの設計書だが、実装 PR は次の 5 段階に分けることを推奨する。

1. **PR1 — 基盤**: tokens / theme / google_fonts / `lib/components/frame/` 共通 Widget / `lib/app.dart` 接続
2. **PR2 — ShoppingListPage 中核**: ListTopBar / GroupChipsBar / FilterChipsBar / ProgressBlock / ItemRow / ExpandableFab / バナー類 / SnackBar 改修
3. **PR3 — 周辺画面 (前半)**: Onboarding / Auth / Home / ShoppingListSettingPage / FilterPage / SettingPage / ThemeColorSelectionPage / PaywallPage
4. **PR4 — 周辺画面 (後半)**: GroupList / GroupCreate / GroupSetting / GroupInvitationAccept / GroupCategory / CategoryEdit / ShoppingLocation / LocationPicker
5. **PR5 — ホームウィジェット**: iOS WidgetKit / Android Glance のスタイル更新 + テーマ色同期

各 PR は `flutter analyze`, `flutter test`, `flutter build ios`, `flutter build apk`, `maestro` を必ずパスさせる。

---

## 共通基盤（PR1）

### ファイル一覧

| 種別 | パス |
|---|---|
| 新規 | `lib/style/tokens.dart` |
| 新規 | `lib/style/theme.dart` |
| 改修 | `lib/provider/theme_color.dart`（5 色化、`AccentPreset` 解決） |
| 改修 | `lib/app.dart`（`buildAppTheme(brightness, accent)` 経由に） |
| 改修 | `pubspec.yaml`（`google_fonts: ^6.2.1` 追加） |
| 新規 | `lib/components/frame/app_pill.dart` |
| 新規 | `lib/components/frame/app_round_button.dart` |
| 新規 | `lib/components/frame/app_checkbox.dart` |
| 新規 | `lib/components/frame/app_chip.dart` |
| 新規 | `lib/components/frame/app_large_app_bar.dart` |
| 新規 | `lib/components/frame/app_bottom_tab_bar.dart` |
| 新規 | `lib/components/frame/app_section_card.dart` |

### `lib/style/tokens.dart`

`AppNeutralColors`（21 色 light/dark）、`AccentPreset` enum（5 色）、`AppTokens extends ThemeExtension<AppTokens>` を定義する。

```dart
// lib/style/tokens.dart
import 'package:flutter/material.dart';

@immutable
class AppNeutralColors {
  final Color paper, surface, surface2, card;
  final Color ink, ink2, ink3, ink4;
  final Color divider, divider2;
  final Color ok, okSoft, warn, danger, dangerSoft, checked;

  const AppNeutralColors({
    required this.paper, required this.surface, required this.surface2,
    required this.card, required this.ink, required this.ink2,
    required this.ink3, required this.ink4, required this.divider,
    required this.divider2, required this.ok, required this.okSoft,
    required this.warn, required this.danger, required this.dangerSoft,
    required this.checked,
  });

  static const light = AppNeutralColors(
    paper: Color(0xFFECE5D3), surface: Color(0xFFF8F2E2),
    surface2: Color(0xFFFFFCF3), card: Color(0xFFFFFFFF),
    ink: Color(0xFF1B1813), ink2: Color(0xFF5A5246),
    ink3: Color(0xFF948A77), ink4: Color(0xFFBDB39E),
    divider: Color(0xFFE0D5BC), divider2: Color(0xFFEBE2C9),
    ok: Color(0xFF2F6B43), okSoft: Color(0xFFDCEBDF),
    warn: Color(0xFFB47B1F), danger: Color(0xFFB53D3D),
    dangerSoft: Color(0xFFF4DEDB), checked: Color(0xFFA89E89),
  );
  static const dark = AppNeutralColors(
    paper: Color(0xFF13110D), surface: Color(0xFF1B1813),
    surface2: Color(0xFF221E18), card: Color(0xFF26221C),
    ink: Color(0xFFF2EDE2), ink2: Color(0xFFBFB6A3),
    ink3: Color(0xFF847C6B), ink4: Color(0xFF5A5246),
    divider: Color(0xFF2A251F), divider2: Color(0xFF332D26),
    ok: Color(0xFF6BB07F), okSoft: Color(0xFF1F3325),
    warn: Color(0xFFE1B05A), danger: Color(0xFFE47A7A),
    dangerSoft: Color(0xFF3A2020), checked: Color(0xFF5A5246),
  );

  AppNeutralColors lerp(AppNeutralColors other, double t) => AppNeutralColors(
    paper: Color.lerp(paper, other.paper, t)!, surface: Color.lerp(surface, other.surface, t)!,
    surface2: Color.lerp(surface2, other.surface2, t)!, card: Color.lerp(card, other.card, t)!,
    ink: Color.lerp(ink, other.ink, t)!, ink2: Color.lerp(ink2, other.ink2, t)!,
    ink3: Color.lerp(ink3, other.ink3, t)!, ink4: Color.lerp(ink4, other.ink4, t)!,
    divider: Color.lerp(divider, other.divider, t)!, divider2: Color.lerp(divider2, other.divider2, t)!,
    ok: Color.lerp(ok, other.ok, t)!, okSoft: Color.lerp(okSoft, other.okSoft, t)!,
    warn: Color.lerp(warn, other.warn, t)!, danger: Color.lerp(danger, other.danger, t)!,
    dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!, checked: Color.lerp(checked, other.checked, t)!,
  );
}

/// 5 色のアクセントプリセット。Firestore 永続化キーは LIGHT 値の `#RRGGBB`。
enum AccentPreset {
  shu(    light: Color(0xFFC2410C), dark: Color(0xFFE8743A), softLight: Color(0xFFFBE4D0), softDark: Color(0xFF3A2316), inkLight: Color(0xFF7C2A07), inkDark: Color(0xFFFCD7BB), label: '朱'),
  matcha( light: Color(0xFF1F6B4E), dark: Color(0xFF6BB07F), softLight: Color(0xFFDCEBDF), softDark: Color(0xFF1F3325), inkLight: Color(0xFF0F3D2A), inkDark: Color(0xFFB7D9C2), label: '抹茶'),
  ai(     light: Color(0xFF0F4C81), dark: Color(0xFF5FA0D6), softLight: Color(0xFFD8E4F0), softDark: Color(0xFF162B3E), inkLight: Color(0xFF0A2E50), inkDark: Color(0xFFC4DAEC), label: '藍'),
  sumi(   light: Color(0xFF1B1B1B), dark: Color(0xFFE8E5DD), softLight: Color(0xFFE8E5DD), softDark: Color(0xFF33302A), inkLight: Color(0xFF000000), inkDark: Color(0xFFF2EDE2), label: '墨'),
  kuchiba(light: Color(0xFFB45309), dark: Color(0xFFE0985A), softLight: Color(0xFFF6E1C9), softDark: Color(0xFF3A2812), inkLight: Color(0xFF6B2F05), inkDark: Color(0xFFF1D2A8), label: '朽葉');

  const AccentPreset({required this.light, required this.dark, required this.softLight, required this.softDark, required this.inkLight, required this.inkDark, required this.label});
  final Color light, dark, softLight, softDark, inkLight, inkDark;
  final String label;

  String get persistHex =>
      '#${light.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}

class AppTokens extends ThemeExtension<AppTokens> {
  final Brightness brightness;
  final AccentPreset accentPreset;
  final AppNeutralColors neutral;
  final List<BoxShadow> cardShadow;

  const AppTokens({required this.brightness, required this.accentPreset, required this.neutral, required this.cardShadow});

  bool get isDark => brightness == Brightness.dark;
  Color get accent     => isDark ? accentPreset.dark : accentPreset.light;
  Color get accentSoft => isDark ? accentPreset.softDark : accentPreset.softLight;
  Color get accentInk  => isDark ? accentPreset.inkDark : accentPreset.inkLight;

  static const s2 = 2.0; static const s4 = 4.0; static const s6 = 6.0;
  static const s8 = 8.0; static const s10 = 10.0; static const s12 = 12.0;
  static const s14 = 14.0; static const s16 = 16.0; static const s18 = 18.0;
  static const s20 = 20.0; static const s24 = 24.0; static const s32 = 32.0;

  static const radiusPill = 999.0; static const radiusButtonSm = 12.0;
  static const radiusButton = 14.0; static const radiusCta = 16.0;
  static const radiusCard = 14.0; static const radiusInput = 12.0;
  static const radiusSheet = 18.0;

  static const shadowLight = <BoxShadow>[
    BoxShadow(color: Color(0x0D1B1813), offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A1B1813), offset: Offset(0, 6), blurRadius: 18),
  ];
  static const shadowDark = <BoxShadow>[
    BoxShadow(color: Color(0x66000000), offset: Offset(0, 1)),
    BoxShadow(color: Color(0x4D000000), offset: Offset(0, 6), blurRadius: 18),
  ];

  factory AppTokens.of({required Brightness brightness, required AccentPreset accent}) {
    final isDark = brightness == Brightness.dark;
    return AppTokens(
      brightness: brightness, accentPreset: accent,
      neutral: isDark ? AppNeutralColors.dark : AppNeutralColors.light,
      cardShadow: isDark ? shadowDark : shadowLight,
    );
  }

  @override
  AppTokens copyWith({Brightness? brightness, AccentPreset? accentPreset}) =>
      AppTokens.of(brightness: brightness ?? this.brightness, accent: accentPreset ?? this.accentPreset);

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      brightness: t < 0.5 ? brightness : other.brightness,
      accentPreset: t < 0.5 ? accentPreset : other.accentPreset,
      neutral: neutral.lerp(other.neutral, t),
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
    );
  }
}

extension AppTokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
```

### `lib/style/theme.dart`

```dart
// lib/style/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoppinglist/style/tokens.dart';

ThemeData buildAppTheme({required Brightness brightness, required AccentPreset accent}) {
  final tokens = AppTokens.of(brightness: brightness, accent: accent);
  final neutral = tokens.neutral;
  final isDark = brightness == Brightness.dark;
  const features = <FontFeature>[FontFeature('palt')];

  TextStyle sans(double size, FontWeight w, {double height = 1.5, double ls = -0.005, Color? color}) =>
      GoogleFonts.notoSansJp(fontSize: size, fontWeight: w, height: height, letterSpacing: ls,
          fontFeatures: features, color: color ?? neutral.ink);
  TextStyle serif(double size, FontWeight w, {double height = 1.15, double ls = -0.02}) =>
      GoogleFonts.zenKakuGothicNew(fontSize: size, fontWeight: w, height: height, letterSpacing: ls,
          fontFeatures: features, color: neutral.ink);
  TextStyle mono(double size, FontWeight w) =>
      GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: w, height: 1.0,
          fontFeatures: const [FontFeature.tabularFigures()], color: neutral.ink);

  final base = GoogleFonts.notoSansJpTextTheme(
    isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
  ).apply(bodyColor: neutral.ink, displayColor: neutral.ink);

  final textTheme = base.copyWith(
    displayLarge:  serif(34, FontWeight.w800),
    displayMedium: serif(28, FontWeight.w800),
    headlineSmall: sans(22, FontWeight.w700, height: 1.25, ls: -0.015),
    titleLarge:    sans(17, FontWeight.w700, height: 1.3,  ls: -0.01),
    titleMedium:   sans(15, FontWeight.w600, height: 1.4,  ls: -0.005),
    bodyLarge:     sans(15, FontWeight.w400, height: 1.7),
    bodyMedium:    sans(14, FontWeight.w400, height: 1.6),
    bodySmall:     sans(12, FontWeight.w400, height: 1.4),
    labelLarge:    sans(13.5, FontWeight.w600, height: 1.0),
    labelSmall:    sans(11.5, FontWeight.w400, height: 1.4),
  );

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: tokens.accent, onPrimary: isDark ? neutral.ink : Colors.white,
    primaryContainer: tokens.accentSoft, onPrimaryContainer: tokens.accentInk,
    secondary: tokens.accent, onSecondary: isDark ? neutral.ink : Colors.white,
    error: neutral.danger, onError: Colors.white,
    errorContainer: neutral.dangerSoft, onErrorContainer: neutral.danger,
    surface: neutral.surface, onSurface: neutral.ink,
    surfaceContainerLowest: neutral.paper, surfaceContainerLow: neutral.surface,
    surfaceContainer: neutral.surface2, surfaceContainerHigh: neutral.card,
    surfaceContainerHighest: neutral.card,
    onSurfaceVariant: neutral.ink2,
    outline: neutral.divider, outlineVariant: neutral.divider2,
    shadow: const Color(0x141B1813),
    inverseSurface: neutral.ink, onInverseSurface: neutral.surface,
  );

  return ThemeData(
    useMaterial3: true, brightness: brightness, colorScheme: colorScheme,
    scaffoldBackgroundColor: neutral.surface, canvasColor: neutral.surface,
    textTheme: textTheme, extensions: [tokens],
    appBarTheme: AppBarTheme(
      backgroundColor: neutral.surface, foregroundColor: neutral.ink,
      elevation: 0, scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge, centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: neutral.surface, selectedItemColor: tokens.accent,
      unselectedItemColor: neutral.ink3, type: BottomNavigationBarType.fixed,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: neutral.surface, side: BorderSide(color: neutral.divider),
      labelStyle: sans(12.5, FontWeight.w500, height: 1.0),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: const StadiumBorder(),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      backgroundColor: tokens.accent, foregroundColor: Colors.white,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: sans(15, FontWeight.w600, height: 1.0),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
      foregroundColor: neutral.ink, side: BorderSide(color: neutral.divider),
      shape: const StadiumBorder(),
    )),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: tokens.accent)),
    dialogTheme: DialogThemeData(
      backgroundColor: neutral.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSheet)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: neutral.ink,
      contentTextStyle: sans(13, FontWeight.w500, color: neutral.surface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusButton)),
    ),
    dividerTheme: DividerThemeData(color: neutral.divider, thickness: 0.5, space: 0.5),
    splashFactory: NoSplash.splashFactory,
  );
}
```

### `lib/provider/theme_color.dart` 改修（5 色化＋fallback）

```dart
// lib/provider/theme_color.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/style/tokens.dart';

part 'theme_color.g.dart';

const defaultThemeColorHex = '#C2410C';

final themeColorPresets = AccentPreset.values
    .map((p) => (hex: p.persistHex, label: p.label, color: p.light, preset: p))
    .toList(growable: false);

bool isSupportedThemeColorHex(String themeColorHex) =>
    AccentPreset.values.any((p) => p.persistHex == themeColorHex);

AccentPreset resolveAccentPreset(String? themeColorHex) {
  for (final p in AccentPreset.values) {
    if (p.persistHex == themeColorHex) return p;
  }
  return AccentPreset.shu;
}

@Deprecated('Use resolveAccentPreset(...).light instead.')
Color resolveThemeColor(String? themeColorHex) =>
    resolveAccentPreset(themeColorHex).light;

class ThemeColorUpdate {
  final UserDatabase userDatabase;
  ThemeColorUpdate({required this.userDatabase});

  Future<void> call({required AccentPreset preset}) async {
    await userDatabase.userReference().update({
      'themeColorHex': preset.persistHex,
      'updatedDateTime': FieldValue.serverTimestamp(),
      'serverUpdatedDateTime': FieldValue.serverTimestamp(),
    });
  }
}

@Riverpod(dependencies: [userDatabase])
ThemeColorUpdate themeColorUpdate(Ref ref) =>
    ThemeColorUpdate(userDatabase: ref.read(userDatabaseProvider));
```

`dart run build_runner build --delete-conflicting-outputs` で `theme_color.g.dart` 再生成必須。

### `lib/app.dart` 改修（L39-58）

```dart
// Before: seedColor / ColorScheme.fromSeed
// After:
final accent = resolveAccentPreset(
  ref.watch(appUserProvider).asData?.value.themeColorHex,
);

return MaterialApp(
  navigatorKey: _navigatorKey,
  title: '買い物リスト',
  theme: buildAppTheme(brightness: Brightness.light, accent: accent),
  darkTheme: buildAppTheme(brightness: Brightness.dark, accent: accent),
  themeMode: ThemeMode.system,
  // ...（home, builder は既存維持）
);
```

import 追加: `package:shoppinglist/style/theme.dart`, `package:shoppinglist/style/tokens.dart`

### `pubspec.yaml`

```yaml
dependencies:
  google_fonts: ^6.2.1
```

`main.dart` の `runApp` 直前に `await GoogleFonts.pendingFonts([...])` を追加してフォントをプリロードする（オフライン耐性のため将来的に `assets/fonts/` 同梱も検討、但し本フェーズでは見送り）。

### 共通 frame コンポーネント

- `app_pill.dart`: `AppPill(label, onPressed, variant: neutral|accent|soft|ghost|danger, large: bool, icon)` — `StadiumBorder` + variant 色 + `large` で h=50/36
- `app_round_button.dart`: `AppRoundButton(icon, onPressed, size: 36, soft: bool, ring: bool)` — `CircleBorder`
- `app_checkbox.dart`: 円形 22px、`scale 1→1.2→1` の pop アニメ（`useAnimationController` + `TweenSequence`）
- `app_chip.dart`: 高さ 30、`active / soft / icon / dotColor` パラメータ、`StadiumBorder`
- `app_large_app_bar.dart`: `PreferredSizeWidget`、SafeArea + 上段 52px + 下段 大見出し 28pt + 任意 subtitle
- `app_bottom_tab_bar.dart`: 2 タブ固定 (`AppTab.list / settings`)、active accent + 600 weight
- `app_section_card.dart`: 設定画面の Section / Cell ラッパー、card 背景 + 角丸 14 + divider2

実装は別 Plan の付録参照（`feature-dev-code-architect-A` の 6.1〜6.7）。各 Widget のコード例はそこに完全形がある。

---

## ShoppingListPage 中核（PR2）

### 構造（Before / After）

**Before** (`lib/features/shopping_list/page.dart` L308-423):
- `Retry > Scaffold(appBar: ShoppingListAppBar, FAB(+), body: SafeArea > Column [_ProgressSection, Expanded(ShoppingListItems), 30日 footer])`

**After**:
- `Scaffold(appBar: null, FAB: ExpandableFab, body: SafeArea(top, bottom: false) > Column [ListTopBar(52), GroupChipsBar(46), FilterChipsBar(44), ProgressBlock(72) (totalCount > 0 のとき), RetentionBanner / AllDoneBanner / AIProcessingBanner (条件付き), Expanded(items.when(data: ShoppingListItems / EmptyShoppingListHint, error: ListErrorCard, loading: Loading))])`

外側 `ShoppingListPage` (L27-184) は `GroupSwitcher` を `GroupChipsBar` に置換。内側 `_Body` は `appBar: null` 化＋ Column に各バー。`AppBar` 廃止により `ShoppingListAppBar` は削除、PopupMenu 5 メニューは `ExpandableFab` に統合する。

### ファイル一覧

| 種別 | パス |
|---|---|
| 改修 | `lib/features/shopping_list/page.dart` |
| 削除 | `lib/features/shopping_list/components/app_bar.dart`（PopupMenu ロジックは ExpandableFab へ移動） |
| 削除 | `lib/features/shopping_list/components/group_switcher.dart`（`GroupChipsBar` に置換） |
| 新規 | `lib/features/shopping_list/components/list_top_bar.dart` |
| 新規 | `lib/features/shopping_list/components/group_chips_bar.dart` |
| 新規 | `lib/features/shopping_list/components/filter_chips_bar.dart` |
| 新規 | `lib/features/shopping_list/components/progress_block.dart` |
| 新規 | `lib/features/shopping_list/components/expandable_fab.dart` |
| 新規 | `lib/features/shopping_list/components/banners/retention_banner.dart` |
| 新規 | `lib/features/shopping_list/components/banners/all_done_banner.dart` |
| 新規 | `lib/features/shopping_list/components/banners/ai_processing_banner.dart` |
| 新規 | `lib/features/shopping_list/components/banners/list_error_card.dart` |
| 改修 | `lib/features/shopping_list/components/notification_member_bar.dart`（5 秒、card 背景） |
| 改修 | `lib/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart`（円形 Checkbox / focused 時左 2px accent / pop アニメ） |
| 改修 | `lib/features/shopping_list/components/shopping_list_items/empty_text_shopping_list_item.dart`（dashed hint box） |
| 改修 | `lib/features/shopping_list/components/shopping_list_items/shopping_list_items.dart`（CategorySectionHeader 差し替え） |
| 新規 | `lib/features/shopping_list/components/shopping_list_items/category_section_header.dart` |
| 新規 | `lib/features/shopping_list/components/shopping_list_items/ghost_item_row.dart` |
| 新規 | `lib/provider/ai_processing.dart`（AI 処理中の bool フラグ） |

### `progress_block.dart`

```dart
class ProgressBlock extends StatelessWidget {
  final int checkedCount;
  final int totalCount;
  const ProgressBlock({super.key, required this.checkedCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pct = totalCount == 0 ? 0.0 : checkedCount / totalCount;
    final allDone = checkedCount == totalCount && totalCount > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Text.rich(TextSpan(children: [
            TextSpan(text: '$checkedCount',
              style: GoogleFonts.ibmPlexMono(fontSize: 24, fontWeight: FontWeight.w600,
                  color: t.neutral.ink, fontFeatures: const [FontFeature.tabularFigures()])),
            TextSpan(text: '/$totalCount',
              style: GoogleFonts.ibmPlexMono(fontSize: 24, fontWeight: FontWeight.w400,
                  color: t.neutral.ink3, fontFeatures: const [FontFeature.tabularFigures()])),
          ])),
          const SizedBox(width: 8),
          Text(allDone ? '完了!' : 'チェック済み',
               style: TextStyle(fontSize: 12, color: t.neutral.ink2)),
          const Spacer(),
          if (allDone)
            Text('✓ おつかれさま',
                 style: TextStyle(fontSize: 12, color: t.neutral.ok, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct, minHeight: 4,
            backgroundColor: t.neutral.divider2,
            valueColor: AlwaysStoppedAnimation(allDone ? t.neutral.ok : t.accent),
          ),
        ),
      ]),
    );
  }
}
```

### `text_shopping_list_item.dart` 改修ポイント

連続入力 UX のロジック（`RawKeyboardListener` for Backspace L256-269 / `onSubmitted` で末尾空行追加 L293-334）は**完全保持**。装飾だけ差し替える。

1. 既存 `Transform.scale(scale: 1.5, child: Checkbox(shape: CircleBorder()))` (L72-95) を `_CircleCheckbox`（独自 Widget、22px、stroke 1.5px、pop アニメ込み）に置換。
2. Row 全体を `Container(decoration: BoxDecoration(border: Border(left: BorderSide(color: focused ? t.accent : Colors.transparent, width: 2)), color: focused ? t.accentSoft.withValues(alpha: 0.4) : null))` でラップ。
3. テキストスタイル: checked 時 `color: t.neutral.checked, decoration: TextDecoration.lineThrough, decorationColor: t.neutral.ink4`。
4. L309-317 の「最後の 1 件でも delete」が if/else 両方とも同じ実装になっているのを `if (value.isEmpty) { /* 一律 delete */ return; }` に整理。
5. `RawKeyboardListener` deprecated は `// ignore: deprecated_member_use` + 「ソフトキーボードの Backspace を拾うため意図して維持。Flutter SDK で代替が安定したら置換」とコメント。

```dart
class _CircleCheckbox extends StatefulWidget {
  final bool checked;
  final Color accent;
  final ValueChanged<bool> onChanged;
  const _CircleCheckbox({required this.checked, required this.accent, required this.onChanged});
  @override
  State<_CircleCheckbox> createState() => _CircleCheckboxState();
}
class _CircleCheckboxState extends State<_CircleCheckbox> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(duration: const Duration(milliseconds: 220), vsync: this);
  late final _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 60),
  ]).animate(_ctrl);
  @override
  void didUpdateWidget(_CircleCheckbox old) {
    super.didUpdateWidget(old);
    if (!old.checked && widget.checked) _ctrl.forward(from: 0);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ScaleTransition(scale: _scale, child: GestureDetector(
      onTap: () => widget.onChanged(!widget.checked),
      child: Container(width: 22, height: 22,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: widget.checked ? widget.accent : Colors.transparent,
          border: Border.all(color: widget.checked ? widget.accent : t.neutral.ink4, width: 1.5),
        ),
        alignment: Alignment.center,
        child: widget.checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
      ),
    ));
  }
}
```

### `expandable_fab.dart`

- 閉時 56×56、accent、plus アイコン
- 開時 4 アクション縦並び（写真 / URL / テキスト貼付 / 空行追加）+ ラベル pill (ink 背景 / surface 文字)
- AI バッジ: accent 背景 + 9px/700 で「AI」文字
- spring 280ms (`Curves.easeOutBack` / reverse: `Curves.easeIn`)
- 既存 PopupMenu のメニュー実装（`lib/features/shopping_list/components/app_bar.dart` L150-186 / `_showImagePicker` L285-, `_pasteFromClipboard` L406-428, URL ダイアログ L709- / `_AddShoppingListBottomSheet`）はこちらへ移植

### バナー類

```dart
// retention_banner.dart - 50 件超 / 30 日警告（無料時のみ）
class RetentionBanner extends StatelessWidget {
  const RetentionBanner({super.key});
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.accentSoft, borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(Icons.workspace_premium_outlined, size: 16, color: t.accent),
        const SizedBox(width: 10),
        Expanded(child: Text('無料プランは作成から30日でリストが整理されます',
              style: TextStyle(fontSize: 11.5, color: t.accentInk))),
        InkWell(onTap: () => showPaywall(context: context),
          child: Text('詳しく',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.accent))),
      ]),
    );
  }
}
```

`AllDoneBanner`（okSoft + 🌿 + 「全部チェック完了!」）、`AIProcessingBanner`（accentSoft + spinner + wand icon + 「画像から候補を抽出中...」+ shimmer 6 行）、`ListErrorCard`（dangerSoft + 再試行 / サポートに連絡）も同パターン。

### SnackBar 改修

`notification_member_bar.dart` L228-255 の `showNotificationSnackBar`:
- `duration: 5 seconds`（現状 10 秒）
- `backgroundColor: t.neutral.ink`、`shape: RoundedRectangleBorder(borderRadius: 14)`
- `margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16)`
- `dismissDirection: DismissDirection.startToEnd`
- メッセージは「『XXX』を追加 — 家族に通知しますか？」形式（最後に追加されたアイテム名を渡す）

### EmptyShoppingListHint（dashed hint box）

`empty_text_shopping_list_item.dart` を以下に書き換え:
- 上部: focused な ItemRowEmpty 1 行（タップで実アイテム追加）
- 中段: `GhostItemRow` × 5（opacity 0.5、italic 「例: 牛乳 1L」等）
- 下段: dashed border の Container（`CustomPainter` で破線実装、依存追加なし）に「return で次の行へ。空行で delete で行を消せます。」のヒント

### CategorySectionHeader

```dart
class CategorySectionHeader extends StatelessWidget {
  final GroupCategory category;
  final int doneCount;
  final int totalCount;
  const CategorySectionHeader({super.key, required this.category, required this.doneCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = category.color != null ? colorFromHex(category.color!) : t.neutral.ink3;
    return Container(
      color: t.neutral.surface,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(category.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: t.neutral.ink2, letterSpacing: 0.06)),
        const Spacer(),
        Text('$doneCount/$totalCount', style: GoogleFonts.ibmPlexMono(fontSize: 11,
          color: t.neutral.ink3, fontFeatures: const [FontFeature.tabularFigures()])),
      ]),
    );
  }
}
```

### AI 処理中フラグ

```dart
// lib/provider/ai_processing.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'ai_processing.g.dart';

enum AIProcessingType { image, url }

@riverpod
class AIProcessing extends _$AIProcessing {
  @override
  AIProcessingType? build() => null;
  void start(AIProcessingType type) => state = type;
  void end() => state = null;
}
```

`ExpandableFab` 内の画像 / URL 起動時に `start()`、結果到着 / エラー時に `end()`。`page.dart` 側で `ref.watch(aIProcessingProvider) != null` のとき `AIProcessingBanner` を表示。

### 移行リスク

| リスク | 対策 |
|---|---|
| `RawKeyboardListener` deprecated | コメント＋ ignore で意図的維持。後継 SDK API が安定したら置換タスク化 |
| `_Body` の `Scaffold(appBar: null)` 化で SafeArea を欠く | `ShoppingListPage` 外側 (page.dart L52) の `SafeArea(top: true, bottom: false)` で吸収済 |
| `GroupChipsBar` から groupID 切替伝搬 | `ShoppingListPage` 外側に置き、`_Body` には groupID を `ValueKey` 込みで渡す既存パターンを維持 |
| `themeColorPresets` の旧 hex とデザイン 5 色不一致 | `AccentPreset.fromHex` の fallback で `shu` に倒す（読み取りのみ） |
| `IBM Plex Mono` フォント | `google_fonts` のランタイム DL を使う（同梱は将来検討） |
| dashed border 用 `dotted_border` 依存 | `CustomPainter` で自作（依存最小化） |

---

## 周辺 16 画面 + Onboarding（PR3 / PR4）

各画面の改修ポリシーは「Material3 標準ウィジェットを `lib/components/frame/` の Widget で置き換え、トークンで配色」。ロジック（Provider / call クラス）は無改変。

各画面の inline style（padding / radius / 色）詳細は `design_handoff_shopping_list/source/screens-*.jsx` を都度参照する。

### 1. OnboardingPage（新規）

ファイル:
- 新規 `lib/features/onboarding/page.dart`
- 新規 `lib/features/resolver/onboarding_resolver.dart`
- 改修 `lib/root.dart`: resolver chain に `OnboardingResolver` を `AuthResolver` の前に追加

実装方針:
- `PageView.builder` 3 スライド + ドット + CTA（朱、56px、radius 14）+ skip
- スライド 1: 「家族と作る、買い物リスト」
- スライド 2: 「写真や URL から、まとめて追加」
- スライド 3: 「いつもの並び順で、店舗を回る」
- 完了時 `SharedPreferences.setBool('hasSeenOnboarding', true)` → `Navigator.pushReplacement(AuthPage)`
- 表示判定: `hasSeenOnboarding == false` かつ未認証ユーザー（既存ユーザーは出さない）

```dart
// lib/features/resolver/onboarding_resolver.dart 概要
class OnboardingResolver extends ConsumerWidget {
  final Widget child;
  const OnboardingResolver({super.key, required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final seen = prefs.getBool('hasSeenOnboarding') ?? false;
    final user = FirebaseAuth.instance.currentUser;
    if (!seen && user == null) {
      return const OnboardingPage();
    }
    return child;
  }
}
```

### 2. AuthPage

ファイル: `lib/features/auth/page.dart`

差分:
- AppBar 削除、`Scaffold(backgroundColor: surface)`、Column 全画面構造
- 中央に紙袋＋葉物の SVG イラスト（プレースホルダ）+ タイトル + 説明
- AppleSignInButton: 黒背景 / 高さ 52 / radius 14
- GoogleSignInButton: surface2 + divider / 高さ 52 / radius 14
- `loading-apple` 状態: ボタン内スピナー、他ボタン disabled
- error 状態: 上端に DismissibleBanner（dangerSoft + danger テキスト + radius 12）
- 規約・ポリシー: `.lk` style（下線 1px / underline-offset 3px）、`AppPill(variant: ghost)` 不可（テキストリンクのため `RichText` + `TapGestureRecognizer`）

### 3. HomePage

ファイル: `lib/features/home/page.dart`

差分:
- 既存 `NavigationBar` を `AppBottomTabBar(active: AppTab.list, onChanged: ...)` に置換
- `Scaffold(bottomNavigationBar: AppBottomTabBar(...))` + body は既存 TabBarView 維持
- `useTabController` のままアニメーション制御

### 4. ShoppingListSettingPage

ファイル: `lib/features/shopping_list_setting/page.dart`

差分:
- AppBar を `AppBar(title: Text('買い物リスト設定'), leading: AppRoundButton(icon: Icons.close, ...))` に
- body 全体を `paper` 背景に、`AppSectionCard` で Section / Cell の繰り返し
- リスト名 input、買い物する場所、保存期間（プレミアム CTA）、共有（招待 + グループ設定）、削除ボタン（`AppPill(variant: danger)`）
- `InviteCodeDialog`: 8 桁 mono + コピー / 共有 Pill
- `DeleteConfirmDialog`: AlertDialog ベース、削除ボタン `AppPill(variant: danger)`

### 5. ShoppingListItemFilterPage

ファイル: `lib/features/shopping_list_item_filter/page.dart`

差分:
- AppBar `x close`
- `AppSectionCard` 内に `SwitchListTile`（チェック済み表示 / カテゴリ順、後者はカテゴリ未定義時 disabled）
- ヒント box（`surface2` + radius 14）

### 6. GroupListPage

ファイル: `lib/features/group_list/page.dart`

差分:
- AppBar `chev-l`
- グループカード: `Card`（card 背景 + radius 14 + cardShadow）、内側にアバタースタック（28×28、-8 オーバーラップ、border 1.5px solid card）+ 名前 + メンバー数 + chev-r
- isDefault バッジ: `accentSoft + accent`
- free-limit 時 `AppSectionCard`（accentSoft 背景）に crown icon + 「最大3グループ」+ 解除リンク
- FAB: 通常時 accent + plus、上限時 surface2 + lock（既存実装維持）

### 7. GroupCreatePage

ファイル: `lib/features/group_create/page.dart`

差分:
- AppBar `chev-l`
- card 内に「グループ名」 input + 下線 1px accent
- 「作成する」`AppPill(variant: accent, large: true)` 全幅
- creating 時 内側 spinner、error 時 dangerSoft 帯

### 8. GroupSettingPage

ファイル: `lib/features/group_setting/page.dart`

差分:
- AppBar `chev-l` + trailing `AppRoundButton(more-h)`
- グループ名 input（オーナーのみ編集可）
- メンバーセクション: 36×36 アバター（自分=accent / オーナー=普通）+ `AppPill(soft, icon: person-add, label: '招待コードを発行')`
- リスト軸セクション: 買い物する場所 / カテゴリ Cell（`AppSectionCard` 内）
- 既存のロケーション / カテゴリの**インライン CRUD**は新デザインだと別ページ（`ShoppingLocationPage` / `GroupCategoryPage`）に分離されているので、Cell タップで該当ページに push する形に変更

### 9. GroupInvitationAcceptPage

ファイル: `lib/features/group_invitation/page.dart`

差分:
- AppBar `chev-l`
- 中央: 72×72 accentSoft 円 + person-add アイコン
- 8 桁コード入力 box: `mono 28/700, letterSpacing: 6, ink4 placeholder ·`
- 4 桁目で `marginRight: 12` の区切り
- valid 時 枠 accent、invalid 時 枠 danger + 下にエラー文
- 「参加する」`AppPill(accent)` + 「キャンセル」`AppPill(ghost)`

### 10. GroupCategoryPage

ファイル: `lib/features/group_category/page.dart`

差分:
- AppBar `chev-l`
- 並び順ピル（店舗ドロップダウン + `chev-d`）+ カテゴリ行（drag handle + 32×32 色付きアイコンタイル + 名前 + キーワード件数 + edit/trash）
- free-locked 時 crown バナー
- FAB（plus）

### 11. GroupCategoryEditPage

ファイル: `lib/features/group_category/category_edit_page.dart`

差分:
- 名前 input
- 色: 40×40 swatch 9 個 + 「なし」（X）、選択は outline 2px ink + 二重リング
- アイコン: 6 列グリッド、44×44、未設定タイル「先頭1文字」+ mono "未設定"、最後に「AI 生成」(dashed accent + crown badge、無料は disabled)
- キーワード CRUD: 部分一致 / 完全一致 + ×、「キーワードを追加」`AppPill(ghost)`

### 12. ShoppingLocationPage

ファイル: `lib/features/shopping_location/page.dart`

差分:
- AppBar `chev-l`
- 場所カード: 36×36 アイコンタイル（位置情報あり=accentSoft + accent pin-fill / なし=surface2 + ink3 store）+ 名前 + サブ + edit/trash
- empty 時: 破線 box + store アイコン + 案内
- add dialog: 名前 input + 「地図で場所を設定」破線ボタン + PRO バッジ

### 13. LocationPickerPage

ファイル: `lib/features/shopping_location/location_picker_page.dart`

差分:
- AppBar `chev-l`、bg `surface`
- GoogleMap 中央 + 大きい pin-fill 42 + drop-shadow
- 右下 crosshair 円ボタン 44×44
- 底のカード（left:16 right:16 bottom:36, padding 16, radius 18）
- loading 時: stripe-ph skeleton（CustomPainter で 45° 縞）+ LinearProgressIndicator 40%
- 「この場所を設定」`AppPill(accent, large: true)`

### 14. SettingPage

ファイル: `lib/features/settings/page.dart`

差分:
- 背景 `paper`、上端「設定」見出し（28/700）
- プロファイルカード（`AppSectionCard`）
- プレミアムカード:
  - 無料: surface2 + crown accentSoft + 「プレミアムにアップグレード」 CTA
  - プレミアム: linear-gradient(135deg, accent → #7C2A07) + 白文字 + crown
- グループ Section、外観 Section（テーマカラー Cell + 末尾 crown if 無料）、通知 Section、アプリについて Section、退会ボタン
- バージョン表示: `mono 11/400, ink3, 'v1.4.2 (build 248)'`
- bottom: `AppBottomTabBar(active: AppTab.settings)`

### 15. ThemeColorSelectionPage

ファイル: `lib/features/settings/theme_color_selection_page.dart`

差分:
- **5 色のみ表示**（既存 10 色 → 5 色）
- AppBar `chev-l`
- 説明文 + 5 列グリッド（gap 14）
- 各色: 52×52 円、選択時 border 3px solid surface + outline 2px solid ink + box-shadow + 中に check
- 下に `serif 12/700` で和の名（朱 / 抹茶 / 藍 / 朽葉 / 墨）
- 非プレミアムはタップで `showPaywall(context)` を呼ぶ
- `await ref.read(themeColorUpdateProvider).call(preset: preset);` に置換

### 16. PaywallPage

ファイル: `lib/features/paywall/paywall_page.dart`

差分:
- AppBar `x close`
- Hero: 64×64 グラデーション(accent → `#7C2A07`)タイル + crown + タイトル(22/800) + 説明
- Features カード: 6 項目（pin / image / wand / palette / export / doc）+ check OK
- Plans: 3 プラン横並び `_PaywallPackageTile` 改修。年額に「お得」 `AppPill(soft, label: 'お得')` バッジ（accent / serif）
- loading: 価格部分のみ shimmer
- error: dangerSoft + 再試行ボタン
- no-plans: 破線 box
- フッター: 規約 / ポリシー / 復元 リンク（`.lk` style）

### iOS / Android ホームウィジェット（PR5）

ホームウィジェットのネイティブファイルパスは PR 着手時に Glob で確定する（現時点で `ios/`, `android/` 配下を調査済みでない）。`lib/features/home_widget/home_widget_data_sync.dart` の `syncThemeColor` で渡す HEX を `AccentPreset` の light / dark 値に切り替える。

#### iOS (Swift / WidgetKit)

`ios/Widget/` あるいは `ios/Runner/Widget/` 想定:
- Small (158×158): リスト名 + 残数 (mono / 大) + 進捗バー、背景 paper
- Medium (338×158): 左 リスト名・残数 / 右 未チェック上位 3 件
- Large (338×354): 上位 6-8 件 + プログレス + メンバーアバター
- iOS 17+ Interactive Widget でチェック操作対応

App Group `group.com.bannzai.shoppinglist` の SharedDefaults に `themeColorHex`、ライト/ダーク判定用の値、リスト JSON を渡す（既存）。Swift 側で HEX → UIColor に変換する箇所が新 5 色 HEX のみを許容する形に変更。旧 HEX が来たら `#C2410C` にフォールバック（Flutter 側と同じセマンティクス）。

#### Android (Kotlin / Glance)

`android/app/src/main/kotlin/.../widget/` 想定:
- 4×2 cell, Material You 動的色取り（accent からトーン展開）
- Glance Composable + AppWidgetProvider

Android SharedPreferences `home_widget` 経由で同じ JSON / HEX を受け取る。

#### `lib/features/home_widget/home_widget_data_sync.dart`

L 内部の `_defaultThemeColorHex = '#673AB7'` を `'#C2410C'` に変更。`syncThemeColor` の渡し値も `AccentPreset` 経由で light/dark の HEX を別々に渡す（現状はライト 1 色のみ渡している場合は両方渡すよう拡張）。

---

## 検証方法

実装は段階 PR 分割を推奨だが、各 PR で以下を必ず通す。

### 共通

- `flutter analyze` → エラー 0、`deprecated_member_use` の `RawKeyboardListener` のみ ignore コメント付きで許容
- `flutter test` → 既存テスト全件パス + 新規テストが通る
- `flutter build ios --no-codesign` 成功
- `flutter build apk --debug` 成功
- `flutter pub get` 後 `dart run build_runner build --delete-conflicting-outputs` で `.g.dart` 再生成

### PR1（基盤）

- `test/theme_color_test.dart` を新仕様に書き換え:
  - `resolveAccentPreset(null) == AccentPreset.shu`
  - `resolveAccentPreset('#673AB7') == AccentPreset.shu`（旧 10 色フォールバック）
  - `resolveAccentPreset('#1F6B4E') == AccentPreset.matcha` 等 5 色の解決
  - `isSupportedThemeColorHex` の判定
- 新規 widget test: `AppPill / AppCheckbox / AppLargeAppBar`
- Maestro E2E: `maestro/flows/foundation_theme_smoke.yaml`（テーマカラー切替で primary が変わる確認）

### PR2（ShoppingListPage）

- 既存 Maestro flow が通る（連続入力 / スワイプ削除 / カテゴリ表示 / 空リスト / リスト切替）:
  - `maestro/flows/add_and_check_item.yaml`
  - `maestro/flows/swipe_delete_item.yaml`
  - `maestro/flows/category_matching_test.yaml`
  - `maestro/flows/empty_shopping_list_create.yaml`
- 新規 Widget Test:
  - `progress_block_test.dart`
  - `item_row_focus_test.dart`（focused 時に左 2px accent border が描画される）
  - `expandable_fab_test.dart`（4 メニューが展開する）
  - `all_done_banner_test.dart`（全完了時に表示）

### PR3 / PR4（周辺画面）

- 各画面に対して Maestro flow を追加 / 既存を確認:
  - Onboarding: `onboarding_first_launch.yaml`（新規ユーザーで 3 スライド + skip / 完走）
  - Auth: `auth_apple_signin.yaml` / `auth_error.yaml`
  - SettingPage: `theme_color_change.yaml`（5 色のいずれかを選択）
  - PaywallPage: 既存の Maestro flow 維持
- ThemeColorSelectionPage の `Key('theme_preset_${preset.name}')` を Maestro 用に付与

### PR5（ホームウィジェット）

- iOS / Android 両方で実機（or シミュレータ）にウィジェット追加 → 表示確認
- テーマカラー切替時に widget の accent が追従するか手動確認
- `lib/features/home_widget/home_widget_sync.dart` の `ref.listen` 経由で再同期されるか

### 手動チェックリスト（リリース前）

- [ ] 旧 10 色 (`#673AB7` 等) を保存済みのアカウントでログイン → アクセントが朱になっている
- [ ] 設定画面で抹茶 → 全画面の primary が緑系に切り替わる
- [ ] OS のダーク / ライト切替で `tokens.isDark` が反応する
- [ ] 初回起動で Noto Sans JP が描画される（フォールバックなし）
- [ ] OnboardingPage が新規ユーザーのみに表示され、既存ユーザーには表示されない
- [ ] ShoppingListPage の連続入力（Enter で末尾空行追加 / 空 Backspace で削除）が動作する
- [ ] ホームウィジェットの色がアプリのテーマと同期する

---

## 実装順序の推奨

1. PR1 をマージ → ベースが新トークンに乗る
2. PR2 をマージ → 中核 UX 完成、レビュー優先
3. PR3 / PR4 を並列で進める（互いに干渉しない画面群に分けて）
4. PR5（ウィジェット）はネイティブ側変更を含むので最後に集中レビュー

各 PR で issue 250 / 251 をリンクし、最終マージ時にこれらの issue を close する。

---

## 実装上の注意点

- **`palt`**: `TextStyle.fontFeatures: [FontFeature('palt')]` をテキストテーマ全体に適用。フォントが palt を持たなければ無視される（落ちない）
- **`tnum`**: 数値（mono）は `FontFeature.tabularFigures()` を別途指定。`palt` と同居可能
- **`ThemeExtension` の null チェック**: `Theme.of(context).extension<AppTokens>()!`。必ず `buildAppTheme` 経由でなければならない
- **`riverpod_generator`**: `provider/theme_color.dart` を編集したら必ず `dart run build_runner build --delete-conflicting-outputs`
- **`google_fonts` のオフライン挙動**: 初回起動時 Wi-Fi がないと Roboto フォールバック。`main.dart` で `GoogleFonts.pendingFonts(...)` プリロード推奨
- **無料 / プレミアム境界の文言**: README で「グループ最大3、保持期間30日」とあるが、実装は「グループ追加1、リスト5本、AI月5回 / 月50回」。**今回はビジネスロジック変更なし**で、表示文言だけ デザインに合わせる（30 日保持表記は新デザインのコピー、内部的なクリーンアップ Functions は別途要確認・必要なら別 issue で対応）
- **既存ユーザーの themeColor 保護**: 読み取り fallback のみ、書き戻ししない。設定画面で明示的に色変更したときだけ新 HEX が永続化される
- **削除予定ファイル**: `lib/features/shopping_list/components/app_bar.dart`、`group_switcher.dart` は PR2 で削除。中身のロジック（PopupMenu、URL ダイアログ、AddListBottomSheet）は `expandable_fab.dart` または個別ファイルに移植
- **`lib/components/toolbar/picker.dart`** の `CupertinoButton` は `AppPill` への置換を後続フェーズで検討（PR1 では触らない）

---

## 再修正ラウンド (Round 2): デザイン忠実度の引き上げ

### Context

1 回目の実装で PR1 (基盤) + PR2 (ShoppingListPage 中核) を完了したが、ユーザー評価は「雰囲気だけできていて Claude Design のものと違う」だった。

`design_handoff_shopping_list/source/{tokens.jsx, styles.css, frame.jsx, screens-list.jsx}` と現状実装を再照合した結果、数値・配置・色・配色・状態出し分けに細かいドリフトが多数あった。本ラウンドはそれらを潰す。

スコープは初回ヒアリングどおり PR1 + PR2 のみ。PR3 / PR4 / PR5 は別ラウンド。

### 影響範囲サマリ

| カテゴリ | 主な修正内容 |
|---|---|
| PR1 基盤 (5 ファイル) | 文字スタイル正本化 (w800→w700)、影方針修正、palt 継承、Pop アイコン強化 |
| PR2 page.dart 構造 | ProgressBlock 常時表示・Error/AI 時 FAB 抑止・RetentionBanner 位置 |
| PR2 共通 Widget (3 ファイル) | ListTopBar 縮小 + AvatarStack 削除・GroupChips/FilterChips active 条件 |
| PR2 進捗 / FAB (2 ファイル) | baseline 整列・letterSpacing・240ms width アニメ・accent 影 |
| PR2 バナー類 (4 ファイル) | retention 背景・ai_processing 全面書換・list_error 固定文言・サポート Pill |
| PR2 ItemRow 系 (5 ファイル) | padding 20/11・サムネ 40×40・dashed hint card 絶対配置・末尾の isEmpty focused 行 |
| PR2 SnackBar (1 ファイル) | 2 段テキスト・accent pill・26×26 配色循環 avatar |
| 重複削除 | `_CircleCheckbox` (text_shopping_list_item.dart L255-324) を削除し `AppCheckbox` に統一 |

---

### PR1 基盤の修正点

#### B1. theme.dart: タイポスケール正本化

frame.jsx の AppBar large は w700、compact は w600。現状 `displayMedium = w800` + `titleTextStyle = textTheme.titleLarge (=w700)` は両方とも仕様より太い。

```dart
// lib/style/theme.dart
final textTheme = base.copyWith(
  displayLarge:  serif(38, FontWeight.w800, height: 1.15, ls: -0.02),
  displayMedium: serif(28, FontWeight.w700, height: 1.15, ls: -0.02), // w800 → w700
  headlineSmall: sans(22, FontWeight.w700, height: 1.25, ls: -0.015),
  // ...既存維持
);

return ThemeData(
  // ...
  appBarTheme: AppBarTheme(
    backgroundColor: neutral.surface,
    foregroundColor: neutral.ink,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: sans(17, FontWeight.w600, height: 1.3, ls: -0.01), // titleLarge ではなく明示
    centerTitle: true,
    surfaceTintColor: Colors.transparent,
  ),
  // ...
);
```

#### B2. AppSectionCard: 影削除

handoff README L124「フローティングしているもの以外には影を載せない」。AppSectionCard は面に貼り付いた構造なので `boxShadow` を削除する。

```dart
// lib/components/frame/app_section_card.dart
Container(
  decoration: BoxDecoration(
    color: neutral.card,
    borderRadius: BorderRadius.circular(AppTokens.radiusCard),
    border: Border.all(color: neutral.divider, width: 0.5),
    // boxShadow: tokens.cardShadow,  ← 削除 (handoff: フローティング以外影なし)
  ),
  child: Column(children: _withDividers(children, neutral.divider2)),
)
```

#### B3. AppLargeAppBar: subtitle サイズ

```dart
// lib/components/frame/app_large_app_bar.dart
if (subtitle != null) ...[
  const SizedBox(height: 4),
  Text(
    subtitle!,
    style: textTheme.bodyMedium?.copyWith(
      fontSize: 13, // 14 → 13 (frame.jsx L80)
      color: neutral.ink2,
    ),
  ),
],
```

#### B4. AppPill / AppChip / AppBottomTabBar: textTheme 経由でフォント継承

新規 `TextStyle(...)` を直書きしているため `fontFamily` が継承されず `palt` も効かない。textTheme 由来の `copyWith` に統一する。

```dart
// lib/components/frame/app_pill.dart  (label の Text)
Text(
  label,
  style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: fg,
        fontSize: large ? 15 : 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.005,
      ),
),

// lib/components/frame/app_chip.dart
Text(
  label,
  softWrap: false,
  overflow: TextOverflow.visible,
  style: Theme.of(context).chipTheme.labelStyle?.copyWith(
        fontSize: 12.5,
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        letterSpacing: -0.005,
        color: fg,
      ),
),

// lib/components/frame/app_bottom_tab_bar.dart
Text(
  label,
  style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontSize: 10.5,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        letterSpacing: 0.02,
        color: color,
        height: 1.0,
      ),
),
```

#### B5. AppCheckbox: チェックアイコン強化 + disabled

frame.jsx の `sw: 2.4` は単一線の太さ指定。Material Icons には太さ可変が無いので `Icons.check_rounded` + `weight: 700` で疑似強化する。また `onChanged: null` 時に `opacity: 0.5` を適用。

```dart
// lib/components/frame/app_checkbox.dart
@override
Widget build(BuildContext context) {
  final tokens = context.tokens;
  final neutral = tokens.neutral;
  final disabled = widget.onChanged == null;
  return Opacity(
    opacity: disabled ? 0.5 : 1.0,
    child: ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: disabled ? null : () => widget.onChanged!(!widget.checked),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.checked ? (widget.color ?? tokens.accent) : Colors.transparent,
            border: Border.all(
              color: widget.checked ? (widget.color ?? tokens.accent) : neutral.ink4,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: widget.checked
              ? Icon(
                  Icons.check_rounded,    // ← 太め
                  size: widget.size * 0.62,
                  color: Colors.white,
                  weight: 700,
                )
              : null,
        ),
      ),
    ),
  );
}
```

---

### PR2 ShoppingListPage の修正点

#### P1. page.dart: 縦構造の再編

仕様 (screens-list.jsx) との差分:
- Empty 状態でも `done=0 / total=0` で ProgressBlock を表示
- AI 処理中 / Error 時は FAB を出さない
- Error 時は FilterChips / ProgressBlock / RetentionBanner を非表示
- RetentionBanner は list body の「上」(`Expanded` の前) に置く

```dart
// lib/features/shopping_list/page.dart : _Body.build の中
final isError = shoppingListItemsAsync.hasError;

return Retry(
  retry: () => ref.invalidate(...),
  child: Scaffold(
    backgroundColor: tokens.neutral.surface,
    floatingActionButton: (aiProcessingType != null || isError)
        ? null
        : ExpandableFab(...),
    body: Column(
      children: [
        ListTopBar(...),
        if (isError)
          Expanded(child: ListErrorCard(onRetry: () => Retry.of(context).retry()))
        else ...[
          FilterChipsBar(...),
          ProgressBlock(checkedCount: checkedCount, totalCount: totalCount), // 常時表示
          if (totalCount > 0 && checkedCount == totalCount) const AllDoneBanner(),
          if (aiProcessingType != null)
            AIProcessingBanner(type: aiProcessingType, onCancel: () => ref.read(aIProcessingProvider.notifier).end()),
          if (!firestoreIsPremium && totalCount > 50) const RetentionBanner(),
          Expanded(
            child: shoppingListItemsAsync.when(
              data: (items) => ShoppingListBodyContent(...),
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const Loading(),
            ),
          ),
        ],
      ],
    ),
  ),
);
```

加えて `showNotificationSnackBar` に `addedItemMessage` を渡せるよう拡張し、useEffect で直近追加された非空メッセージを推定して渡す (P12 連動)。

#### P2. list_top_bar.dart: 高さ・アイコン・AvatarStack 削除

screens-list.jsx の ListTopBar は h=48、右側は `RoundBtn(filter) + RoundBtn(more-h)` のみで AvatarStack は無い (アバターは NotifySnack 内に存在)。

```dart
// lib/features/shopping_list/components/list_top_bar.dart
return SizedBox(
  height: 48, // 52 → 48
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
    child: Row(
      children: [
        InkWell(
          onTap: ...,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(child: Text(
                shoppingList?.name ?? '買い物リスト',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: tokens.neutral.ink, letterSpacing: -0.17),
              )),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: tokens.neutral.ink2), // 18 → 16
            ]),
          ),
        ),
        const Spacer(),
        // AvatarStack は screens-list.jsx には存在しない → 削除
        AppRoundButton(icon: Icons.filter_list, onPressed: () { /* filter sheet */ }, size: 36, iconSize: 18),
        const SizedBox(width: 4),
        AppRoundButton(icon: Icons.more_horiz, onPressed: () { /* more sheet (リスト設定など) */ }, size: 36, iconSize: 18),
      ],
    ),
  ),
);
```

#### P3. group_chips_bar.dart: padding 修正 + アクティブ時 check

```dart
// lib/features/shopping_list/components/group_chips_bar.dart
Padding(
  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), // top 8 → 0 (screens-list.jsx L42)
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(children: [
      for (final (i, group) in groups.indexed) ...[
        if (i > 0) const SizedBox(width: 6),
        AppChip(
          label: group.name ?? 'グループ',
          active: group.id == currentGroupID,
          soft: true,
          // アクティブ時は check、非アクティブはメンバー数で people/person
          icon: group.id == currentGroupID
              ? Icons.check
              : (groupMemberCount(group) > 1 ? Icons.people_outline : Icons.person_outline),
          onTap: group.id == currentGroupID ? null : () => onGroupChanged(group.id),
        ),
      ],
      if (onAddGroup != null) ...[
        const SizedBox(width: 6),
        AppChip(label: '追加', icon: Icons.add, onTap: onAddGroup),
      ],
    ]),
  ),
);
```

#### P4. filter_chips_bar.dart: active 時のみ icon + soft

```dart
// lib/features/shopping_list/components/filter_chips_bar.dart
AppChip(
  label: showChecked.value ? 'チェック済み 表示' : 'チェック済み 非表示', // 半角スペース入り
  icon: !showChecked.value ? Icons.check : null,   // active 時のみ
  soft: !showChecked.value,                         // active 時のみ
  active: !showChecked.value,
  onTap: () { ... },
),
const SizedBox(width: 6),
AppChip(
  label: sortByCategory.value ? 'カテゴリ順' : 'リスト順',
  icon: sortByCategory.value ? Icons.sell_outlined : null,
  soft: sortByCategory.value,
  active: sortByCategory.value,
  onTap: hasCategories ? () { ... } : null,
),
```

#### P5. progress_block.dart: baseline + letterSpacing + 240ms アニメ

```dart
// lib/features/shopping_list/components/progress_block.dart
Row(
  crossAxisAlignment: CrossAxisAlignment.baseline,
  textBaseline: TextBaseline.alphabetic,
  children: [
    Text.rich(TextSpan(children: [
      TextSpan(
        text: '$checkedCount',
        style: monoTextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: neutral.ink)
            .copyWith(letterSpacing: -0.48), // -0.02em × 24px
      ),
      TextSpan(
        text: '/$totalCount',
        style: monoTextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: neutral.ink3)
            .copyWith(letterSpacing: -0.48),
      ),
    ])),
    const SizedBox(width: 8),
    Text(
      allDone ? '完了!' : 'チェック済み',
      style: TextStyle(fontSize: 12, color: neutral.ink2, fontWeight: FontWeight.w400), // w500 → w400
    ),
    const Spacer(),
    if (allDone)
      Text('✓ おつかれさま', style: TextStyle(fontSize: 12, color: neutral.ok, fontWeight: FontWeight.w600)),
  ],
),
const SizedBox(height: 8),
ClipRRect(
  borderRadius: BorderRadius.circular(4),
  child: TweenAnimationBuilder<double>(
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOut,
    tween: Tween(begin: 0, end: progress),
    builder: (context, value, _) => LinearProgressIndicator(
      value: value,
      minHeight: 4,
      backgroundColor: neutral.divider2,
      valueColor: AlwaysStoppedAnimation<Color>(allDone ? neutral.ok : tokens.accent),
    ),
  ),
),
```

#### P6. expandable_fab.dart: accent 影 / 副ボタン spec

```dart
// 主ボタン (open ボタン)
Container(
  width: 56, height: 56,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: tokens.accent,
    boxShadow: [
      BoxShadow(color: tokens.accent.withValues(alpha: 0.35), offset: const Offset(0, 6), blurRadius: 14),
    ],
  ),
  child: Material(
    color: Colors.transparent, shape: const CircleBorder(),
    child: InkWell(customBorder: const CircleBorder(), onTap: ..., child: const Center(child: Icon(Icons.add, size: 26, color: Colors.white))),
  ),
);

// 副ボタン (_ActionRow 内)
Container(
  width: 44, height: 44,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: tokens.neutral.surface, // surface2 → surface
    boxShadow: const [
      BoxShadow(color: Color(0x1F1B1813), offset: Offset(0, 6), blurRadius: 14),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    shape: CircleBorder(side: BorderSide(color: tokens.neutral.divider)), // 1px divider
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: action.onTap,
      child: Center(child: Icon(action.icon, size: 18, color: tokens.neutral.ink)), // 20 → 18
    ),
  ),
);
```

#### P7. banners: 4 種類の正本化

```dart
// banners/all_done_banner.dart
Text(
  'お会計のあと、リストをアーカイブしますか?', // 仕様文言
  style: TextStyle(fontSize: 11, color: tokens.neutral.ok.withValues(alpha: 0.85), fontWeight: FontWeight.w400),
),

// banners/retention_banner.dart : surface2 + 1px divider + 塗り crown
return Container(
  margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  decoration: BoxDecoration(
    color: tokens.neutral.surface2, // accentSoft → surface2 (screens-list.jsx L432-440)
    border: Border.all(color: tokens.neutral.divider, width: 1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(children: [
    Icon(Icons.workspace_premium, size: 14, color: tokens.accent), // 塗り版 + 16 → 14
    const SizedBox(width: 10),
    Expanded(child: Text(
      '無料プランは作成から30日でリストが整理されます',
      style: TextStyle(fontSize: 11.5, color: tokens.neutral.ink2), // accentInk → ink2
    )),
    InkWell(onTap: ..., child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text('詳しく', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tokens.accent)),
    )),
  ]),
);

// banners/ai_processing_banner.dart : 全面書き換え (44×44 stripe spinner + サブテキスト + ghost cancel)
class AIProcessingBanner extends HookWidget {
  final AIProcessingType type;
  final VoidCallback? onCancel;
  const AIProcessingBanner({super.key, required this.type, this.onCancel});
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final (title, sub) = switch (type) {
      AIProcessingType.image => ('写真からアイテムを生成中', 'レシート 1枚 ・ 候補を抽出しています…'),
      AIProcessingType.url   => ('URL からアイテムを生成中', 'ページを解析しています…'),
    };
    final controller = useAnimationController(duration: const Duration(seconds: 1))..repeat();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: tokens.accentSoft, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        SizedBox(width: 44, height: 44, child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) => Transform.rotate(
            angle: controller.value * 6.2831853,
            child: CustomPaint(painter: StripeBorderPainter(accent: tokens.accent, dark: tokens.isDark)),
          ),
        )),
        const SizedBox(width: 12),
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.auto_awesome, size: 14, color: tokens.isDark ? tokens.accentInk : tokens.accent),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.isDark ? tokens.accentInk : tokens.accent)),
          ]),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 11, color: tokens.neutral.ink2)),
        ])),
        if (onCancel != null) TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: tokens.neutral.ink3,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('キャンセル', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// banners/list_error_card.dart : 固定文言 + サポート Pill
return Center(child: Container(
  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
  decoration: BoxDecoration(color: tokens.neutral.dangerSoft, borderRadius: BorderRadius.circular(18)),
  child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Text('📡', style: TextStyle(fontSize: 32)),
    const SizedBox(height: 8),
    Text('リストを読み込めませんでした', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: tokens.neutral.danger)),
    const SizedBox(height: 4),
    Text(
      '通信状態を確認してください。\nもう一度お試しいただくか、しばらくしてから開き直してください。',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: tokens.neutral.ink2, height: 1.6),
    ),
    const SizedBox(height: 14),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      AppPill(label: 'サポートに連絡', variant: AppPillVariant.ghost, onPressed: () { /* mailto / support */ }),
      const SizedBox(width: 8),
      AppPill(label: '再試行', variant: AppPillVariant.accent, onPressed: onRetry),
    ]),
  ]),
));
```

`StripeBorderPainter` は新規追加。`-45°` ストライプ + `2px accent border (top transparent)` を `Canvas` で描画。

#### P8. text_shopping_list_item.dart: padding / サムネ / more / 重複削除

```dart
// lib/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart
// 1. L255-324 の _CircleCheckbox を全削除 (AppCheckbox と完全に同じロジック)

// 2. L98-121 の Checkbox 部分を AppCheckbox に統一
child: Padding(
  padding: const EdgeInsets.only(top: 1),       // Checkbox を 1px 下げる
  child: AppCheckbox(
    checked: isChecked,
    size: 22,
    color: textShoppingListItem.color != null ? colorFromHex(textShoppingListItem.color!) : tokens.accent,
    onChanged: (_) {
      analytics.logEvent(...);
      ref.read(toggleShoppingListItemCheckProvider(groupID: groupID)).call(...);
    },
  ),
),

// 3. background & padding (L72-94)
final focused = isEditing.value;
final backgroundColor = focused
    ? tokens.accentSoft.withValues(alpha: 0x60 / 0xFF) // 0.4 → 0.376 (= 96/255)
    : Colors.transparent;                              // itemColor/divider2 塗りは削除

return Material(
  color: backgroundColor,
  child: InkWell(
    onTap: () => focusNode.requestFocus(),
    child: Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: focused ? tokens.accent : Colors.transparent, width: 2)),
      ),
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11), // 16/4 → 20/11
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // center → start
        children: [
          /* ...AppCheckbox + SizedBox(12)... */,
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
              ...
              cursorColor: tokens.accent,
              cursorWidth: 1.5,                    // 追加 (.fake-caret の 1.5px)
              cursorRadius: const Radius.circular(0.75),
            ),
            if (hasDescription)
              Padding(
                padding: const EdgeInsets.only(top: 2), // marginTop 2
                child: Opacity(
                  opacity: isChecked ? 0.5 : 1.0,        // checked 時 opacity
                  child: Text(textShoppingListItem.description!,
                    style: TextStyle(fontSize: 12, color: tokens.neutral.ink3, height: 1.4),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
          ])),
          // 4. サムネ 40×40 + radius 10 + カテゴリ色 0x30 背景 + divider border + stripe placeholder
          if (textShoppingListItem.imageURL != null)
            Padding(padding: const EdgeInsets.only(left: 4), child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: textShoppingListItem.color != null
                    ? colorFromHex(textShoppingListItem.color!).withValues(alpha: 0x30 / 0xFF)
                    : tokens.neutral.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: tokens.neutral.divider, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(fit: StackFit.expand, children: [
                CustomPaint(painter: StripePlaceholderPainter(color: tokens.neutral.ink)),
                CachedNetworkImage(imageUrl: textShoppingListItem.imageURL!, fit: BoxFit.cover, ...),
              ]),
            )),
          // 5. more icon を InkResponse + size 16 + padding 4 に
          Padding(padding: const EdgeInsets.only(top: 2), child: InkResponse(
            onTap: () { /* 詳細シート */ },
            radius: 16,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.more_horiz, size: 16, color: isChecked ? tokens.neutral.ink4 : tokens.neutral.ink3),
            ),
          )),
        ],
      ),
    ),
  ),
);
```

`StripePlaceholderPainter` 新規: `repeating-linear-gradient(-45deg, rgba(27,24,19,0.04) 0 8px, rgba(27,24,19,0.07) 8px 16px)` を `Canvas.drawLine` で再現。

#### P9. empty_text_shopping_list_item.dart: Stack 構造 + 絶対配置 hint card

screens-list.jsx L324-347 の `ShoppingListEmpty` 構造:
- 最上段 `ItemRow isEmpty focused` (placeholder「アイテムを入力…」+ `.fake-caret`)
- ghost ×5 (先頭だけ hint='例: 牛乳 1L'、残りは「新しいアイテム…」)
- 画面下から `bottom: 170` の絶対配置 dashed hint card (radius 14 / surface2 bg / inline mono chip)

```dart
// lib/features/shopping_list/components/shopping_list_items/empty_text_shopping_list_item.dart
return Stack(children: [
  ListView(
    padding: const EdgeInsets.only(top: 6, bottom: 220),
    children: [
      _StarterRow(onTap: () async { /* addShoppingListItem(message: '') */ }),
      const GhostItemRow(hint: '例: 牛乳 1L'),
      for (var i = 0; i < 4; i++) const GhostItemRow(), // default hint「新しいアイテム…」
    ],
  ),
  Positioned(left: 20, right: 20, bottom: 170, child: _UsageHintCard()),
]);

// _StarterRow を ItemRow isEmpty focused 相当に書き換え
class _StarterRow extends StatelessWidget {
  final VoidCallback onTap;
  const _StarterRow({required this.onTap});
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        color: tokens.accentSoft.withValues(alpha: 0x40 / 0xFF),
        border: Border(left: BorderSide(color: tokens.accent, width: 2)),
      ),
      child: Row(children: [
        const AppCheckbox(checked: false, onChanged: null),
        const SizedBox(width: 12),
        Expanded(child: Text('アイテムを入力…', style: TextStyle(fontSize: 16, color: tokens.neutral.ink3))),
        _BlinkingCaret(color: tokens.accent),
      ]),
    ));
  }
}

// _BlinkingCaret 新規 (styles.css#.fake-caret 相当: 1.5×16, 1.06s steps(2) blink)
// _UsageHintCard 新規 (dashed 14 + surface2 + 「そのまま入力できます」13/600 + 段落 inline mono chip)
// _MonoChip 新規 (bg surface, padding 6/1, radius 4, 1px divider border, mono フォント)

// _UsageHintCard の本文 (Text.rich):
// 「空行をタップして名前を打ち、[return] で次の行へ。空行で [delete] で行を消せます。」
// [] 内は _MonoChip(label: 'return') / _MonoChip(label: 'delete') を WidgetSpan で挿入
```

`_DashedRectPainter._radius` を `12.0` → `14.0` に修正。

#### P10. shopping_list_items.dart: 末尾の ItemRow isEmpty focused

screens-list.jsx の Flat / ByCategory は **末尾に常に `ItemRow isEmpty focused`** が描画されており、タップで空 item が追加される UX。現状は `EmptyTextShoppingListItems` (リストが完全に空のとき) のみで、items がある状態の末尾には何も無い。

```dart
// lib/features/shopping_list/components/shopping_list_items/shopping_list_items.dart
// _FlatShoppingListItems を SliverReorderableList + 末尾 _TailEmptyRow に
return CustomScrollView(slivers: [
  SliverReorderableList(
    onReorder: ...,
    itemCount: shoppingListItems.length,
    itemBuilder: (context, index) => TextShoppingListItemWidget(...),
  ),
  SliverToBoxAdapter(child: _TailEmptyRow(
    groupID: groupID,
    shoppingListID: shoppingListItems.isNotEmpty ? shoppingListItems.first.shoppingListID : shoppingListID,
    nextOrder: shoppingListItems.nextOrder,
  )),
  const SliverToBoxAdapter(child: SizedBox(height: 100)),
]);

// _GroupedListView の children の末尾にも _TailEmptyRow と SizedBox(100) を追加
```

`_TailEmptyRow` は `_StarterRow` と同じ見た目で、タップで `addShoppingListItemProvider.call(message: '')` を呼ぶ。共通化のため `lib/features/shopping_list/components/shopping_list_items/tail_empty_row.dart` に新規ファイル。

#### P11. category_section_header.dart: letterSpacing 単位修正

```dart
// lib/features/shopping_list/components/shopping_list_items/category_section_header.dart
Text(name, style: TextStyle(
  fontSize: 11, fontWeight: FontWeight.w700, color: neutral.ink2,
  letterSpacing: 0.66, // em → px 換算: 0.06em × 11px = 0.66 (現状 0.06 を絶対値として誤用)
  height: 1.2,
)),
```

#### P12. ghost_item_row.dart: サイズ・デフォルト hint

```dart
// lib/features/shopping_list/components/shopping_list_items/ghost_item_row.dart
class GhostItemRow extends StatelessWidget {
  final String hint;
  const GhostItemRow({super.key, this.hint = '新しいアイテム…'});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Opacity(opacity: 0.5, child: Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        const AppCheckbox(checked: false, onChanged: null),
        const SizedBox(width: 12),
        Expanded(child: Text(hint, style: TextStyle(
          fontSize: 16, // 14 → 16
          fontStyle: FontStyle.italic,
          color: tokens.neutral.ink3,
        ))),
      ]),
    ));
  }
}
```

#### P13. notification_member_bar.dart: 2 段テキスト + 重なり avatar + accent pill

```dart
// lib/features/shopping_list/components/notification_member_bar.dart
return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
  Icon(Icons.notifications_outlined, size: 16, color: neutral.surface), // 18 → 16
  const SizedBox(width: 10),
  Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(
      addedItemMessage != null ? '『$addedItemMessage』を追加' : 'リストが更新されました',
      style: TextStyle(color: neutral.surface, fontSize: 13, fontWeight: FontWeight.w500, height: 1.3),
      maxLines: 1, overflow: TextOverflow.ellipsis,
    ),
    const SizedBox(height: 2),
    Text('家族に通知しますか?',
      style: TextStyle(color: neutral.surface.withValues(alpha: 0.7), fontSize: 11, height: 1.2),
    ),
  ])),
  const SizedBox(width: 10),
  _StackedMemberAvatars(otherMembers: otherMembers, sendingUserIDs: sendingUserIDs, sentUserIDs: sentUserIDs),
  const SizedBox(width: 10),
  _SendAllButton(/* accent pill 化 */),
]);

// _StackedMemberAvatars: 26×26 円 + 1.5px ink border + 配色循環 ['#C2410C','#1F6B4E','#0F4C81']
//                       + Stack で -6 重なり + 4 人目以降 "+N" バッジ

// _SendAllButton: accent bg + radius 999 + padding 12/6 + 「全員に通知」 12/w700/white
//                 disabled (all sent / sending 中) は accent.withAlpha(0.5)
```

呼び出し側 (page.dart):

```dart
ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  content: NotificationMemberBar(..., addedItemMessage: lastAddedMessage),
  duration: const Duration(seconds: 5),
  behavior: SnackBarBehavior.floating,
  backgroundColor: tokens.neutral.ink,
  margin: const EdgeInsets.fromLTRB(16, 0, 16, 156), // FAB(56) + bottom(90) + 余白(10)
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  dismissDirection: DismissDirection.startToEnd,
  elevation: 6,
));
```

---

### 検証

#### 静的解析・ビルド
- [ ] `flutter analyze` エラーなし (`deprecated_member_use` の `RawKeyboardListener` のみ `// ignore` で許容)
- [ ] `dart run build_runner build --delete-conflicting-outputs` 成功
- [ ] `flutter test` 全件パス
- [ ] `flutter build ios` 成功
- [ ] `flutter build apk` 成功

#### Widget Test (新規 or 既存追加)
- [ ] `progress_block_test.dart`: baseline 整列 + letterSpacing -0.48 + ラベル w400
- [ ] `retention_banner_test.dart`: surface2 背景 + 1px divider border + crown stroke accent
- [ ] `all_done_banner_test.dart`: sub 文言「お会計のあと、リストをアーカイブしますか?」
- [ ] `expandable_fab_test.dart`: 4 メニュー + AI バッジ + 主ボタン accent 影
- [ ] `text_shopping_list_item_test.dart`: padding 20/11 + minHeight 52 + crossAxisAlignment.start + サムネ 40/radius 10
- [ ] `empty_text_shopping_list_item_test.dart`: Stack 構造 + 絶対配置 dashed カード + _BlinkingCaret
- [ ] `category_section_header_test.dart`: letterSpacing 0.66 px
- [ ] `notification_member_bar_test.dart`: 2 段テキスト + accent pill + 26x26 avatar + 配色循環

#### Maestro E2E (既存維持を確認)
- [ ] `maestro/flows/add_and_check_item.yaml`
- [ ] `maestro/flows/swipe_delete_item.yaml`
- [ ] `maestro/flows/category_matching_test.yaml`
- [ ] `maestro/flows/empty_shopping_list_create.yaml`

#### 目視確認 (iPhone 16 Plus simulator)
- [ ] ライト / ダーク両方で ShoppingListPage を表示
- [ ] 朱 / 抹茶 / 藍 / 墨 / 朽葉 5 色アクセント切替が反映される
- [ ] 空リスト: dashed Tips カードが画面下から 170px 位置に絶対配置
- [ ] 進捗バーが 240ms width アニメで補間
- [ ] AI 処理中: FAB 非表示 + ai_processing バナー (44×44 spinner + ghost cancel) 表示
- [ ] エラー: FAB 非表示 + ListErrorCard + サポート / 再試行 2 Pill
- [ ] AllDone: バー ok 色 + 「✓ おつかれさま」 + okSoft バナー
- [ ] FreeNotice: surface2 + divider 枠 + 塗り crown
- [ ] Notify SnackBar: 2 段「『XXX』を追加 / 家族に通知しますか?」 + 26x26 配色循環 avatar + accent pill「全員に通知」
- [ ] ItemRow: padding 20/11 + サムネ 40×40 / radius 10 / カテゴリ色背景
- [ ] design_handoff_shopping_list/買い物リスト UI再設計.html と並べて見比べ、視覚一致を確認

---

### 実装順序の推奨

各ステップで `flutter analyze` を通し、簡単な目視確認を入れる:

1. **PR1 修正 (B1-B5)**: `theme.dart` / `AppSectionCard` / `AppLargeAppBar` / `AppPill`+`AppChip`+`AppBottomTabBar` / `AppCheckbox`
2. **PR2 ItemRow 系 (P8, P11, P12, P10)**: `text_shopping_list_item` (重複 `_CircleCheckbox` 削除込み) / `category_section_header` / `ghost_item_row` / `shopping_list_items` (末尾 `_TailEmptyRow`)
3. **PR2 Empty 系 (P9)**: `empty_text_shopping_list_item` + 新規 `_BlinkingCaret` / `_MonoChip` / `_UsageHintCard`
4. **PR2 構造系 (P1, P2, P3, P4, P5, P6)**: `page.dart` / `list_top_bar` / `group_chips_bar` / `filter_chips_bar` / `progress_block` / `expandable_fab`
5. **PR2 バナー (P7)**: `all_done` / `retention` / `ai_processing` / `list_error`
6. **PR2 SnackBar (P13)**: `notification_member_bar` + `page.dart` の呼び出し改修
7. **最終確認**: `flutter analyze` / `flutter test` / `flutter build ios` / `flutter build apk` / Maestro 流す

---

## チェックリスト

### 実装内容
- [x] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [x] 既存コードのパターン・構成を確認し、同じパターンで実装している

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios` 成功
- [ ] Android ビルド: `flutter build apk` 成功
- [ ] 新規・変更機能に対するテストが存在する（なければ新規作成）
- [ ] Maestro E2E: 該当する maestro flow があれば実行、なければ新規作成
- [ ] Entity命名: フィールド名が省略されていない
- [ ] DB操作: Firestore操作は `call` クラスのProvider経由
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり（timestamp等メタデータ除く）
- [ ] ref使い分け: build内は `ref.watch`、コールバック・操作は `ref.read`
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（該当する場合）

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
