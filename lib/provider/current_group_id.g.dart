// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_group_id.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentGroupIDHash() => r'249ca4f9127397143dc3d1b1e275770ac31987a6';

/// 現在表示中のグループID。アプリ全体で1つだけ保持する選択状態。
///
/// 既定値(appUser.defaultGroupID)の初期化は CurrentGroupResolver が行う。
/// ここで appUserProvider を読まないのは、appUser の更新ごとに build が再実行され
/// ユーザーの手動グループ切替がリセットされるのを避けるため(scope 依存も持ち込まない)。
///
/// Copied from [CurrentGroupID].
@ProviderFor(CurrentGroupID)
final currentGroupIDProvider =
    AutoDisposeNotifierProvider<CurrentGroupID, String?>.internal(
  CurrentGroupID.new,
  name: r'currentGroupIDProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentGroupIDHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentGroupID = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
