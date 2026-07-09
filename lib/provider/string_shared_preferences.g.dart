// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'string_shared_preferences.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stringSharedPreferencesHash() =>
    r'938a1a9d3b198e9b203c5485e08a6518e6ac98e0';

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

abstract class _$StringSharedPreferences extends BuildlessNotifier<String?> {
  late final String key;

  String? build({required String key});
}

/// SharedPreferences の String 値を [key] 単位で読み書きする汎用 Notifier。
///
/// [BoolSharedPreferences] と対称の構造。family のキーは [key] のみで、Riverpod の
/// family キャッシュにより同じ [key] では同一インスタンスが返る。値が存在しない場合は null。
///
/// DateTime のような値は呼び出し側で ISO8601 文字列などに変換して保存・復元する
/// (この Provider は文字列の生の read/write に徹する)。
///
/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。
///
/// Copied from [StringSharedPreferences].
@ProviderFor(StringSharedPreferences)
const stringSharedPreferencesProvider = StringSharedPreferencesFamily();

/// SharedPreferences の String 値を [key] 単位で読み書きする汎用 Notifier。
///
/// [BoolSharedPreferences] と対称の構造。family のキーは [key] のみで、Riverpod の
/// family キャッシュにより同じ [key] では同一インスタンスが返る。値が存在しない場合は null。
///
/// DateTime のような値は呼び出し側で ISO8601 文字列などに変換して保存・復元する
/// (この Provider は文字列の生の read/write に徹する)。
///
/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。
///
/// Copied from [StringSharedPreferences].
class StringSharedPreferencesFamily extends Family<String?> {
  /// SharedPreferences の String 値を [key] 単位で読み書きする汎用 Notifier。
  ///
  /// [BoolSharedPreferences] と対称の構造。family のキーは [key] のみで、Riverpod の
  /// family キャッシュにより同じ [key] では同一インスタンスが返る。値が存在しない場合は null。
  ///
  /// DateTime のような値は呼び出し側で ISO8601 文字列などに変換して保存・復元する
  /// (この Provider は文字列の生の read/write に徹する)。
  ///
  /// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
  /// それに依存する本 Provider も keepAlive にする。
  ///
  /// Copied from [StringSharedPreferences].
  const StringSharedPreferencesFamily();

  /// SharedPreferences の String 値を [key] 単位で読み書きする汎用 Notifier。
  ///
  /// [BoolSharedPreferences] と対称の構造。family のキーは [key] のみで、Riverpod の
  /// family キャッシュにより同じ [key] では同一インスタンスが返る。値が存在しない場合は null。
  ///
  /// DateTime のような値は呼び出し側で ISO8601 文字列などに変換して保存・復元する
  /// (この Provider は文字列の生の read/write に徹する)。
  ///
  /// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
  /// それに依存する本 Provider も keepAlive にする。
  ///
  /// Copied from [StringSharedPreferences].
  StringSharedPreferencesProvider call({required String key}) {
    return StringSharedPreferencesProvider(key: key);
  }

  @override
  StringSharedPreferencesProvider getProviderOverride(
    covariant StringSharedPreferencesProvider provider,
  ) {
    return call(key: provider.key);
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    sharedPreferencesProvider,
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
        sharedPreferencesProvider,
        ...?sharedPreferencesProvider.allTransitiveDependencies,
      };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'stringSharedPreferencesProvider';
}

/// SharedPreferences の String 値を [key] 単位で読み書きする汎用 Notifier。
///
/// [BoolSharedPreferences] と対称の構造。family のキーは [key] のみで、Riverpod の
/// family キャッシュにより同じ [key] では同一インスタンスが返る。値が存在しない場合は null。
///
/// DateTime のような値は呼び出し側で ISO8601 文字列などに変換して保存・復元する
/// (この Provider は文字列の生の read/write に徹する)。
///
/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。
///
/// Copied from [StringSharedPreferences].
class StringSharedPreferencesProvider
    extends NotifierProviderImpl<StringSharedPreferences, String?> {
  /// SharedPreferences の String 値を [key] 単位で読み書きする汎用 Notifier。
  ///
  /// [BoolSharedPreferences] と対称の構造。family のキーは [key] のみで、Riverpod の
  /// family キャッシュにより同じ [key] では同一インスタンスが返る。値が存在しない場合は null。
  ///
  /// DateTime のような値は呼び出し側で ISO8601 文字列などに変換して保存・復元する
  /// (この Provider は文字列の生の read/write に徹する)。
  ///
  /// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
  /// それに依存する本 Provider も keepAlive にする。
  ///
  /// Copied from [StringSharedPreferences].
  StringSharedPreferencesProvider({required String key})
    : this._internal(
        () => StringSharedPreferences()..key = key,
        from: stringSharedPreferencesProvider,
        name: r'stringSharedPreferencesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$stringSharedPreferencesHash,
        dependencies: StringSharedPreferencesFamily._dependencies,
        allTransitiveDependencies:
            StringSharedPreferencesFamily._allTransitiveDependencies,
        key: key,
      );

  StringSharedPreferencesProvider._internal(
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
  String? runNotifierBuild(covariant StringSharedPreferences notifier) {
    return notifier.build(key: key);
  }

  @override
  Override overrideWith(StringSharedPreferences Function() create) {
    return ProviderOverride(
      origin: this,
      override: StringSharedPreferencesProvider._internal(
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
  NotifierProviderElement<StringSharedPreferences, String?> createElement() {
    return _StringSharedPreferencesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StringSharedPreferencesProvider && other.key == key;
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
mixin StringSharedPreferencesRef on NotifierProviderRef<String?> {
  /// The parameter `key` of this provider.
  String get key;
}

class _StringSharedPreferencesProviderElement
    extends NotifierProviderElement<StringSharedPreferences, String?>
    with StringSharedPreferencesRef {
  _StringSharedPreferencesProviderElement(super.provider);

  @override
  String get key => (origin as StringSharedPreferencesProvider).key;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
