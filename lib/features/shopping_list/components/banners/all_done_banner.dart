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
          const Text('🌿', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            '全部チェック完了!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: tokens.neutral.ok,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'お会計のあと、また再開もできます',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              color: tokens.neutral.ok.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
