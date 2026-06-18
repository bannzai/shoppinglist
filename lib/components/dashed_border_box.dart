import 'package:flutter/material.dart';

/// 角丸長方形に破線枠を描画する Box。
/// `design_handoff_shopping_list/preview/screens-list-settings.jsx#InviteCodeDialog`
/// の招待コード表示枠 (`border: 1px dashed ${t.divider}`) を再現する。
class DashedBorderBox extends StatelessWidget {
  /// 中央配置する子。
  final Widget child;

  /// 角丸半径。Web SSOT の `radius 14` を既定値とする。
  final double borderRadius;

  /// 破線の色。`tokens.neutral.divider` を渡す想定。
  final Color color;

  /// 破線の太さ。Web SSOT の `1px` を既定値とする。
  final double strokeWidth;

  /// 破線パターン [線, 空白] を交互に描画する。
  final List<double> dashPattern;

  const DashedBorderBox({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = 14,
    this.strokeWidth = 1,
    this.dashPattern = const [4, 3],
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        color: color,
        strokeWidth: strokeWidth,
        radius: borderRadius,
        dashPattern: dashPattern,
      ),
      child: child,
    );
  }
}

/// 角丸長方形のアウトラインを `dashPattern` に沿って破線描画する CustomPainter。
class _DashedRRectPainter extends CustomPainter {
  /// 破線の色。
  final Color color;

  /// 破線の太さ。
  final double strokeWidth;

  /// 角丸半径。
  final double radius;

  /// [線, 空白] を交互に繰り返すパターン。
  final List<double> dashPattern;

  _DashedRRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final source =
        Path()..addRRect(
          RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
        );
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      int index = 0;
      while (distance < metric.length) {
        final len = dashPattern[index % dashPattern.length];
        if (draw) {
          dashed.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
        index++;
      }
    }
    canvas.drawPath(
      dashed,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.radius != radius ||
      old.dashPattern != dashPattern;
}
