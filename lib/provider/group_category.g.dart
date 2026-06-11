// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_category.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupCategoryAxesHash() => r'6c49d99fa772a78f3b4874d3cfa012b821992190';

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

/// See also [groupCategoryAxes].
@ProviderFor(groupCategoryAxes)
const groupCategoryAxesProvider = GroupCategoryAxesFamily();

/// See also [groupCategoryAxes].
class GroupCategoryAxesFamily
    extends Family<AsyncValue<List<GroupCategoryAxis>>> {
  /// See also [groupCategoryAxes].
  const GroupCategoryAxesFamily();

  /// See also [groupCategoryAxes].
  GroupCategoryAxesProvider call({
    required String groupID,
  }) {
    return GroupCategoryAxesProvider(
      groupID: groupID,
    );
  }

  @override
  GroupCategoryAxesProvider getProviderOverride(
    covariant GroupCategoryAxesProvider provider,
  ) {
    return call(
      groupID: provider.groupID,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    groupDatabaseProvider,
    userDatabaseProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    groupDatabaseProvider,
    ...?groupDatabaseProvider.allTransitiveDependencies,
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupCategoryAxesProvider';
}

/// See also [groupCategoryAxes].
class GroupCategoryAxesProvider
    extends AutoDisposeStreamProvider<List<GroupCategoryAxis>> {
  /// See also [groupCategoryAxes].
  GroupCategoryAxesProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupCategoryAxes(
            ref as GroupCategoryAxesRef,
            groupID: groupID,
          ),
          from: groupCategoryAxesProvider,
          name: r'groupCategoryAxesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupCategoryAxesHash,
          dependencies: GroupCategoryAxesFamily._dependencies,
          allTransitiveDependencies:
              GroupCategoryAxesFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupCategoryAxesProvider._internal(
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
    Stream<List<GroupCategoryAxis>> Function(GroupCategoryAxesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupCategoryAxesProvider._internal(
        (ref) => create(ref as GroupCategoryAxesRef),
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
  AutoDisposeStreamProviderElement<List<GroupCategoryAxis>> createElement() {
    return _GroupCategoryAxesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryAxesProvider && other.groupID == groupID;
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
mixin GroupCategoryAxesRef
    on AutoDisposeStreamProviderRef<List<GroupCategoryAxis>> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupCategoryAxesProviderElement
    extends AutoDisposeStreamProviderElement<List<GroupCategoryAxis>>
    with GroupCategoryAxesRef {
  _GroupCategoryAxesProviderElement(super.provider);

  @override
  String get groupID => (origin as GroupCategoryAxesProvider).groupID;
}

String _$groupCategoryAxisAddHash() =>
    r'42254d5778dd8761fb182c8890a73ba38eaec7dc';

/// See also [groupCategoryAxisAdd].
@ProviderFor(groupCategoryAxisAdd)
const groupCategoryAxisAddProvider = GroupCategoryAxisAddFamily();

/// See also [groupCategoryAxisAdd].
class GroupCategoryAxisAddFamily extends Family<GroupCategoryAxisAdd> {
  /// See also [groupCategoryAxisAdd].
  const GroupCategoryAxisAddFamily();

  /// See also [groupCategoryAxisAdd].
  GroupCategoryAxisAddProvider call({
    required String groupID,
  }) {
    return GroupCategoryAxisAddProvider(
      groupID: groupID,
    );
  }

  @override
  GroupCategoryAxisAddProvider getProviderOverride(
    covariant GroupCategoryAxisAddProvider provider,
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
  String? get name => r'groupCategoryAxisAddProvider';
}

/// See also [groupCategoryAxisAdd].
class GroupCategoryAxisAddProvider
    extends AutoDisposeProvider<GroupCategoryAxisAdd> {
  /// See also [groupCategoryAxisAdd].
  GroupCategoryAxisAddProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupCategoryAxisAdd(
            ref as GroupCategoryAxisAddRef,
            groupID: groupID,
          ),
          from: groupCategoryAxisAddProvider,
          name: r'groupCategoryAxisAddProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupCategoryAxisAddHash,
          dependencies: GroupCategoryAxisAddFamily._dependencies,
          allTransitiveDependencies:
              GroupCategoryAxisAddFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupCategoryAxisAddProvider._internal(
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
    GroupCategoryAxisAdd Function(GroupCategoryAxisAddRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupCategoryAxisAddProvider._internal(
        (ref) => create(ref as GroupCategoryAxisAddRef),
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
  AutoDisposeProviderElement<GroupCategoryAxisAdd> createElement() {
    return _GroupCategoryAxisAddProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryAxisAddProvider && other.groupID == groupID;
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
mixin GroupCategoryAxisAddRef on AutoDisposeProviderRef<GroupCategoryAxisAdd> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupCategoryAxisAddProviderElement
    extends AutoDisposeProviderElement<GroupCategoryAxisAdd>
    with GroupCategoryAxisAddRef {
  _GroupCategoryAxisAddProviderElement(super.provider);

  @override
  String get groupID => (origin as GroupCategoryAxisAddProvider).groupID;
}

String _$groupCategoryAxisDeleteHash() =>
    r'c0b68bb509392b5f1eaafe6b537e7e6091877003';

/// See also [groupCategoryAxisDelete].
@ProviderFor(groupCategoryAxisDelete)
const groupCategoryAxisDeleteProvider = GroupCategoryAxisDeleteFamily();

/// See also [groupCategoryAxisDelete].
class GroupCategoryAxisDeleteFamily extends Family<GroupCategoryAxisDelete> {
  /// See also [groupCategoryAxisDelete].
  const GroupCategoryAxisDeleteFamily();

  /// See also [groupCategoryAxisDelete].
  GroupCategoryAxisDeleteProvider call({
    required String groupID,
  }) {
    return GroupCategoryAxisDeleteProvider(
      groupID: groupID,
    );
  }

  @override
  GroupCategoryAxisDeleteProvider getProviderOverride(
    covariant GroupCategoryAxisDeleteProvider provider,
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
  String? get name => r'groupCategoryAxisDeleteProvider';
}

/// See also [groupCategoryAxisDelete].
class GroupCategoryAxisDeleteProvider
    extends AutoDisposeProvider<GroupCategoryAxisDelete> {
  /// See also [groupCategoryAxisDelete].
  GroupCategoryAxisDeleteProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupCategoryAxisDelete(
            ref as GroupCategoryAxisDeleteRef,
            groupID: groupID,
          ),
          from: groupCategoryAxisDeleteProvider,
          name: r'groupCategoryAxisDeleteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupCategoryAxisDeleteHash,
          dependencies: GroupCategoryAxisDeleteFamily._dependencies,
          allTransitiveDependencies:
              GroupCategoryAxisDeleteFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupCategoryAxisDeleteProvider._internal(
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
    GroupCategoryAxisDelete Function(GroupCategoryAxisDeleteRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupCategoryAxisDeleteProvider._internal(
        (ref) => create(ref as GroupCategoryAxisDeleteRef),
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
  AutoDisposeProviderElement<GroupCategoryAxisDelete> createElement() {
    return _GroupCategoryAxisDeleteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryAxisDeleteProvider && other.groupID == groupID;
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
mixin GroupCategoryAxisDeleteRef
    on AutoDisposeProviderRef<GroupCategoryAxisDelete> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupCategoryAxisDeleteProviderElement
    extends AutoDisposeProviderElement<GroupCategoryAxisDelete>
    with GroupCategoryAxisDeleteRef {
  _GroupCategoryAxisDeleteProviderElement(super.provider);

  @override
  String get groupID => (origin as GroupCategoryAxisDeleteProvider).groupID;
}

String _$groupCategoriesHash() => r'83b5669da9b319116992246e1d3efadc8f7faaf2';

/// See also [groupCategories].
@ProviderFor(groupCategories)
const groupCategoriesProvider = GroupCategoriesFamily();

/// See also [groupCategories].
class GroupCategoriesFamily extends Family<AsyncValue<List<GroupCategory>>> {
  /// See also [groupCategories].
  const GroupCategoriesFamily();

  /// See also [groupCategories].
  GroupCategoriesProvider call({
    required String groupID,
    required String categoryAxisID,
  }) {
    return GroupCategoriesProvider(
      groupID: groupID,
      categoryAxisID: categoryAxisID,
    );
  }

  @override
  GroupCategoriesProvider getProviderOverride(
    covariant GroupCategoriesProvider provider,
  ) {
    return call(
      groupID: provider.groupID,
      categoryAxisID: provider.categoryAxisID,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    groupDatabaseProvider,
    userDatabaseProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    groupDatabaseProvider,
    ...?groupDatabaseProvider.allTransitiveDependencies,
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupCategoriesProvider';
}

/// See also [groupCategories].
class GroupCategoriesProvider
    extends AutoDisposeStreamProvider<List<GroupCategory>> {
  /// See also [groupCategories].
  GroupCategoriesProvider({
    required String groupID,
    required String categoryAxisID,
  }) : this._internal(
          (ref) => groupCategories(
            ref as GroupCategoriesRef,
            groupID: groupID,
            categoryAxisID: categoryAxisID,
          ),
          from: groupCategoriesProvider,
          name: r'groupCategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupCategoriesHash,
          dependencies: GroupCategoriesFamily._dependencies,
          allTransitiveDependencies:
              GroupCategoriesFamily._allTransitiveDependencies,
          groupID: groupID,
          categoryAxisID: categoryAxisID,
        );

  GroupCategoriesProvider._internal(
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
    Stream<List<GroupCategory>> Function(GroupCategoriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupCategoriesProvider._internal(
        (ref) => create(ref as GroupCategoriesRef),
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
  AutoDisposeStreamProviderElement<List<GroupCategory>> createElement() {
    return _GroupCategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoriesProvider &&
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
mixin GroupCategoriesRef on AutoDisposeStreamProviderRef<List<GroupCategory>> {
  /// The parameter `groupID` of this provider.
  String get groupID;

  /// The parameter `categoryAxisID` of this provider.
  String get categoryAxisID;
}

class _GroupCategoriesProviderElement
    extends AutoDisposeStreamProviderElement<List<GroupCategory>>
    with GroupCategoriesRef {
  _GroupCategoriesProviderElement(super.provider);

  @override
  String get groupID => (origin as GroupCategoriesProvider).groupID;
  @override
  String get categoryAxisID =>
      (origin as GroupCategoriesProvider).categoryAxisID;
}

String _$groupCategoryAddHash() => r'7b6ae53a4483afe2d9f1c167d366a6ac6e87bfdc';

/// See also [groupCategoryAdd].
@ProviderFor(groupCategoryAdd)
const groupCategoryAddProvider = GroupCategoryAddFamily();

/// See also [groupCategoryAdd].
class GroupCategoryAddFamily extends Family<GroupCategoryAdd> {
  /// See also [groupCategoryAdd].
  const GroupCategoryAddFamily();

  /// See also [groupCategoryAdd].
  GroupCategoryAddProvider call({
    required String groupID,
  }) {
    return GroupCategoryAddProvider(
      groupID: groupID,
    );
  }

  @override
  GroupCategoryAddProvider getProviderOverride(
    covariant GroupCategoryAddProvider provider,
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
  String? get name => r'groupCategoryAddProvider';
}

/// See also [groupCategoryAdd].
class GroupCategoryAddProvider extends AutoDisposeProvider<GroupCategoryAdd> {
  /// See also [groupCategoryAdd].
  GroupCategoryAddProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupCategoryAdd(
            ref as GroupCategoryAddRef,
            groupID: groupID,
          ),
          from: groupCategoryAddProvider,
          name: r'groupCategoryAddProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupCategoryAddHash,
          dependencies: GroupCategoryAddFamily._dependencies,
          allTransitiveDependencies:
              GroupCategoryAddFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupCategoryAddProvider._internal(
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
    GroupCategoryAdd Function(GroupCategoryAddRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupCategoryAddProvider._internal(
        (ref) => create(ref as GroupCategoryAddRef),
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
  AutoDisposeProviderElement<GroupCategoryAdd> createElement() {
    return _GroupCategoryAddProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryAddProvider && other.groupID == groupID;
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
mixin GroupCategoryAddRef on AutoDisposeProviderRef<GroupCategoryAdd> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupCategoryAddProviderElement
    extends AutoDisposeProviderElement<GroupCategoryAdd>
    with GroupCategoryAddRef {
  _GroupCategoryAddProviderElement(super.provider);

  @override
  String get groupID => (origin as GroupCategoryAddProvider).groupID;
}

String _$groupCategoryUpdateHash() =>
    r'f29ef09ff481015f44999f6847d63c6686fd60f1';

/// See also [groupCategoryUpdate].
@ProviderFor(groupCategoryUpdate)
const groupCategoryUpdateProvider = GroupCategoryUpdateFamily();

/// See also [groupCategoryUpdate].
class GroupCategoryUpdateFamily extends Family<GroupCategoryUpdate> {
  /// See also [groupCategoryUpdate].
  const GroupCategoryUpdateFamily();

  /// See also [groupCategoryUpdate].
  GroupCategoryUpdateProvider call({
    required String groupID,
  }) {
    return GroupCategoryUpdateProvider(
      groupID: groupID,
    );
  }

  @override
  GroupCategoryUpdateProvider getProviderOverride(
    covariant GroupCategoryUpdateProvider provider,
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
  String? get name => r'groupCategoryUpdateProvider';
}

/// See also [groupCategoryUpdate].
class GroupCategoryUpdateProvider
    extends AutoDisposeProvider<GroupCategoryUpdate> {
  /// See also [groupCategoryUpdate].
  GroupCategoryUpdateProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupCategoryUpdate(
            ref as GroupCategoryUpdateRef,
            groupID: groupID,
          ),
          from: groupCategoryUpdateProvider,
          name: r'groupCategoryUpdateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupCategoryUpdateHash,
          dependencies: GroupCategoryUpdateFamily._dependencies,
          allTransitiveDependencies:
              GroupCategoryUpdateFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupCategoryUpdateProvider._internal(
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
    GroupCategoryUpdate Function(GroupCategoryUpdateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupCategoryUpdateProvider._internal(
        (ref) => create(ref as GroupCategoryUpdateRef),
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
  AutoDisposeProviderElement<GroupCategoryUpdate> createElement() {
    return _GroupCategoryUpdateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryUpdateProvider && other.groupID == groupID;
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
mixin GroupCategoryUpdateRef on AutoDisposeProviderRef<GroupCategoryUpdate> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupCategoryUpdateProviderElement
    extends AutoDisposeProviderElement<GroupCategoryUpdate>
    with GroupCategoryUpdateRef {
  _GroupCategoryUpdateProviderElement(super.provider);

  @override
  String get groupID => (origin as GroupCategoryUpdateProvider).groupID;
}

String _$groupCategoryDeleteHash() =>
    r'cdb3eb76537d83d87349546fe68d5f38b8b476d3';

/// See also [groupCategoryDelete].
@ProviderFor(groupCategoryDelete)
const groupCategoryDeleteProvider = GroupCategoryDeleteFamily();

/// See also [groupCategoryDelete].
class GroupCategoryDeleteFamily extends Family<GroupCategoryDelete> {
  /// See also [groupCategoryDelete].
  const GroupCategoryDeleteFamily();

  /// See also [groupCategoryDelete].
  GroupCategoryDeleteProvider call({
    required String groupID,
  }) {
    return GroupCategoryDeleteProvider(
      groupID: groupID,
    );
  }

  @override
  GroupCategoryDeleteProvider getProviderOverride(
    covariant GroupCategoryDeleteProvider provider,
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
  String? get name => r'groupCategoryDeleteProvider';
}

/// See also [groupCategoryDelete].
class GroupCategoryDeleteProvider
    extends AutoDisposeProvider<GroupCategoryDelete> {
  /// See also [groupCategoryDelete].
  GroupCategoryDeleteProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupCategoryDelete(
            ref as GroupCategoryDeleteRef,
            groupID: groupID,
          ),
          from: groupCategoryDeleteProvider,
          name: r'groupCategoryDeleteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupCategoryDeleteHash,
          dependencies: GroupCategoryDeleteFamily._dependencies,
          allTransitiveDependencies:
              GroupCategoryDeleteFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupCategoryDeleteProvider._internal(
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
    GroupCategoryDelete Function(GroupCategoryDeleteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupCategoryDeleteProvider._internal(
        (ref) => create(ref as GroupCategoryDeleteRef),
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
  AutoDisposeProviderElement<GroupCategoryDelete> createElement() {
    return _GroupCategoryDeleteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryDeleteProvider && other.groupID == groupID;
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
mixin GroupCategoryDeleteRef on AutoDisposeProviderRef<GroupCategoryDelete> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupCategoryDeleteProviderElement
    extends AutoDisposeProviderElement<GroupCategoryDelete>
    with GroupCategoryDeleteRef {
  _GroupCategoryDeleteProviderElement(super.provider);

  @override
  String get groupID => (origin as GroupCategoryDeleteProvider).groupID;
}

String _$groupCategoryBatchUpdateHash() =>
    r'a70103975b726e18559c9af0b31883446a72053f';

/// See also [groupCategoryBatchUpdate].
@ProviderFor(groupCategoryBatchUpdate)
const groupCategoryBatchUpdateProvider = GroupCategoryBatchUpdateFamily();

/// See also [groupCategoryBatchUpdate].
class GroupCategoryBatchUpdateFamily extends Family<GroupCategoryBatchUpdate> {
  /// See also [groupCategoryBatchUpdate].
  const GroupCategoryBatchUpdateFamily();

  /// See also [groupCategoryBatchUpdate].
  GroupCategoryBatchUpdateProvider call({
    required String groupID,
  }) {
    return GroupCategoryBatchUpdateProvider(
      groupID: groupID,
    );
  }

  @override
  GroupCategoryBatchUpdateProvider getProviderOverride(
    covariant GroupCategoryBatchUpdateProvider provider,
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
  String? get name => r'groupCategoryBatchUpdateProvider';
}

/// See also [groupCategoryBatchUpdate].
class GroupCategoryBatchUpdateProvider
    extends AutoDisposeProvider<GroupCategoryBatchUpdate> {
  /// See also [groupCategoryBatchUpdate].
  GroupCategoryBatchUpdateProvider({
    required String groupID,
  }) : this._internal(
          (ref) => groupCategoryBatchUpdate(
            ref as GroupCategoryBatchUpdateRef,
            groupID: groupID,
          ),
          from: groupCategoryBatchUpdateProvider,
          name: r'groupCategoryBatchUpdateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupCategoryBatchUpdateHash,
          dependencies: GroupCategoryBatchUpdateFamily._dependencies,
          allTransitiveDependencies:
              GroupCategoryBatchUpdateFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  GroupCategoryBatchUpdateProvider._internal(
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
    GroupCategoryBatchUpdate Function(GroupCategoryBatchUpdateRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupCategoryBatchUpdateProvider._internal(
        (ref) => create(ref as GroupCategoryBatchUpdateRef),
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
  AutoDisposeProviderElement<GroupCategoryBatchUpdate> createElement() {
    return _GroupCategoryBatchUpdateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryBatchUpdateProvider &&
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
mixin GroupCategoryBatchUpdateRef
    on AutoDisposeProviderRef<GroupCategoryBatchUpdate> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _GroupCategoryBatchUpdateProviderElement
    extends AutoDisposeProviderElement<GroupCategoryBatchUpdate>
    with GroupCategoryBatchUpdateRef {
  _GroupCategoryBatchUpdateProviderElement(super.provider);

  @override
  String get groupID => (origin as GroupCategoryBatchUpdateProvider).groupID;
}

String _$aiCategorizeApplyHash() => r'a841b666e6f93a6712cfc631d9b3dc5dba3df204';

/// See also [aiCategorizeApply].
@ProviderFor(aiCategorizeApply)
const aiCategorizeApplyProvider = AiCategorizeApplyFamily();

/// See also [aiCategorizeApply].
class AiCategorizeApplyFamily extends Family<AICategorizeApply> {
  /// See also [aiCategorizeApply].
  const AiCategorizeApplyFamily();

  /// See also [aiCategorizeApply].
  AiCategorizeApplyProvider call({
    required String groupID,
  }) {
    return AiCategorizeApplyProvider(
      groupID: groupID,
    );
  }

  @override
  AiCategorizeApplyProvider getProviderOverride(
    covariant AiCategorizeApplyProvider provider,
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
  String? get name => r'aiCategorizeApplyProvider';
}

/// See also [aiCategorizeApply].
class AiCategorizeApplyProvider extends AutoDisposeProvider<AICategorizeApply> {
  /// See also [aiCategorizeApply].
  AiCategorizeApplyProvider({
    required String groupID,
  }) : this._internal(
          (ref) => aiCategorizeApply(
            ref as AiCategorizeApplyRef,
            groupID: groupID,
          ),
          from: aiCategorizeApplyProvider,
          name: r'aiCategorizeApplyProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$aiCategorizeApplyHash,
          dependencies: AiCategorizeApplyFamily._dependencies,
          allTransitiveDependencies:
              AiCategorizeApplyFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  AiCategorizeApplyProvider._internal(
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
    AICategorizeApply Function(AiCategorizeApplyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AiCategorizeApplyProvider._internal(
        (ref) => create(ref as AiCategorizeApplyRef),
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
  AutoDisposeProviderElement<AICategorizeApply> createElement() {
    return _AiCategorizeApplyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AiCategorizeApplyProvider && other.groupID == groupID;
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
mixin AiCategorizeApplyRef on AutoDisposeProviderRef<AICategorizeApply> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _AiCategorizeApplyProviderElement
    extends AutoDisposeProviderElement<AICategorizeApply>
    with AiCategorizeApplyRef {
  _AiCategorizeApplyProviderElement(super.provider);

  @override
  String get groupID => (origin as AiCategorizeApplyProvider).groupID;
}

String _$moveItemCategoryKeywordHash() =>
    r'90d6a93a3f3ded7817a269f24d5b1596a077c413';

/// See also [moveItemCategoryKeyword].
@ProviderFor(moveItemCategoryKeyword)
const moveItemCategoryKeywordProvider = MoveItemCategoryKeywordFamily();

/// See also [moveItemCategoryKeyword].
class MoveItemCategoryKeywordFamily extends Family<MoveItemCategoryKeyword> {
  /// See also [moveItemCategoryKeyword].
  const MoveItemCategoryKeywordFamily();

  /// See also [moveItemCategoryKeyword].
  MoveItemCategoryKeywordProvider call({
    required String groupID,
  }) {
    return MoveItemCategoryKeywordProvider(
      groupID: groupID,
    );
  }

  @override
  MoveItemCategoryKeywordProvider getProviderOverride(
    covariant MoveItemCategoryKeywordProvider provider,
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
  String? get name => r'moveItemCategoryKeywordProvider';
}

/// See also [moveItemCategoryKeyword].
class MoveItemCategoryKeywordProvider
    extends AutoDisposeProvider<MoveItemCategoryKeyword> {
  /// See also [moveItemCategoryKeyword].
  MoveItemCategoryKeywordProvider({
    required String groupID,
  }) : this._internal(
          (ref) => moveItemCategoryKeyword(
            ref as MoveItemCategoryKeywordRef,
            groupID: groupID,
          ),
          from: moveItemCategoryKeywordProvider,
          name: r'moveItemCategoryKeywordProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$moveItemCategoryKeywordHash,
          dependencies: MoveItemCategoryKeywordFamily._dependencies,
          allTransitiveDependencies:
              MoveItemCategoryKeywordFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  MoveItemCategoryKeywordProvider._internal(
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
    MoveItemCategoryKeyword Function(MoveItemCategoryKeywordRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MoveItemCategoryKeywordProvider._internal(
        (ref) => create(ref as MoveItemCategoryKeywordRef),
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
  AutoDisposeProviderElement<MoveItemCategoryKeyword> createElement() {
    return _MoveItemCategoryKeywordProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MoveItemCategoryKeywordProvider && other.groupID == groupID;
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
mixin MoveItemCategoryKeywordRef
    on AutoDisposeProviderRef<MoveItemCategoryKeyword> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _MoveItemCategoryKeywordProviderElement
    extends AutoDisposeProviderElement<MoveItemCategoryKeyword>
    with MoveItemCategoryKeywordRef {
  _MoveItemCategoryKeywordProviderElement(super.provider);

  @override
  String get groupID => (origin as MoveItemCategoryKeywordProvider).groupID;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
