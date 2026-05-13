import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/ghost_item_row.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/tail_empty_row.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 空の買い物リストに表示する「使い方ヒント」ビュー。
/// `design_handoff_shopping_list/source/screens-list.jsx#ShoppingListEmpty` 相当。
///
/// レイアウト:
/// - 最上段: `TailEmptyRow` 相当の ItemRow(isEmpty + focused)。
/// - 中段: `GhostItemRow` × 5。先頭だけ「例: 牛乳 1L」、残りはデフォルトの「新しいアイテム…」。
/// - 画面下: 画面下から 170px 位置に絶対配置した dashed のヒントカード（surface2 + `_MonoChip` 入り段落）。
class EmptyTextShoppingListItems extends ConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final List<GroupShoppingListItem> shoppingListItems;
  const EmptyTextShoppingListItems({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(top: 6, bottom: 220),
          children: [
            TailEmptyRow(
              groupID: groupID,
              shoppingListID: shoppingListID,
              nextOrder: shoppingListItems.nextOrder,
            ),
            const GhostItemRow(hint: '例: 牛乳 1L'),
            for (var i = 0; i < 4; i++) const GhostItemRow(),
          ],
        ),
        const Positioned(
          left: 20,
          right: 20,
          bottom: 170,
          child: _UsageHintCard(),
        ),
      ],
    );
  }
}

/// `screens-list.jsx#ShoppingListEmpty` の下部 dashed ヒントカード。
/// 「そのまま入力できます」の見出し + inline `_MonoChip` 入り段落。
class _UsageHintCard extends StatelessWidget {
  const _UsageHintCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    return CustomPaint(
      painter: _DashedRectPainter(color: neutral.divider),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: neutral.surface2,
          borderRadius: BorderRadius.circular(_DashedRectPainter._radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'そのまま入力できます',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: neutral.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: neutral.ink2,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(text: '空行をタップして名前を打ち、'),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: _MonoChip(label: 'return'),
                  ),
                  const TextSpan(text: ' で次の行へ。空行で '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: _MonoChip(label: 'delete'),
                  ),
                  const TextSpan(text: ' で行を消せます。'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `styles.css#.mono` を inline チップ風に転用した小さなキー表示。
/// bg surface, padding 1px 6px, radius 4, 1px divider border, IBM Plex Mono。
class _MonoChip extends StatelessWidget {
  final String label;
  const _MonoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final neutral = context.tokens.neutral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: neutral.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: neutral.divider, width: 1),
      ),
      child: Text(
        label,
        style: monoTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: neutral.ink2,
          height: 1.2,
        ),
      ),
    );
  }
}

/// rounded rect の dashed border を描く CustomPainter。
/// dotted_border パッケージ依存を避けるための自作実装。
class _DashedRectPainter extends CustomPainter {
  final Color color;

  _DashedRectPainter({required this.color});

  /// `_UsageHintCard` の Container.borderRadius と同じ値を使う。
  static const _radius = 14.0;
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
