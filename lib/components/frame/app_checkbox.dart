import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 円形チェックボックス。
/// `design_handoff_shopping_list/source/frame.jsx#Checkbox` 相当。
/// チェック ON 時に `scale 1 → 1.2 → 1` の pop アニメーションを再生する。
class AppCheckbox extends StatefulWidget {
  /// チェック状態。
  final bool checked;

  /// タップ時のコールバック。`!checked` を渡す。null で disabled。
  final ValueChanged<bool>? onChanged;

  /// 円の直径。
  final double size;

  /// チェック時に塗る色を上書きしたい場合に渡す。null なら `tokens.accent`。
  final Color? color;

  const AppCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    this.size = 22,
    this.color,
  });

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 220),
    vsync: this,
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 60),
  ]).animate(_controller);

  @override
  void didUpdateWidget(covariant AppCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.checked && widget.checked) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final accent = widget.color ?? tokens.accent;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onChanged == null
            ? null
            : () => widget.onChanged!(!widget.checked),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.checked ? accent : Colors.transparent,
            border: Border.all(
              color: widget.checked ? accent : tokens.neutral.ink4,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: widget.checked
              ? Icon(Icons.check, size: widget.size * 0.62, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
