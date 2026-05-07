import admin from "firebase-admin";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { appAuthPolicy } from "../utils/authPolicy";
import { developerToken, isDeveloper } from "../../core/developer";
import {
  DataResponseSchema,
  ErrorResponseSchema,
} from "../../entity/response";

/** カテゴリドキュメントの必要フィールド。 */
interface CategoryData {
  name: string;
  locationOrders: Record<string, number>;
}

/** 買い物場所ドキュメントの必要フィールド。 */
interface LocationData {
  name: string;
}

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({ success: z.boolean() }),
  }),
  ErrorResponseSchema,
]);

// 検証用引数: { "groupID": "<groupID>", "locationName": "テストスーパー", "firstCategoryName": "肉", "secondCategoryName": "野菜" }
const setupTestCategoryLocationOrderFlow = ai.defineFlow(
  {
    name: "setupTestCategoryLocationOrder",
    inputSchema: z.object({
      groupID: z.string(),
      locationName: z.string(),
      firstCategoryName: z.string(),
      secondCategoryName: z.string(),
    }),
    outputSchema: ResponseSchema,
  },
  async ({ groupID, locationName, firstCategoryName, secondCategoryName }) => {
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

      const firestore = admin.firestore();

      // userCategoryAxes の先頭 1 件を取得
      const axesSnap = await firestore
        .collection(`groups/${groupID}/userCategoryAxes`)
        .limit(1)
        .get();
      if (axesSnap.empty) {
        return {
          result: "NG" as const,
          error: { message: "userCategoryAxes が見つかりません" },
        };
      }
      const axisID = axesSnap.docs[0].id;

      // カテゴリを全件取得して名前で検索
      const categoriesSnap = await firestore
        .collection(`groups/${groupID}/userCategoryAxes/${axisID}/categories`)
        .get();
      const firstCategoryDoc = categoriesSnap.docs.find(
        (d) => (d.data() as CategoryData).name === firstCategoryName
      );
      const secondCategoryDoc = categoriesSnap.docs.find(
        (d) => (d.data() as CategoryData).name === secondCategoryName
      );
      if (!firstCategoryDoc || !secondCategoryDoc) {
        return {
          result: "NG" as const,
          error: {
            message: `カテゴリが見つかりません: ${firstCategoryName}, ${secondCategoryName}`,
          },
        };
      }

      // 買い物場所を名前で検索
      const locationsSnap = await firestore
        .collection(`groups/${groupID}/shoppingLocations`)
        .get();
      const locationDoc = locationsSnap.docs.find(
        (d) => (d.data() as LocationData).name === locationName
      );
      if (!locationDoc) {
        return {
          result: "NG" as const,
          error: { message: `場所が見つかりません: ${locationName}` },
        };
      }
      const locationID = locationDoc.id;

      const firstCategoryRef = firestore.doc(
        `groups/${groupID}/userCategoryAxes/${axisID}/categories/${firstCategoryDoc.id}`
      );
      const secondCategoryRef = firestore.doc(
        `groups/${groupID}/userCategoryAxes/${axisID}/categories/${secondCategoryDoc.id}`
      );

      // locationOrders を runTransaction で原子的に更新（firstCategory=0, secondCategory=1）
      await firestore.runTransaction(async (transaction) => {
        const firstSnap = await transaction.get(firstCategoryRef);
        const secondSnap = await transaction.get(secondCategoryRef);

        const firstData = firstSnap.data() as CategoryData | undefined;
        const secondData = secondSnap.data() as CategoryData | undefined;
        if (!firstData || !secondData) {
          throw new Error("カテゴリドキュメントが取得できませんでした");
        }

        transaction.update(firstCategoryRef, {
          locationOrders: { ...firstData.locationOrders, [locationID]: 0 },
          serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
        transaction.update(secondCategoryRef, {
          locationOrders: { ...secondData.locationOrders, [locationID]: 1 },
          serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      logger.info(
        `Set category location order for group ${groupID}: ${firstCategoryName}=0, ${secondCategoryName}=1 for location ${locationID}`
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
              : "カテゴリロケーション順序の設定に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("setupTestCategoryLocationOrder"),
    secrets: [developerToken],
  },
  setupTestCategoryLocationOrderFlow
);
