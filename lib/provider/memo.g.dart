// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memosHash() => r'01948d83c6718db2aee22fed29b3d04303f4ed7d';

/// See also [memos].
@ProviderFor(memos)
final memosProvider = AutoDisposeStreamProvider<Memo?>.internal(
  memos,
  name: r'memosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$memosHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{userDatabaseProvider, ...?userDatabaseProvider.allTransitiveDependencies},
);

typedef MemosRef = AutoDisposeStreamProviderRef<Memo?>;
String _$shoppingListMemoHash() => r'e1a6b7b1a445f32ddf8bf4cf49eeab832c9f5f6a';

/// See also [shoppingListMemo].
@ProviderFor(shoppingListMemo)
final shoppingListMemoProvider = AutoDisposeStreamProvider<Memo?>.internal(
  shoppingListMemo,
  name: r'shoppingListMemoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$shoppingListMemoHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{userDatabaseProvider, ...?userDatabaseProvider.allTransitiveDependencies},
);

typedef ShoppingListMemoRef = AutoDisposeStreamProviderRef<Memo?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
