import 'package:flutter/material.dart';
import 'package:shoppinglist/provider/ai_processing.dart';
import 'package:shoppinglist/style/tokens.dart';

/// AI で写真 / URL から候補を抽出している最中に表示するバナー。
/// `design_handoff_shopping_list/source/screens-list.jsx#ShoppingListAIProcessing` 相当。
class AIProcessingBanner extends StatelessWidget {
  /// 現在処理中の AI 種別。null は表示しない。
  final AIProcessingType type;

  const AIProcessingBanner({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final label = switch (type) {
      AIProcessingType.image => '画像から候補を抽出中...',
      AIProcessingType.url => 'URL から候補を抽出中...',
    };
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.accentSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.accent),
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.auto_fix_high, size: 16, color: tokens.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: tokens.accentInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
