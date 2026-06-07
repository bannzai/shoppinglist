import 'package:flutter/material.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/ghost_item_row.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 空の買い物リストに表示する「使い方ヒント」ビュー。
/// `design_handoff_shopping_list/source/screens-list.jsx#ShoppingListEmpty` 相当。
///
/// 入力は画面下部の常設コンポーザーで行うため、ここでは例文(ghost)と操作ヒントのみを示す。
/// - 中段に GhostItemRow × 5 で例文を表示
/// - 下部に dashed border のヒントカードで操作方法を説明
class EmptyTextShoppingListItems extends StatelessWidget {
  const EmptyTextShoppingListItems({super.key});

  static const _hints = [
    '例: 牛乳 1L',
    '例: 卵 1パック',
    '例: パン',
    '例: 玉ねぎ 2個',
    '例: トマト',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final hint in _hints) GhostItemRow(hint: hint),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.neutral.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: _DashedRectPainter(color: tokens.neutral.divider),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'こんな風に使えます',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: tokens.neutral.ink2,
                          ),
                    ),
                    const SizedBox(height: 6),
                    _HintLine(text: '・下の入力欄に書いて return で追加'),
                    _HintLine(text: '・アイテムをタップして編集'),
                    _HintLine(text: '・スワイプで削除 / チェック'),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _HintLine extends StatelessWidget {
  final String text;
  const _HintLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        text,
        style: monoTextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w400,
            color: tokens.neutral.ink2,
            height: 1.4,
            letterSpacing: null),
      ),
    );
  }
}

/// rounded rect の dashed border を描く CustomPainter。
/// dotted_border パッケージ依存を避けるための自作実装。
class _DashedRectPainter extends CustomPainter {
  final Color color;

  _DashedRectPainter({required this.color});

  static const _radius = 12.0;
  static const _dashLength = 6.0;
  static const _gapLength = 4.0;
  static const _strokeWidth = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(_radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + _dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter old) => old.color != color;
}
