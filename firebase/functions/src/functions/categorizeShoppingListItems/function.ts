import admin from "firebase-admin";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { currentAuthUID } from "../utils/currentAuthUID";
import { appAuthPolicy } from "../utils/authPolicy";
import { DataResponseSchema, ErrorResponseSchema } from "../../entity/response";
import { UserAIUsageData } from "../../entity/ai_usage";
import { defineSecret } from "firebase-functions/params";

/// Gemini API Key。Secret Manager 経由で取得する。
const googleAIApiKey = defineSecret("GOOGLE_GENAI_API_KEY");

/** カテゴリ分けに使うモデル。環境変数で切り替え可能。 */
const categorizeModel =
  process.env.CATEGORIZE_MODEL ?? "googleai/gemini-2.5-flash";

/** 1リクエストで分類できる最大アイテム数。 */
const maxItems = 100;

/** 1アイテム名/カテゴリ名あたりの最大文字数。 */
const maxNameLength = 100;

/** 無料ユーザーのAIカテゴリ分け月次上限。 */
const freeMonthlyCategorizeLimit = 5;

/** プレミアムユーザーのAIカテゴリ分け月次上限。 */
const premiumMonthlyCategorizeLimit = 50;

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      categorizedItems: z.array(
        z.object({ name: z.string(), categoryName: z.string() })
      ),
    }),
  }),
  ErrorResponseSchema,
]);

/** AI構造化出力のスキーマ。 */
const CategorizationSchema = z.object({
  categorizedItems: z.array(
    z.object({ name: z.string(), categoryName: z.string() })
  ),
});

/** Firebase Auth Custom Claimsからプレミアム判定を行う。 */
async function hasPremiumEntitlement(uid: string): Promise<boolean> {
  try {
    return (await admin.auth().getUser(uid)).customClaims?.["premium"] === true;
  } catch (error) {
    logger.error("hasPremiumEntitlement failed", {
      uid,
      errorName: error instanceof Error ? error.name : "unknown",
    });
    return false;
  }
}

/**
 * 買い物リストの未分類アイテムを「野菜」「肉」等のカテゴリに分類するFunction。
 *
 * クライアント側ではアイテムにカテゴリIDを持たず、カテゴリのキーワードとの
 * マッチングで分類するため、ここでは「アイテム名 → カテゴリ名」の対応のみを返す。
 * 永続化（キーワード追記・カテゴリ作成）はクライアントが行う。
 *
 * ## 検証用パラメータ例
 * ```json
 * {
 *   "itemNames": ["にんじん", "牛乳", "鶏もも肉", "トイレットペーパー"],
 *   "existingCategoryNames": ["野菜", "肉"]
 * }
 * ```
 *
 * ## 制限
 * - 認証必須
 * - itemNames: 1〜100件、各100文字以下
 * - 月次利用上限: 無料5回、プレミアム50回（UTC基準）
 */
const categorizeShoppingListItemsFlow = ai.defineFlow(
  {
    name: "categorizeShoppingListItems",
    inputSchema: z.object({
      itemNames: z.array(z.string()),
      existingCategoryNames: z.array(z.string()),
    }),
    outputSchema: ResponseSchema,
  },
  async (input: { itemNames: string[]; existingCategoryNames: string[] }) => {
    // 認証チェック（クライアントからの回避を防ぐため Function 側で強制）
    const uid = currentAuthUID();
    if (!uid) {
      return { result: "NG" as const, error: { message: "認証されていません" } };
    }

    // 入力検証: アイテム名
    const itemNames = input.itemNames
      .map((n) => n.trim())
      .filter((n) => n.length > 0 && n.length <= maxNameLength)
      .slice(0, maxItems);
    if (itemNames.length === 0) {
      return {
        result: "NG" as const,
        error: { message: "分類するアイテムがありません" },
      };
    }
    const existingCategoryNames = input.existingCategoryNames
      .map((n) => n.trim())
      .filter((n) => n.length > 0 && n.length <= maxNameLength);

    // サーバー管理データからプレミアム判定（クライアントの申告値は信用しない）
    const isPremium = await hasPremiumEntitlement(uid);
    const monthlyLimit = isPremium
      ? premiumMonthlyCategorizeLimit
      : freeMonthlyCategorizeLimit;

    const firestore = admin.firestore();
    const now = new Date();
    const yearMonth = `${now.getUTCFullYear()}-${String(
      now.getUTCMonth() + 1
    ).padStart(2, "0")}`;
    const aiUsageRef = firestore
      .collection("users")
      .doc(uid)
      .collection("aiUsage")
      .doc(yearMonth);

    // 上限判定とカウント更新は同一トランザクション内で実施
    // 冪等にしない理由: 月次利用上限を正確に適用するため、上限判定を通過したリクエストごとに1回だけ加算する必要がある。
    const limitCheckResult = await firestore.runTransaction(async (tx) => {
      const aiUsageDoc = await tx.get(aiUsageRef);
      const aiUsageData = aiUsageDoc.data() as UserAIUsageData | undefined;
      if ((aiUsageData?.categorizeCount ?? 0) >= monthlyLimit) {
        return { isLimitReached: true as const };
      }

      if (aiUsageDoc.exists) {
        tx.update(aiUsageRef, {
          categorizeCount: admin.firestore.FieldValue.increment(1),
          serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        tx.set(aiUsageRef, {
          id: yearMonth,
          userID: uid,
          imageRecognitionCount: 0,
          urlRecognitionCount: 0,
          categorizeCount: 1,
          serverCreatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
          serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      return { isLimitReached: false as const };
    });

    if (limitCheckResult.isLimitReached) {
      return {
        result: "NG" as const,
        error: {
          message: `AIカテゴリ分けの月間利用回数（${monthlyLimit}回）に達しました`,
        },
      };
    }

    try {
      const existingHint =
        existingCategoryNames.length > 0
          ? `既存のカテゴリ: ${existingCategoryNames.join(
              ", "
            )}。これらに当てはまるアイテムは必ず既存カテゴリ名をそのまま使ってください。`
          : "";

      // Genkitで構造化出力としてカテゴリ分けを得る
      const generation = await ai.generate({
        model: categorizeModel,
        prompt:
          `次の買い物リストのアイテムを、スーパーの売り場コーナー単位で日本語のカテゴリに分類してください。` +
          `カテゴリ名は「野菜」「肉」「魚」「乳製品」「飲料」「調味料」「パン」「お菓子」「冷凍食品」「日用品」のように短い一般名詞にしてください。` +
          `${existingHint}\n各アイテムを漏れなく1つのカテゴリに割り当ててください。\n\nアイテム:\n${itemNames
            .map((n) => `- ${n}`)
            .join("\n")}`,
        output: { schema: CategorizationSchema },
      });
      const parsed = CategorizationSchema.safeParse(generation.output);
      if (!parsed.success) {
        throw new Error("Invalid model output payload");
      }

      // 入力に存在するアイテムのみ・正規化して返す
      const itemNameSet = new Set(itemNames);
      const categorizedItems = parsed.data.categorizedItems
        .map((e) => ({
          name: e.name.trim(),
          categoryName: e.categoryName.trim(),
        }))
        .filter(
          (e) =>
            itemNameSet.has(e.name) &&
            e.categoryName.length > 0 &&
            e.categoryName.length <= maxNameLength
        );

      return {
        result: "OK",
        status: 200,
        data: { categorizedItems },
      } as z.infer<typeof ResponseSchema>;
    } catch (error) {
      logger.error("categorizeShoppingListItems failed", {
        uid,
        yearMonth,
        errorName: error instanceof Error ? error.name : "unknown",
      });
      return {
        result: "NG",
        error: {
          message:
            error instanceof Error ? error.message : "カテゴリ分けに失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("categorizeShoppingListItems"),
    secrets: [googleAIApiKey],
  },
  categorizeShoppingListItemsFlow
);
