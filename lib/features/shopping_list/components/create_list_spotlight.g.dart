// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_list_spotlight.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 開発者オプションからスポットライトを強制表示するための in-memory フラグ。
///
/// true の間、[CreateListSpotlightHost] は表示条件を無視してスポットライトを表示する。
/// 強制表示時は SharedPreferences の履歴を書かない(本番状態を汚さない)。表示後に false へ戻す。
/// 開発者オプションを閉じて買い物リスト画面へ戻るまで状態を保持するため keepAlive にする。

@ProviderFor(DebugForceCreateListSpotlight)
final debugForceCreateListSpotlightProvider =
    DebugForceCreateListSpotlightProvider._();

/// 開発者オプションからスポットライトを強制表示するための in-memory フラグ。
///
/// true の間、[CreateListSpotlightHost] は表示条件を無視してスポットライトを表示する。
/// 強制表示時は SharedPreferences の履歴を書かない(本番状態を汚さない)。表示後に false へ戻す。
/// 開発者オプションを閉じて買い物リスト画面へ戻るまで状態を保持するため keepAlive にする。
final class DebugForceCreateListSpotlightProvider
    extends $NotifierProvider<DebugForceCreateListSpotlight, bool> {
  /// 開発者オプションからスポットライトを強制表示するための in-memory フラグ。
  ///
  /// true の間、[CreateListSpotlightHost] は表示条件を無視してスポットライトを表示する。
  /// 強制表示時は SharedPreferences の履歴を書かない(本番状態を汚さない)。表示後に false へ戻す。
  /// 開発者オプションを閉じて買い物リスト画面へ戻るまで状態を保持するため keepAlive にする。
  DebugForceCreateListSpotlightProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debugForceCreateListSpotlightProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debugForceCreateListSpotlightHash();

  @$internal
  @override
  DebugForceCreateListSpotlight create() => DebugForceCreateListSpotlight();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$debugForceCreateListSpotlightHash() =>
    r'd77605948149ff201929be754589b638ab8886d6';

/// 開発者オプションからスポットライトを強制表示するための in-memory フラグ。
///
/// true の間、[CreateListSpotlightHost] は表示条件を無視してスポットライトを表示する。
/// 強制表示時は SharedPreferences の履歴を書かない(本番状態を汚さない)。表示後に false へ戻す。
/// 開発者オプションを閉じて買い物リスト画面へ戻るまで状態を保持するため keepAlive にする。

abstract class _$DebugForceCreateListSpotlight extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
