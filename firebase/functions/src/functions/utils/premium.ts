import { logger } from "firebase-functions";
import { defineSecret } from "firebase-functions/params";

/// RevenueCat Secret API Key。Subscribers/Promotions APIの呼び出しに使用する。Secret Manager 経由で取得。
export const revenueCatSecretApiKey = defineSecret("REVENUECAT_SECRET_API_KEY");

/// RevenueCatのプレミアムEntitlement識別子。
export const PREMIUM_ENTITLEMENT_IDENTIFIER = "Premium";

/** RevenueCat Subscribers APIレスポンスのうちプレミアム判定に必要な部分。 */
interface RevenueCatSubscriberResponse {
  subscriber?: {
    entitlements?: Record<string, { expires_date: string | null }>;
  };
}

/**
 * RevenueCat Subscribers APIからプレミアム判定を行う。
 *
 * プレミアム状態のSSOTはRevenueCatであり、ストア課金・Promotional付与の両方が反映される。
 * Firebase Auth Custom Claimsは購入時に設定する経路が存在せず常にfalseになるため使用しない（Issue #385）。
 * GET /v1/subscribers は未登録のsubscriberを登録して返すが、繰り返し呼んでも同一状態になるため冪等。
 * 判定に失敗した場合は無料ユーザーとして扱う。
 */
export async function hasPremiumEntitlement(uid: string): Promise<boolean> {
  try {
    const response = await fetch(
      `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(uid)}`,
      {
        headers: {
          Authorization: `Bearer ${revenueCatSecretApiKey.value()}`,
          "Content-Type": "application/json",
        },
      }
    );
    if (!response.ok) {
      logger.error("hasPremiumEntitlement: RevenueCat API error", {
        uid,
        status: response.status,
      });
      return false;
    }

    const entitlement = (
      (await response.json()) as RevenueCatSubscriberResponse
    ).subscriber?.entitlements?.[PREMIUM_ENTITLEMENT_IDENTIFIER];
    if (!entitlement) {
      return false;
    }
    // expires_date が null は無期限（lifetime）の付与を表す
    return (
      entitlement.expires_date == null ||
      Date.parse(entitlement.expires_date) > Date.now()
    );
  } catch (error) {
    logger.error("hasPremiumEntitlement failed", {
      uid,
      errorName: error instanceof Error ? error.name : "unknown",
    });
    return false;
  }
}
