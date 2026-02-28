// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_groups.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userGroupsHash() => r'dad1683587f62d6e3d9f2b12d8f5f871ca484bfd';

/// See also [userGroups].
@ProviderFor(userGroups)
final userGroupsProvider = AutoDisposeStreamProvider<List<Group>>.internal(
  userGroups,
  name: r'userGroupsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userGroupsHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserGroupsRef = AutoDisposeStreamProviderRef<List<Group>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
