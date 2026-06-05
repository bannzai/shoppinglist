// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toast.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$toastHash() => r'aa3f7c6e1401e5adb6596e7db5482906c46f4df2';

/// 画面最前面（モーダルより上）に出すグローバルトーストの表示状態。
/// `null` のとき非表示。値が入っているとその Widget を描画する。
/// 表示中に再度 `show` されたら即座に置き換える（単一表示）。
///
/// keepAlive: アプリ全体で 1 インスタンスを共有し、`appProviderContainer`
/// 経由のグローバル関数と `ToastOverlay` が同じ状態を参照するため。
///
/// Copied from [Toast].
@ProviderFor(Toast)
final toastProvider = NotifierProvider<Toast, Widget?>.internal(
  Toast.new,
  name: r'toastProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$toastHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Toast = Notifier<Widget?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
