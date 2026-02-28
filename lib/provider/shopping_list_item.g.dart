// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_item.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$textShoppingListItemsHash() =>
    r'd26df9c9516204a1724030165b0997975c5a7741';

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

/// See also [textShoppingListItems].
@ProviderFor(textShoppingListItems)
const textShoppingListItemsProvider = TextShoppingListItemsFamily();

/// See also [textShoppingListItems].
class TextShoppingListItemsFamily
    extends Family<AsyncValue<List<GroupShoppingListItem>>> {
  /// See also [textShoppingListItems].
  const TextShoppingListItemsFamily();

  /// See also [textShoppingListItems].
  TextShoppingListItemsProvider call({
    required String groupID,
    required String shoppingListID,
    required bool showChecked,
  }) {
    return TextShoppingListItemsProvider(
      groupID: groupID,
      shoppingListID: shoppingListID,
      showChecked: showChecked,
    );
  }

  @override
  TextShoppingListItemsProvider getProviderOverride(
    covariant TextShoppingListItemsProvider provider,
  ) {
    return call(
      groupID: provider.groupID,
      shoppingListID: provider.shoppingListID,
      showChecked: provider.showChecked,
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
  String? get name => r'textShoppingListItemsProvider';
}

/// See also [textShoppingListItems].
class TextShoppingListItemsProvider
    extends AutoDisposeStreamProvider<List<GroupShoppingListItem>> {
  /// See also [textShoppingListItems].
  TextShoppingListItemsProvider({
    required String groupID,
    required String shoppingListID,
    required bool showChecked,
  }) : this._internal(
          (ref) => textShoppingListItems(
            ref as TextShoppingListItemsRef,
            groupID: groupID,
            shoppingListID: shoppingListID,
            showChecked: showChecked,
          ),
          from: textShoppingListItemsProvider,
          name: r'textShoppingListItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$textShoppingListItemsHash,
          dependencies: TextShoppingListItemsFamily._dependencies,
          allTransitiveDependencies:
              TextShoppingListItemsFamily._allTransitiveDependencies,
          groupID: groupID,
          shoppingListID: shoppingListID,
          showChecked: showChecked,
        );

  TextShoppingListItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupID,
    required this.shoppingListID,
    required this.showChecked,
  }) : super.internal();

  final String groupID;
  final String shoppingListID;
  final bool showChecked;

  @override
  Override overrideWith(
    Stream<List<GroupShoppingListItem>> Function(
            TextShoppingListItemsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TextShoppingListItemsProvider._internal(
        (ref) => create(ref as TextShoppingListItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupID: groupID,
        shoppingListID: shoppingListID,
        showChecked: showChecked,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<GroupShoppingListItem>>
      createElement() {
    return _TextShoppingListItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TextShoppingListItemsProvider &&
        other.groupID == groupID &&
        other.shoppingListID == shoppingListID &&
        other.showChecked == showChecked;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupID.hashCode);
    hash = _SystemHash.combine(hash, shoppingListID.hashCode);
    hash = _SystemHash.combine(hash, showChecked.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TextShoppingListItemsRef
    on AutoDisposeStreamProviderRef<List<GroupShoppingListItem>> {
  /// The parameter `groupID` of this provider.
  String get groupID;

  /// The parameter `shoppingListID` of this provider.
  String get shoppingListID;

  /// The parameter `showChecked` of this provider.
  bool get showChecked;
}

class _TextShoppingListItemsProviderElement
    extends AutoDisposeStreamProviderElement<List<GroupShoppingListItem>>
    with TextShoppingListItemsRef {
  _TextShoppingListItemsProviderElement(super.provider);

  @override
  String get groupID => (origin as TextShoppingListItemsProvider).groupID;
  @override
  String get shoppingListID =>
      (origin as TextShoppingListItemsProvider).shoppingListID;
  @override
  bool get showChecked => (origin as TextShoppingListItemsProvider).showChecked;
}

String _$addShoppingListItemHash() =>
    r'7d38d2babe2ea031c73cd31707eedf63d6163a2a';

/// See also [addShoppingListItem].
@ProviderFor(addShoppingListItem)
const addShoppingListItemProvider = AddShoppingListItemFamily();

/// See also [addShoppingListItem].
class AddShoppingListItemFamily extends Family<AddShoppingListItem> {
  /// See also [addShoppingListItem].
  const AddShoppingListItemFamily();

  /// See also [addShoppingListItem].
  AddShoppingListItemProvider call({
    required String groupID,
  }) {
    return AddShoppingListItemProvider(
      groupID: groupID,
    );
  }

  @override
  AddShoppingListItemProvider getProviderOverride(
    covariant AddShoppingListItemProvider provider,
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
  String? get name => r'addShoppingListItemProvider';
}

/// See also [addShoppingListItem].
class AddShoppingListItemProvider
    extends AutoDisposeProvider<AddShoppingListItem> {
  /// See also [addShoppingListItem].
  AddShoppingListItemProvider({
    required String groupID,
  }) : this._internal(
          (ref) => addShoppingListItem(
            ref as AddShoppingListItemRef,
            groupID: groupID,
          ),
          from: addShoppingListItemProvider,
          name: r'addShoppingListItemProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$addShoppingListItemHash,
          dependencies: AddShoppingListItemFamily._dependencies,
          allTransitiveDependencies:
              AddShoppingListItemFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  AddShoppingListItemProvider._internal(
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
    AddShoppingListItem Function(AddShoppingListItemRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AddShoppingListItemProvider._internal(
        (ref) => create(ref as AddShoppingListItemRef),
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
  AutoDisposeProviderElement<AddShoppingListItem> createElement() {
    return _AddShoppingListItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AddShoppingListItemProvider && other.groupID == groupID;
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
mixin AddShoppingListItemRef on AutoDisposeProviderRef<AddShoppingListItem> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _AddShoppingListItemProviderElement
    extends AutoDisposeProviderElement<AddShoppingListItem>
    with AddShoppingListItemRef {
  _AddShoppingListItemProviderElement(super.provider);

  @override
  String get groupID => (origin as AddShoppingListItemProvider).groupID;
}

String _$shoppingListItemBatchUpdateHash() =>
    r'd1d20f2dc3ac6e9a43e79e02e7d3d6d2e4f2ca09';

/// See also [shoppingListItemBatchUpdate].
@ProviderFor(shoppingListItemBatchUpdate)
const shoppingListItemBatchUpdateProvider = ShoppingListItemBatchUpdateFamily();

/// See also [shoppingListItemBatchUpdate].
class ShoppingListItemBatchUpdateFamily
    extends Family<ShoppingListItemBatchUpdate> {
  /// See also [shoppingListItemBatchUpdate].
  const ShoppingListItemBatchUpdateFamily();

  /// See also [shoppingListItemBatchUpdate].
  ShoppingListItemBatchUpdateProvider call({
    required String groupID,
  }) {
    return ShoppingListItemBatchUpdateProvider(
      groupID: groupID,
    );
  }

  @override
  ShoppingListItemBatchUpdateProvider getProviderOverride(
    covariant ShoppingListItemBatchUpdateProvider provider,
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
  String? get name => r'shoppingListItemBatchUpdateProvider';
}

/// See also [shoppingListItemBatchUpdate].
class ShoppingListItemBatchUpdateProvider
    extends AutoDisposeProvider<ShoppingListItemBatchUpdate> {
  /// See also [shoppingListItemBatchUpdate].
  ShoppingListItemBatchUpdateProvider({
    required String groupID,
  }) : this._internal(
          (ref) => shoppingListItemBatchUpdate(
            ref as ShoppingListItemBatchUpdateRef,
            groupID: groupID,
          ),
          from: shoppingListItemBatchUpdateProvider,
          name: r'shoppingListItemBatchUpdateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shoppingListItemBatchUpdateHash,
          dependencies: ShoppingListItemBatchUpdateFamily._dependencies,
          allTransitiveDependencies:
              ShoppingListItemBatchUpdateFamily._allTransitiveDependencies,
          groupID: groupID,
        );

  ShoppingListItemBatchUpdateProvider._internal(
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
    ShoppingListItemBatchUpdate Function(
            ShoppingListItemBatchUpdateRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShoppingListItemBatchUpdateProvider._internal(
        (ref) => create(ref as ShoppingListItemBatchUpdateRef),
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
  AutoDisposeProviderElement<ShoppingListItemBatchUpdate> createElement() {
    return _ShoppingListItemBatchUpdateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingListItemBatchUpdateProvider &&
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
mixin ShoppingListItemBatchUpdateRef
    on AutoDisposeProviderRef<ShoppingListItemBatchUpdate> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _ShoppingListItemBatchUpdateProviderElement
    extends AutoDisposeProviderElement<ShoppingListItemBatchUpdate>
    with ShoppingListItemBatchUpdateRef {
  _ShoppingListItemBatchUpdateProviderElement(super.provider);

  @override
  String get groupID => (origin as ShoppingListItemBatchUpdateProvider).groupID;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
