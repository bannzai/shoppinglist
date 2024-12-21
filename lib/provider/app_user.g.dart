// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appUserHash() => r'd4db768e8c250fd8a19d1bb85ead8d5df365a312';

/// See also [appUser].
@ProviderFor(appUser)
final appUserProvider = AutoDisposeStreamProvider<AppUser>.internal(
  appUser,
  name: r'appUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$appUserHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{userDatabaseProvider, ...?userDatabaseProvider.allTransitiveDependencies},
);

typedef AppUserRef = AutoDisposeStreamProviderRef<AppUser>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
