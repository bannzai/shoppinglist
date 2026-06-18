// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_developer_token_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userDeveloperTokenSyncHash() =>
    r'4a1798dd847dfaa9d1b08475813c0c1f8d72fad6';

/// [UserDeveloperTokenSync] を提供する Provider。
///
/// Copied from [userDeveloperTokenSync].
@ProviderFor(userDeveloperTokenSync)
final userDeveloperTokenSyncProvider =
    AutoDisposeProvider<UserDeveloperTokenSync>.internal(
      userDeveloperTokenSync,
      name: r'userDeveloperTokenSyncProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$userDeveloperTokenSyncHash,
      dependencies: <ProviderOrFamily>[userDatabaseProvider],
      allTransitiveDependencies: <ProviderOrFamily>{
        userDatabaseProvider,
        ...?userDatabaseProvider.allTransitiveDependencies,
      },
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserDeveloperTokenSyncRef =
    AutoDisposeProviderRef<UserDeveloperTokenSync>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
