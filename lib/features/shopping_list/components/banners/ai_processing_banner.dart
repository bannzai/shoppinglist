import 'package:flutter/material.dart';
import 'package:shoppinglist/provider/ai_processing.dart';
import 'package:shoppinglist/style/tokens.dart';

/// AI で写真 / URL から候補を抽出している最中に表示するバナー。
/// `design_handoff_shoppinglist/preview/screens-list.jsx#ShoppingListAIProcessing` 相当。
/// 32×32 の 45° 縞 stripe-ph（1.6s loop）+ wand icon + ラベルを表示する。
class AIProcessingBanner extends StatefulWidget {
  /// 現在処理中の AI 種別。
  final AIProcessingType type;

  const AIProcessingBanner({super.key, required this.type});

  @override
  State<AIProcessingBanner> createState() => _AIProcessingBannerState();
}

class _AIProcessingBannerState extends State<AIProcessingBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final label = switch (widget.type) {
      AIProcessingType.image => '画像から候補を抽出中...',
      AIProcessingType.url => 'URL から候補を抽出中...',
    };
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.accentSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => CustomPaint(
                size: const Size(32, 32),
                painter: _StripePainter(
                  stripeColor: tokens.accent.withValues(alpha: 0.45),
                  bgColor: tokens.accent.withValues(alpha: 0.15),
                  offset: _ctrl.value,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.auto_fix_high, size: 16, color: tokens.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tokens.accentInk,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 45° 縞模様のプレースホルダ Painter。offset (0..1) で縞をスクロールさせる。
class _StripePainter extends CustomPainter {
  final Color stripeColor;
  final Color bgColor;
  final double offset;
  const _StripePainter({
    required this.stripeColor,
    required this.bgColor,
    required this.offset,
  });

  static const _stripeWidth = 6.0;
  static const _gapWidth = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final stripePaint = Paint()..color = stripeColor;
    final period = _stripeWidth + _gapWidth;
    final shift = offset * period;
    final diagonal = size.width + size.height;
    for (var x = -diagonal + shift; x < diagonal; x += period) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + _stripeWidth, size.height)
        ..lineTo(x + _stripeWidth + size.height, 0)
        ..lineTo(x + size.height, 0)
        ..close();
      canvas.drawPath(path, stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter old) =>
      old.offset != offset ||
      old.stripeColor != stripeColor ||
      old.bgColor != bgColor;
}
