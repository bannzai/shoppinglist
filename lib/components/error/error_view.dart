import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shoppinglist/utils/error/error_display.dart';

/// ページ全体に表示するエラービュー。
/// タイトル・本文はそのまま表示し、StackTrace はレベルを落として（小さく控えめに）表示する。
/// 表示時に生のエラーを debugPrint/Crashlytics へ一度だけ記録する。
class ErrorView extends HookWidget {
  final Object error;
  final StackTrace? stackTrace;

  /// 本文の下に置く操作（再試行ボタン等）。なければ null。
  final Widget? action;

  const ErrorView({
    super.key,
    required this.error,
    required this.stackTrace,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    // ページ全体にエラーを出すと同時に、生のエラーを一度だけ記録する。
    // error が変わった時のみ再記録するため、依存配列は [error]。
    useEffect(() {
      logError(error, stackTrace);
      return null;
    }, [error]);

    final display = describeError(error, stackTrace);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // タイトル・本文・操作（再試行ボタン等）は常に画面内に収め、中央に寄せる。
          // 内容が縦に長い場合に備えてこの領域内だけスクロールさせる。
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (display.title != null) ...[
                      Text(
                        display.title!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      display.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (action != null) ...[
                      const SizedBox(height: 16),
                      action!,
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (display.stackTrace != null) ...[
            const SizedBox(height: 16),
            // StackTrace はレベルを落として（小さめ・控えめ色）表示する。
            // 高さ上限を設けて内部スクロールにし、タイトル/本文/操作を画面外へ
            // 押し出さない（全体が画面内に収まる）。
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    display.stackTrace.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
