// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_id.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// サインイン中の Firebase Auth ユーザーの uid。未サインイン・読込中は null。
// firebaseUserChanges は dependencies を持つ (scoped な) provider で、Riverpod 3 は
// それを watch する provider が dependencies に列挙していないと実行時に例外を投げる

@ProviderFor(currentUserID)
final currentUserIDProvider = CurrentUserIDProvider._();

/// サインイン中の Firebase Auth ユーザーの uid。未サインイン・読込中は null。
// firebaseUserChanges は dependencies を持つ (scoped な) provider で、Riverpod 3 は
// それを watch する provider が dependencies に列挙していないと実行時に例外を投げる

final class CurrentUserIDProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// サインイン中の Firebase Auth ユーザーの uid。未サインイン・読込中は null。
  // firebaseUserChanges は dependencies を持つ (scoped な) provider で、Riverpod 3 は
  // それを watch する provider が dependencies に列挙していないと実行時に例外を投げる
  CurrentUserIDProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIDProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[firebaseUserChangesProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          CurrentUserIDProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = firebaseUserChangesProvider;

  @override
  String debugGetCreateSourceHash() => _$currentUserIDHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentUserID(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentUserIDHash() => r'9c2b209ace771efef84c21df245af203fa72ce82';
