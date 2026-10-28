// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appUser)
final appUserProvider = AppUserProvider._();

final class AppUserProvider
    extends $FunctionalProvider<AsyncValue<AppUser>, AppUser, Stream<AppUser>>
    with $FutureModifier<AppUser>, $StreamProvider<AppUser> {
  AppUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUserProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[userDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          AppUserProvider.$allTransitiveDependencies0,
          AppUserProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = userDatabaseProvider;
  static final $allTransitiveDependencies1 =
      UserDatabaseProvider.$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$appUserHash();

  @$internal
  @override
  $StreamProviderElement<AppUser> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppUser> create(Ref ref) {
    return appUser(ref);
  }
}

String _$appUserHash() => r'ba194a96944f6c3713a705684d24bc1c358fd399';

/// AppUserドキュメントが存在しない場合は null を返す。
/// AppUserCreateResolver で使用する。ドキュメント作成前のストリーム発火時に
/// エラーにならず null として扱える。

@ProviderFor(optionalAppUser)
final optionalAppUserProvider = OptionalAppUserProvider._();

/// AppUserドキュメントが存在しない場合は null を返す。
/// AppUserCreateResolver で使用する。ドキュメント作成前のストリーム発火時に
/// エラーにならず null として扱える。

final class OptionalAppUserProvider
    extends
        $FunctionalProvider<AsyncValue<AppUser?>, AppUser?, Stream<AppUser?>>
    with $FutureModifier<AppUser?>, $StreamProvider<AppUser?> {
  /// AppUserドキュメントが存在しない場合は null を返す。
  /// AppUserCreateResolver で使用する。ドキュメント作成前のストリーム発火時に
  /// エラーにならず null として扱える。
  OptionalAppUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'optionalAppUserProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[userDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          OptionalAppUserProvider.$allTransitiveDependencies0,
          OptionalAppUserProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = userDatabaseProvider;
  static final $allTransitiveDependencies1 =
      UserDatabaseProvider.$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$optionalAppUserHash();

  @$internal
  @override
  $StreamProviderElement<AppUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppUser?> create(Ref ref) {
    return optionalAppUser(ref);
  }
}

String _$optionalAppUserHash() => r'73a1a68b8be25fe0eac81c89a514e5273708b3a4';
