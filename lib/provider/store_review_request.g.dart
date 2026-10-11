// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_review_request.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$requestStoreReviewOnPurchasedItemCheckHash() =>
    r'747460f3246e667fbba6a06247de81519a19b612';

/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。
///
/// Copied from [requestStoreReviewOnPurchasedItemCheck].
@ProviderFor(requestStoreReviewOnPurchasedItemCheck)
final requestStoreReviewOnPurchasedItemCheckProvider =
    Provider<RequestStoreReviewOnPurchasedItemCheck>.internal(
      requestStoreReviewOnPurchasedItemCheck,
      name: r'requestStoreReviewOnPurchasedItemCheckProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$requestStoreReviewOnPurchasedItemCheckHash,
      dependencies: <ProviderOrFamily>[sharedPreferencesProvider],
      allTransitiveDependencies: <ProviderOrFamily>{
        sharedPreferencesProvider,
        ...?sharedPreferencesProvider.allTransitiveDependencies,
      },
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RequestStoreReviewOnPurchasedItemCheckRef =
    ProviderRef<RequestStoreReviewOnPurchasedItemCheck>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
