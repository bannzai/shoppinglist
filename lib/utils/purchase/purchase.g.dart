// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$offeringsHash() => r'ebd4126332e68385e116eae2daef545cc07975d9';

/// RevenueCat Offerings を取得する Provider。
///
/// `Purchases.configure` 直後の race（Issue #237: Maestro `clearState=true +
/// clearKeychain=true` 起動で `PlatformException(code:23, CONFIGURATION_ERROR)`
/// を踏むケース）に備え、`PurchasesErrorCode.configurationError` のみ
/// 指数バックオフで最大 3 回 retry する。それ以外のエラーは即時 rethrow。
///
/// Copied from [offerings].
@ProviderFor(offerings)
final offeringsProvider = AutoDisposeFutureProvider<Offerings>.internal(
  offerings,
  name: r'offeringsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$offeringsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfferingsRef = AutoDisposeFutureProviderRef<Offerings>;
String _$currentOfferingPackagesHash() =>
    r'5107fb41411f79b3bf42a35d141a1d7c0d57c0f0';

/// See also [currentOfferingPackages].
@ProviderFor(currentOfferingPackages)
final currentOfferingPackagesProvider =
    AutoDisposeProvider<List<Package>>.internal(
      currentOfferingPackages,
      name: r'currentOfferingPackagesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$currentOfferingPackagesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentOfferingPackagesRef = AutoDisposeProviderRef<List<Package>>;
String _$weeklyPackageHash() => r'ba26c9b5ee0fd47b82377fe698a98759c7286f1e';

/// See also [weeklyPackage].
@ProviderFor(weeklyPackage)
final weeklyPackageProvider = AutoDisposeProvider<Package?>.internal(
  weeklyPackage,
  name: r'weeklyPackageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weeklyPackageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeeklyPackageRef = AutoDisposeProviderRef<Package?>;
String _$monthlyPackageHash() => r'43e529cd7d27fba0cf9e591bc80f23b0abf2d893';

/// See also [monthlyPackage].
@ProviderFor(monthlyPackage)
final monthlyPackageProvider = AutoDisposeProvider<Package?>.internal(
  monthlyPackage,
  name: r'monthlyPackageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$monthlyPackageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyPackageRef = AutoDisposeProviderRef<Package?>;
String _$sixMonthPackageHash() => r'3293887aad384d28bcb0ae42e2f94c35a6028c33';

/// See also [sixMonthPackage].
@ProviderFor(sixMonthPackage)
final sixMonthPackageProvider = AutoDisposeProvider<Package?>.internal(
  sixMonthPackage,
  name: r'sixMonthPackageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sixMonthPackageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SixMonthPackageRef = AutoDisposeProviderRef<Package?>;
String _$annualPackageHash() => r'84a4a588f0eaebbd8d31e87c839f0c2cb6ece25e';

/// 現在 Offering から annual (1 年) Package を返す。Offering に未設定なら null。
///
/// Copied from [annualPackage].
@ProviderFor(annualPackage)
final annualPackageProvider = AutoDisposeProvider<Package?>.internal(
  annualPackage,
  name: r'annualPackageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$annualPackageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnnualPackageRef = AutoDisposeProviderRef<Package?>;
String _$lifetimePackageHash() => r'd6ce85cb4d25c704a916e53bbae5458d1fbcdd7b';

/// 現在 Offering から lifetime (買い切り) Package を返す。Offering に未設定なら null。
///
/// Copied from [lifetimePackage].
@ProviderFor(lifetimePackage)
final lifetimePackageProvider = AutoDisposeProvider<Package?>.internal(
  lifetimePackage,
  name: r'lifetimePackageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lifetimePackageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LifetimePackageRef = AutoDisposeProviderRef<Package?>;
String _$monthlyPremiumPackageHash() =>
    r'b60369ee20eb3938b31dae6ff05bebfcb615512f';

/// See also [monthlyPremiumPackage].
@ProviderFor(monthlyPremiumPackage)
final monthlyPremiumPackageProvider = AutoDisposeProvider<Package?>.internal(
  monthlyPremiumPackage,
  name: r'monthlyPremiumPackageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$monthlyPremiumPackageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyPremiumPackageRef = AutoDisposeProviderRef<Package?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
