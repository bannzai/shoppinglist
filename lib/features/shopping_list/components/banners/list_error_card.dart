import 'package:flutter/material.dart';
import 'package:shoppinglist/components/frame/app_pill.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 買い物リスト読み込み失敗時のエラーカード。
/// `design_handoff_shopping_list/source/screens-list.jsx#ShoppingListError` 相当。
class ListErrorCard extends StatelessWidget {
  /// 表示する例外。`e.toString()` をそのまま表示する。
  final Object? exception;

  /// 「再試行」押下時のコールバック。
  final VoidCallback onRetry;

  const ListErrorCard(
      {super.key, required this.exception, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        decoration: BoxDecoration(
          color: tokens.neutral.dangerSoft,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📡', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 10),
            Text(
              'リストを読み込めませんでした',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tokens.neutral.danger,
                  ),
            ),
            const SizedBox(height: 6),
            if (exception != null)
              Text(
                exception.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: tokens.neutral.ink2),
              ),
            const SizedBox(height: 14),
            AppPill(
              label: '再試行',
              variant: AppPillVariant.accent,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
