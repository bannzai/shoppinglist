import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/frame/app_checkbox.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/ghost_item_row.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 空の買い物リストに表示する「使い方ヒント」ビュー。
/// `design_handoff_shopping_list/source/screens-list.jsx#ShoppingListEmpty` 相当。
///
/// - 上部に「タップで入力開始できる空行」を 1 つ配置
/// - 中段に GhostItemRow × 5 で例文を表示
/// - 下部に dashed border のヒントカードで操作方法を説明
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

  static const _hints = [
    '例: 牛乳 1L',
    '例: 卵 1パック',
    '例: パン',
    '例: 玉ねぎ 2個',
    '例: トマト',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _StarterRow(
          onTap: () async {
            analytics.logEvent(name: 'tap_create_first_item', parameters: {
              'groupID': groupID,
              'shoppingListID': shoppingListID,
            });
            await ref
                .read(addShoppingListItemProvider(groupID: groupID))
                .call(
                  shoppingListID: shoppingListID,
                  userID: ref.read(currentUserIDProvider)!,
                  message: '',
                  order: shoppingListItems.nextOrder,
                  description: null,
                  color: null,
                );
          },
        ),
        for (final hint in _hints) GhostItemRow(hint: hint),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: tokens.neutral.ink2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _HintLine(text: '・タップしてそのまま入力'),
                  _HintLine(text: '・return で次の行へ'),
                  _HintLine(text: '・空行で delete で行を消せます'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// 入力開始用の最初の空行（タップで `addShoppingListItem(message: '')`）。
class _StarterRow extends StatelessWidget {
  final VoidCallback onTap;
  const _StarterRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: tokens.accentSoft.withValues(alpha: 0.4),
          border: Border(
            left: BorderSide(color: tokens.accent, width: 2),
          ),
        ),
        child: Row(
          children: [
            const AppCheckbox(checked: false, onChanged: null),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'タップで入力開始',
                style: TextStyle(
                  fontSize: 14,
                  color: tokens.accentInk,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.edit_outlined, size: 16, color: tokens.accent),
          ],
        ),
      ),
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
          color: tokens.neutral.ink3,
          height: 1.4,
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
