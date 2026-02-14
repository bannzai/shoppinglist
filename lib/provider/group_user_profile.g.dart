// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_user_profile.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupUserProfilesHash() => r'e617234f50c1881869e0711f10bfb571fe8c00a4';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [groupUserProfiles].
@ProviderFor(groupUserProfiles)
const groupUserProfilesProvider = GroupUserProfilesFamily();

/// See also [groupUserProfiles].
class GroupUserProfilesFamily
    extends Family<AsyncValue<List<GroupUserProfile>>> {
  /// See also [groupUserProfiles].
  const GroupUserProfilesFamily();

  /// See also [groupUserProfiles].
  GroupUserProfilesProvider call({
    required String groupID,
  }) {
    return GroupUserProfilesProvider(
      groupID: groupID,
    );
  }

  @override
  GroupUserProfilesProvider getProviderOverride(
    covariant GroupUserProfilesProvider provider,
  ) {
    return call(
      groupID: provider.groupID,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    groupDatabaseProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    groupDatabaseProvider,
    ...?groupDatabaseProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupUserProfilesProvider';
}

/// See also [groupUserProfiles].
class GroupUserProfilesProvider
    extends AutoDisposeStreamProvider<List<GroupUserProfile>> {
  /// See also [groupUserProfiles].
  GroupUserProfilesProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupUserProfiles(
            ref as GroupUserProfilesRef,
            groupID: groupID,
          ),
          from: groupUserProfilesProvider,
          name: r'groupUserProfilesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupUserProfilesHash,
          dependencies: GroupUserProfilesFamily._dependencies,
          allTransitiveDependencies:
              GroupUserProfilesFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupUserProfilesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupID,
  }) : super.internal();

  final String groupID;

  @override
  Override overrideWith(
    Stream<List<GroupUserProfile>> Function(GroupUserProfilesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupUserProfilesProvider._internal(
        (ref) => create(ref as GroupUserProfilesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupID: groupID,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<GroupUserProfile>> createElement() {
    return _GroupUserProfilesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupUserProfilesProvider && other.groupID == groupID;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupID.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupUserProfilesRef
    on AutoDisposeStreamProviderRef<List<GroupUserProfile>> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupUserProfilesProviderElement
    extends AutoDisposeStreamProviderElement<List<GroupUserProfile>>
    with GroupUserProfilesRef {
  _GroupUserProfilesProviderElement(super.provider);

  @override
  String get groupID => (origin as GroupUserProfilesProvider).groupID;
}

String _$groupUserProfileUpdateHash() =>
    r'cf657427b21cccf05fb115def874f2588b5285d6';

/// See also [groupUserProfileUpdate].
@ProviderFor(groupUserProfileUpdate)
const groupUserProfileUpdateProvider = GroupUserProfileUpdateFamily();

/// See also [groupUserProfileUpdate].
class GroupUserProfileUpdateFamily extends Family<GroupUserProfileUpdate> {
  /// See also [groupUserProfileUpdate].
  const GroupUserProfileUpdateFamily();

  /// See also [groupUserProfileUpdate].
  GroupUserProfileUpdateProvider call({
    required String groupID,
  }) {
    return GroupUserProfileUpdateProvider(
      groupID: groupID,
    );
  }

  @override
  GroupUserProfileUpdateProvider getProviderOverride(
    covariant GroupUserProfileUpdateProvider provider,
  ) {
    return call(
      groupID: provider.groupID,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    groupDatabaseProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    groupDatabaseProvider,
    ...?groupDatabaseProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupUserProfileUpdateProvider';
}

/// See also [groupUserProfileUpdate].
class GroupUserProfileUpdateProvider
    extends AutoDisposeProvider<GroupUserProfileUpdate> {
  /// See also [groupUserProfileUpdate].
  GroupUserProfileUpdateProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupUserProfileUpdate(
            ref as GroupUserProfileUpdateRef,
            groupID: groupID,
          ),
          from: groupUserProfileUpdateProvider,
          name: r'groupUserProfileUpdateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupUserProfileUpdateHash,
          dependencies: GroupUserProfileUpdateFamily._dependencies,
          allTransitiveDependencies:
              GroupUserProfileUpdateFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupUserProfileUpdateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupID,
  }) : super.internal();

  final String groupID;

  @override
  Override overrideWith(
    GroupUserProfileUpdate Function(GroupUserProfileUpdateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupUserProfileUpdateProvider._internal(
        (ref) => create(ref as GroupUserProfileUpdateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupID: groupID,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<GroupUserProfileUpdate> createElement() {
    return _GroupUserProfileUpdateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupUserProfileUpdateProvider && other.groupID == groupID;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupID.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupUserProfileUpdateRef
    on AutoDisposeProviderRef<GroupUserProfileUpdate> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupUserProfileUpdateProviderElement
    extends AutoDisposeProviderElement<GroupUserProfileUpdate>
    with GroupUserProfileUpdateRef {
  _GroupUserProfileUpdateProviderElement(super.provider);

  @override
  String get groupID => (origin as GroupUserProfileUpdateProvider).groupID;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
