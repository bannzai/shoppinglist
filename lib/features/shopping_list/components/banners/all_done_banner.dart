import 'package:flutter/material.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 全アイテムがチェック済みのときに表示する祝福バナー。
/// `design_handoff_shopping_list/source/screens-list.jsx#ShoppingListAllDone` 相当。
class AllDoneBanner extends StatelessWidget {
  const AllDoneBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: tokens.neutral.okSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('🌿', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '全部チェック完了!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tokens.neutral.ok,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'お会計のあと、また再開もできます',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: tokens.neutral.ok.withValues(alpha: 0.85),
                ),
          ),
        ],
      ),
    );
  }
}
