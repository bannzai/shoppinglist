// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_location.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shoppingLocationsHash() => r'7aed51dda16a45608c0db4f7a23717bdd80c6f27';

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

/// See also [shoppingLocations].
@ProviderFor(shoppingLocations)
const shoppingLocationsProvider = ShoppingLocationsFamily();

/// See also [shoppingLocations].
class ShoppingLocationsFamily
    extends Family<AsyncValue<List<GroupShoppingLocation>>> {
  /// See also [shoppingLocations].
  const ShoppingLocationsFamily();

  /// See also [shoppingLocations].
  ShoppingLocationsProvider call({
    required String groupID,
  }) {
    return ShoppingLocationsProvider(
      groupID: groupID,
    );
  }

  @override
  ShoppingLocationsProvider getProviderOverride(
    covariant ShoppingLocationsProvider provider,
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
  String? get name => r'shoppingLocationsProvider';
}

/// See also [shoppingLocations].
class ShoppingLocationsProvider
    extends AutoDisposeStreamProvider<List<GroupShoppingLocation>> {
  /// See also [shoppingLocations].
  ShoppingLocationsProvider({
    required String groupID,
  }) : this._internal(
          (ref) => shoppingLocations(
            ref as ShoppingLocationsRef,
            groupID: groupID,
          ),
          from: shoppingLocationsProvider,
          name: r'shoppingLocationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shoppingLocationsHash,
          dependencies: ShoppingLocationsFamily._dependencies,
          allTransitiveDependencies:
              ShoppingLocationsFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  ShoppingLocationsProvider._internal(
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
    Stream<List<GroupShoppingLocation>> Function(ShoppingLocationsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShoppingLocationsProvider._internal(
        (ref) => create(ref as ShoppingLocationsRef),
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
  AutoDisposeStreamProviderElement<List<GroupShoppingLocation>>
      createElement() {
    return _ShoppingLocationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingLocationsProvider && other.groupID == groupID;
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
mixin ShoppingLocationsRef
    on AutoDisposeStreamProviderRef<List<GroupShoppingLocation>> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _ShoppingLocationsProviderElement
    extends AutoDisposeStreamProviderElement<List<GroupShoppingLocation>>
    with ShoppingLocationsRef {
  _ShoppingLocationsProviderElement(super.provider);

  @override
  String get groupID => (origin as ShoppingLocationsProvider).groupID;
}

String _$shoppingLocationAddHash() =>
    r'de0716db61107ad8cbd46cf74587fb167f6d8598';

/// See also [shoppingLocationAdd].
@ProviderFor(shoppingLocationAdd)
const shoppingLocationAddProvider = ShoppingLocationAddFamily();

/// See also [shoppingLocationAdd].
class ShoppingLocationAddFamily extends Family<ShoppingLocationAdd> {
  /// See also [shoppingLocationAdd].
  const ShoppingLocationAddFamily();

  /// See also [shoppingLocationAdd].
  ShoppingLocationAddProvider call({
    required String groupID,
  }) {
    return ShoppingLocationAddProvider(
      groupID: groupID,
    );
  }

  @override
  ShoppingLocationAddProvider getProviderOverride(
    covariant ShoppingLocationAddProvider provider,
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
  String? get name => r'shoppingLocationAddProvider';
}

/// See also [shoppingLocationAdd].
class ShoppingLocationAddProvider
    extends AutoDisposeProvider<ShoppingLocationAdd> {
  /// See also [shoppingLocationAdd].
  ShoppingLocationAddProvider({
    required String groupID,
  }) : this._internal(
          (ref) => shoppingLocationAdd(
            ref as ShoppingLocationAddRef,
            groupID: groupID,
          ),
          from: shoppingLocationAddProvider,
          name: r'shoppingLocationAddProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shoppingLocationAddHash,
          dependencies: ShoppingLocationAddFamily._dependencies,
          allTransitiveDependencies:
              ShoppingLocationAddFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  ShoppingLocationAddProvider._internal(
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
    ShoppingLocationAdd Function(ShoppingLocationAddRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShoppingLocationAddProvider._internal(
        (ref) => create(ref as ShoppingLocationAddRef),
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
  AutoDisposeProviderElement<ShoppingLocationAdd> createElement() {
    return _ShoppingLocationAddProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingLocationAddProvider && other.groupID == groupID;
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
mixin ShoppingLocationAddRef on AutoDisposeProviderRef<ShoppingLocationAdd> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _ShoppingLocationAddProviderElement
    extends AutoDisposeProviderElement<ShoppingLocationAdd>
    with ShoppingLocationAddRef {
  _ShoppingLocationAddProviderElement(super.provider);

  @override
  String get groupID => (origin as ShoppingLocationAddProvider).groupID;
}

String _$shoppingLocationUpdateHash() =>
    r'0557896dbd7b18fa7eb8f3239a5934a8688d2114';

/// See also [shoppingLocationUpdate].
@ProviderFor(shoppingLocationUpdate)
const shoppingLocationUpdateProvider = ShoppingLocationUpdateFamily();

/// See also [shoppingLocationUpdate].
class ShoppingLocationUpdateFamily extends Family<ShoppingLocationUpdate> {
  /// See also [shoppingLocationUpdate].
  const ShoppingLocationUpdateFamily();

  /// See also [shoppingLocationUpdate].
  ShoppingLocationUpdateProvider call({
    required String groupID,
  }) {
    return ShoppingLocationUpdateProvider(
      groupID: groupID,
    );
  }

  @override
  ShoppingLocationUpdateProvider getProviderOverride(
    covariant ShoppingLocationUpdateProvider provider,
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
  String? get name => r'shoppingLocationUpdateProvider';
}

/// See also [shoppingLocationUpdate].
class ShoppingLocationUpdateProvider
    extends AutoDisposeProvider<ShoppingLocationUpdate> {
  /// See also [shoppingLocationUpdate].
  ShoppingLocationUpdateProvider({
    required String groupID,
  }) : this._internal(
          (ref) => shoppingLocationUpdate(
            ref as ShoppingLocationUpdateRef,
            groupID: groupID,
          ),
          from: shoppingLocationUpdateProvider,
          name: r'shoppingLocationUpdateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shoppingLocationUpdateHash,
          dependencies: ShoppingLocationUpdateFamily._dependencies,
          allTransitiveDependencies:
              ShoppingLocationUpdateFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  ShoppingLocationUpdateProvider._internal(
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
    ShoppingLocationUpdate Function(ShoppingLocationUpdateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShoppingLocationUpdateProvider._internal(
        (ref) => create(ref as ShoppingLocationUpdateRef),
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
  AutoDisposeProviderElement<ShoppingLocationUpdate> createElement() {
    return _ShoppingLocationUpdateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingLocationUpdateProvider && other.groupID == groupID;
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
mixin ShoppingLocationUpdateRef
    on AutoDisposeProviderRef<ShoppingLocationUpdate> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _ShoppingLocationUpdateProviderElement
    extends AutoDisposeProviderElement<ShoppingLocationUpdate>
    with ShoppingLocationUpdateRef {
  _ShoppingLocationUpdateProviderElement(super.provider);

  @override
  String get groupID => (origin as ShoppingLocationUpdateProvider).groupID;
}

String _$shoppingLocationDeleteHash() =>
    r'7782457cf60a645870f39b136a8088058d359816';

/// See also [shoppingLocationDelete].
@ProviderFor(shoppingLocationDelete)
const shoppingLocationDeleteProvider = ShoppingLocationDeleteFamily();

/// See also [shoppingLocationDelete].
class ShoppingLocationDeleteFamily extends Family<ShoppingLocationDelete> {
  /// See also [shoppingLocationDelete].
  const ShoppingLocationDeleteFamily();

  /// See also [shoppingLocationDelete].
  ShoppingLocationDeleteProvider call({
    required String groupID,
  }) {
    return ShoppingLocationDeleteProvider(
      groupID: groupID,
    );
  }

  @override
  ShoppingLocationDeleteProvider getProviderOverride(
    covariant ShoppingLocationDeleteProvider provider,
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
  String? get name => r'shoppingLocationDeleteProvider';
}

/// See also [shoppingLocationDelete].
class ShoppingLocationDeleteProvider
    extends AutoDisposeProvider<ShoppingLocationDelete> {
  /// See also [shoppingLocationDelete].
  ShoppingLocationDeleteProvider({
    required String groupID,
  }) : this._internal(
          (ref) => shoppingLocationDelete(
            ref as ShoppingLocationDeleteRef,
            groupID: groupID,
          ),
          from: shoppingLocationDeleteProvider,
          name: r'shoppingLocationDeleteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shoppingLocationDeleteHash,
          dependencies: ShoppingLocationDeleteFamily._dependencies,
          allTransitiveDependencies:
              ShoppingLocationDeleteFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  ShoppingLocationDeleteProvider._internal(
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
    ShoppingLocationDelete Function(ShoppingLocationDeleteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShoppingLocationDeleteProvider._internal(
        (ref) => create(ref as ShoppingLocationDeleteRef),
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
  AutoDisposeProviderElement<ShoppingLocationDelete> createElement() {
    return _ShoppingLocationDeleteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingLocationDeleteProvider && other.groupID == groupID;
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
mixin ShoppingLocationDeleteRef
    on AutoDisposeProviderRef<ShoppingLocationDelete> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _ShoppingLocationDeleteProviderElement
    extends AutoDisposeProviderElement<ShoppingLocationDelete>
    with ShoppingLocationDeleteRef {
  _ShoppingLocationDeleteProviderElement(super.provider);

  @override
  String get groupID => (origin as ShoppingLocationDeleteProvider).groupID;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
