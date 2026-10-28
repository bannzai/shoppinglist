// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// RevenueCat Offerings を取得する Provider。
///
/// `Purchases.configure` 直後の race（Issue #237: Maestro `clearState=true +
/// clearKeychain=true` 起動で `PlatformException(code:23, CONFIGURATION_ERROR)`
/// を踏むケース）に備え、`PurchasesErrorCode.configurationError` のみ
/// 指数バックオフで最大 3 回 retry する。それ以外のエラーは即時 rethrow。

@ProviderFor(offerings)
final offeringsProvider = OfferingsProvider._();

/// RevenueCat Offerings を取得する Provider。
///
/// `Purchases.configure` 直後の race（Issue #237: Maestro `clearState=true +
/// clearKeychain=true` 起動で `PlatformException(code:23, CONFIGURATION_ERROR)`
/// を踏むケース）に備え、`PurchasesErrorCode.configurationError` のみ
/// 指数バックオフで最大 3 回 retry する。それ以外のエラーは即時 rethrow。

final class OfferingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Offerings>,
          Offerings,
          FutureOr<Offerings>
        >
    with $FutureModifier<Offerings>, $FutureProvider<Offerings> {
  /// RevenueCat Offerings を取得する Provider。
  ///
  /// `Purchases.configure` 直後の race（Issue #237: Maestro `clearState=true +
  /// clearKeychain=true` 起動で `PlatformException(code:23, CONFIGURATION_ERROR)`
  /// を踏むケース）に備え、`PurchasesErrorCode.configurationError` のみ
  /// 指数バックオフで最大 3 回 retry する。それ以外のエラーは即時 rethrow。
  OfferingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offeringsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offeringsHash();

  @$internal
  @override
  $FutureProviderElement<Offerings> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Offerings> create(Ref ref) {
    return offerings(ref);
  }
}

String _$offeringsHash() => r'ebd4126332e68385e116eae2daef545cc07975d9';

@ProviderFor(currentOfferingPackages)
final currentOfferingPackagesProvider = CurrentOfferingPackagesProvider._();

final class CurrentOfferingPackagesProvider
    extends $FunctionalProvider<List<Package>, List<Package>, List<Package>>
    with $Provider<List<Package>> {
  CurrentOfferingPackagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentOfferingPackagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentOfferingPackagesHash();

  @$internal
  @override
  $ProviderElement<List<Package>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Package> create(Ref ref) {
    return currentOfferingPackages(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Package> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Package>>(value),
    );
  }
}

String _$currentOfferingPackagesHash() =>
    r'5107fb41411f79b3bf42a35d141a1d7c0d57c0f0';

@ProviderFor(weeklyPackage)
final weeklyPackageProvider = WeeklyPackageProvider._();

final class WeeklyPackageProvider
    extends $FunctionalProvider<Package?, Package?, Package?>
    with $Provider<Package?> {
  WeeklyPackageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyPackageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyPackageHash();

  @$internal
  @override
  $ProviderElement<Package?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Package? create(Ref ref) {
    return weeklyPackage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Package? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Package?>(value),
    );
  }
}

String _$weeklyPackageHash() => r'ba26c9b5ee0fd47b82377fe698a98759c7286f1e';

@ProviderFor(monthlyPackage)
final monthlyPackageProvider = MonthlyPackageProvider._();

final class MonthlyPackageProvider
    extends $FunctionalProvider<Package?, Package?, Package?>
    with $Provider<Package?> {
  MonthlyPackageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyPackageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyPackageHash();

  @$internal
  @override
  $ProviderElement<Package?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Package? create(Ref ref) {
    return monthlyPackage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Package? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Package?>(value),
    );
  }
}

String _$monthlyPackageHash() => r'43e529cd7d27fba0cf9e591bc80f23b0abf2d893';

@ProviderFor(sixMonthPackage)
final sixMonthPackageProvider = SixMonthPackageProvider._();

final class SixMonthPackageProvider
    extends $FunctionalProvider<Package?, Package?, Package?>
    with $Provider<Package?> {
  SixMonthPackageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sixMonthPackageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sixMonthPackageHash();

  @$internal
  @override
  $ProviderElement<Package?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Package? create(Ref ref) {
    return sixMonthPackage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Package? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Package?>(value),
    );
  }
}

String _$sixMonthPackageHash() => r'3293887aad384d28bcb0ae42e2f94c35a6028c33';

/// 現在 Offering から annual (1 年) Package を返す。Offering に未設定なら null。

@ProviderFor(annualPackage)
final annualPackageProvider = AnnualPackageProvider._();

/// 現在 Offering から annual (1 年) Package を返す。Offering に未設定なら null。

final class AnnualPackageProvider
    extends $FunctionalProvider<Package?, Package?, Package?>
    with $Provider<Package?> {
  /// 現在 Offering から annual (1 年) Package を返す。Offering に未設定なら null。
  AnnualPackageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'annualPackageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$annualPackageHash();

  @$internal
  @override
  $ProviderElement<Package?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Package? create(Ref ref) {
    return annualPackage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Package? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Package?>(value),
    );
  }
}

String _$annualPackageHash() => r'84a4a588f0eaebbd8d31e87c839f0c2cb6ece25e';

/// 現在 Offering から lifetime (買い切り) Package を返す。Offering に未設定なら null。

@ProviderFor(lifetimePackage)
final lifetimePackageProvider = LifetimePackageProvider._();

/// 現在 Offering から lifetime (買い切り) Package を返す。Offering に未設定なら null。

final class LifetimePackageProvider
    extends $FunctionalProvider<Package?, Package?, Package?>
    with $Provider<Package?> {
  /// 現在 Offering から lifetime (買い切り) Package を返す。Offering に未設定なら null。
  LifetimePackageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lifetimePackageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lifetimePackageHash();

  @$internal
  @override
  $ProviderElement<Package?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Package? create(Ref ref) {
    return lifetimePackage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Package? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Package?>(value),
    );
  }
}

String _$lifetimePackageHash() => r'd6ce85cb4d25c704a916e53bbae5458d1fbcdd7b';

@ProviderFor(monthlyPremiumPackage)
final monthlyPremiumPackageProvider = MonthlyPremiumPackageProvider._();

final class MonthlyPremiumPackageProvider
    extends $FunctionalProvider<Package?, Package?, Package?>
    with $Provider<Package?> {
  MonthlyPremiumPackageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyPremiumPackageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyPremiumPackageHash();

  @$internal
  @override
  $ProviderElement<Package?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Package? create(Ref ref) {
    return monthlyPremiumPackage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Package? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Package?>(value),
    );
  }
}

String _$monthlyPremiumPackageHash() =>
    r'7572232808b77c79e276b7538f148bc97f61a07b';
