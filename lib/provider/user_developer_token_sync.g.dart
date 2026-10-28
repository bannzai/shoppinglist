// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_developer_token_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [UserDeveloperTokenSync] を提供する Provider。

@ProviderFor(userDeveloperTokenSync)
final userDeveloperTokenSyncProvider = UserDeveloperTokenSyncProvider._();

/// [UserDeveloperTokenSync] を提供する Provider。

final class UserDeveloperTokenSyncProvider
    extends
        $FunctionalProvider<
          UserDeveloperTokenSync,
          UserDeveloperTokenSync,
          UserDeveloperTokenSync
        >
    with $Provider<UserDeveloperTokenSync> {
  /// [UserDeveloperTokenSync] を提供する Provider。
  UserDeveloperTokenSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userDeveloperTokenSyncProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[userDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          UserDeveloperTokenSyncProvider.$allTransitiveDependencies0,
          UserDeveloperTokenSyncProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = userDatabaseProvider;
  static final $allTransitiveDependencies1 =
      UserDatabaseProvider.$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$userDeveloperTokenSyncHash();

  @$internal
  @override
  $ProviderElement<UserDeveloperTokenSync> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserDeveloperTokenSync create(Ref ref) {
    return userDeveloperTokenSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserDeveloperTokenSync value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserDeveloperTokenSync>(value),
    );
  }
}

String _$userDeveloperTokenSyncHash() =>
    r'4a1798dd847dfaa9d1b08475813c0c1f8d72fad6';
