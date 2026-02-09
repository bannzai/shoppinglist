// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shoppingListsHash() => r'4cc92a414f44ffe552d13422b0fe01076af28176';

/// See also [shoppingLists].
@ProviderFor(shoppingLists)
final shoppingListsProvider =
    AutoDisposeStreamProvider<List<GroupShoppingList>>.internal(
  shoppingLists,
  name: r'shoppingListsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shoppingListsHash,
  dependencies: <ProviderOrFamily>[groupDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    groupDatabaseProvider,
    ...?groupDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShoppingListsRef
    = AutoDisposeStreamProviderRef<List<GroupShoppingList>>;
String _$shoppingListAddHash() => r'd8132db83f3db4de1e739825445e18bbb812f796';

/// See also [shoppingListAdd].
@ProviderFor(shoppingListAdd)
final shoppingListAddProvider = AutoDisposeProvider<ShoppingListAdd>.internal(
  shoppingListAdd,
  name: r'shoppingListAddProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shoppingListAddHash,
  dependencies: <ProviderOrFamily>[groupDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    groupDatabaseProvider,
    ...?groupDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShoppingListAddRef = AutoDisposeProviderRef<ShoppingListAdd>;
String _$shoppingListDeleteHash() =>
    r'3026f09603b1271e29bb65793c10bba0e62c6574';

/// See also [shoppingListDelete].
@ProviderFor(shoppingListDelete)
final shoppingListDeleteProvider =
    AutoDisposeProvider<ShoppingListDelete>.internal(
  shoppingListDelete,
  name: r'shoppingListDeleteProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shoppingListDeleteHash,
  dependencies: <ProviderOrFamily>[groupDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    groupDatabaseProvider,
    ...?groupDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShoppingListDeleteRef = AutoDisposeProviderRef<ShoppingListDelete>;
String _$shoppingListUpdateHash() =>
    r'964c89845817010b884905b247391fc8fabb7511';

/// See also [shoppingListUpdate].
@ProviderFor(shoppingListUpdate)
final shoppingListUpdateProvider =
    AutoDisposeProvider<ShoppingListUpdate>.internal(
  shoppingListUpdate,
  name: r'shoppingListUpdateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shoppingListUpdateHash,
  dependencies: <ProviderOrFamily>[groupDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    groupDatabaseProvider,
    ...?groupDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShoppingListUpdateRef = AutoDisposeProviderRef<ShoppingListUpdate>;
String _$shoppingListDuplicateHash() =>
    r'56b508ddc6797e953f4f128398b82afa0bb5c25e';

/// See also [shoppingListDuplicate].
@ProviderFor(shoppingListDuplicate)
final shoppingListDuplicateProvider =
    AutoDisposeProvider<ShoppingListDuplicate>.internal(
  shoppingListDuplicate,
  name: r'shoppingListDuplicateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shoppingListDuplicateHash,
  dependencies: <ProviderOrFamily>[
    shoppingListAddProvider,
    addTextShoppingListItemProvider,
    groupDatabaseProvider
  ],
  allTransitiveDependencies: <ProviderOrFamily>{
    shoppingListAddProvider,
    ...?shoppingListAddProvider.allTransitiveDependencies,
    addTextShoppingListItemProvider,
    ...?addTextShoppingListItemProvider.allTransitiveDependencies,
    groupDatabaseProvider,
    ...?groupDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShoppingListDuplicateRef
    = AutoDisposeProviderRef<ShoppingListDuplicate>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
