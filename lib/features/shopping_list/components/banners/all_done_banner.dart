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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: tokens.neutral.okSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('🌿', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '全部チェック完了!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: tokens.neutral.ok,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'お会計のあと、また再開もできます',
                  style: TextStyle(
                    fontSize: 11,
                    color: tokens.neutral.ok.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
