// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shoppingListsHash() => r'6d2679957616ece54f3043c04a0fc7e04adc42c8';

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

/// See also [shoppingLists].
@ProviderFor(shoppingLists)
const shoppingListsProvider = ShoppingListsFamily();

/// See also [shoppingLists].
class ShoppingListsFamily extends Family<AsyncValue<List<GroupShoppingList>>> {
  /// See also [shoppingLists].
  const ShoppingListsFamily();

  /// See also [shoppingLists].
  ShoppingListsProvider call({
    required String groupID,
  }) {
    return ShoppingListsProvider(
      groupID: groupID,
    );
  }

  @override
  ShoppingListsProvider getProviderOverride(
    covariant ShoppingListsProvider provider,
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
  String? get name => r'shoppingListsProvider';
}

/// See also [shoppingLists].
class ShoppingListsProvider
    extends AutoDisposeStreamProvider<List<GroupShoppingList>> {
  /// See also [shoppingLists].
  ShoppingListsProvider({
    required String groupID,
  }) : this._internal(
          (ref) => shoppingLists(
            ref as ShoppingListsRef,
            groupID: groupID,
          ),
          from: shoppingListsProvider,
          name: r'shoppingListsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shoppingListsHash,
          dependencies: ShoppingListsFamily._dependencies,
          allTransitiveDependencies:
              ShoppingListsFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  ShoppingListsProvider._internal(
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
    Stream<List<GroupShoppingList>> Function(ShoppingListsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShoppingListsProvider._internal(
        (ref) => create(ref as ShoppingListsRef),
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
  AutoDisposeStreamProviderElement<List<GroupShoppingList>> createElement() {
    return _ShoppingListsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingListsProvider && other.groupID == groupID;
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
mixin ShoppingListsRef
    on AutoDisposeStreamProviderRef<List<GroupShoppingList>> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _ShoppingListsProviderElement
    extends AutoDisposeStreamProviderElement<List<GroupShoppingList>>
    with ShoppingListsRef {
  _ShoppingListsProviderElement(super.provider);

  @override
  String get groupID => (origin as ShoppingListsProvider).groupID;
}

String _$shoppingListAddHash() => r'36207893c21f77fd46ad8760207a52933eaa5869';

/// See also [shoppingListAdd].
@ProviderFor(shoppingListAdd)
const shoppingListAddProvider = ShoppingListAddFamily();

/// See also [shoppingListAdd].
class ShoppingListAddFamily extends Family<ShoppingListAdd> {
  /// See also [shoppingListAdd].
  const ShoppingListAddFamily();

  /// See also [shoppingListAdd].
  ShoppingListAddProvider call({
    required String groupID,
  }) {
    return ShoppingListAddProvider(
      groupID: groupID,
    );
  }

  @override
  ShoppingListAddProvider getProviderOverride(
    covariant ShoppingListAddProvider provider,
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
  String? get name => r'shoppingListAddProvider';
}

/// See also [shoppingListAdd].
class ShoppingListAddProvider extends AutoDisposeProvider<ShoppingListAdd> {
  /// See also [shoppingListAdd].
  ShoppingListAddProvider({
    required String groupID,
  }) : this._internal(
          (ref) => shoppingListAdd(
            ref as ShoppingListAddRef,
            groupID: groupID,
          ),
          from: shoppingListAddProvider,
          name: r'shoppingListAddProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shoppingListAddHash,
          dependencies: ShoppingListAddFamily._dependencies,
          allTransitiveDependencies:
              ShoppingListAddFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  ShoppingListAddProvider._internal(
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
    ShoppingListAdd Function(ShoppingListAddRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShoppingListAddProvider._internal(
        (ref) => create(ref as ShoppingListAddRef),
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
  AutoDisposeProviderElement<ShoppingListAdd> createElement() {
    return _ShoppingListAddProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingListAddProvider && other.groupID == groupID;
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
mixin ShoppingListAddRef on AutoDisposeProviderRef<ShoppingListAdd> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _ShoppingListAddProviderElement
    extends AutoDisposeProviderElement<ShoppingListAdd>
    with ShoppingListAddRef {
  _ShoppingListAddProviderElement(super.provider);

  @override
  String get groupID => (origin as ShoppingListAddProvider).groupID;
}

String _$shoppingListDeleteHash() =>
    r'53194ebbcaca78982b67ad88d5433c427a23462d';

/// See also [shoppingListDelete].
@ProviderFor(shoppingListDelete)
const shoppingListDeleteProvider = ShoppingListDeleteFamily();

/// See also [shoppingListDelete].
class ShoppingListDeleteFamily extends Family<ShoppingListDelete> {
  /// See also [shoppingListDelete].
  const ShoppingListDeleteFamily();

  /// See also [shoppingListDelete].
  ShoppingListDeleteProvider call({
    required String groupID,
  }) {
    return ShoppingListDeleteProvider(
      groupID: groupID,
    );
  }

  @override
  ShoppingListDeleteProvider getProviderOverride(
    covariant ShoppingListDeleteProvider provider,
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
  String? get name => r'shoppingListDeleteProvider';
}

/// See also [shoppingListDelete].
class ShoppingListDeleteProvider
    extends AutoDisposeProvider<ShoppingListDelete> {
  /// See also [shoppingListDelete].
  ShoppingListDeleteProvider({
    required String groupID,
  }) : this._internal(
          (ref) => shoppingListDelete(
            ref as ShoppingListDeleteRef,
            groupID: groupID,
          ),
          from: shoppingListDeleteProvider,
          name: r'shoppingListDeleteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shoppingListDeleteHash,
          dependencies: ShoppingListDeleteFamily._dependencies,
          allTransitiveDependencies:
              ShoppingListDeleteFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  ShoppingListDeleteProvider._internal(
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
    ShoppingListDelete Function(ShoppingListDeleteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShoppingListDeleteProvider._internal(
        (ref) => create(ref as ShoppingListDeleteRef),
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
  AutoDisposeProviderElement<ShoppingListDelete> createElement() {
    return _ShoppingListDeleteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingListDeleteProvider && other.groupID == groupID;
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
mixin ShoppingListDeleteRef on AutoDisposeProviderRef<ShoppingListDelete> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _ShoppingListDeleteProviderElement
    extends AutoDisposeProviderElement<ShoppingListDelete>
    with ShoppingListDeleteRef {
  _ShoppingListDeleteProviderElement(super.provider);

  @override
  String get groupID => (origin as ShoppingListDeleteProvider).groupID;
}

String _$shoppingListUpdateHash() =>
    r'78b4ec8d0e4956e2998fd8c202915a274aae7bc5';

/// See also [shoppingListUpdate].
@ProviderFor(shoppingListUpdate)
const shoppingListUpdateProvider = ShoppingListUpdateFamily();

/// See also [shoppingListUpdate].
class ShoppingListUpdateFamily extends Family<ShoppingListUpdate> {
  /// See also [shoppingListUpdate].
  const ShoppingListUpdateFamily();

  /// See also [shoppingListUpdate].
  ShoppingListUpdateProvider call({
    required String groupID,
  }) {
    return ShoppingListUpdateProvider(
      groupID: groupID,
    );
  }

  @override
  ShoppingListUpdateProvider getProviderOverride(
    covariant ShoppingListUpdateProvider provider,
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
  String? get name => r'shoppingListUpdateProvider';
}

/// See also [shoppingListUpdate].
class ShoppingListUpdateProvider
    extends AutoDisposeProvider<ShoppingListUpdate> {
  /// See also [shoppingListUpdate].
  ShoppingListUpdateProvider({
    required String groupID,
  }) : this._internal(
          (ref) => shoppingListUpdate(
            ref as ShoppingListUpdateRef,
            groupID: groupID,
          ),
          from: shoppingListUpdateProvider,
          name: r'shoppingListUpdateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shoppingListUpdateHash,
          dependencies: ShoppingListUpdateFamily._dependencies,
          allTransitiveDependencies:
              ShoppingListUpdateFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  ShoppingListUpdateProvider._internal(
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
    ShoppingListUpdate Function(ShoppingListUpdateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShoppingListUpdateProvider._internal(
        (ref) => create(ref as ShoppingListUpdateRef),
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
  AutoDisposeProviderElement<ShoppingListUpdate> createElement() {
    return _ShoppingListUpdateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingListUpdateProvider && other.groupID == groupID;
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
mixin ShoppingListUpdateRef on AutoDisposeProviderRef<ShoppingListUpdate> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _ShoppingListUpdateProviderElement
    extends AutoDisposeProviderElement<ShoppingListUpdate>
    with ShoppingListUpdateRef {
  _ShoppingListUpdateProviderElement(super.provider);

  @override
  String get groupID => (origin as ShoppingListUpdateProvider).groupID;
}

String _$shoppingListDuplicateHash() =>
    r'065006997da40e65a906ee85c0d2e54499386a33';

/// See also [shoppingListDuplicate].
@ProviderFor(shoppingListDuplicate)
const shoppingListDuplicateProvider = ShoppingListDuplicateFamily();

/// See also [shoppingListDuplicate].
class ShoppingListDuplicateFamily extends Family<ShoppingListDuplicate> {
  /// See also [shoppingListDuplicate].
  const ShoppingListDuplicateFamily();

  /// See also [shoppingListDuplicate].
  ShoppingListDuplicateProvider call({
    required String groupID,
  }) {
    return ShoppingListDuplicateProvider(
      groupID: groupID,
    );
  }

  @override
  ShoppingListDuplicateProvider getProviderOverride(
    covariant ShoppingListDuplicateProvider provider,
  ) {
    return call(
      groupID: provider.groupID,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    shoppingListAddProvider,
    addShoppingListItemProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    shoppingListAddProvider,
    ...?shoppingListAddProvider.allTransitiveDependencies,
    addShoppingListItemProvider,
    ...?addShoppingListItemProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'shoppingListDuplicateProvider';
}

/// See also [shoppingListDuplicate].
class ShoppingListDuplicateProvider
    extends AutoDisposeProvider<ShoppingListDuplicate> {
  /// See also [shoppingListDuplicate].
  ShoppingListDuplicateProvider({
    required String groupID,
  }) : this._internal(
          (ref) => shoppingListDuplicate(
            ref as ShoppingListDuplicateRef,
            groupID: groupID,
          ),
          from: shoppingListDuplicateProvider,
          name: r'shoppingListDuplicateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shoppingListDuplicateHash,
          dependencies: ShoppingListDuplicateFamily._dependencies,
          allTransitiveDependencies:
              ShoppingListDuplicateFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  ShoppingListDuplicateProvider._internal(
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
    ShoppingListDuplicate Function(ShoppingListDuplicateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShoppingListDuplicateProvider._internal(
        (ref) => create(ref as ShoppingListDuplicateRef),
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
  AutoDisposeProviderElement<ShoppingListDuplicate> createElement() {
    return _ShoppingListDuplicateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingListDuplicateProvider && other.groupID == groupID;
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
mixin ShoppingListDuplicateRef
    on AutoDisposeProviderRef<ShoppingListDuplicate> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _ShoppingListDuplicateProviderElement
    extends AutoDisposeProviderElement<ShoppingListDuplicate>
    with ShoppingListDuplicateRef {
  _ShoppingListDuplicateProviderElement(super.provider);

  @override
  String get groupID => (origin as ShoppingListDuplicateProvider).groupID;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
