import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 高さ 30 の Chip。
/// `design_handoff_shopping_list/source/frame.jsx#Chip` 相当。
/// active=true で塗りつぶし、`soft=true` で accent 薄塗り、`active=false` でアウトライン。
class AppChip extends StatelessWidget {
  /// 表示テキスト。
  final String label;

  /// 先頭に表示するアイコン（任意）。
  final IconData? icon;

  /// 先頭の色ドット（任意）。`icon` と同居可能。
  final Color? dotColor;

  /// 選択状態。
  final bool active;

  /// active 時に accentSoft で塗るか（true）、ink 反転で塗るか（false）。
  final bool soft;

  /// タップ時のコールバック。null で disabled（opacity 0.5）。
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    required this.icon,
    required this.dotColor,
    this.active = false,
    this.soft = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;

    final bg =
        active ? (soft ? tokens.accentSoft : neutral.ink) : neutral.surface;
    final fg = active ? (soft ? tokens.accent : Colors.white) : neutral.ink2;
    final disabled = onTap == null;

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: bg,
        shape: StadiumBorder(
          // active+soft は薄塗りが背景(cream)に埋もれてコントラストが低いため、
          // accent 色の枠線を足して選択状態をはっきりさせる。
          // ink 反転塗り(soft=false)は塗り自体が高コントラストなので枠線なし。
          side: active
              ? (soft
                  ? BorderSide(color: tokens.accent, width: 1.5)
                  : BorderSide.none)
              : BorderSide(color: neutral.divider),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 30,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dotColor != null) ...[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: fg),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w500,
                          letterSpacing: -0.005,
                          color: fg,
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
