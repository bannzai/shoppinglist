// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toast.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 画面最前面（モーダルより上）に出すグローバルトーストの表示状態。
/// `null` のとき非表示。値が入っているとその Widget を描画する。
/// 表示中に再度 `show` されたら即座に置き換える（単一表示）。
///
/// keepAlive: アプリ全体で 1 インスタンスを共有し、`appProviderContainer`
/// 経由のグローバル関数と `ToastOverlay` が同じ状態を参照するため。

@ProviderFor(Toast)
final toastProvider = ToastProvider._();

/// 画面最前面（モーダルより上）に出すグローバルトーストの表示状態。
/// `null` のとき非表示。値が入っているとその Widget を描画する。
/// 表示中に再度 `show` されたら即座に置き換える（単一表示）。
///
/// keepAlive: アプリ全体で 1 インスタンスを共有し、`appProviderContainer`
/// 経由のグローバル関数と `ToastOverlay` が同じ状態を参照するため。
final class ToastProvider extends $NotifierProvider<Toast, Widget?> {
  /// 画面最前面（モーダルより上）に出すグローバルトーストの表示状態。
  /// `null` のとき非表示。値が入っているとその Widget を描画する。
  /// 表示中に再度 `show` されたら即座に置き換える（単一表示）。
  ///
  /// keepAlive: アプリ全体で 1 インスタンスを共有し、`appProviderContainer`
  /// 経由のグローバル関数と `ToastOverlay` が同じ状態を参照するため。
  ToastProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'toastProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$toastHash();

  @$internal
  @override
  Toast create() => Toast();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Widget? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Widget?>(value),
    );
  }
}

String _$toastHash() => r'aa3f7c6e1401e5adb6596e7db5482906c46f4df2';

/// 画面最前面（モーダルより上）に出すグローバルトーストの表示状態。
/// `null` のとき非表示。値が入っているとその Widget を描画する。
/// 表示中に再度 `show` されたら即座に置き換える（単一表示）。
///
/// keepAlive: アプリ全体で 1 インスタンスを共有し、`appProviderContainer`
/// 経由のグローバル関数と `ToastOverlay` が同じ状態を参照するため。

abstract class _$Toast extends $Notifier<Widget?> {
  Widget? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Widget?, Widget?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Widget?, Widget?>,
              Widget?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
