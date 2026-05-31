import 'package:flutter/material.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// チェック進捗を `done/total` だけで示す小さな浮遊ピル。
/// リスト左下に影付きで浮かせ（FAB と対称）、最小限の進捗表示を担う。
/// 祝福メッセージや進捗バーは持たない。
class ProgressPill extends StatelessWidget {
  /// チェック済みアイテム数。
  final int checkedCount;

  /// 全アイテム数。
  final int totalCount;

  const ProgressPill({
    super.key,
    required this.checkedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s12,
        vertical: AppTokens.s6,
      ),
      decoration: BoxDecoration(
        color: neutral.card,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        border: Border.all(color: neutral.divider),
        boxShadow: tokens.cardShadow,
      ),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: '$checkedCount',
            style: monoTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: neutral.ink,
            ),
          ),
          TextSpan(
            text: '/$totalCount',
            style: monoTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: neutral.ink3,
            ),
          ),
        ]),
      ),
    );
  }
}
