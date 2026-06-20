// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appUserHash() => r'ba194a96944f6c3713a705684d24bc1c358fd399';

/// See also [appUser].
@ProviderFor(appUser)
final appUserProvider = AutoDisposeStreamProvider<AppUser>.internal(
  appUser,
  name: r'appUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appUserHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies,
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppUserRef = AutoDisposeStreamProviderRef<AppUser>;
String _$optionalAppUserHash() => r'73a1a68b8be25fe0eac81c89a514e5273708b3a4';

/// AppUserドキュメントが存在しない場合は null を返す。
/// AppUserCreateResolver で使用する。ドキュメント作成前のストリーム発火時に
/// エラーにならず null として扱える。
///
/// Copied from [optionalAppUser].
@ProviderFor(optionalAppUser)
final optionalAppUserProvider = AutoDisposeStreamProvider<AppUser?>.internal(
  optionalAppUser,
  name: r'optionalAppUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$optionalAppUserHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies,
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OptionalAppUserRef = AutoDisposeStreamProviderRef<AppUser?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
