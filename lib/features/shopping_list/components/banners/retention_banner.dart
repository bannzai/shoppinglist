import 'package:flutter/material.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 無料プランの 30 日保持期間バナー。List body の上に表示する。
/// `design_handoff_shopping_list/source/screens-list.jsx#ShoppingListFreeNotice` 相当。
///
/// 仕様: 背景は `surface2` + 1px divider border（README L194 の `accentSoft` ではなく
/// screens-list.jsx L432-440 の実装に合わせる）。crown と「詳しく」だけが accent 色。
class RetentionBanner extends StatelessWidget {
  const RetentionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.neutral.surface2,
        border: Border.all(color: tokens.neutral.divider, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 仕様: 塗り版 crown を 14px / accent stroke で。
          Icon(Icons.workspace_premium, size: 14, color: tokens.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '無料プランは作成から30日でリストが整理されます',
              style: TextStyle(fontSize: 11.5, color: tokens.neutral.ink2),
            ),
          ),
          InkWell(
            onTap: () {
              analytics.logEvent(name: 'tap_retention_banner_detail');
              showPaywall(context: context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                '詳しく',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: tokens.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
