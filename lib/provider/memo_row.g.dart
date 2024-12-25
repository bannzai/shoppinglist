// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_row.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$textMemoRowsHash() => r'6b33810169f498f03d89ddba733143d4880e80cb';

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
  }) {
    return TextMemoRowsProvider(
      memoID: memoID,
    );
  }

  @override
  TextMemoRowsProvider getProviderOverride(
    covariant TextMemoRowsProvider provider,
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
  String? get name => r'textMemoRowsProvider';
}

/// See also [textMemoRows].
class TextMemoRowsProvider extends AutoDisposeStreamProvider<List<MemoRow>> {
  /// See also [textMemoRows].
  TextMemoRowsProvider({
    required String memoID,
  }) : this._internal(
          (ref) => textMemoRows(
            ref as TextMemoRowsRef,
            memoID: memoID,
          ),
          from: textMemoRowsProvider,
          name: r'textMemoRowsProvider',
          debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$textMemoRowsHash,
          dependencies: TextMemoRowsFamily._dependencies,
          allTransitiveDependencies: TextMemoRowsFamily._allTransitiveDependencies,
          memoID: memoID,
        );

  TextMemoRowsProvider._internal(
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
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<MemoRow>> createElement() {
    return _TextMemoRowsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TextMemoRowsProvider && other.memoID == memoID;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memoID.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TextMemoRowsRef on AutoDisposeStreamProviderRef<List<MemoRow>> {
  /// The parameter `memoID` of this provider.
  String get memoID;
}

class _TextMemoRowsProviderElement extends AutoDisposeStreamProviderElement<List<MemoRow>> with TextMemoRowsRef {
  _TextMemoRowsProviderElement(super.provider);

  @override
  String get memoID => (origin as TextMemoRowsProvider).memoID;
}

String _$linkMemoRowsHash() => r'd826393f7e0eb89f47ecb3a0c6922073c606f829';

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

String _$addLinkMemoRowHash() => r'e060747d52030baf4fbe077c1ad28d0db6ff515a';

/// See also [addLinkMemoRow].
@ProviderFor(addLinkMemoRow)
const addLinkMemoRowProvider = AddLinkMemoRowFamily();

/// See also [addLinkMemoRow].
class AddLinkMemoRowFamily extends Family<AsyncValue<void>> {
  /// See also [addLinkMemoRow].
  const AddLinkMemoRowFamily();

  /// See also [addLinkMemoRow].
  AddLinkMemoRowProvider call({
    required String memoID,
    required String url,
  }) {
    return AddLinkMemoRowProvider(
      memoID: memoID,
      url: url,
    );
  }

  @override
  AddLinkMemoRowProvider getProviderOverride(
    covariant AddLinkMemoRowProvider provider,
  ) {
    return call(
      memoID: provider.memoID,
      url: provider.url,
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
  String? get name => r'addLinkMemoRowProvider';
}

/// See also [addLinkMemoRow].
class AddLinkMemoRowProvider extends AutoDisposeFutureProvider<void> {
  /// See also [addLinkMemoRow].
  AddLinkMemoRowProvider({
    required String memoID,
    required String url,
  }) : this._internal(
          (ref) => addLinkMemoRow(
            ref as AddLinkMemoRowRef,
            memoID: memoID,
            url: url,
          ),
          from: addLinkMemoRowProvider,
          name: r'addLinkMemoRowProvider',
          debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$addLinkMemoRowHash,
          dependencies: AddLinkMemoRowFamily._dependencies,
          allTransitiveDependencies: AddLinkMemoRowFamily._allTransitiveDependencies,
          memoID: memoID,
          url: url,
        );

  AddLinkMemoRowProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memoID,
    required this.url,
  }) : super.internal();

  final String memoID;
  final String url;

  @override
  Override overrideWith(
    FutureOr<void> Function(AddLinkMemoRowRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AddLinkMemoRowProvider._internal(
        (ref) => create(ref as AddLinkMemoRowRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memoID: memoID,
        url: url,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _AddLinkMemoRowProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AddLinkMemoRowProvider && other.memoID == memoID && other.url == url;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memoID.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AddLinkMemoRowRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `memoID` of this provider.
  String get memoID;

  /// The parameter `url` of this provider.
  String get url;
}

class _AddLinkMemoRowProviderElement extends AutoDisposeFutureProviderElement<void> with AddLinkMemoRowRef {
  _AddLinkMemoRowProviderElement(super.provider);

  @override
  String get memoID => (origin as AddLinkMemoRowProvider).memoID;
  @override
  String get url => (origin as AddLinkMemoRowProvider).url;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
