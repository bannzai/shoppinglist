import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 円形のアイコンボタン。
/// `design_handoff_shopping_list/source/frame.jsx#RoundBtn` 相当。
class AppRoundButton extends StatelessWidget {
  /// 表示するアイコン。
  final IconData icon;

  /// タップ時のコールバック。null で disabled。
  final VoidCallback? onPressed;

  /// 円のサイズ（直径）。
  final double size;

  /// アイコンのサイズ。
  final double iconSize;

  /// `accentSoft` 背景 + `accent` アイコン色にするか。
  final bool soft;

  /// divider で 1px のリング枠を付けるか。
  final bool ring;

  const AppRoundButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 36,
    this.iconSize = 18,
    this.soft = false,
    this.ring = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: soft ? tokens.accentSoft : Colors.transparent,
      shape: CircleBorder(
        side:
            ring ? BorderSide(color: tokens.neutral.divider) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: iconSize,
            color: soft ? tokens.accent : tokens.neutral.ink,
          ),
        ),
      ),
    );
  }
}
