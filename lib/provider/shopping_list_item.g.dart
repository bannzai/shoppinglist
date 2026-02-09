// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_item.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$textShoppingListItemsHash() =>
    r'16b954d570880311023efacebe95b890842ec067';

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
    extends Family<AsyncValue<List<ShoppingListItem>>> {
  /// See also [textShoppingListItems].
  const TextShoppingListItemsFamily();

  /// See also [textShoppingListItems].
  TextShoppingListItemsProvider call({
    required String shoppingListID,
    required bool showChecked,
  }) {
    return TextShoppingListItemsProvider(
      shoppingListID: shoppingListID,
      showChecked: showChecked,
    );
  }

  @override
  TextShoppingListItemsProvider getProviderOverride(
    covariant TextShoppingListItemsProvider provider,
  ) {
    return call(
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
    extends AutoDisposeStreamProvider<List<ShoppingListItem>> {
  /// See also [textShoppingListItems].
  TextShoppingListItemsProvider({
    required String shoppingListID,
    required bool showChecked,
  }) : this._internal(
          (ref) => textShoppingListItems(
            ref as TextShoppingListItemsRef,
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
    required this.shoppingListID,
    required this.showChecked,
  }) : super.internal();

  final String shoppingListID;
  final bool showChecked;

  @override
  Override overrideWith(
    Stream<List<ShoppingListItem>> Function(TextShoppingListItemsRef provider)
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
        shoppingListID: shoppingListID,
        showChecked: showChecked,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ShoppingListItem>> createElement() {
    return _TextShoppingListItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TextShoppingListItemsProvider &&
        other.shoppingListID == shoppingListID &&
        other.showChecked == showChecked;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shoppingListID.hashCode);
    hash = _SystemHash.combine(hash, showChecked.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TextShoppingListItemsRef
    on AutoDisposeStreamProviderRef<List<ShoppingListItem>> {
  /// The parameter `shoppingListID` of this provider.
  String get shoppingListID;

  /// The parameter `showChecked` of this provider.
  bool get showChecked;
}

class _TextShoppingListItemsProviderElement
    extends AutoDisposeStreamProviderElement<List<ShoppingListItem>>
    with TextShoppingListItemsRef {
  _TextShoppingListItemsProviderElement(super.provider);

  @override
  String get shoppingListID =>
      (origin as TextShoppingListItemsProvider).shoppingListID;
  @override
  bool get showChecked => (origin as TextShoppingListItemsProvider).showChecked;
}

String _$linkShoppingListItemsHash() =>
    r'd6a1d3dc504394cca526db32fe6ffb5f895ca88d';

/// See also [linkShoppingListItems].
@ProviderFor(linkShoppingListItems)
const linkShoppingListItemsProvider = LinkShoppingListItemsFamily();

/// See also [linkShoppingListItems].
class LinkShoppingListItemsFamily
    extends Family<AsyncValue<List<ShoppingListItem>>> {
  /// See also [linkShoppingListItems].
  const LinkShoppingListItemsFamily();

  /// See also [linkShoppingListItems].
  LinkShoppingListItemsProvider call({
    required String shoppingListID,
  }) {
    return LinkShoppingListItemsProvider(
      shoppingListID: shoppingListID,
    );
  }

  @override
  LinkShoppingListItemsProvider getProviderOverride(
    covariant LinkShoppingListItemsProvider provider,
  ) {
    return call(
      shoppingListID: provider.shoppingListID,
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
  String? get name => r'linkShoppingListItemsProvider';
}

/// See also [linkShoppingListItems].
class LinkShoppingListItemsProvider
    extends AutoDisposeStreamProvider<List<ShoppingListItem>> {
  /// See also [linkShoppingListItems].
  LinkShoppingListItemsProvider({
    required String shoppingListID,
  }) : this._internal(
          (ref) => linkShoppingListItems(
            ref as LinkShoppingListItemsRef,
            shoppingListID: shoppingListID,
          ),
          from: linkShoppingListItemsProvider,
          name: r'linkShoppingListItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$linkShoppingListItemsHash,
          dependencies: LinkShoppingListItemsFamily._dependencies,
          allTransitiveDependencies:
              LinkShoppingListItemsFamily._allTransitiveDependencies,
          shoppingListID: shoppingListID,
        );

  LinkShoppingListItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shoppingListID,
  }) : super.internal();

  final String shoppingListID;

  @override
  Override overrideWith(
    Stream<List<ShoppingListItem>> Function(LinkShoppingListItemsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LinkShoppingListItemsProvider._internal(
        (ref) => create(ref as LinkShoppingListItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shoppingListID: shoppingListID,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ShoppingListItem>> createElement() {
    return _LinkShoppingListItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LinkShoppingListItemsProvider &&
        other.shoppingListID == shoppingListID;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shoppingListID.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LinkShoppingListItemsRef
    on AutoDisposeStreamProviderRef<List<ShoppingListItem>> {
  /// The parameter `shoppingListID` of this provider.
  String get shoppingListID;
}

class _LinkShoppingListItemsProviderElement
    extends AutoDisposeStreamProviderElement<List<ShoppingListItem>>
    with LinkShoppingListItemsRef {
  _LinkShoppingListItemsProviderElement(super.provider);

  @override
  String get shoppingListID =>
      (origin as LinkShoppingListItemsProvider).shoppingListID;
}

String _$addTextShoppingListItemHash() =>
    r'c13c52ec983492a12baa839bd0c22be21dbd7b4a';

/// See also [addTextShoppingListItem].
@ProviderFor(addTextShoppingListItem)
final addTextShoppingListItemProvider =
    AutoDisposeProvider<AddTextShoppingListItem>.internal(
  addTextShoppingListItem,
  name: r'addTextShoppingListItemProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$addTextShoppingListItemHash,
  dependencies: <ProviderOrFamily>[groupDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    groupDatabaseProvider,
    ...?groupDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddTextShoppingListItemRef
    = AutoDisposeProviderRef<AddTextShoppingListItem>;
String _$addLinkShoppingListItemHash() =>
    r'af4e6816fa9489dcbda95365d6ade58948a551e2';

/// See also [addLinkShoppingListItem].
@ProviderFor(addLinkShoppingListItem)
final addLinkShoppingListItemProvider =
    AutoDisposeProvider<AddLinkShoppingListItem>.internal(
  addLinkShoppingListItem,
  name: r'addLinkShoppingListItemProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$addLinkShoppingListItemHash,
  dependencies: <ProviderOrFamily>[groupDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    groupDatabaseProvider,
    ...?groupDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddLinkShoppingListItemRef
    = AutoDisposeProviderRef<AddLinkShoppingListItem>;
String _$shoppingListItemBatchUpdateHash() =>
    r'06d9716bfe611a03b60dfa94b697ce482c9471ef';

/// See also [shoppingListItemBatchUpdate].
@ProviderFor(shoppingListItemBatchUpdate)
final shoppingListItemBatchUpdateProvider =
    AutoDisposeProvider<ShoppingListItemBatchUpdate>.internal(
  shoppingListItemBatchUpdate,
  name: r'shoppingListItemBatchUpdateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shoppingListItemBatchUpdateHash,
  dependencies: <ProviderOrFamily>[groupDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    groupDatabaseProvider,
    ...?groupDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShoppingListItemBatchUpdateRef
    = AutoDisposeProviderRef<ShoppingListItemBatchUpdate>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
