// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupHash() => r'00db553ddde7bb5b274e9eb9932fa26c9f18296a';

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

/// See also [group].
@ProviderFor(group)
const groupProvider = GroupFamily();

/// See also [group].
class GroupFamily extends Family<AsyncValue<Group>> {
  /// See also [group].
  const GroupFamily();

  /// See also [group].
  GroupProvider call({
    required String groupID,
  }) {
    return GroupProvider(
      groupID: groupID,
    );
  }

  @override
  GroupProvider getProviderOverride(
    covariant GroupProvider provider,
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
  String? get name => r'groupProvider';
}

/// See also [group].
class GroupProvider extends AutoDisposeStreamProvider<Group> {
  /// See also [group].
  GroupProvider({
    required String groupID,
  }) : this._internal(
          (ref) => group(
            ref as GroupRef,
            groupID: groupID,
          ),
          from: groupProvider,
          name: r'groupProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupHash,
          dependencies: GroupFamily._dependencies,
          allTransitiveDependencies: GroupFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupProvider._internal(
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
    Stream<Group> Function(GroupRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupProvider._internal(
        (ref) => create(ref as GroupRef),
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
  AutoDisposeStreamProviderElement<Group> createElement() {
    return _GroupProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupProvider && other.groupID == groupID;
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
mixin GroupRef on AutoDisposeStreamProviderRef<Group> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupProviderElement extends AutoDisposeStreamProviderElement<Group>
    with GroupRef {
  _GroupProviderElement(super.provider);

  @override
  String get groupID => (origin as GroupProvider).groupID;
}

String _$groupNameUpdateHash() => r'ed13b835734a917bbae3b6dc4f3650a800f7b241';

/// See also [groupNameUpdate].
@ProviderFor(groupNameUpdate)
const groupNameUpdateProvider = GroupNameUpdateFamily();

/// See also [groupNameUpdate].
class GroupNameUpdateFamily extends Family<GroupNameUpdate> {
  /// See also [groupNameUpdate].
  const GroupNameUpdateFamily();

  /// See also [groupNameUpdate].
  GroupNameUpdateProvider call({
    required String groupID,
  }) {
    return GroupNameUpdateProvider(
      groupID: groupID,
    );
  }

  @override
  GroupNameUpdateProvider getProviderOverride(
    covariant GroupNameUpdateProvider provider,
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
  String? get name => r'groupNameUpdateProvider';
}

/// See also [groupNameUpdate].
class GroupNameUpdateProvider extends AutoDisposeProvider<GroupNameUpdate> {
  /// See also [groupNameUpdate].
  GroupNameUpdateProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupNameUpdate(
            ref as GroupNameUpdateRef,
            groupID: groupID,
          ),
          from: groupNameUpdateProvider,
          name: r'groupNameUpdateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupNameUpdateHash,
          dependencies: GroupNameUpdateFamily._dependencies,
          allTransitiveDependencies:
              GroupNameUpdateFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupNameUpdateProvider._internal(
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
    GroupNameUpdate Function(GroupNameUpdateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupNameUpdateProvider._internal(
        (ref) => create(ref as GroupNameUpdateRef),
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
  AutoDisposeProviderElement<GroupNameUpdate> createElement() {
    return _GroupNameUpdateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupNameUpdateProvider && other.groupID == groupID;
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
mixin GroupNameUpdateRef on AutoDisposeProviderRef<GroupNameUpdate> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupNameUpdateProviderElement
    extends AutoDisposeProviderElement<GroupNameUpdate>
    with GroupNameUpdateRef {
  _GroupNameUpdateProviderElement(super.provider);

  @override
  String get groupID => (origin as GroupNameUpdateProvider).groupID;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
