// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memosHash() => r'6aa73abb6f8ee9bcca2e81831d86a2f484d02639';

/// See also [memos].
@ProviderFor(memos)
final memosProvider = AutoDisposeStreamProvider<List<Memo>>.internal(
  memos,
  name: r'memosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$memosHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{userDatabaseProvider, ...?userDatabaseProvider.allTransitiveDependencies},
);

typedef MemosRef = AutoDisposeStreamProviderRef<List<Memo>>;
String _$memoAddHash() => r'3b8418ed6fc934fe6397c5d0f019c2865153a9d2';

/// See also [memoAdd].
@ProviderFor(memoAdd)
final memoAddProvider = AutoDisposeProvider<MemoAdd>.internal(
  memoAdd,
  name: r'memoAddProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$memoAddHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{userDatabaseProvider, ...?userDatabaseProvider.allTransitiveDependencies},
);

typedef MemoAddRef = AutoDisposeProviderRef<MemoAdd>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
