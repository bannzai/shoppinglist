import 'package:flutter/material.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 無料プランの 30 日保持期間バナー。リスト最下部に表示する。
/// `design_handoff_shopping_list/source/screens-list.jsx#ShoppingListFreeNotice` 相当。
class RetentionBanner extends StatelessWidget {
  const RetentionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.accentSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_outlined,
              size: 16, color: tokens.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '無料プランは作成から30日でリストが整理されます',
              style: TextStyle(fontSize: 11.5, color: tokens.accentInk),
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
