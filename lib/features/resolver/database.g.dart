// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userDatabaseHash() => r'35709f65ca4a0feec61e6242b2bff4a5defb5e56';

/// See also [userDatabase].
@ProviderFor(userDatabase)
final userDatabaseProvider = Provider<UserDatabase>.internal(
  userDatabase,
  name: r'userDatabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userDatabaseHash,
  dependencies: const <ProviderOrFamily>[],
  allTransitiveDependencies: const <ProviderOrFamily>{},
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserDatabaseRef = ProviderRef<UserDatabase>;
String _$groupDatabaseHash() => r'61da22f4243932579f224c8b0dc12902e6bcf56e';

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

/// See also [groupDatabase].
@ProviderFor(groupDatabase)
const groupDatabaseProvider = GroupDatabaseFamily();

/// See also [groupDatabase].
class GroupDatabaseFamily extends Family<GroupDatabase> {
  /// See also [groupDatabase].
  const GroupDatabaseFamily();

  /// See also [groupDatabase].
  GroupDatabaseProvider call({
    required String groupID,
  }) {
    return GroupDatabaseProvider(
      groupID: groupID,
    );
  }

  @override
  GroupDatabaseProvider getProviderOverride(
    covariant GroupDatabaseProvider provider,
  ) {
    return call(
      groupID: provider.groupID,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies =
      const <ProviderOrFamily>[];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      const <ProviderOrFamily>{};

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupDatabaseProvider';
}

/// See also [groupDatabase].
class GroupDatabaseProvider extends Provider<GroupDatabase> {
  /// See also [groupDatabase].
  GroupDatabaseProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupDatabase(
            ref as GroupDatabaseRef,
            groupID: groupID,
          ),
          from: groupDatabaseProvider,
          name: r'groupDatabaseProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupDatabaseHash,
          dependencies: GroupDatabaseFamily._dependencies,
          allTransitiveDependencies:
              GroupDatabaseFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupDatabaseProvider._internal(
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
    GroupDatabase Function(GroupDatabaseRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupDatabaseProvider._internal(
        (ref) => create(ref as GroupDatabaseRef),
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
  ProviderElement<GroupDatabase> createElement() {
    return _GroupDatabaseProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupDatabaseProvider && other.groupID == groupID;
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
mixin GroupDatabaseRef on ProviderRef<GroupDatabase> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupDatabaseProviderElement extends ProviderElement<GroupDatabase>
    with GroupDatabaseRef {
  _GroupDatabaseProviderElement(super.provider);

  @override
  String get groupID => (origin as GroupDatabaseProvider).groupID;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
