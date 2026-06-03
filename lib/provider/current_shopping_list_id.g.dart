// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_shopping_list_id.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentShoppingListIDHash() =>
    r'767f84743ebb572811f0bcd00f3e4a39d7684266';

/// ユーザーが明示的に選択した買い物リストID。未選択(=先頭にフォールバック)なら null。
/// グループ切替時は null に戻す(切替先グループの先頭リストへフォールバックさせる)。
///
/// Copied from [CurrentShoppingListID].
@ProviderFor(CurrentShoppingListID)
final currentShoppingListIDProvider =
    AutoDisposeNotifierProvider<CurrentShoppingListID, String?>.internal(
  CurrentShoppingListID.new,
  name: r'currentShoppingListIDProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentShoppingListIDHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentShoppingListID = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
