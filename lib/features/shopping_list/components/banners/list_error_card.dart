import 'package:flutter/material.dart';
import 'package:shoppinglist/components/frame/app_pill.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 買い物リスト読み込み失敗時のエラーカード。
/// `design_handoff_shopping_list/source/screens-list.jsx#ShoppingListError` 相当。
///
/// 仕様: dangerSoft 背景 + 中央寄せの📡 + タイトル + 固定文言 + 「サポートに連絡」(ghost) / 「再試行」(accent) の 2 Pill。
class ListErrorCard extends StatelessWidget {
  /// 表示する例外。デバッグ用情報として保持する（UI には固定文言を表示）。
  final Object? exception;

  /// 「再試行」押下時のコールバック。
  final VoidCallback onRetry;

  /// 「サポートに連絡」押下時のコールバック。null なら button は出さない。
  final VoidCallback? onContactSupport;

  const ListErrorCard({
    super.key,
    required this.exception,
    required this.onRetry,
    this.onContactSupport,
  });

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
            const Text('📡', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              'リストを読み込めませんでした',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: tokens.neutral.danger,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '通信状態を確認してください。\nもう一度お試しいただくか、しばらくしてから開き直してください。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: tokens.neutral.ink2,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onContactSupport != null) ...[
                  AppPill(
                    label: 'サポートに連絡',
                    variant: AppPillVariant.ghost,
                    onPressed: onContactSupport,
                  ),
                  const SizedBox(width: 8),
                ],
                AppPill(
                  label: '再試行',
                  variant: AppPillVariant.accent,
                  onPressed: onRetry,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
