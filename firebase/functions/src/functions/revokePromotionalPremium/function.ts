import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import { defineSecret } from "firebase-functions/params";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { currentAuthUID } from "../utils/currentAuthUID";
import { appAuthPolicy } from "../utils/authPolicy";
import { developerToken, isDeveloper } from "../../core/developer";
import {
  DataResponseSchema,
  ErrorResponseSchema,
} from "../../entity/response";

/// RevenueCat Secret API Key。Promotions APIのrevoke呼び出しに使用する。Secret Manager 経由で取得。
const revenueCatSecretApiKey = defineSecret("REVENUECAT_SECRET_API_KEY");

/// RevenueCatのプレミアムEntitlement識別子。
const PREMIUM_ENTITLEMENT_IDENTIFIER = "Premium";

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      success: z.boolean(),
    }),
  }),
  ErrorResponseSchema,
]);

// 検証用引数: {}
const revokePromotionalPremiumFlow = ai.defineFlow(
  {
    name: "revokePromotionalPremium",
    inputSchema: z.object({}),
    outputSchema: ResponseSchema,
  },
  async () => {
    try {
      const uid = currentAuthUID();
      if (!uid) {
        return {
          result: "NG" as const,
          error: { message: "認証されていません" },
        };
      }
      // 登録された開発者本人のみ実行可能。本番ユーザーが叩いても NG を返す。
      if (!(await isDeveloper(uid))) {
        return {
          result: "NG" as const,
          error: { message: "この機能は開発者のみ使用できます" },
        };
      }

      // RevenueCat v1 Promotions API: 当該ユーザーに付与済みの Promotional Entitlement
      // を即時取り消す。実購入由来の Entitlement には影響しない。
      // 関連 Issue: #237 (https://github.com/bannzai/shoppinglist/issues/237) /
      //          #239 (https://github.com/bannzai/shoppinglist/issues/239)
      const revenueCatResponse = await fetch(
        `https://api.revenuecat.com/v1/subscribers/${uid}/entitlements/${PREMIUM_ENTITLEMENT_IDENTIFIER}/revoke_promotionals`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${revenueCatSecretApiKey.value()}`,
            "Content-Type": "application/json",
          },
        }
      );

      if (!revenueCatResponse.ok) {
        const errorBody = await revenueCatResponse.text();
        logger.error(
          `RevenueCat Revoke Promotions API error: ${revenueCatResponse.status} ${errorBody}`
        );
        return {
          result: "NG" as const,
          error: {
            message: `RevenueCat APIエラー: ${revenueCatResponse.status}`,
          },
        };
      }

      logger.info(`Revoked promotional premium from ${uid}`);

      return {
        result: "OK" as const,
        data: { success: true },
      } as z.infer<typeof ResponseSchema>;
    } catch (error) {
      logger.error(error);
      return {
        result: "NG" as const,
        error: {
          message:
            error instanceof Error
              ? error.message
              : "プレミアムの剥奪に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("revokePromotionalPremium"),
    secrets: [developerToken, revenueCatSecretApiKey],
  },
  revokePromotionalPremiumFlow
);
