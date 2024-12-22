// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_rows.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memoRowsHash() => r'c9eda0189e393d79c87b28caff0a5a27484b3ce1';

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

/// See also [memoRows].
@ProviderFor(memoRows)
const memoRowsProvider = MemoRowsFamily();

/// See also [memoRows].
class MemoRowsFamily extends Family<AsyncValue<List<MemoRow>>> {
  /// See also [memoRows].
  const MemoRowsFamily();

  /// See also [memoRows].
  MemoRowsProvider call({
    required String memoID,
  }) {
    return MemoRowsProvider(
      memoID: memoID,
    );
  }

  @override
  MemoRowsProvider getProviderOverride(
    covariant MemoRowsProvider provider,
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
  String? get name => r'memoRowsProvider';
}

/// See also [memoRows].
class MemoRowsProvider extends AutoDisposeStreamProvider<List<MemoRow>> {
  /// See also [memoRows].
  MemoRowsProvider({
    required String memoID,
  }) : this._internal(
          (ref) => memoRows(
            ref as MemoRowsRef,
            memoID: memoID,
          ),
          from: memoRowsProvider,
          name: r'memoRowsProvider',
          debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$memoRowsHash,
          dependencies: MemoRowsFamily._dependencies,
          allTransitiveDependencies: MemoRowsFamily._allTransitiveDependencies,
          memoID: memoID,
        );

  MemoRowsProvider._internal(
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
    Stream<List<MemoRow>> Function(MemoRowsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MemoRowsProvider._internal(
        (ref) => create(ref as MemoRowsRef),
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
    return _MemoRowsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MemoRowsProvider && other.memoID == memoID;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memoID.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MemoRowsRef on AutoDisposeStreamProviderRef<List<MemoRow>> {
  /// The parameter `memoID` of this provider.
  String get memoID;
}

class _MemoRowsProviderElement extends AutoDisposeStreamProviderElement<List<MemoRow>> with MemoRowsRef {
  _MemoRowsProviderElement(super.provider);

  @override
  String get memoID => (origin as MemoRowsProvider).memoID;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
