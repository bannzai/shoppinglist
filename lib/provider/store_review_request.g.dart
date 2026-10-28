// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_review_request.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。

@ProviderFor(requestStoreReviewOnPurchasedItemCheck)
final requestStoreReviewOnPurchasedItemCheckProvider =
    RequestStoreReviewOnPurchasedItemCheckProvider._();

/// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
/// それに依存する本 Provider も keepAlive にする。

final class RequestStoreReviewOnPurchasedItemCheckProvider
    extends
        $FunctionalProvider<
          RequestStoreReviewOnPurchasedItemCheck,
          RequestStoreReviewOnPurchasedItemCheck,
          RequestStoreReviewOnPurchasedItemCheck
        >
    with $Provider<RequestStoreReviewOnPurchasedItemCheck> {
  /// sharedPreferencesProvider が override 前提の keepAlive Provider であるため、
  /// それに依存する本 Provider も keepAlive にする。
  RequestStoreReviewOnPurchasedItemCheckProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestStoreReviewOnPurchasedItemCheckProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[sharedPreferencesProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          RequestStoreReviewOnPurchasedItemCheckProvider
              .$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = sharedPreferencesProvider;

  @override
  String debugGetCreateSourceHash() =>
      _$requestStoreReviewOnPurchasedItemCheckHash();

  @$internal
  @override
  $ProviderElement<RequestStoreReviewOnPurchasedItemCheck> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RequestStoreReviewOnPurchasedItemCheck create(Ref ref) {
    return requestStoreReviewOnPurchasedItemCheck(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RequestStoreReviewOnPurchasedItemCheck value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<RequestStoreReviewOnPurchasedItemCheck>(value),
    );
  }
}

String _$requestStoreReviewOnPurchasedItemCheckHash() =>
    r'747460f3246e667fbba6a06247de81519a19b612';
