// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bool_shared_preferences.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$boolSharedPreferencesHash() =>
    r'fa1a27ecef2408e8da294fb0d439126353c54a22';

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

abstract class _$BoolSharedPreferences extends BuildlessNotifier<bool> {
  late final String key;

  bool build({
    required String key,
  });
}

/// SharedPreferences の bool 値を [key] 単位で読み書きする汎用 Notifier。
///
/// family のキーは [key] のみ。Riverpod の family キャッシュにより、
/// 同じ [key] では同一インスタンスが返り、異なる [key] には別インスタンスが割り当てられる。
/// 値が存在しない場合の既定値は false。
///
/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。
///
/// Copied from [BoolSharedPreferences].
@ProviderFor(BoolSharedPreferences)
const boolSharedPreferencesProvider = BoolSharedPreferencesFamily();

/// SharedPreferences の bool 値を [key] 単位で読み書きする汎用 Notifier。
///
/// family のキーは [key] のみ。Riverpod の family キャッシュにより、
/// 同じ [key] では同一インスタンスが返り、異なる [key] には別インスタンスが割り当てられる。
/// 値が存在しない場合の既定値は false。
///
/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。
///
/// Copied from [BoolSharedPreferences].
class BoolSharedPreferencesFamily extends Family<bool> {
  /// SharedPreferences の bool 値を [key] 単位で読み書きする汎用 Notifier。
  ///
  /// family のキーは [key] のみ。Riverpod の family キャッシュにより、
  /// 同じ [key] では同一インスタンスが返り、異なる [key] には別インスタンスが割り当てられる。
  /// 値が存在しない場合の既定値は false。
  ///
  /// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
  /// それに依存する本 Provider も keepAlive にする。
  ///
  /// Copied from [BoolSharedPreferences].
  const BoolSharedPreferencesFamily();

  /// SharedPreferences の bool 値を [key] 単位で読み書きする汎用 Notifier。
  ///
  /// family のキーは [key] のみ。Riverpod の family キャッシュにより、
  /// 同じ [key] では同一インスタンスが返り、異なる [key] には別インスタンスが割り当てられる。
  /// 値が存在しない場合の既定値は false。
  ///
  /// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
  /// それに依存する本 Provider も keepAlive にする。
  ///
  /// Copied from [BoolSharedPreferences].
  BoolSharedPreferencesProvider call({
    required String key,
  }) {
    return BoolSharedPreferencesProvider(
      key: key,
    );
  }

  @override
  BoolSharedPreferencesProvider getProviderOverride(
    covariant BoolSharedPreferencesProvider provider,
  ) {
    return call(
      key: provider.key,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    sharedPreferencesProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    sharedPreferencesProvider,
    ...?sharedPreferencesProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'boolSharedPreferencesProvider';
}

/// SharedPreferences の bool 値を [key] 単位で読み書きする汎用 Notifier。
///
/// family のキーは [key] のみ。Riverpod の family キャッシュにより、
/// 同じ [key] では同一インスタンスが返り、異なる [key] には別インスタンスが割り当てられる。
/// 値が存在しない場合の既定値は false。
///
/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。
///
/// Copied from [BoolSharedPreferences].
class BoolSharedPreferencesProvider
    extends NotifierProviderImpl<BoolSharedPreferences, bool> {
  /// SharedPreferences の bool 値を [key] 単位で読み書きする汎用 Notifier。
  ///
  /// family のキーは [key] のみ。Riverpod の family キャッシュにより、
  /// 同じ [key] では同一インスタンスが返り、異なる [key] には別インスタンスが割り当てられる。
  /// 値が存在しない場合の既定値は false。
  ///
  /// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
  /// それに依存する本 Provider も keepAlive にする。
  ///
  /// Copied from [BoolSharedPreferences].
  BoolSharedPreferencesProvider({
    required String key,
  }) : this._internal(
          () => BoolSharedPreferences()..key = key,
          from: boolSharedPreferencesProvider,
          name: r'boolSharedPreferencesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$boolSharedPreferencesHash,
          dependencies: BoolSharedPreferencesFamily._dependencies,
          allTransitiveDependencies:
              BoolSharedPreferencesFamily._allTransitiveDependencies,
          key: key,
        );

  BoolSharedPreferencesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final String key;

  @override
  bool runNotifierBuild(
    covariant BoolSharedPreferences notifier,
  ) {
    return notifier.build(
      key: key,
    );
  }

  @override
  Override overrideWith(BoolSharedPreferences Function() create) {
    return ProviderOverride(
      origin: this,
      override: BoolSharedPreferencesProvider._internal(
        () => create()..key = key,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  NotifierProviderElement<BoolSharedPreferences, bool> createElement() {
    return _BoolSharedPreferencesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BoolSharedPreferencesProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BoolSharedPreferencesRef on NotifierProviderRef<bool> {
  /// The parameter `key` of this provider.
  String get key;
}

class _BoolSharedPreferencesProviderElement
    extends NotifierProviderElement<BoolSharedPreferences, bool>
    with BoolSharedPreferencesRef {
  _BoolSharedPreferencesProviderElement(super.provider);

  @override
  String get key => (origin as BoolSharedPreferencesProvider).key;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
