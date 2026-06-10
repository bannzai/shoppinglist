import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/app_navigator_key.dart';
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

/// `toastProvider` を監視し、root Navigator の最前面へトースト route を積む。
///
/// 表示内容・自動消滅・identity による重複抑止は既存どおり [toastProvider] が管理する。
/// この Widget は provider state を最前面 route に同期する表示層に徹する。
class ToastOverlay extends ConsumerStatefulWidget {
  const ToastOverlay({super.key});

  @override
  ConsumerState<ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends ConsumerState<ToastOverlay> {
  ProviderSubscription<Widget?>? _subscription;
  _GlobalToastRoute? _route;

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual<Widget?>(
      toastProvider,
      (_, next) => _syncRoute(next),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _subscription?.close();
    _removeRoute();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  void _syncRoute(Widget? content) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (content == null) {
        _removeRoute();
        return;
      }

      final navigator = appNavigatorKey.currentState;
      if (navigator == null) {
        return;
      }

      _removeRoute();
      final route = _GlobalToastRoute(child: content);
      _route = route;
      unawaited(
        navigator.push(route).whenComplete(() {
          if (identical(_route, route)) {
            _route = null;
          }
        }),
      );
    });
  }

  void _removeRoute() {
    final route = _route;
    if (route == null) {
      return;
    }
    _route = null;
    route.remove();
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

class _GlobalToastRoute extends OverlayRoute<void> {
  final Widget child;

  _GlobalToastRoute({required this.child});

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    return [OverlayEntry(builder: _buildOverlay)];
  }

  Widget _buildOverlay(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: child,
          ),
        ],
      ),
    );
  }

  void remove() {
    navigator?.removeRoute(this);
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
