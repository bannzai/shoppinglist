import 'package:flutter/material.dart';
import 'package:shoppinglist/components/frame/stripe_placeholder.dart';
import 'package:shoppinglist/provider/ai_processing.dart';
import 'package:shoppinglist/style/tokens.dart';

/// AI で写真 / URL から候補を抽出している最中に表示するバナー。
/// `design_handoff_shopping_list/source/screens-list.jsx#ShoppingListAIProcessing` 相当。
///
/// 構造（3 列）:
/// - 左: 44×44 角丸 12 の白塗りタイル（stripe placeholder）+ 周囲 2px accent border (top transparent) で 1s 回転スピナー。
/// - 中央: タイトル 13/700 (accent) + wand アイコン 14 + サブ 11/ink2。
/// - 右: ghost cancel（12/600/ink3）。
class AIProcessingBanner extends StatelessWidget {
  /// 現在処理中の AI 種別。
  final AIProcessingType type;

  /// キャンセル押下時のコールバック（任意）。null なら button は出さない。
  final VoidCallback? onCancel;

  const AIProcessingBanner({super.key, required this.type, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final (title, sub) = switch (type) {
      AIProcessingType.image => (
          '写真からアイテムを生成中',
          'レシート 1 枚 ・ 候補を抽出しています…',
        ),
      AIProcessingType.url => (
          'URL からアイテムを生成中',
          'ページを解析しています…',
        ),
    };
    final accentText = tokens.isDark ? tokens.accentInk : tokens.accent;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.accentSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 44×44 stripe placeholder + 周囲 accent ring (= CircularProgressIndicator の indeterminate)。
          SizedBox(
            width: 44,
            height: 44,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: neutral.card),
                  CustomPaint(
                    painter: StripePlaceholderPainter(color: neutral.ink),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(tokens.accent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: accentText),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: accentText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: neutral.ink2,
                  ),
                ),
              ],
            ),
          ),
          if (onCancel != null)
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                foregroundColor: neutral.ink3,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('キャンセル'),
            ),
        ],
      ),
    );
  }
}
