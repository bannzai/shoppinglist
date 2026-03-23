// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_setting.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$autoNotifyShoppingListUpdateHash() =>
    r'90c37e4c7d2f05afb851d544b35ba12fe39a6a9f';

/// See also [AutoNotifyShoppingListUpdate].
@ProviderFor(AutoNotifyShoppingListUpdate)
final autoNotifyShoppingListUpdateProvider =
    NotifierProvider<AutoNotifyShoppingListUpdate, bool>.internal(
  AutoNotifyShoppingListUpdate.new,
  name: r'autoNotifyShoppingListUpdateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$autoNotifyShoppingListUpdateHash,
  dependencies: <ProviderOrFamily>[sharedPreferencesProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    sharedPreferencesProvider,
    ...?sharedPreferencesProvider.allTransitiveDependencies
  },
);

typedef _$AutoNotifyShoppingListUpdate = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
