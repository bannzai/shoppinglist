import 'package:flutter/material.dart';

/// `design_handoff_shopping_list/source/styles.css#.stripe-ph` 相当のストライプ塗りつぶし。
/// `repeating-linear-gradient(-45deg, rgba(ink, 0.04) 0 8px, rgba(ink, 0.07) 8px 16px)` を再現する。
/// 画像がロードされる前の placeholder や AI 処理中のサムネ枠の質感に使う。
class StripePlaceholderPainter extends CustomPainter {
  /// ストライプの基本色（通常は `tokens.neutral.ink`）。透明度は内部で調整する。
  final Color color;

  const StripePlaceholderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // 背景に薄い帯と濃い帯を交互に塗る。
    final lightBand = Paint()..color = color.withValues(alpha: 0.04);
    final darkBand = Paint()..color = color.withValues(alpha: 0.07);

    // -45° 方向に 8px 幅の帯を交互に並べる。
    // 単純化のため、長辺の対角線方向に矩形を回転描画する。
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    // 矩形を 45 度回転すると、対角線方向の長さ (= sqrt(w^2 + h^2)) の倍が必要。
    final diagonal = size.width + size.height;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.7853981633974483); // -45° (= -π/4)
    canvas.translate(-diagonal / 2, -diagonal / 2);

    const stripeWidth = 8.0;
    for (double x = 0; x < diagonal; x += stripeWidth * 2) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, stripeWidth, diagonal),
        lightBand,
      );
      canvas.drawRect(
        Rect.fromLTWH(x + stripeWidth, 0, stripeWidth, diagonal),
        darkBand,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StripePlaceholderPainter oldDelegate) =>
      oldDelegate.color != color;
}
