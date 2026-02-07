// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memosHash() => r'8ffbb1d05ecbb91e844a19fa2ef4fd937c6f52ae';

/// See also [memos].
@ProviderFor(memos)
final memosProvider = AutoDisposeStreamProvider<List<Memo>>.internal(
  memos,
  name: r'memosProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$memosHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemosRef = AutoDisposeStreamProviderRef<List<Memo>>;
String _$memoAddHash() => r'3b8418ed6fc934fe6397c5d0f019c2865153a9d2';

/// See also [memoAdd].
@ProviderFor(memoAdd)
final memoAddProvider = AutoDisposeProvider<MemoAdd>.internal(
  memoAdd,
  name: r'memoAddProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$memoAddHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemoAddRef = AutoDisposeProviderRef<MemoAdd>;
String _$memoDeleteHash() => r'10fb70215dc3ef830d406325c83737dd2be046d4';

/// See also [memoDelete].
@ProviderFor(memoDelete)
final memoDeleteProvider = AutoDisposeProvider<MemoDelete>.internal(
  memoDelete,
  name: r'memoDeleteProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$memoDeleteHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemoDeleteRef = AutoDisposeProviderRef<MemoDelete>;
String _$memoUpdateHash() => r'ae056b44b145f7fd9e49c721211db590ea1fe709';

/// See also [memoUpdate].
@ProviderFor(memoUpdate)
final memoUpdateProvider = AutoDisposeProvider<MemoUpdate>.internal(
  memoUpdate,
  name: r'memoUpdateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$memoUpdateHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemoUpdateRef = AutoDisposeProviderRef<MemoUpdate>;
String _$memoDuplicateHash() => r'a8c093726a4373efc9ae049d4c91149f95bc8c0f';

/// See also [memoDuplicate].
@ProviderFor(memoDuplicate)
final memoDuplicateProvider = AutoDisposeProvider<MemoDuplicate>.internal(
  memoDuplicate,
  name: r'memoDuplicateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$memoDuplicateHash,
  dependencies: <ProviderOrFamily>[
    memoAddProvider,
    addTextMemoRowProvider,
    userDatabaseProvider
  ],
  allTransitiveDependencies: <ProviderOrFamily>{
    memoAddProvider,
    ...?memoAddProvider.allTransitiveDependencies,
    addTextMemoRowProvider,
    ...?addTextMemoRowProvider.allTransitiveDependencies,
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemoDuplicateRef = AutoDisposeProviderRef<MemoDuplicate>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
