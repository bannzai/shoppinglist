// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_invitation.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$createGroupInvitationHash() =>
    r'37d90c1c7b87d21cde64f7e18904ec1610e4ec0d';

/// See also [createGroupInvitation].
@ProviderFor(createGroupInvitation)
final createGroupInvitationProvider =
    AutoDisposeProvider<CreateGroupInvitation>.internal(
  createGroupInvitation,
  name: r'createGroupInvitationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createGroupInvitationHash,
  dependencies: const <ProviderOrFamily>[],
  allTransitiveDependencies: const <ProviderOrFamily>{},
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateGroupInvitationRef
    = AutoDisposeProviderRef<CreateGroupInvitation>;
String _$acceptGroupInvitationHash() =>
    r'0b02a95d6a3ace9aee14a55a1b1c01262acafd18';

/// See also [acceptGroupInvitation].
@ProviderFor(acceptGroupInvitation)
final acceptGroupInvitationProvider =
    AutoDisposeProvider<AcceptGroupInvitation>.internal(
  acceptGroupInvitation,
  name: r'acceptGroupInvitationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$acceptGroupInvitationHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AcceptGroupInvitationRef
    = AutoDisposeProviderRef<AcceptGroupInvitation>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
