// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_color.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// テーマカラー更新操作を提供するProvider。

@ProviderFor(themeColorUpdate)
final themeColorUpdateProvider = ThemeColorUpdateProvider._();

/// テーマカラー更新操作を提供するProvider。

final class ThemeColorUpdateProvider
    extends
        $FunctionalProvider<
          ThemeColorUpdate,
          ThemeColorUpdate,
          ThemeColorUpdate
        >
    with $Provider<ThemeColorUpdate> {
  /// テーマカラー更新操作を提供するProvider。
  ThemeColorUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeColorUpdateProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[userDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          ThemeColorUpdateProvider.$allTransitiveDependencies0,
          ThemeColorUpdateProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = userDatabaseProvider;
  static final $allTransitiveDependencies1 =
      UserDatabaseProvider.$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$themeColorUpdateHash();

  @$internal
  @override
  $ProviderElement<ThemeColorUpdate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeColorUpdate create(Ref ref) {
    return themeColorUpdate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeColorUpdate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeColorUpdate>(value),
    );
  }
}

String _$themeColorUpdateHash() => r'918a6417158a116910455aeee795f9d1da8c24a8';
