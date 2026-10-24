import admin from "firebase-admin";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { currentAuthUID } from "../utils/currentAuthUID";
import { appAuthPolicy } from "../utils/authPolicy";
import {
  fetchPremiumEntitlementState,
  revenueCatSecretApiKey,
} from "../utils/premium";
import {
  DataResponseSchema,
  ErrorResponseSchema,
} from "../../entity/response";
import { premiumEntitlementDocumentID } from "../../entity/premium_entitlement";

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      isPremium: z.boolean(),
    }),
  }),
  ErrorResponseSchema,
]);

/**
 * 認証ユーザーのプレミアム状態を RevenueCat から取得し、
 * `users/{uid}/premiumEntitlements/PremiumEntitlement_users_{uid}` に書き写す Function。
 *
 * firestore.rules は RevenueCat を参照できないため、無料プランの買い物リスト数の上限判定
 * (Issue #683) はこの写しを `get()` で読む。クライアントは RevenueCat の CustomerInfo が
 * 変わるたびに呼ぶ。書き込み先は rules でクライアントからの書き込みを拒否している。
 * 取得に失敗した場合は写しを書き換えずに NG を返す (一時的な失敗で有料会員を無料扱いにしないため)。
 * 同じ RevenueCat の状態に対しては同じ内容を書くため冪等。
 *
 * ## 検証用パラメータ例
 * ```json
 * {}
 * ```
 */
const syncPremiumEntitlementFlow = ai.defineFlow(
  {
    name: "syncPremiumEntitlement",
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

      const premiumEntitlementState = await fetchPremiumEntitlementState(uid);
      await admin
        .firestore()
        .collection(`users/${uid}/premiumEntitlements`)
        .doc(premiumEntitlementDocumentID({ userID: uid }))
        .set(
          {
            userID: uid,
            isPremium: premiumEntitlementState.isPremium,
            expiresDateTime:
              premiumEntitlementState.expiresDateTime == null
                ? null
                : Timestamp.fromDate(premiumEntitlementState.expiresDateTime),
            serverCreatedDateTime: FieldValue.serverTimestamp(),
            serverUpdatedDateTime: FieldValue.serverTimestamp(),
          },
          { merge: true }
        );

      logger.info(
        `Synced premium entitlement of ${uid}: ${premiumEntitlementState.isPremium}`
      );

      return {
        result: "OK" as const,
        data: { isPremium: premiumEntitlementState.isPremium },
      } as z.infer<typeof ResponseSchema>;
    } catch (error) {
      logger.error(error);
      return {
        result: "NG" as const,
        error: {
          message:
            error instanceof Error
              ? error.message
              : "プレミアム状態の同期に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("syncPremiumEntitlement"),
    secrets: [revenueCatSecretApiKey],
  },
  syncPremiumEntitlementFlow
);
