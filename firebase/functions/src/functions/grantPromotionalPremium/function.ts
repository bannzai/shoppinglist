import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { currentAuthUID } from "../utils/currentAuthUID";
import { appAuthPolicy } from "../utils/authPolicy";
import {
  PREMIUM_ENTITLEMENT_IDENTIFIER,
  revenueCatSecretApiKey,
} from "../utils/premium";
import { developerToken, isDeveloper } from "../../core/developer";
import {
  DataResponseSchema,
  ErrorResponseSchema,
} from "../../entity/response";

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

      // RevenueCat Promotions APIを呼び出してプレミアムEntitlementを付与する。
      // Custom Claimsの設定は不要。クライアント側でRevenueCat SDKのcustomerInfoを
      // refetchすることでプレミアム状態を取得する。
      const revenueCatResponse = await fetch(
        `https://api.revenuecat.com/v1/subscribers/${uid}/entitlements/${PREMIUM_ENTITLEMENT_IDENTIFIER}/promotional`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${revenueCatSecretApiKey.value()}`,
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
    secrets: [developerToken, revenueCatSecretApiKey],
  },
  grantPromotionalPremiumFlow
);
