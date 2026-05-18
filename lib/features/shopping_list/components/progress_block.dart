import 'package:flutter/material.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 買い物リストの進捗ブロック（高さ 72）。
/// `design_handoff_shopping_list/source/screens-list.jsx#ProgressBlock` 相当。
/// `done/total` を mono タイポで表示し、進捗バー（accent / 全完了時 ok）と
/// 全完了メッセージ「✓ おつかれさま」を出す。
class ProgressBlock extends StatelessWidget {
  /// チェック済みアイテム数。
  final int checkedCount;

  /// 全アイテム数。
  final int totalCount;

  const ProgressBlock({
    super.key,
    required this.checkedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final allDone = totalCount > 0 && checkedCount == totalCount;
    final progress = totalCount == 0 ? 0.0 : checkedCount / totalCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: '$checkedCount',
                    style: monoTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: neutral.ink,
                    ),
                  ),
                  TextSpan(
                    text: '/$totalCount',
                    style: monoTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: neutral.ink3,
                    ),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              if (!allDone)
                Text(
                  'チェック済み',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: neutral.ink2,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              const Spacer(),
              if (allDone)
                Text(
                  '✓ おつかれさま',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: neutral.ok,
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: neutral.divider2,
              valueColor: AlwaysStoppedAnimation<Color>(
                allDone ? neutral.ok : tokens.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
