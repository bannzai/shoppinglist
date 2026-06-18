import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/utils/config/environment.dart';
import 'package:shoppinglist/secret/secret.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/logger/error.dart';
import 'package:shoppinglist/utils/purchase/error.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase.g.dart';

const promotionProductIdentifierPrefix = 'rc_promo_Premium';
const premiumEntitlementIdentifier = 'Premium';

enum OfferingType { discounted, premium }

extension OfferingTypeFunction on OfferingType {
  String get identifier {
    switch (this) {
      case OfferingType.discounted:
        return 'discounted';

      case OfferingType.premium:
        return 'default';
    }
  }
}

final customerInfoProvider = StreamProvider((ref) {
  final StreamController<CustomerInfo> stream =
      StreamController<CustomerInfo>();
  // ref.invalidate 直後でも最新の CustomerInfo を即座に AsyncData として返せるよう、
  // Purchases.getCustomerInfo() の結果を初期値として流す。listener 経由の更新は
  // その後に上書きされる。
  Purchases.getCustomerInfo().then((info) {
    if (!stream.isClosed) {
      stream.sink.add(info);
    }
  });
  void listener(CustomerInfo customerInfo) {
    stream.sink.add(customerInfo);
  }

  Purchases.addCustomerInfoUpdateListener(listener);

  ref.onDispose(() {
    Purchases.removeCustomerInfoUpdateListener(listener);
    stream.close();
  });
  return stream.stream;
});

extension CustomerInfoExtension on CustomerInfo {
  // rc_promo_Premium `のみ` が含まれている場合は値を返す
  DateTime? get promotionExpirationDate {
    final premiumEntitlement =
        entitlements.active[premiumEntitlementIdentifier];
    final expirationDate = premiumEntitlement?.expirationDate;
    if (premiumEntitlement == null || expirationDate == null) {
      return null;
    }
    if (!premiumEntitlement.productIdentifier.startsWith(
      promotionProductIdentifierPrefix,
    )) {
      return null;
    }

    if (activeSubscriptions.isEmpty) {
      return null;
    }
    if (activeSubscriptions.any(
      (element) => !element.startsWith(promotionProductIdentifierPrefix),
    )) {
      return null;
    }
    return DateTime.parse(expirationDate);
  }

  // Promotional Entitlement 期間中も true を返す（Focus アプリの hasPremiumEntitlement と
  // 同じ方針）。ディスカウント表示判定は isInDiscountDuration / currentOfferingType で
  // 独立に行うため、ここで除外する必要はない。Issue #239 でも「プロモーション付与で
  // プレミアム機能を解禁する」前提に揃える。
  bool get isPremium {
    return entitlements.active.containsKey(premiumEntitlementIdentifier);
  }

  bool get isInPromotion {
    return promotionExpirationDate?.isAfter(DateTime.now()) ?? false;
  }

  DateTime? get discountDeadlineDate {
    return promotionExpirationDate?.add(const Duration(days: 3));
  }

  bool get isInDiscountDuration {
    if (discountDeadlineDate == null) {
      return false;
    }
    return discountDeadlineDate!.isAfter(DateTime.now());
  }

  OfferingType get currentOfferingType {
    if (isInDiscountDuration) {
      return OfferingType.discounted;
    } else {
      return OfferingType.premium;
    }
  }
}

/// RevenueCat Offerings を取得する Provider。
///
/// `Purchases.configure` 直後の race（Issue #237: Maestro `clearState=true +
/// clearKeychain=true` 起動で `PlatformException(code:23, CONFIGURATION_ERROR)`
/// を踏むケース）に備え、`PurchasesErrorCode.configurationError` のみ
/// 指数バックオフで最大 3 回 retry する。それ以外のエラーは即時 rethrow。
@Riverpod()
Future<Offerings> offerings(Ref ref) async {
  const retryDelays = [
    Duration(milliseconds: 500),
    Duration(seconds: 1),
    Duration(seconds: 2),
  ];
  for (var attempt = 0; ; attempt++) {
    try {
      return await Purchases.getOfferings();
    } on PlatformException catch (exception) {
      final isConfigurationError =
          PurchasesErrorHelper.getErrorCode(exception) ==
          PurchasesErrorCode.configurationError;
      if (!isConfigurationError || attempt >= retryDelays.length) {
        rethrow;
      }
      analytics.logEvent(
        name: 'offerings_retry_after_configuration_error',
        parameters: {'attempt': attempt},
      );
      await Future.delayed(retryDelays[attempt]);
    }
  }
}

@Riverpod()
List<Package> currentOfferingPackages(Ref ref) {
  final offerings = ref.watch(offeringsProvider).asData?.value;
  final customerInfo = ref.watch(customerInfoProvider).asData?.value;
  if (offerings == null || customerInfo == null) {
    return [];
  }

  // 通常は currentOfferingType.identifier ('default'/'discounted') の Offering を使う。
  // 当該 identifier が未設定の構成でも RC の "Current" Offering で表示できるよう fallback する。
  final offering =
      offerings.all[customerInfo.currentOfferingType.identifier] ??
      offerings.current;
  return offering?.availablePackages ?? [];
}

@Riverpod()
Package? weeklyPackage(Ref ref) {
  final currentOfferingPackages = ref.watch(currentOfferingPackagesProvider);
  return currentOfferingPackages.firstWhereOrNull(
    (element) => element.packageType == PackageType.weekly,
  );
}

@Riverpod()
Package? monthlyPackage(Ref ref) {
  final currentOfferingPackages = ref.watch(currentOfferingPackagesProvider);
  return currentOfferingPackages.firstWhereOrNull(
    (element) => element.packageType == PackageType.monthly,
  );
}

@Riverpod()
Package? sixMonthPackage(Ref ref) {
  final currentOfferingPackages = ref.watch(currentOfferingPackagesProvider);
  return currentOfferingPackages.firstWhereOrNull(
    (element) => element.packageType == PackageType.sixMonth,
  );
}

/// 現在 Offering から annual (1 年) Package を返す。Offering に未設定なら null。
@Riverpod()
Package? annualPackage(Ref ref) {
  final currentOfferingPackages = ref.watch(currentOfferingPackagesProvider);
  return currentOfferingPackages.firstWhereOrNull(
    (element) => element.packageType == PackageType.annual,
  );
}

/// 現在 Offering から lifetime (買い切り) Package を返す。Offering に未設定なら null。
@Riverpod()
Package? lifetimePackage(Ref ref) {
  final currentOfferingPackages = ref.watch(currentOfferingPackagesProvider);
  return currentOfferingPackages.firstWhereOrNull(
    (element) => element.packageType == PackageType.lifetime,
  );
}

@Riverpod()
Package? monthlyPremiumPackage(Ref ref) {
  const premiumPackageOfferingType = OfferingType.premium;
  final offering =
      ref.watch(offeringsProvider).valueOrNull?.all[premiumPackageOfferingType
          .identifier];
  if (offering == null) {
    return null;
  }
  return offering.availablePackages.firstWhereOrNull(
    (element) => element.packageType == PackageType.monthly,
  );
}

// Issue #237 (https://github.com/bannzai/shoppinglist/issues/237) /
// Issue #239 (https://github.com/bannzai/shoppinglist/issues/239) 経緯:
// iOS Test Store mock purchase modal 経由の Maestro E2E (`maestro/flows/shared/mock_purchase.yaml`)
// が long-term で flaky なため、`premium_*.yaml` の動作確認は
// `maestro/flows/shared/grant_premium_via_debug.yaml` 経由（開発者オプション画面の
// 「プレミアム付与（1日）」ボタンから RC Promotional Entitlement を直接付与）に切り替えた。
// `iap_purchase_*.yaml` のみ実購入動線検証として mock_purchase を踏み続ける。

/// RevenueCat SDK の初期化。
///
/// `Purchases.configure` は同期返却 API だが、内部のネイティブ初期化は
/// 非同期で走る。Issue #237: Maestro `clearState=true + clearKeychain=true`
/// 起動時、初期化完了前に `getOfferings` が走り CONFIGURATION_ERROR を踏むため、
/// configure 直後に `Purchases.getCustomerInfo()` を await して
/// SDK の初期化完了を barrier として待つ。
Future<void> initializePurchase() async {
  await Purchases.setLogLevel(
    Environment.isDevelopment ? LogLevel.debug : LogLevel.info,
  );

  // kDebugMode=true のとき RC Test Store Key を使い、mock purchase modal で IAP フローを検証する。
  // Release ビルドでは kDebugMode=false となり本番キーが使われる（本番キー誤差し替え防止のガード）。
  // Debug ビルドで本番課金フローを検証したい場合は、ここの apiKey の値を一時的に
  // Secret.revenueCatPublicAPIKey に差し替える運用とする（USE_RC_TEST_STORE のような環境変数スイッチは設けない）。
  final apiKey =
      kDebugMode
          ? Secret.revenueCatTestStorePublicAPIKey
          : Secret.revenueCatPublicAPIKey;

  assert(
    !kDebugMode || apiKey.isNotEmpty,
    'REVENUECAT_TEST_STORE_API_KEY is required in debug builds. '
    'Pass it via --dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx',
  );

  Purchases.configure(PurchasesConfiguration(apiKey));

  // configure 完了の barrier。CustomerInfo 取得失敗自体は致命でないため例外を握りつぶす
  // （offeringsProvider 側で getOfferings を retry するため）。
  try {
    await Purchases.getCustomerInfo();
  } on PlatformException catch (exception, stack) {
    errorLogger.recordError(exception, stack);
  }
}

final purchaseProvider = Provider((ref) => Purchase());

class Purchase {
  /// Return true indicates end of regularllly pattern.
  /// Return false indicates not regulally pattern.
  /// Return value is used to display the completion page
  Future<bool> call(Package package) async {
    try {
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      final premiumEntitlement =
          purchaseResult
              .customerInfo
              .entitlements
              .all[premiumEntitlementIdentifier];
      if (premiumEntitlement == null) {
        throw AssertionError('unexpected premium entitlements is not exists');
      }
      if (!premiumEntitlement.isActive) {
        throw const FormatException('課金の有効化が完了しておりません。しばらく時間をおいてからご確認ください');
      }
      return Future.value(true);
    } on PlatformException catch (exception, stack) {
      analytics.logEvent(
        name: 'catched_purchase_exception',
        parameters: {
          'code': exception.code,
          'details': exception.details.toString(),
          'message': exception.message ?? 'empty message',
        },
      );
      final newException = mapToDisplayedException(exception);
      if (newException == null) {
        return Future.value(false);
      }
      errorLogger.recordError(exception, stack);
      throw newException;
    } catch (exception, stack) {
      analytics.logEvent(
        name: 'catched_purchase_anonymous',
        parameters: {'exception_type': exception.runtimeType.toString()},
      );
      errorLogger.recordError(exception, stack);
      rethrow;
    }
  }
}
