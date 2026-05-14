import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// Pill 形状ボタンの色バリアント。
/// `design_handoff_shopping_list/source/frame.jsx#Pill` の variant に対応する。
enum AppPillVariant {
  /// 中立色（surface2 + ink + divider 枠）。
  neutral,

  /// アクセント色塗りつぶし（accent + 白文字）。
  accent,

  /// アクセント薄塗り（accentSoft + accentInk）。
  soft,

  /// 透過＋ divider 枠。
  ghost,

  /// 破壊的操作（dangerSoft + danger）。
  danger,
}

/// Pill 形状ボタン（StadiumBorder）。
/// `design_handoff_shopping_list/source/frame.jsx#Pill` 相当。
/// `large=true` で h=50（CTA）、`false` で h=36。
class AppPill extends StatelessWidget {
  /// ボタンラベル。
  final String label;

  /// 先頭に表示するアイコン（任意）。
  final IconData? icon;

  /// タップ時のコールバック。null で disabled（opacity 0.5）。
  final VoidCallback? onPressed;

  /// 色バリアント。
  final AppPillVariant variant;

  /// CTA サイズ（高さ 50）にするか。
  final bool large;

  /// 横幅を親に合わせて広げるか（`SizedBox(width: double.infinity)` でラップする想定）。
  /// 既定は false（中身に合わせて最小幅）。
  final bool expanded;

  const AppPill({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppPillVariant.neutral,
    this.large = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final disabled = onPressed == null;

    final (bg, fg, side) = switch (variant) {
      AppPillVariant.accent => (tokens.accent, Colors.white, BorderSide.none),
      AppPillVariant.soft => (
          tokens.accentSoft,
          tokens.accentInk,
          BorderSide.none,
        ),
      AppPillVariant.danger => (
          neutral.dangerSoft,
          neutral.danger,
          BorderSide.none,
        ),
      AppPillVariant.ghost => (
          Colors.transparent,
          neutral.ink,
          BorderSide(color: neutral.divider),
        ),
      AppPillVariant.neutral => (
          neutral.surface2,
          neutral.ink,
          BorderSide(color: neutral.divider),
        ),
    };

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: bg,
        shape: StadiumBorder(side: side),
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: large ? 24 : 14),
            child: SizedBox(
              height: large ? 50 : 36,
              child: Row(
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: large ? 18 : 16, color: fg),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontSize: large ? 15 : 13.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.005,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
