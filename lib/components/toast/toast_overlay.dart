import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/app_navigator_key.dart';
import 'package:shoppinglist/provider/app_provider_container.dart';
import 'package:shoppinglist/provider/toast.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/error/error_display.dart';

/// どこからでもテキストトーストを表示する。ref / BuildContext 不要。
void showGlobalToast(String message, {required String? title}) {
  showGlobalToastWidget(
    ToastTextContent(title: title, message: message),
    identity: 'text ${title ?? ''} $message',
  );
}

/// エラーをグローバルトーストで通知する。本文・タイトルはそのまま、StackTrace は出さない。
/// debugPrint/Crashlytics には生のエラーを記録する。
void showGlobalErrorToast(Object error, [StackTrace? stackTrace]) {
  logError(error, stackTrace);
  final display = describeError(error, stackTrace);
  showGlobalToast(display.message, title: display.title);
}

/// 任意 Widget をトーストとして表示する（メンバー通知バー等のリッチ内容用）。
/// `_ToastFrame` で ink 背景を付け、`UniqueKey` で包んで同一内容の再 show でも
/// 新しい state として描画されるようにする。
void showGlobalToastWidget(
  Widget content, {
  Duration duration = const Duration(seconds: 5),
  Object? identity,
}) {
  appProviderContainer
      .read(toastProvider.notifier)
      .show(
        KeyedSubtree(key: UniqueKey(), child: _ToastFrame(child: content)),
        duration: duration,
        identity: identity,
      );
}

/// 表示中のトーストを即座に消す。リッチ内容側からの明示 dismiss に使う。
void dismissGlobalToast() {
  appProviderContainer.read(toastProvider.notifier).dismiss();
}

/// アクションボタン付きのテキストトーストを表示する（アップグレード導線等）。
/// アクションのタップでトーストを消してから `onAction` を実行する。
void showGlobalActionToast({
  required String message,
  required String actionLabel,
  required VoidCallback onAction,
}) {
  showGlobalToastWidget(
    ToastActionContent(
      message: message,
      actionLabel: actionLabel,
      onAction: () {
        dismissGlobalToast();
        onAction();
      },
    ),
    identity: 'action $actionLabel $message',
  );
}

/// `toastProvider` を監視し、root Navigator の Overlay 最前面へトーストの
/// `OverlayEntry` を同期する。
///
/// 表示内容・自動消滅・identity による重複抑止は既存どおり [toastProvider] が管理する。
/// この Widget は provider state を Overlay のエントリに同期する表示層に徹する。
///
/// route（`Navigator.push`）で表示しない理由: トースト表示中に呼ばれる
/// `Navigator.pop`（シートの保存後クローズ等）がシートではなくトーストを pop して
/// しまうため。`OverlayEntry` は Navigator の pop 履歴に載らず、表示時点の全 route
/// （ダイアログ/ボトムシート含む）のエントリより上に insert されるため前面に描画される。
class ToastOverlay extends ConsumerStatefulWidget {
  const ToastOverlay({super.key});

  @override
  ConsumerState<ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends ConsumerState<ToastOverlay> {
  ProviderSubscription<Widget?>? _subscription;
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual<Widget?>(
      toastProvider,
      (_, next) => _syncEntry(next),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _subscription?.close();
    _removeEntry();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  /// provider の state 変化を Overlay のエントリへ反映する。
  /// post frame にするのは、build/layout 中の Overlay 変更による assert を避けるため。
  void _syncEntry(Widget? content) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _removeEntry();
      if (content == null) {
        return;
      }
      final overlay = appNavigatorKey.currentState?.overlay;
      if (overlay == null) {
        return;
      }
      final entry = OverlayEntry(
        builder: (context) => _ToastViewport(child: content),
      );
      _entry = entry;
      overlay.insert(entry);
    });
    // addPostFrameCallback は「次のフレーム末尾に実行する」ようキューへ積むだけで、
    // フレーム自体は要求しない。Flutter は必要な時しか描画しないため、FCM の
    // フォアグラウンド受信など UI イベント外からの show では画面がアイドルで
    // vsync が止まっており、誰もフレームを要求しないと上のコールバックが永遠に
    // 発火せずトーストが表示されない(#528)。
    //
    // scheduleFrame はエンジンへ「次の vsync でフレームを1回描く」と依頼する
    // ワンショットの要求。これでほぼ空のフレームが1回走り、そのフレーム末尾で
    // 上のコールバックが OverlayEntry を insert する(insert が Overlay を dirty に
    // するので、続くフレームでトーストが実際に描画される)。
    // フレーム予定済みなら no-op のため、タップ起点などフレームが既に予定されて
    // いる経路から呼ばれても二重要求にはならず、常に呼んでよい。
    WidgetsBinding.instance.scheduleFrame();
  }

  void _removeEntry() {
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }
}

/// Overlay エントリ内でトーストを画面下部に配置する viewport。
/// トースト以外の領域はタップを透過させ、背後のシート/ページの操作を妨げない。
/// キーボード表示中は viewInsets ぶん持ち上げ、キーボードの背後に隠れないようにする。
class _ToastViewport extends StatelessWidget {
  final Widget child;
  const _ToastViewport({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Stack(
          children: [Positioned(left: 0, right: 0, bottom: 0, child: child)],
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

/// 標準テキストトーストの内容（任意タイトル + 本文）。ink 背景上の白系文字。
class ToastTextContent extends StatelessWidget {
  /// 太字で出すタイトル。null/空なら省略。
  final String? title;

  /// 本文。空なら省略（FCM で title のみのケースに対応）。
  final String message;

  const ToastTextContent({
    super.key,
    required this.title,
    required this.message,
  });

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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: onInk),
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: onInk),
          ),
        ),
        const SizedBox(width: 12),
        // InkWell のスプラッシュを背景色で潰さないよう、背景は Material 側に持たせる。
        Material(
          color: tokens.accent,
          borderRadius: BorderRadius.circular(AppThemeExtension.radiusPill),
          child: InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(AppThemeExtension.radiusPill),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                actionLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
