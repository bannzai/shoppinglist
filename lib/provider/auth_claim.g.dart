// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_claim.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firestoreIsPremiumHash() =>
    r'e6118f35a8ac91320b46916ac0c1aff7a77611ee';

/// Firebase Auth IDトークンの Custom Claims から isPremium を解決するプロバイダー。
/// Firestoreクエリの表示フィルタに使用する。UI表示用途には customerInfoProvider を使用すること。
/// 購入/復元直後は currentUser.getIdToken(true) 実行後に invalidate して再取得する。
///
/// Copied from [firestoreIsPremium].
@ProviderFor(firestoreIsPremium)
final firestoreIsPremiumProvider = FutureProvider<bool>.internal(
  firestoreIsPremium,
  name: r'firestoreIsPremiumProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firestoreIsPremiumHash,
  dependencies: <ProviderOrFamily>[firebaseUserChangesProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    firebaseUserChangesProvider,
    ...?firebaseUserChangesProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirestoreIsPremiumRef = FutureProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
