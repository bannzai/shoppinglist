import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/utils/config/platform.dart';

// See also: https://docs.revenuecat.com/docs/errors
Exception? mapToDisplayedException(
  AppLocalizations l10n,
  PlatformException exception,
) {
  final errorCode = PurchasesErrorHelper.getErrorCode(exception);
  final details = '${exception.message}:${exception.details}';
  final code = '$errorCode';
  switch (errorCode) {
    case PurchasesErrorCode.unknownError:
      return FormatException(l10n.purchaseErrorUnknown(details));
    case PurchasesErrorCode.purchaseCancelledError:
      // NOTE: This exception indicates that the User has canceled.
      // See more details: https://docs.revenuecat.com/docs/errors#--purchase_cancelled
      // > No action required. The user decided not to proceed with their in-app purchase.
      return null;
    case PurchasesErrorCode.storeProblemError:
      // NOTE: RevenueCat auto retring purchase request on backend services.
      // ReplAI must not be handling error message.
      // See more detail: https://docs.revenuecat.com/docs/errors#--store_problem
      // > If everything was working while testing, you shouldn't have to do anything to handle this error in production. RevenueCat will automatically retry any purchase failures so no data is lost.
      // But, return ambigious error message to be the on the safe side
      return FormatException(l10n.purchaseErrorStoreProblem(storeName));
    case PurchasesErrorCode.purchaseNotAllowedError:
      // NOTE: Maybe simulator or emulators
      // See more details: https://docs.revenuecat.com/docs/errors#--purchase_not_allowed
      return FormatException(l10n.purchaseErrorNotAllowed);
    case PurchasesErrorCode.purchaseInvalidError:
      // See more details: https://docs.revenuecat.com/docs/errors#-purchase_invalid
      return FormatException(l10n.purchaseErrorInvalidPayment);
    case PurchasesErrorCode.productNotAvailableForPurchaseError:
      // Maybe missed implement or User references older payment product.
      // See more details: https://docs.revenuecat.com/docs/errors#-product_not_available_for_purchase
      return FormatException(l10n.purchaseErrorProductNotAvailable);
    case PurchasesErrorCode.productAlreadyPurchasedError:
      // User already has same product. Announcement to restore
      // See more details: https://docs.revenuecat.com/docs/errors#-product_already_purchased
      // > If this occurs in production, make sure the user restores purchases to re-sync any transactions with their current App User Id.
      return FormatException(l10n.purchaseErrorAlreadyPurchased);
    case PurchasesErrorCode.receiptAlreadyInUseError:
      return FormatException(
        l10n.purchaseErrorReceiptAlreadyInUse(accountName(l10n)),
      );
    case PurchasesErrorCode.invalidReceiptError:
      return FormatException(l10n.purchaseErrorInvalidReceipt);
    case PurchasesErrorCode.missingReceiptFileError:
      return FormatException(
        l10n.purchaseErrorMissingReceipt(accountName(l10n)),
      );
    case PurchasesErrorCode.networkError:
      return FormatException(l10n.purchaseErrorNetwork);
    case PurchasesErrorCode.invalidCredentialsError:
      // Maybe developer or store settings error
      // See more details: https://docs.revenuecat.com/docs/errors#---invalid_credentials
      return FormatException(l10n.purchaseErrorPurchaseFailed(details));
    case PurchasesErrorCode.unexpectedBackendResponseError:
      // Maybe RevenueCat incident
      // See more details: https://docs.revenuecat.com/docs/errors#-unexpected_backend_response_error
      return FormatException(l10n.purchaseErrorUnavailable(details));
    case PurchasesErrorCode.receiptInUseByOtherSubscriberError:
      return FormatException(
        l10n.purchaseErrorReceiptInUseByOther(accountName(l10n)),
      );
    case PurchasesErrorCode.invalidAppUserIdError:
      return FormatException(l10n.purchaseErrorInvalidAppUserId(details));
    case PurchasesErrorCode.operationAlreadyInProgressError:
      return FormatException(l10n.purchaseErrorOperationInProgress);
    case PurchasesErrorCode.unknownBackendError:
      // Maybe RevenueCat incident
      // See more details: https://docs.revenuecat.com/docs/errors#-unknown_backend_error
      return FormatException(l10n.purchaseErrorUnavailable(details));
    case PurchasesErrorCode.invalidAppleSubscriptionKeyError:
      // Maybe developer setting error on AppStore
      // See more details: https://docs.revenuecat.com/docs/errors#-invalid_apple_subscription_key
      // > In order to provide Subscription Offers you must first generate a subscription key.
      return FormatException(l10n.purchaseErrorPurchaseFailed(details));
    case PurchasesErrorCode.ineligibleError:
      // Invalidate user
      // See more details: https://docs.revenuecat.com/docs/errors#-ineligible_error
      return FormatException(l10n.purchaseErrorIneligible(details));
    case PurchasesErrorCode.insufficientPermissionsError:
      return FormatException(
        l10n.purchaseErrorInsufficientPermissions(accountName(l10n)),
      );
    case PurchasesErrorCode.paymentPendingError:
      return FormatException(
        l10n.purchaseErrorPaymentPending(accountName(l10n), storeName),
      );
    case PurchasesErrorCode.invalidSubscriberAttributesError:
      // See more details: https://docs.revenuecat.com/docs/errors#-invalid_subscriber_attributes
      return FormatException(l10n.purchaseErrorPurchaseFailed(details));
    case PurchasesErrorCode.logOutWithAnonymousUserError:
      return FormatException(l10n.purchaseErrorUserInfoFailed(details));
    case PurchasesErrorCode.configurationError:
      return FormatException(l10n.purchaseErrorConfiguration(details));
    case PurchasesErrorCode.unsupportedError:
      return FormatException(l10n.purchaseErrorUpdateRequired(code, details));
    case PurchasesErrorCode.emptySubscriberAttributesError:
      return FormatException(
        l10n.purchaseErrorEmptySubscriberAttributes(details),
      );
    case PurchasesErrorCode.productDiscountMissingIdentifierError:
      return FormatException(l10n.purchaseErrorUpdateRequired(code, details));
    case PurchasesErrorCode.unknownNonNativeError:
      return FormatException(l10n.purchaseErrorUpdateRequired(code, details));
    case PurchasesErrorCode
        .productDiscountMissingSubscriptionGroupIdentifierError:
      return FormatException(l10n.purchaseErrorUpdateRequired(code, details));
    case PurchasesErrorCode.customerInfoError:
      return FormatException(l10n.purchaseErrorCustomerInfo(code, details));
    case PurchasesErrorCode.systemInfoError:
      return FormatException(l10n.purchaseErrorSystemInfo(code, details));
    case PurchasesErrorCode.beginRefundRequestError:
      return FormatException(
        l10n.purchaseErrorBeginRefundRequest(code, details),
      );
    case PurchasesErrorCode.productRequestTimeout:
      return FormatException(l10n.purchaseErrorTimeout(details));
    case PurchasesErrorCode.apiEndpointBlocked:
      return FormatException(l10n.purchaseErrorUpdateRequired(code, details));
    case PurchasesErrorCode.invalidPromotionalOfferError:
      return FormatException(l10n.purchaseErrorUpdateRequired(code, details));
    case PurchasesErrorCode.offlineConnectionError:
      return FormatException(l10n.purchaseErrorOfflineConnection(details));
    case PurchasesErrorCode
        .featureNotAvailableInCustomEntitlementsComputationMode:
      return FormatException(
        l10n.purchaseErrorFeatureNotAvailable(code, details),
      );
    case PurchasesErrorCode.signatureVerificationFailed:
      return FormatException(
        l10n.purchaseErrorSignatureVerification(code, details),
      );
    case PurchasesErrorCode.featureNotSupportedWithStoreKit1:
      return FormatException(
        l10n.purchaseErrorFeatureNotSupported(code, details),
      );
    case PurchasesErrorCode.invalidWebPurchaseToken:
      return FormatException(
        l10n.purchaseErrorInvalidWebPurchaseToken(code, details),
      );
    case PurchasesErrorCode.purchaseBelongsToOtherUser:
      return FormatException(
        l10n.purchaseErrorBelongsToOtherUser(code, details),
      );
    case PurchasesErrorCode.expiredWebPurchaseToken:
      return FormatException(
        l10n.purchaseErrorExpiredWebPurchaseToken(code, details),
      );
    case PurchasesErrorCode.testStoreSimulatedPurchaseError:
      return FormatException(
        l10n.purchaseErrorTestStoreSimulated(code, details),
      );
  }
}
