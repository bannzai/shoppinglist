import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import { defineString } from "firebase-functions/params";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { appAuthPolicy } from "../utils/authPolicy";
import { developerToken, isDeveloper } from "../../core/developer";
import {
  DataResponseSchema,
  ErrorResponseSchema,
} from "../../entity/response";

/// RevenueCat Secret API Key。Promotions APIの呼び出しに使用する。
const REVENUECAT_SECRET_API_KEY = defineString("REVENUECAT_SECRET_API_KEY");

/// RevenueCatのプレミアムEntitlement識別子。
const PREMIUM_ENTITLEMENT_IDENTIFIER = "Premium";

/// プロモーション付与の期間。
type PromotionDuration =
  | "daily"
  | "three_day"
  | "weekly"
  | "monthly"
  | "two_month"
  | "three_month"
  | "six_month"
  | "yearly"
  | "lifetime";

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      success: z.boolean(),
    }),
  }),
  ErrorResponseSchema,
]);

// 検証用引数: { "duration": "daily" }
const grantPromotionalPremiumFlow = ai.defineFlow(
  {
    name: "grantPromotionalPremium",
    inputSchema: z.object({
      duration: z
        .enum([
          "daily",
          "three_day",
          "weekly",
          "monthly",
          "two_month",
          "three_month",
          "six_month",
          "yearly",
          "lifetime",
        ])
        .default("daily"),
    }),
    outputSchema: ResponseSchema,
  },
  async ({ duration }) => {
    try {
      const context = ai.currentContext();
      const uid = context?.auth?.uid;
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

      // RevenueCat Promotions APIを呼び出してプレミアムEntitlementを付与する。
      // Custom Claimsの設定は不要。クライアント側でRevenueCat SDKのcustomerInfoを
      // refetchすることでプレミアム状態を取得する。
      const revenueCatResponse = await fetch(
        `https://api.revenuecat.com/v1/subscribers/${uid}/entitlements/${PREMIUM_ENTITLEMENT_IDENTIFIER}/promotional`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${REVENUECAT_SECRET_API_KEY.value()}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ duration: duration as PromotionDuration }),
        }
      );

      if (!revenueCatResponse.ok) {
        const errorBody = await revenueCatResponse.text();
        logger.error(
          `RevenueCat Promotions API error: ${revenueCatResponse.status} ${errorBody}`
        );
        return {
          result: "NG" as const,
          error: {
            message: `RevenueCat APIエラー: ${revenueCatResponse.status}`,
          },
        };
      }

      logger.info(
        `Granted promotional premium to ${uid} with duration ${duration}`
      );

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
              : "プレミアムの付与に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("grantPromotionalPremium"),
    secrets: [developerToken],
  },
  grantPromotionalPremiumFlow
);
