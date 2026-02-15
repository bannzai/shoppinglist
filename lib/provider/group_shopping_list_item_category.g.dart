// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_shopping_list_item_category.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupShoppingListItemCategoryAxesHash() =>
    r'39e4b7bdffc086a0d3f9807528773fb3bd02123d';

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

/// See also [groupShoppingListItemCategoryAxes].
@ProviderFor(groupShoppingListItemCategoryAxes)
const groupShoppingListItemCategoryAxesProvider =
    GroupShoppingListItemCategoryAxesFamily();

/// See also [groupShoppingListItemCategoryAxes].
class GroupShoppingListItemCategoryAxesFamily
    extends Family<AsyncValue<List<GroupShoppingListItemCategoryAxis>>> {
  /// See also [groupShoppingListItemCategoryAxes].
  const GroupShoppingListItemCategoryAxesFamily();

  /// See also [groupShoppingListItemCategoryAxes].
  GroupShoppingListItemCategoryAxesProvider call({
    required String groupID,
  }) {
    return GroupShoppingListItemCategoryAxesProvider(
      groupID: groupID,
    );
  }

  @override
  GroupShoppingListItemCategoryAxesProvider getProviderOverride(
    covariant GroupShoppingListItemCategoryAxesProvider provider,
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
  String? get name => r'groupShoppingListItemCategoryAxesProvider';
}

/// See also [groupShoppingListItemCategoryAxes].
class GroupShoppingListItemCategoryAxesProvider
    extends AutoDisposeStreamProvider<List<GroupShoppingListItemCategoryAxis>> {
  /// See also [groupShoppingListItemCategoryAxes].
  GroupShoppingListItemCategoryAxesProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupShoppingListItemCategoryAxes(
            ref as GroupShoppingListItemCategoryAxesRef,
            groupID: groupID,
          ),
          from: groupShoppingListItemCategoryAxesProvider,
          name: r'groupShoppingListItemCategoryAxesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupShoppingListItemCategoryAxesHash,
          dependencies: GroupShoppingListItemCategoryAxesFamily._dependencies,
          allTransitiveDependencies: GroupShoppingListItemCategoryAxesFamily
              ._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupShoppingListItemCategoryAxesProvider._internal(
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
    Stream<List<GroupShoppingListItemCategoryAxis>> Function(
            GroupShoppingListItemCategoryAxesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupShoppingListItemCategoryAxesProvider._internal(
        (ref) => create(ref as GroupShoppingListItemCategoryAxesRef),
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
  AutoDisposeStreamProviderElement<List<GroupShoppingListItemCategoryAxis>>
      createElement() {
    return _GroupShoppingListItemCategoryAxesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupShoppingListItemCategoryAxesProvider &&
        other.groupID == groupID;
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
mixin GroupShoppingListItemCategoryAxesRef
    on AutoDisposeStreamProviderRef<List<GroupShoppingListItemCategoryAxis>> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupShoppingListItemCategoryAxesProviderElement
    extends AutoDisposeStreamProviderElement<
        List<GroupShoppingListItemCategoryAxis>>
    with GroupShoppingListItemCategoryAxesRef {
  _GroupShoppingListItemCategoryAxesProviderElement(super.provider);

  @override
  String get groupID =>
      (origin as GroupShoppingListItemCategoryAxesProvider).groupID;
}

String _$groupShoppingListItemCategoryAxisAddHash() =>
    r'1f01742488ca69527d8ab18bc1012ef929b4ddca';

/// See also [groupShoppingListItemCategoryAxisAdd].
@ProviderFor(groupShoppingListItemCategoryAxisAdd)
const groupShoppingListItemCategoryAxisAddProvider =
    GroupShoppingListItemCategoryAxisAddFamily();

/// See also [groupShoppingListItemCategoryAxisAdd].
class GroupShoppingListItemCategoryAxisAddFamily
    extends Family<GroupShoppingListItemCategoryAxisAdd> {
  /// See also [groupShoppingListItemCategoryAxisAdd].
  const GroupShoppingListItemCategoryAxisAddFamily();

  /// See also [groupShoppingListItemCategoryAxisAdd].
  GroupShoppingListItemCategoryAxisAddProvider call({
    required String groupID,
  }) {
    return GroupShoppingListItemCategoryAxisAddProvider(
      groupID: groupID,
    );
  }

  @override
  GroupShoppingListItemCategoryAxisAddProvider getProviderOverride(
    covariant GroupShoppingListItemCategoryAxisAddProvider provider,
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
  String? get name => r'groupShoppingListItemCategoryAxisAddProvider';
}

/// See also [groupShoppingListItemCategoryAxisAdd].
class GroupShoppingListItemCategoryAxisAddProvider
    extends AutoDisposeProvider<GroupShoppingListItemCategoryAxisAdd> {
  /// See also [groupShoppingListItemCategoryAxisAdd].
  GroupShoppingListItemCategoryAxisAddProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupShoppingListItemCategoryAxisAdd(
            ref as GroupShoppingListItemCategoryAxisAddRef,
            groupID: groupID,
          ),
          from: groupShoppingListItemCategoryAxisAddProvider,
          name: r'groupShoppingListItemCategoryAxisAddProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupShoppingListItemCategoryAxisAddHash,
          dependencies:
              GroupShoppingListItemCategoryAxisAddFamily._dependencies,
          allTransitiveDependencies: GroupShoppingListItemCategoryAxisAddFamily
              ._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupShoppingListItemCategoryAxisAddProvider._internal(
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
    GroupShoppingListItemCategoryAxisAdd Function(
            GroupShoppingListItemCategoryAxisAddRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupShoppingListItemCategoryAxisAddProvider._internal(
        (ref) => create(ref as GroupShoppingListItemCategoryAxisAddRef),
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
  AutoDisposeProviderElement<GroupShoppingListItemCategoryAxisAdd>
      createElement() {
    return _GroupShoppingListItemCategoryAxisAddProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupShoppingListItemCategoryAxisAddProvider &&
        other.groupID == groupID;
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
mixin GroupShoppingListItemCategoryAxisAddRef
    on AutoDisposeProviderRef<GroupShoppingListItemCategoryAxisAdd> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupShoppingListItemCategoryAxisAddProviderElement
    extends AutoDisposeProviderElement<GroupShoppingListItemCategoryAxisAdd>
    with GroupShoppingListItemCategoryAxisAddRef {
  _GroupShoppingListItemCategoryAxisAddProviderElement(super.provider);

  @override
  String get groupID =>
      (origin as GroupShoppingListItemCategoryAxisAddProvider).groupID;
}

String _$groupShoppingListItemCategoryAxisDeleteHash() =>
    r'2691e4ea85e29c5fc669de2bc3002dbe9c7cd128';

/// See also [groupShoppingListItemCategoryAxisDelete].
@ProviderFor(groupShoppingListItemCategoryAxisDelete)
const groupShoppingListItemCategoryAxisDeleteProvider =
    GroupShoppingListItemCategoryAxisDeleteFamily();

/// See also [groupShoppingListItemCategoryAxisDelete].
class GroupShoppingListItemCategoryAxisDeleteFamily
    extends Family<GroupShoppingListItemCategoryAxisDelete> {
  /// See also [groupShoppingListItemCategoryAxisDelete].
  const GroupShoppingListItemCategoryAxisDeleteFamily();

  /// See also [groupShoppingListItemCategoryAxisDelete].
  GroupShoppingListItemCategoryAxisDeleteProvider call({
    required String groupID,
  }) {
    return GroupShoppingListItemCategoryAxisDeleteProvider(
      groupID: groupID,
    );
  }

  @override
  GroupShoppingListItemCategoryAxisDeleteProvider getProviderOverride(
    covariant GroupShoppingListItemCategoryAxisDeleteProvider provider,
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
  String? get name => r'groupShoppingListItemCategoryAxisDeleteProvider';
}

/// See also [groupShoppingListItemCategoryAxisDelete].
class GroupShoppingListItemCategoryAxisDeleteProvider
    extends AutoDisposeProvider<GroupShoppingListItemCategoryAxisDelete> {
  /// See also [groupShoppingListItemCategoryAxisDelete].
  GroupShoppingListItemCategoryAxisDeleteProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupShoppingListItemCategoryAxisDelete(
            ref as GroupShoppingListItemCategoryAxisDeleteRef,
            groupID: groupID,
          ),
          from: groupShoppingListItemCategoryAxisDeleteProvider,
          name: r'groupShoppingListItemCategoryAxisDeleteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupShoppingListItemCategoryAxisDeleteHash,
          dependencies:
              GroupShoppingListItemCategoryAxisDeleteFamily._dependencies,
          allTransitiveDependencies:
              GroupShoppingListItemCategoryAxisDeleteFamily
                  ._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupShoppingListItemCategoryAxisDeleteProvider._internal(
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
    GroupShoppingListItemCategoryAxisDelete Function(
            GroupShoppingListItemCategoryAxisDeleteRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupShoppingListItemCategoryAxisDeleteProvider._internal(
        (ref) => create(ref as GroupShoppingListItemCategoryAxisDeleteRef),
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
  AutoDisposeProviderElement<GroupShoppingListItemCategoryAxisDelete>
      createElement() {
    return _GroupShoppingListItemCategoryAxisDeleteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupShoppingListItemCategoryAxisDeleteProvider &&
        other.groupID == groupID;
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
mixin GroupShoppingListItemCategoryAxisDeleteRef
    on AutoDisposeProviderRef<GroupShoppingListItemCategoryAxisDelete> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupShoppingListItemCategoryAxisDeleteProviderElement
    extends AutoDisposeProviderElement<GroupShoppingListItemCategoryAxisDelete>
    with GroupShoppingListItemCategoryAxisDeleteRef {
  _GroupShoppingListItemCategoryAxisDeleteProviderElement(super.provider);

  @override
  String get groupID =>
      (origin as GroupShoppingListItemCategoryAxisDeleteProvider).groupID;
}

String _$groupShoppingListItemCategoriesHash() =>
    r'6dab03ec9d3290655771f6e3a709ed0d5d035d52';

/// See also [groupShoppingListItemCategories].
@ProviderFor(groupShoppingListItemCategories)
const groupShoppingListItemCategoriesProvider =
    GroupShoppingListItemCategoriesFamily();

/// See also [groupShoppingListItemCategories].
class GroupShoppingListItemCategoriesFamily
    extends Family<AsyncValue<List<GroupShoppingListItemCategory>>> {
  /// See also [groupShoppingListItemCategories].
  const GroupShoppingListItemCategoriesFamily();

  /// See also [groupShoppingListItemCategories].
  GroupShoppingListItemCategoriesProvider call({
    required String groupID,
    required String categoryAxisID,
  }) {
    return GroupShoppingListItemCategoriesProvider(
      groupID: groupID,
      categoryAxisID: categoryAxisID,
    );
  }

  @override
  GroupShoppingListItemCategoriesProvider getProviderOverride(
    covariant GroupShoppingListItemCategoriesProvider provider,
  ) {
    return call(
      groupID: provider.groupID,
      categoryAxisID: provider.categoryAxisID,
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
  String? get name => r'groupShoppingListItemCategoriesProvider';
}

/// See also [groupShoppingListItemCategories].
class GroupShoppingListItemCategoriesProvider
    extends AutoDisposeStreamProvider<List<GroupShoppingListItemCategory>> {
  /// See also [groupShoppingListItemCategories].
  GroupShoppingListItemCategoriesProvider({
    required String groupID,
    required String categoryAxisID,
  }) : this._internal(
          (ref) => groupShoppingListItemCategories(
            ref as GroupShoppingListItemCategoriesRef,
            groupID: groupID,
            categoryAxisID: categoryAxisID,
          ),
          from: groupShoppingListItemCategoriesProvider,
          name: r'groupShoppingListItemCategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupShoppingListItemCategoriesHash,
          dependencies: GroupShoppingListItemCategoriesFamily._dependencies,
          allTransitiveDependencies:
              GroupShoppingListItemCategoriesFamily._allTransitiveDependencies,
          groupID: groupID,
          categoryAxisID: categoryAxisID,
        );

  GroupShoppingListItemCategoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupID,
    required this.categoryAxisID,
  }) : super.internal();

  final String groupID;
  final String categoryAxisID;

  @override
  Override overrideWith(
    Stream<List<GroupShoppingListItemCategory>> Function(
            GroupShoppingListItemCategoriesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupShoppingListItemCategoriesProvider._internal(
        (ref) => create(ref as GroupShoppingListItemCategoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupID: groupID,
        categoryAxisID: categoryAxisID,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<GroupShoppingListItemCategory>>
      createElement() {
    return _GroupShoppingListItemCategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupShoppingListItemCategoriesProvider &&
        other.groupID == groupID &&
        other.categoryAxisID == categoryAxisID;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupID.hashCode);
    hash = _SystemHash.combine(hash, categoryAxisID.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupShoppingListItemCategoriesRef
    on AutoDisposeStreamProviderRef<List<GroupShoppingListItemCategory>> {
  /// The parameter `groupID` of this provider.
  String get groupID;

  /// The parameter `categoryAxisID` of this provider.
  String get categoryAxisID;
}

class _GroupShoppingListItemCategoriesProviderElement
    extends AutoDisposeStreamProviderElement<
        List<GroupShoppingListItemCategory>>
    with GroupShoppingListItemCategoriesRef {
  _GroupShoppingListItemCategoriesProviderElement(super.provider);

  @override
  String get groupID =>
      (origin as GroupShoppingListItemCategoriesProvider).groupID;
  @override
  String get categoryAxisID =>
      (origin as GroupShoppingListItemCategoriesProvider).categoryAxisID;
}

String _$groupShoppingListItemCategoryAddHash() =>
    r'8522f792a39725adb5008ed6799787cfbb9035e7';

/// See also [groupShoppingListItemCategoryAdd].
@ProviderFor(groupShoppingListItemCategoryAdd)
const groupShoppingListItemCategoryAddProvider =
    GroupShoppingListItemCategoryAddFamily();

/// See also [groupShoppingListItemCategoryAdd].
class GroupShoppingListItemCategoryAddFamily
    extends Family<GroupShoppingListItemCategoryAdd> {
  /// See also [groupShoppingListItemCategoryAdd].
  const GroupShoppingListItemCategoryAddFamily();

  /// See also [groupShoppingListItemCategoryAdd].
  GroupShoppingListItemCategoryAddProvider call({
    required String groupID,
  }) {
    return GroupShoppingListItemCategoryAddProvider(
      groupID: groupID,
    );
  }

  @override
  GroupShoppingListItemCategoryAddProvider getProviderOverride(
    covariant GroupShoppingListItemCategoryAddProvider provider,
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
  String? get name => r'groupShoppingListItemCategoryAddProvider';
}

/// See also [groupShoppingListItemCategoryAdd].
class GroupShoppingListItemCategoryAddProvider
    extends AutoDisposeProvider<GroupShoppingListItemCategoryAdd> {
  /// See also [groupShoppingListItemCategoryAdd].
  GroupShoppingListItemCategoryAddProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupShoppingListItemCategoryAdd(
            ref as GroupShoppingListItemCategoryAddRef,
            groupID: groupID,
          ),
          from: groupShoppingListItemCategoryAddProvider,
          name: r'groupShoppingListItemCategoryAddProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupShoppingListItemCategoryAddHash,
          dependencies: GroupShoppingListItemCategoryAddFamily._dependencies,
          allTransitiveDependencies:
              GroupShoppingListItemCategoryAddFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupShoppingListItemCategoryAddProvider._internal(
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
    GroupShoppingListItemCategoryAdd Function(
            GroupShoppingListItemCategoryAddRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupShoppingListItemCategoryAddProvider._internal(
        (ref) => create(ref as GroupShoppingListItemCategoryAddRef),
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
  AutoDisposeProviderElement<GroupShoppingListItemCategoryAdd> createElement() {
    return _GroupShoppingListItemCategoryAddProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupShoppingListItemCategoryAddProvider &&
        other.groupID == groupID;
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
mixin GroupShoppingListItemCategoryAddRef
    on AutoDisposeProviderRef<GroupShoppingListItemCategoryAdd> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupShoppingListItemCategoryAddProviderElement
    extends AutoDisposeProviderElement<GroupShoppingListItemCategoryAdd>
    with GroupShoppingListItemCategoryAddRef {
  _GroupShoppingListItemCategoryAddProviderElement(super.provider);

  @override
  String get groupID =>
      (origin as GroupShoppingListItemCategoryAddProvider).groupID;
}

String _$groupShoppingListItemCategoryUpdateHash() =>
    r'5c78b2a1433d15c75bc2fe1165fbb8cc5b1d62e7';

/// See also [groupShoppingListItemCategoryUpdate].
@ProviderFor(groupShoppingListItemCategoryUpdate)
const groupShoppingListItemCategoryUpdateProvider =
    GroupShoppingListItemCategoryUpdateFamily();

/// See also [groupShoppingListItemCategoryUpdate].
class GroupShoppingListItemCategoryUpdateFamily
    extends Family<GroupShoppingListItemCategoryUpdate> {
  /// See also [groupShoppingListItemCategoryUpdate].
  const GroupShoppingListItemCategoryUpdateFamily();

  /// See also [groupShoppingListItemCategoryUpdate].
  GroupShoppingListItemCategoryUpdateProvider call({
    required String groupID,
  }) {
    return GroupShoppingListItemCategoryUpdateProvider(
      groupID: groupID,
    );
  }

  @override
  GroupShoppingListItemCategoryUpdateProvider getProviderOverride(
    covariant GroupShoppingListItemCategoryUpdateProvider provider,
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
  String? get name => r'groupShoppingListItemCategoryUpdateProvider';
}

/// See also [groupShoppingListItemCategoryUpdate].
class GroupShoppingListItemCategoryUpdateProvider
    extends AutoDisposeProvider<GroupShoppingListItemCategoryUpdate> {
  /// See also [groupShoppingListItemCategoryUpdate].
  GroupShoppingListItemCategoryUpdateProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupShoppingListItemCategoryUpdate(
            ref as GroupShoppingListItemCategoryUpdateRef,
            groupID: groupID,
          ),
          from: groupShoppingListItemCategoryUpdateProvider,
          name: r'groupShoppingListItemCategoryUpdateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupShoppingListItemCategoryUpdateHash,
          dependencies: GroupShoppingListItemCategoryUpdateFamily._dependencies,
          allTransitiveDependencies: GroupShoppingListItemCategoryUpdateFamily
              ._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupShoppingListItemCategoryUpdateProvider._internal(
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
    GroupShoppingListItemCategoryUpdate Function(
            GroupShoppingListItemCategoryUpdateRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupShoppingListItemCategoryUpdateProvider._internal(
        (ref) => create(ref as GroupShoppingListItemCategoryUpdateRef),
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
  AutoDisposeProviderElement<GroupShoppingListItemCategoryUpdate>
      createElement() {
    return _GroupShoppingListItemCategoryUpdateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupShoppingListItemCategoryUpdateProvider &&
        other.groupID == groupID;
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
mixin GroupShoppingListItemCategoryUpdateRef
    on AutoDisposeProviderRef<GroupShoppingListItemCategoryUpdate> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupShoppingListItemCategoryUpdateProviderElement
    extends AutoDisposeProviderElement<GroupShoppingListItemCategoryUpdate>
    with GroupShoppingListItemCategoryUpdateRef {
  _GroupShoppingListItemCategoryUpdateProviderElement(super.provider);

  @override
  String get groupID =>
      (origin as GroupShoppingListItemCategoryUpdateProvider).groupID;
}

String _$groupShoppingListItemCategoryDeleteHash() =>
    r'60a3b148ffa860c553f3fde5bd4c8139f8758ce7';

/// See also [groupShoppingListItemCategoryDelete].
@ProviderFor(groupShoppingListItemCategoryDelete)
const groupShoppingListItemCategoryDeleteProvider =
    GroupShoppingListItemCategoryDeleteFamily();

/// See also [groupShoppingListItemCategoryDelete].
class GroupShoppingListItemCategoryDeleteFamily
    extends Family<GroupShoppingListItemCategoryDelete> {
  /// See also [groupShoppingListItemCategoryDelete].
  const GroupShoppingListItemCategoryDeleteFamily();

  /// See also [groupShoppingListItemCategoryDelete].
  GroupShoppingListItemCategoryDeleteProvider call({
    required String groupID,
  }) {
    return GroupShoppingListItemCategoryDeleteProvider(
      groupID: groupID,
    );
  }

  @override
  GroupShoppingListItemCategoryDeleteProvider getProviderOverride(
    covariant GroupShoppingListItemCategoryDeleteProvider provider,
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
  String? get name => r'groupShoppingListItemCategoryDeleteProvider';
}

/// See also [groupShoppingListItemCategoryDelete].
class GroupShoppingListItemCategoryDeleteProvider
    extends AutoDisposeProvider<GroupShoppingListItemCategoryDelete> {
  /// See also [groupShoppingListItemCategoryDelete].
  GroupShoppingListItemCategoryDeleteProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupShoppingListItemCategoryDelete(
            ref as GroupShoppingListItemCategoryDeleteRef,
            groupID: groupID,
          ),
          from: groupShoppingListItemCategoryDeleteProvider,
          name: r'groupShoppingListItemCategoryDeleteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupShoppingListItemCategoryDeleteHash,
          dependencies: GroupShoppingListItemCategoryDeleteFamily._dependencies,
          allTransitiveDependencies: GroupShoppingListItemCategoryDeleteFamily
              ._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupShoppingListItemCategoryDeleteProvider._internal(
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
    GroupShoppingListItemCategoryDelete Function(
            GroupShoppingListItemCategoryDeleteRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupShoppingListItemCategoryDeleteProvider._internal(
        (ref) => create(ref as GroupShoppingListItemCategoryDeleteRef),
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
  AutoDisposeProviderElement<GroupShoppingListItemCategoryDelete>
      createElement() {
    return _GroupShoppingListItemCategoryDeleteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupShoppingListItemCategoryDeleteProvider &&
        other.groupID == groupID;
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
mixin GroupShoppingListItemCategoryDeleteRef
    on AutoDisposeProviderRef<GroupShoppingListItemCategoryDelete> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupShoppingListItemCategoryDeleteProviderElement
    extends AutoDisposeProviderElement<GroupShoppingListItemCategoryDelete>
    with GroupShoppingListItemCategoryDeleteRef {
  _GroupShoppingListItemCategoryDeleteProviderElement(super.provider);

  @override
  String get groupID =>
      (origin as GroupShoppingListItemCategoryDeleteProvider).groupID;
}

String _$groupShoppingListItemCategoryBatchUpdateHash() =>
    r'a14f8352395763cb6dc079bd38fa5c54790255c2';

/// See also [groupShoppingListItemCategoryBatchUpdate].
@ProviderFor(groupShoppingListItemCategoryBatchUpdate)
const groupShoppingListItemCategoryBatchUpdateProvider =
    GroupShoppingListItemCategoryBatchUpdateFamily();

/// See also [groupShoppingListItemCategoryBatchUpdate].
class GroupShoppingListItemCategoryBatchUpdateFamily
    extends Family<GroupShoppingListItemCategoryBatchUpdate> {
  /// See also [groupShoppingListItemCategoryBatchUpdate].
  const GroupShoppingListItemCategoryBatchUpdateFamily();

  /// See also [groupShoppingListItemCategoryBatchUpdate].
  GroupShoppingListItemCategoryBatchUpdateProvider call({
    required String groupID,
  }) {
    return GroupShoppingListItemCategoryBatchUpdateProvider(
      groupID: groupID,
    );
  }

  @override
  GroupShoppingListItemCategoryBatchUpdateProvider getProviderOverride(
    covariant GroupShoppingListItemCategoryBatchUpdateProvider provider,
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
  String? get name => r'groupShoppingListItemCategoryBatchUpdateProvider';
}

/// See also [groupShoppingListItemCategoryBatchUpdate].
class GroupShoppingListItemCategoryBatchUpdateProvider
    extends AutoDisposeProvider<GroupShoppingListItemCategoryBatchUpdate> {
  /// See also [groupShoppingListItemCategoryBatchUpdate].
  GroupShoppingListItemCategoryBatchUpdateProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupShoppingListItemCategoryBatchUpdate(
            ref as GroupShoppingListItemCategoryBatchUpdateRef,
            groupID: groupID,
          ),
          from: groupShoppingListItemCategoryBatchUpdateProvider,
          name: r'groupShoppingListItemCategoryBatchUpdateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupShoppingListItemCategoryBatchUpdateHash,
          dependencies:
              GroupShoppingListItemCategoryBatchUpdateFamily._dependencies,
          allTransitiveDependencies:
              GroupShoppingListItemCategoryBatchUpdateFamily
                  ._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupShoppingListItemCategoryBatchUpdateProvider._internal(
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
    GroupShoppingListItemCategoryBatchUpdate Function(
            GroupShoppingListItemCategoryBatchUpdateRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupShoppingListItemCategoryBatchUpdateProvider._internal(
        (ref) => create(ref as GroupShoppingListItemCategoryBatchUpdateRef),
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
  AutoDisposeProviderElement<GroupShoppingListItemCategoryBatchUpdate>
      createElement() {
    return _GroupShoppingListItemCategoryBatchUpdateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupShoppingListItemCategoryBatchUpdateProvider &&
        other.groupID == groupID;
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
mixin GroupShoppingListItemCategoryBatchUpdateRef
    on AutoDisposeProviderRef<GroupShoppingListItemCategoryBatchUpdate> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupShoppingListItemCategoryBatchUpdateProviderElement
    extends AutoDisposeProviderElement<GroupShoppingListItemCategoryBatchUpdate>
    with GroupShoppingListItemCategoryBatchUpdateRef {
  _GroupShoppingListItemCategoryBatchUpdateProviderElement(super.provider);

  @override
  String get groupID =>
      (origin as GroupShoppingListItemCategoryBatchUpdateProvider).groupID;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
