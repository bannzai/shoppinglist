// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bool_shared_preferences.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SharedPreferences の bool 値を [key] 単位で読み書きする汎用 Notifier。
///
/// family のキーは [key] のみ。Riverpod の family キャッシュにより、
/// 同じ [key] では同一インスタンスが返り、異なる [key] には別インスタンスが割り当てられる。
/// 値が存在しない場合の既定値は false。
///
/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。

@ProviderFor(BoolSharedPreferences)
final boolSharedPreferencesProvider = BoolSharedPreferencesFamily._();

/// SharedPreferences の bool 値を [key] 単位で読み書きする汎用 Notifier。
///
/// family のキーは [key] のみ。Riverpod の family キャッシュにより、
/// 同じ [key] では同一インスタンスが返り、異なる [key] には別インスタンスが割り当てられる。
/// 値が存在しない場合の既定値は false。
///
/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。
final class BoolSharedPreferencesProvider
    extends $NotifierProvider<BoolSharedPreferences, bool> {
  /// SharedPreferences の bool 値を [key] 単位で読み書きする汎用 Notifier。
  ///
  /// family のキーは [key] のみ。Riverpod の family キャッシュにより、
  /// 同じ [key] では同一インスタンスが返り、異なる [key] には別インスタンスが割り当てられる。
  /// 値が存在しない場合の既定値は false。
  ///
  /// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
  /// それに依存する本 Provider も keepAlive にする。
  BoolSharedPreferencesProvider._({
    required BoolSharedPreferencesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'boolSharedPreferencesProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = sharedPreferencesProvider;

  @override
  String debugGetCreateSourceHash() => _$boolSharedPreferencesHash();

  @override
  String toString() {
    return r'boolSharedPreferencesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BoolSharedPreferences create() => BoolSharedPreferences();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BoolSharedPreferencesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$boolSharedPreferencesHash() =>
    r'fa1a27ecef2408e8da294fb0d439126353c54a22';

/// SharedPreferences の bool 値を [key] 単位で読み書きする汎用 Notifier。
///
/// family のキーは [key] のみ。Riverpod の family キャッシュにより、
/// 同じ [key] では同一インスタンスが返り、異なる [key] には別インスタンスが割り当てられる。
/// 値が存在しない場合の既定値は false。
///
/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。

final class BoolSharedPreferencesFamily extends $Family
    with $ClassFamilyOverride<BoolSharedPreferences, bool, bool, bool, String> {
  BoolSharedPreferencesFamily._()
    : super(
        retry: null,
        name: r'boolSharedPreferencesProvider',
        dependencies: <ProviderOrFamily>[sharedPreferencesProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          BoolSharedPreferencesProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: false,
      );

  /// SharedPreferences の bool 値を [key] 単位で読み書きする汎用 Notifier。
  ///
  /// family のキーは [key] のみ。Riverpod の family キャッシュにより、
  /// 同じ [key] では同一インスタンスが返り、異なる [key] には別インスタンスが割り当てられる。
  /// 値が存在しない場合の既定値は false。
  ///
  /// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
  /// それに依存する本 Provider も keepAlive にする。

  BoolSharedPreferencesProvider call({required String key}) =>
      BoolSharedPreferencesProvider._(argument: key, from: this);

  @override
  String toString() => r'boolSharedPreferencesProvider';
}

/// SharedPreferences の bool 値を [key] 単位で読み書きする汎用 Notifier。
///
/// family のキーは [key] のみ。Riverpod の family キャッシュにより、
/// 同じ [key] では同一インスタンスが返り、異なる [key] には別インスタンスが割り当てられる。
/// 値が存在しない場合の既定値は false。
///
/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。

abstract class _$BoolSharedPreferences extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get key => _$args;

  bool build({required String key});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(key: _$args));
  }
}
