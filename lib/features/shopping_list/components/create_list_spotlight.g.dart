// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_list_spotlight.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$debugForceCreateListSpotlightHash() =>
    r'd77605948149ff201929be754589b638ab8886d6';

/// 開発者オプションからスポットライトを強制表示するための in-memory フラグ。
///
/// true の間、[CreateListSpotlightHost] は表示条件を無視してスポットライトを表示する。
/// 強制表示時は SharedPreferences の履歴を書かない(本番状態を汚さない)。表示後に false へ戻す。
/// 開発者オプションを閉じて買い物リスト画面へ戻るまで状態を保持するため keepAlive にする。
///
/// Copied from [DebugForceCreateListSpotlight].
@ProviderFor(DebugForceCreateListSpotlight)
final debugForceCreateListSpotlightProvider =
    NotifierProvider<DebugForceCreateListSpotlight, bool>.internal(
      DebugForceCreateListSpotlight.new,
      name: r'debugForceCreateListSpotlightProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$debugForceCreateListSpotlightHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DebugForceCreateListSpotlight = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
