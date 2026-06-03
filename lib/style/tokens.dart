import 'package:flutter/material.dart';

/// 和紙テイストの中立色パレット（accent を除く）。LIGHT と DARK で別インスタンスを保持する。
@immutable
class AppNeutralColors {
  /// アプリ全体の最外側に敷く暖色ベージュ（和紙イメージ）。
  final Color paper;

  /// 通常の画面ベース面。
  final Color surface;

  /// surface 上にさらに乗せる入れ子の面・チップ背景。
  final Color surface2;

  /// カード・ダイアログ・最前面要素の背景。
  final Color card;

  /// 主要テキスト（墨色）。
  final Color ink;

  /// 副次テキスト。
  final Color ink2;

  /// キャプション・プレースホルダ。
  final Color ink3;

  /// 非アクティブ・矢印アイコン等のヘアライン要素。
  final Color ink4;

  /// 1px 罫線。
  final Color divider;

  /// progress track 等で使う薄めの罫線。
  final Color divider2;

  /// 成功・全完了インジケータ。
  final Color ok;

  /// ok の薄塗り背景。
  final Color okSoft;

  /// 警告色。
  final Color warn;

  /// エラー・破壊的操作。
  final Color danger;

  /// danger の薄塗り背景。
  final Color dangerSoft;

  /// チェック済みアイテムのテキスト色。
  final Color checked;

  const AppNeutralColors({
    required this.paper,
    required this.surface,
    required this.surface2,
    required this.card,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.ink4,
    required this.divider,
    required this.divider2,
    required this.ok,
    required this.okSoft,
    required this.warn,
    required this.danger,
    required this.dangerSoft,
    required this.checked,
  });

  /// LIGHT モードの中立色。`design_handoff_shopping_list/source/tokens.jsx#LIGHT` と一致させる。
  static const light = AppNeutralColors(
    paper: Color(0xFFECE5D3),
    surface: Color(0xFFF8F2E2),
    surface2: Color(0xFFFFFCF3),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF1B1813),
    ink2: Color(0xFF5A5246),
    ink3: Color(0xFF948A77),
    ink4: Color(0xFFBDB39E),
    divider: Color(0xFFE0D5BC),
    divider2: Color(0xFFEBE2C9),
    ok: Color(0xFF2F6B43),
    okSoft: Color(0xFFDCEBDF),
    warn: Color(0xFFB47B1F),
    danger: Color(0xFFB53D3D),
    dangerSoft: Color(0xFFF4DEDB),
    checked: Color(0xFFA89E89),
  );

  /// DARK モードの中立色。`design_handoff_shopping_list/source/tokens.jsx#DARK` と一致させる。
  static const dark = AppNeutralColors(
    paper: Color(0xFF13110D),
    surface: Color(0xFF1B1813),
    surface2: Color(0xFF221E18),
    card: Color(0xFF26221C),
    ink: Color(0xFFF2EDE2),
    ink2: Color(0xFFBFB6A3),
    ink3: Color(0xFF847C6B),
    ink4: Color(0xFF5A5246),
    divider: Color(0xFF2A251F),
    divider2: Color(0xFF332D26),
    ok: Color(0xFF6BB07F),
    okSoft: Color(0xFF1F3325),
    warn: Color(0xFFE1B05A),
    danger: Color(0xFFE47A7A),
    dangerSoft: Color(0xFF3A2020),
    checked: Color(0xFF5A5246),
  );

  /// `ThemeExtension.lerp` から呼び出されるテーマ遷移用の補間。
  AppNeutralColors lerp(AppNeutralColors other, double t) => AppNeutralColors(
        paper: Color.lerp(paper, other.paper, t)!,
        surface: Color.lerp(surface, other.surface, t)!,
        surface2: Color.lerp(surface2, other.surface2, t)!,
        card: Color.lerp(card, other.card, t)!,
        ink: Color.lerp(ink, other.ink, t)!,
        ink2: Color.lerp(ink2, other.ink2, t)!,
        ink3: Color.lerp(ink3, other.ink3, t)!,
        ink4: Color.lerp(ink4, other.ink4, t)!,
        divider: Color.lerp(divider, other.divider, t)!,
        divider2: Color.lerp(divider2, other.divider2, t)!,
        ok: Color.lerp(ok, other.ok, t)!,
        okSoft: Color.lerp(okSoft, other.okSoft, t)!,
        warn: Color.lerp(warn, other.warn, t)!,
        danger: Color.lerp(danger, other.danger, t)!,
        dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
        checked: Color.lerp(checked, other.checked, t)!,
      );
}

/// プレミアム機能で切り替え可能な 5 色のアクセントプリセット（和の伝統色）。
/// `design_handoff_shopping_list/source/tokens.jsx#ACCENT_PRESETS` と一致させる。
enum AccentPreset {
  /// 朱（デフォルト）。
  shu(
    persistHex: '#C2410C',
    light: Color(0xFFC2410C),
    dark: Color(0xFFE8743A),
    softLight: Color(0xFFFBE4D0),
    softDark: Color(0xFF3A2316),
    inkLight: Color(0xFF7C2A07),
    inkDark: Color(0xFFFCD7BB),
    label: '朱',
  ),

  /// 抹茶。
  matcha(
    persistHex: '#1F6B4E',
    light: Color(0xFF1F6B4E),
    dark: Color(0xFF6BB07F),
    softLight: Color(0xFFDCEBDF),
    softDark: Color(0xFF1F3325),
    inkLight: Color(0xFF0F3D2A),
    inkDark: Color(0xFFB7D9C2),
    label: '抹茶',
  ),

  /// 藍。
  ai(
    persistHex: '#0F4C81',
    light: Color(0xFF0F4C81),
    dark: Color(0xFF5FA0D6),
    softLight: Color(0xFFD8E4F0),
    softDark: Color(0xFF162B3E),
    inkLight: Color(0xFF0A2E50),
    inkDark: Color(0xFFC4DAEC),
    label: '藍',
  ),

  /// 墨。
  sumi(
    persistHex: '#1B1B1B',
    light: Color(0xFF1B1B1B),
    dark: Color(0xFFE8E5DD),
    softLight: Color(0xFFE8E5DD),
    softDark: Color(0xFF33302A),
    inkLight: Color(0xFF000000),
    inkDark: Color(0xFFF2EDE2),
    label: '墨',
  ),

  /// 朽葉。
  kuchiba(
    persistHex: '#B45309',
    light: Color(0xFFB45309),
    dark: Color(0xFFE0985A),
    softLight: Color(0xFFF6E1C9),
    softDark: Color(0xFF3A2812),
    inkLight: Color(0xFF6B2F05),
    inkDark: Color(0xFFF1D2A8),
    label: '朽葉',
  );

  const AccentPreset({
    required this.persistHex,
    required this.light,
    required this.dark,
    required this.softLight,
    required this.softDark,
    required this.inkLight,
    required this.inkDark,
    required this.label,
  });

  /// Firestore `users/{uid}.themeColorHex` に保存する `#RRGGBB` 文字列。
  /// 大文字 6 桁固定。`light` の HEX と等価。
  final String persistHex;

  /// LIGHT モード時のアクセント色。
  final Color light;

  /// DARK モード時のアクセント色。
  final Color dark;

  /// LIGHT モード時の薄塗り背景（accentSoft）。
  final Color softLight;

  /// DARK モード時の薄塗り背景。
  final Color softDark;

  /// LIGHT モード時に accentSoft 上に乗せる濃文字色（accentInk）。
  final Color inkLight;

  /// DARK モード時の濃文字色。
  final Color inkDark;

  /// 設定画面に表示する和の伝統色名。
  final String label;
}

/// アプリ全体で参照するデザイントークン。
/// `Theme.of(context).extension<AppTokens>()!` で取得できる。
/// neutral 色 / アクセント / cardShadow / brightness をまとめて持つ。
/// spacing と radius は static 定数として提供する。
class AppTokens extends ThemeExtension<AppTokens> {
  /// 現在の輝度。`isDark` で参照する。
  final Brightness brightness;

  /// 選択されているアクセントプリセット。
  final AccentPreset accentPreset;

  /// brightness に対応する中立色パレット。
  final AppNeutralColors neutral;

  /// `t.shadow` 相当のカード用 BoxShadow リスト（フローティング要素のみに使う）。
  final List<BoxShadow> cardShadow;

  const AppTokens({
    required this.brightness,
    required this.accentPreset,
    required this.neutral,
    required this.cardShadow,
  });

  bool get isDark => brightness == Brightness.dark;

  /// 現在の輝度に応じたアクセント色。
  Color get accent => isDark ? accentPreset.dark : accentPreset.light;

  /// 現在の輝度に応じた accentSoft（薄塗り背景）色。
  Color get accentSoft =>
      isDark ? accentPreset.softDark : accentPreset.softLight;

  /// 現在の輝度に応じた accentInk（accentSoft 上に乗せる濃文字色）。
  Color get accentInk => isDark ? accentPreset.inkDark : accentPreset.inkLight;

  /// スペーシングスケール。`design_handoff_shopping_list/source/styles.css` の Padding scale と一致。
  static const s2 = 2.0;
  static const s4 = 4.0;
  static const s6 = 6.0;
  static const s8 = 8.0;
  static const s10 = 10.0;
  static const s12 = 12.0;
  static const s14 = 14.0;
  static const s16 = 16.0;
  static const s18 = 18.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;

  /// pill / chip 用。
  static const radiusPill = 999.0;

  /// 小型ボタン用。
  static const radiusButtonSm = 12.0;

  /// 通常ボタン用。
  static const radiusButton = 14.0;

  /// メイン CTA 用。
  static const radiusCta = 16.0;

  /// カード・セクションカード用。
  static const radiusCard = 14.0;

  /// 入力フィールド用。
  static const radiusInput = 12.0;

  /// シート・ダイアログ用。
  static const radiusSheet = 18.0;

  /// LIGHT モード時のフローティング影。
  static const shadowLight = <BoxShadow>[
    BoxShadow(color: Color(0x0D1B1813), offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A1B1813), offset: Offset(0, 6), blurRadius: 18),
  ];

  /// DARK モード時のフローティング影。
  static const shadowDark = <BoxShadow>[
    BoxShadow(color: Color(0x66000000), offset: Offset(0, 1)),
    BoxShadow(color: Color(0x4D000000), offset: Offset(0, 6), blurRadius: 18),
  ];

  /// brightness と accent から AppTokens を組み立てる。
  /// neutral と cardShadow は brightness で自動決定する。
  factory AppTokens.of({
    required Brightness brightness,
    required AccentPreset accent,
  }) {
    final isDark = brightness == Brightness.dark;
    return AppTokens(
      brightness: brightness,
      accentPreset: accent,
      neutral: isDark ? AppNeutralColors.dark : AppNeutralColors.light,
      cardShadow: isDark ? shadowDark : shadowLight,
    );
  }

  @override
  AppTokens copyWith({Brightness? brightness, AccentPreset? accentPreset}) =>
      AppTokens.of(
        brightness: brightness ?? this.brightness,
        accent: accentPreset ?? this.accentPreset,
      );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) {
      return this;
    }
    return AppTokens(
      brightness: t < 0.5 ? brightness : other.brightness,
      accentPreset: t < 0.5 ? accentPreset : other.accentPreset,
      neutral: neutral.lerp(other.neutral, t),
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
    );
  }
}

/// `context.tokens` で `Theme.of(context).extension<AppTokens>()!` を取得する糖衣。
/// `buildAppTheme` 経由で構築された ThemeData の下でのみ使用すること。
extension AppTokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
