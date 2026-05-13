import 'package:flutter/material.dart';

/// `design_handoff_shopping_list/source/styles.css#.fake-caret` 相当の静的キャレット表示。
/// 1.5px 幅 × 16px 高さで、1.06s / steps(2) の点滅を行う。
/// 本物の TextField が無いがフォーカス中に見せたい場面（末尾常設の空行 / 空リストヒント）で使う。
class BlinkingCaret extends StatefulWidget {
  /// キャレットの塗り色。通常は `tokens.accent`。
  final Color color;

  const BlinkingCaret({super.key, required this.color});

  @override
  State<BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<BlinkingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1060),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Opacity(
        // `steps(2)` 相当: 前半 100% / 後半 0% の 2 段階。
        opacity: _controller.value < 0.5 ? 1 : 0,
        child: Container(width: 1.5, height: 16, color: widget.color),
      ),
    );
  }
}
