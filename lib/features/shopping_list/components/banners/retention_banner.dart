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
    final tokens = context.appTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.neutral.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.neutral.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium, size: 16, color: tokens.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '無料プランは作成から30日でリストが整理されます',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: tokens.neutral.ink2),
            ),
          ),
          InkWell(
            onTap: () {
              analytics.logEvent(
                  name: 'tap_retention_banner_detail', parameters: null);
              showPaywall(context: context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                '詳しく',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
