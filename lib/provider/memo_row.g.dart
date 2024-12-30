// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_row.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$textMemoRowsHash() => r'4ee36c3410347a3314220017c97aae097e17c4bf';

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

/// See also [textMemoRows].
@ProviderFor(textMemoRows)
const textMemoRowsProvider = TextMemoRowsFamily();

/// See also [textMemoRows].
class TextMemoRowsFamily extends Family<AsyncValue<List<MemoRow>>> {
  /// See also [textMemoRows].
  const TextMemoRowsFamily();

  /// See also [textMemoRows].
  TextMemoRowsProvider call({
    required String memoID,
    required bool showChecked,
  }) {
    return TextMemoRowsProvider(
      memoID: memoID,
      showChecked: showChecked,
    );
  }

  @override
  TextMemoRowsProvider getProviderOverride(
    covariant TextMemoRowsProvider provider,
  ) {
    return call(
      memoID: provider.memoID,
      showChecked: provider.showChecked,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[userDatabaseProvider];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies = <ProviderOrFamily>{
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies => _allTransitiveDependencies;

  @override
  String? get name => r'textMemoRowsProvider';
}

/// See also [textMemoRows].
class TextMemoRowsProvider extends AutoDisposeStreamProvider<List<MemoRow>> {
  /// See also [textMemoRows].
  TextMemoRowsProvider({
    required String memoID,
    required bool showChecked,
  }) : this._internal(
          (ref) => textMemoRows(
            ref as TextMemoRowsRef,
            memoID: memoID,
            showChecked: showChecked,
          ),
          from: textMemoRowsProvider,
          name: r'textMemoRowsProvider',
          debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$textMemoRowsHash,
          dependencies: TextMemoRowsFamily._dependencies,
          allTransitiveDependencies: TextMemoRowsFamily._allTransitiveDependencies,
          memoID: memoID,
          showChecked: showChecked,
        );

  TextMemoRowsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memoID,
    required this.showChecked,
  }) : super.internal();

  final String memoID;
  final bool showChecked;

  @override
  Override overrideWith(
    Stream<List<MemoRow>> Function(TextMemoRowsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TextMemoRowsProvider._internal(
        (ref) => create(ref as TextMemoRowsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memoID: memoID,
        showChecked: showChecked,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<MemoRow>> createElement() {
    return _TextMemoRowsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TextMemoRowsProvider && other.memoID == memoID && other.showChecked == showChecked;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memoID.hashCode);
    hash = _SystemHash.combine(hash, showChecked.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TextMemoRowsRef on AutoDisposeStreamProviderRef<List<MemoRow>> {
  /// The parameter `memoID` of this provider.
  String get memoID;

  /// The parameter `showChecked` of this provider.
  bool get showChecked;
}

class _TextMemoRowsProviderElement extends AutoDisposeStreamProviderElement<List<MemoRow>> with TextMemoRowsRef {
  _TextMemoRowsProviderElement(super.provider);

  @override
  String get memoID => (origin as TextMemoRowsProvider).memoID;
  @override
  bool get showChecked => (origin as TextMemoRowsProvider).showChecked;
}

String _$linkMemoRowsHash() => r'd77354e6b6c7be9791835a7943f67cbce3b637b2';

/// See also [linkMemoRows].
@ProviderFor(linkMemoRows)
const linkMemoRowsProvider = LinkMemoRowsFamily();

/// See also [linkMemoRows].
class LinkMemoRowsFamily extends Family<AsyncValue<List<MemoRow>>> {
  /// See also [linkMemoRows].
  const LinkMemoRowsFamily();

  /// See also [linkMemoRows].
  LinkMemoRowsProvider call({
    required String memoID,
  }) {
    return LinkMemoRowsProvider(
      memoID: memoID,
    );
  }

  @override
  LinkMemoRowsProvider getProviderOverride(
    covariant LinkMemoRowsProvider provider,
  ) {
    return call(
      memoID: provider.memoID,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[userDatabaseProvider];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies = <ProviderOrFamily>{
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies => _allTransitiveDependencies;

  @override
  String? get name => r'linkMemoRowsProvider';
}

/// See also [linkMemoRows].
class LinkMemoRowsProvider extends AutoDisposeStreamProvider<List<MemoRow>> {
  /// See also [linkMemoRows].
  LinkMemoRowsProvider({
    required String memoID,
  }) : this._internal(
          (ref) => linkMemoRows(
            ref as LinkMemoRowsRef,
            memoID: memoID,
          ),
          from: linkMemoRowsProvider,
          name: r'linkMemoRowsProvider',
          debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$linkMemoRowsHash,
          dependencies: LinkMemoRowsFamily._dependencies,
          allTransitiveDependencies: LinkMemoRowsFamily._allTransitiveDependencies,
          memoID: memoID,
        );

  LinkMemoRowsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memoID,
  }) : super.internal();

  final String memoID;

  @override
  Override overrideWith(
    Stream<List<MemoRow>> Function(LinkMemoRowsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LinkMemoRowsProvider._internal(
        (ref) => create(ref as LinkMemoRowsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memoID: memoID,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<MemoRow>> createElement() {
    return _LinkMemoRowsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LinkMemoRowsProvider && other.memoID == memoID;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memoID.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LinkMemoRowsRef on AutoDisposeStreamProviderRef<List<MemoRow>> {
  /// The parameter `memoID` of this provider.
  String get memoID;
}

class _LinkMemoRowsProviderElement extends AutoDisposeStreamProviderElement<List<MemoRow>> with LinkMemoRowsRef {
  _LinkMemoRowsProviderElement(super.provider);

  @override
  String get memoID => (origin as LinkMemoRowsProvider).memoID;
}

String _$addLinkMemoRowHash() => r'bef1d96ed3a5a0de82ff40d29ca906fb11097af1';

/// See also [addLinkMemoRow].
@ProviderFor(addLinkMemoRow)
final addLinkMemoRowProvider = AutoDisposeProvider<AddLinkMemoRow>.internal(
  addLinkMemoRow,
  name: r'addLinkMemoRowProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$addLinkMemoRowHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{userDatabaseProvider, ...?userDatabaseProvider.allTransitiveDependencies},
);

typedef AddLinkMemoRowRef = AutoDisposeProviderRef<AddLinkMemoRow>;
String _$memoRowBatchUpdateHash() => r'3e408fd1248e0f71e92551f87a33d3ade5b0b8cc';

/// See also [memoRowBatchUpdate].
@ProviderFor(memoRowBatchUpdate)
final memoRowBatchUpdateProvider = AutoDisposeProvider<MemoRowBatchUpdate>.internal(
  memoRowBatchUpdate,
  name: r'memoRowBatchUpdateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$memoRowBatchUpdateHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{userDatabaseProvider, ...?userDatabaseProvider.allTransitiveDependencies},
);

typedef MemoRowBatchUpdateRef = AutoDisposeProviderRef<MemoRowBatchUpdate>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
