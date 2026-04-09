// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_color.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeColorUpdateHash() => r'483c9c21d4b24367d50a7d04480f9fe71c366c55';

/// テーマカラー更新操作を提供するProvider。
///
/// Copied from [themeColorUpdate].
@ProviderFor(themeColorUpdate)
final themeColorUpdateProvider = AutoDisposeProvider<ThemeColorUpdate>.internal(
  themeColorUpdate,
  name: r'themeColorUpdateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeColorUpdateHash,
  dependencies: <ProviderOrFamily>[userDatabaseProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    userDatabaseProvider,
    ...?userDatabaseProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ThemeColorUpdateRef = AutoDisposeProviderRef<ThemeColorUpdate>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
