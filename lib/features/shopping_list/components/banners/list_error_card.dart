import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/error/error_display.dart';

/// 買い物リスト読み込み失敗時のエラーカード。
/// `design_handoff_shopping_list/source/screens-list.jsx#ShoppingListError` 相当。
///
/// 例外メッセージはそのまま表示するが StackTrace は表示しない（カードのため）。
/// 表示時に生のエラーを debugPrint/Crashlytics へ一度だけ記録する。
class ListErrorCard extends HookWidget {
  /// 表示する例外。本文(message)のみ表示し StackTrace は出さない。
  final Object? exception;

  /// [exception] の StackTrace。debugPrint/Crashlytics への記録に使う。
  final StackTrace? stackTrace;

  /// 「再試行」押下時のコールバック。
  final VoidCallback onRetry;

  const ListErrorCard({
    super.key,
    required this.exception,
    required this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final error = exception;
    // 表示と同時に生のエラーを一度だけ記録する。exception が変わった時のみ再記録。
    useEffect(() {
      if (error != null) {
        logError(error, stackTrace);
      }
      return null;
    }, [error]);

    final tokens = context.appTheme;
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
              context.l10n.shoppingListLoadErrorTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: tokens.neutral.danger,
              ),
            ),
            const SizedBox(height: 6),
            if (error != null)
              Text(
                describeError(context.l10n, error, stackTrace).message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.neutral.ink2),
              ),
            const SizedBox(height: 14),
            AppPill(
              label: context.l10n.commonRetry,
              variant: AppPillVariant.accent,
              onPressed: onRetry,
              icon: null,
            ),
          ],
        ),
      ),
    );
  }
}
