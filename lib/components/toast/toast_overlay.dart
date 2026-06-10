import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/app_provider_container.dart';
import 'package:shoppinglist/provider/toast.dart';
import 'package:shoppinglist/style/tokens.dart';

/// どこからでもテキストトーストを表示する。ref / BuildContext 不要。
void showGlobalToast(String message, {required String? title}) {
  showGlobalToastWidget(
    ToastTextContent(title: title, message: message),
    identity: 'text ${title ?? ''} $message',
  );
}

/// 任意 Widget をトーストとして表示する（メンバー通知バー等のリッチ内容用）。
/// `_ToastFrame` で ink 背景を付け、`UniqueKey` で包んで出入りアニメーションさせる。
void showGlobalToastWidget(
  Widget content, {
  Duration duration = const Duration(seconds: 5),
  Object? identity,
}) {
  appProviderContainer.read(toastProvider.notifier).show(
        KeyedSubtree(key: UniqueKey(), child: _ToastFrame(child: content)),
        duration: duration,
        identity: identity,
      );
}

/// 表示中のトーストを即座に消す。リッチ内容側からの明示 dismiss に使う。
void dismissGlobalToast() {
  appProviderContainer.read(toastProvider.notifier).dismiss();
}

/// モーダル/ボトムシートの前面に route としてトーストを表示する。
///
/// `MaterialApp.builder` 上の [ToastOverlay] は既存のグローバル通知用に残し、
/// シート表示中にユーザー操作から動的に出す通知は route 化して確実に前面へ積む。
void showForegroundToastWidget(
  BuildContext context,
  WidgetBuilder builder, {
  Duration duration = const Duration(seconds: 5),
}) {
  final route = _ForegroundToastRoute(builder: builder, duration: duration);
  unawaited(Navigator.of(context, rootNavigator: true).push(route));
}

/// アクション付きの前面トーストを表示する。
void showForegroundActionToast({
  required BuildContext context,
  required String message,
  required String actionLabel,
  required VoidCallback onAction,
  Duration duration = const Duration(seconds: 5),
}) {
  showForegroundToastWidget(
    context,
    (toastContext) => ToastActionContent(
      message: message,
      actionLabel: actionLabel,
      onAction: () {
        Navigator.of(toastContext).pop();
        onAction();
      },
    ),
    duration: duration,
  );
}

/// `MaterialApp.builder` の `Stack` に常駐し、グローバルトーストを描画する。
/// ルートが `Positioned` なので **`Stack` の直接の子** として配置すること。
///
/// モーダル/ボトムシートの表示中にユーザー操作から動的に出す通知は、
/// route として前面に積む [showForegroundToastWidget] を使う。
class ToastOverlay extends ConsumerWidget {
  const ToastOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: ref.watch(toastProvider) ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// トーストの ink 背景フレーム（角丸 14・elevation 6）。
class _ToastFrame extends StatelessWidget {
  final Widget child;
  const _ToastFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Material(
        color: context.appTheme.neutral.ink,
        elevation: 6,
        borderRadius: BorderRadius.circular(AppThemeExtension.radiusButton),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: child,
        ),
      ),
    );
  }
}

class _ForegroundToastRoute extends PopupRoute<void> {
  final WidgetBuilder builder;
  final Duration duration;
  Timer? _timer;

  _ForegroundToastRoute({required this.builder, required this.duration});

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 220);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 160);

  @override
  void install() {
    super.install();
    _timer = Timer(duration, () {
      if (isActive) {
        navigator?.removeRoute(this);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ToastFrame(child: builder(context)),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

/// 標準テキストトーストの内容（任意タイトル + 本文）。ink 背景上の白系文字。
class ToastTextContent extends StatelessWidget {
  /// 太字で出すタイトル。null/空なら省略。
  final String? title;

  /// 本文。空なら省略（FCM で title のみのケースに対応）。
  final String message;

  const ToastTextContent(
      {super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final onInk = context.appTheme.neutral.surface;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty)
          Text(
            title!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onInk,
                  fontWeight: FontWeight.w700,
                ),
          ),
        if (message.isNotEmpty)
          Text(
            message,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: onInk),
          ),
      ],
    );
  }
}

/// 本文 + 右側アクションのトースト内容。
class ToastActionContent extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const ToastActionContent({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final onInk = tokens.neutral.surface;
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: onInk),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(AppThemeExtension.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tokens.accent,
              borderRadius: BorderRadius.circular(AppThemeExtension.radiusPill),
            ),
            child: Text(
              actionLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
