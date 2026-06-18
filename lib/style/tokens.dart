import 'package:flutter/material.dart';

/// 和紙テイストの中立色パレット（accent を除く）。
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

  /// 中立色。茶色味を抑え明度差で奥行きを残す（ADR 0018）。
  /// `design_handoff_shoppinglist/preview/tokens.jsx#LIGHT` と一致させる。
  static const light = AppNeutralColors(
    paper: Color(0xFFF1EDE4),
    surface: Color(0xFFF7F4EE),
    surface2: Color(0xFFFCFAF6),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF1B1813),
    ink2: Color(0xFF57514A),
    ink3: Color(0xFF837A6A),
    ink4: Color(0xFFBBB2A4),
    divider: Color(0xFFE5DFD3),
    divider2: Color(0xFFEDE8DE),
    ok: Color(0xFF2F6B43),
    okSoft: Color(0xFFDCEBDF),
    warn: Color(0xFFB47B1F),
    danger: Color(0xFFB53D3D),
    dangerSoft: Color(0xFFF4DEDB),
    checked: Color(0xFFA39A89),
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
    softLight: Color(0xFFFBE4D0),
    inkLight: Color(0xFF7C2A07),
    label: '朱',
  ),

  /// 抹茶。
  matcha(
    persistHex: '#1F6B4E',
    light: Color(0xFF1F6B4E),
    softLight: Color(0xFFDCEBDF),
    inkLight: Color(0xFF0F3D2A),
    label: '抹茶',
  ),

  /// 藍。
  ai(
    persistHex: '#0F4C81',
    light: Color(0xFF0F4C81),
    softLight: Color(0xFFD8E4F0),
    inkLight: Color(0xFF0A2E50),
    label: '藍',
  ),

  /// 墨。
  sumi(
    persistHex: '#1B1B1B',
    light: Color(0xFF1B1B1B),
    softLight: Color(0xFFE8E5DD),
    inkLight: Color(0xFF000000),
    label: '墨',
  ),

  /// 朽葉。
  kuchiba(
    persistHex: '#B45309',
    light: Color(0xFFB45309),
    softLight: Color(0xFFF6E1C9),
    inkLight: Color(0xFF6B2F05),
    label: '朽葉',
  );

  const AccentPreset({
    required this.persistHex,
    required this.light,
    required this.softLight,
    required this.inkLight,
    required this.label,
  });

  /// Firestore `users/{uid}.themeColorHex` に保存する `#RRGGBB` 文字列。
  /// 大文字 6 桁固定。`light` の HEX と等価。
  final String persistHex;

  /// アクセント色。
  final Color light;

  /// 薄塗り背景（accentSoft）。
  final Color softLight;

  /// accentSoft 上に乗せる濃文字色（accentInk）。
  final Color inkLight;

  /// 設定画面に表示する和の伝統色名。
  final String label;
}

/// アプリ全体で参照するデザイントークン。
/// `Theme.of(context).extension<AppThemeExtension>()!` で取得できる。
/// neutral 色 / アクセント / cardShadow をまとめて持つ。
/// radius は static 定数として提供する。
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  /// 選択されているアクセントプリセット。
  final AccentPreset accentPreset;

  /// 中立色パレット。
  final AppNeutralColors neutral;

  /// `t.shadow` 相当のカード用 BoxShadow リスト（フローティング要素のみに使う）。
  final List<BoxShadow> cardShadow;

  const AppThemeExtension({
    required this.accentPreset,
    required this.neutral,
    required this.cardShadow,
  });

  /// アクセント色。
  Color get accent => accentPreset.light;

  /// accentSoft（薄塗り背景）色。
  Color get accentSoft => accentPreset.softLight;

  /// accentInk（accentSoft 上に乗せる濃文字色）。
  Color get accentInk => accentPreset.inkLight;

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

  /// フローティング影。
  static const shadowLight = <BoxShadow>[
    BoxShadow(color: Color(0x0D1B1813), offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A1B1813), offset: Offset(0, 6), blurRadius: 18),
  ];

  /// accent から AppThemeExtension を組み立てる。
  /// neutral と cardShadow はライトモード固定。
  factory AppThemeExtension.of({required AccentPreset accent}) {
    return AppThemeExtension(
      accentPreset: accent,
      neutral: AppNeutralColors.light,
      cardShadow: shadowLight,
    );
  }

  @override
  AppThemeExtension copyWith({AccentPreset? accentPreset}) =>
      AppThemeExtension.of(accent: accentPreset ?? this.accentPreset);

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      accentPreset: t < 0.5 ? accentPreset : other.accentPreset,
      neutral: neutral.lerp(other.neutral, t),
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
    );
  }
}

/// `context.appTheme` で `Theme.of(context).extension<AppThemeExtension>()!` を取得する糖衣。
/// `buildAppTheme` 経由で構築された ThemeData の下でのみ使用すること。
extension AppThemeExtensionX on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
