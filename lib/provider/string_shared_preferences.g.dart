// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'string_shared_preferences.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(StringSharedPreferences)
final stringSharedPreferencesProvider = StringSharedPreferencesFamily._();

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
final class StringSharedPreferencesProvider
    extends $NotifierProvider<StringSharedPreferences, String?> {
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
  StringSharedPreferencesProvider._({
    required StringSharedPreferencesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'stringSharedPreferencesProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = sharedPreferencesProvider;

  @override
  String debugGetCreateSourceHash() => _$stringSharedPreferencesHash();

  @override
  String toString() {
    return r'stringSharedPreferencesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StringSharedPreferences create() => StringSharedPreferences();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StringSharedPreferencesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stringSharedPreferencesHash() =>
    r'938a1a9d3b198e9b203c5485e08a6518e6ac98e0';

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

final class StringSharedPreferencesFamily extends $Family
    with
        $ClassFamilyOverride<
          StringSharedPreferences,
          String?,
          String?,
          String?,
          String
        > {
  StringSharedPreferencesFamily._()
    : super(
        retry: null,
        name: r'stringSharedPreferencesProvider',
        dependencies: <ProviderOrFamily>[sharedPreferencesProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          StringSharedPreferencesProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: false,
      );

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

  StringSharedPreferencesProvider call({required String key}) =>
      StringSharedPreferencesProvider._(argument: key, from: this);

  @override
  String toString() => r'stringSharedPreferencesProvider';
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

abstract class _$StringSharedPreferences extends $Notifier<String?> {
  late final _$args = ref.$arg as String;
  String get key => _$args;

  String? build({required String key});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(key: _$args));
  }
}
