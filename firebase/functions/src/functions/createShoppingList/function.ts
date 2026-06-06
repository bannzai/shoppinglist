import admin from "firebase-admin";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { currentAuthUID } from "../utils/currentAuthUID";
import { appAuthPolicy } from "../utils/authPolicy";
import {
  DataResponseSchema,
  ErrorResponseSchema,
} from "../../entity/response";

/// 無料ユーザーのグループあたりアクティブリスト数上限。
const FREE_GROUP_ACTIVE_SHOPPING_LIST_LIMIT = 5;

/// グループデータの型定義。
interface GroupData {
  memberUserIDs: string[];
  ownerUserID: string | null;
  name: string | null;
}

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      shoppingListID: z.string(),
    }),
  }),
  ErrorResponseSchema,
]);

// 検証用引数: { "groupID": "test-group-id", "createUserID": "test-user-id", "shoppingLocationID": null, "duplicatedFromGroupShoppingListID": null }
const createShoppingListFlow = ai.defineFlow(
  {
    name: "createShoppingList",
    inputSchema: z.object({
      groupID: z
        .string()
        .min(1)
        .refine((v) => !v.includes("/")),
      createUserID: z
        .string()
        .min(1)
        .refine((v) => !v.includes("/")),
      shoppingLocationID: z.string().nullable(),
      duplicatedFromGroupShoppingListID: z.string().nullable(),
    }),
    outputSchema: ResponseSchema,
  },
  async (input) => {
    const {
      groupID,
      createUserID,
      shoppingLocationID,
      duplicatedFromGroupShoppingListID,
    } = input;

    try {
      const uid = currentAuthUID();
      if (!uid) {
        return {
          result: "NG" as const,
          error: { message: "認証されていません" },
        };
      }

      if (uid !== createUserID) {
        return {
          result: "NG" as const,
          error: { message: "createUserIDが認証ユーザーと一致しません" },
        };
      }

      const firestore = admin.firestore();
      const groupDoc = await firestore
        .collection("groups")
        .doc(groupID)
        .get();
      if (!groupDoc.exists) {
        return {
          result: "NG" as const,
          error: { message: "グループが見つかりません" },
        };
      }

      const groupData = groupDoc.data() as GroupData | undefined;
      const memberUserIDs: string[] = groupData?.memberUserIDs ?? [];
      if (!memberUserIDs.includes(uid)) {
        return {
          result: "NG" as const,
          error: { message: "グループのメンバーではありません" },
        };
      }

      const isPremium = ai.currentContext()?.auth?.token?.isPremium === true;

      const shoppingListsRef = firestore.collection(
        `groups/${groupID}/shoppingLists`
      );
      const newDocRef = shoppingListsRef.doc();

      // 上限チェックとリスト作成をトランザクションで囲み、レースコンディションを防止する
      await firestore.runTransaction(async (transaction) => {
        if (!isPremium) {
          // トランザクション内では .count().get() が使えないため、クエリでドキュメントを取得して .size で件数を数える
          const activeListsQuery = shoppingListsRef.where(
            "status",
            "==",
            "active"
          );
          const activeSnapshot = await transaction.get(activeListsQuery);
          if (activeSnapshot.size >= FREE_GROUP_ACTIVE_SHOPPING_LIST_LIMIT) {
            throw new Error(
              `無料プランでは1グループあたり${FREE_GROUP_ACTIVE_SHOPPING_LIST_LIMIT}個までリストを作成できます。プレミアムにアップグレードすると無制限に作成できます`
            );
          }
        }

        const allSnapshot = await transaction.get(shoppingListsRef);
        const allCount = allSnapshot.size;
        const now = new Date();
        const dateStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`;
        const name = allCount === 0 ? dateStr : `${dateStr} (${allCount})`;

        // createdDateTime / updatedDateTime はクライアント側タイムスタンプのため、サーバーでは設定しない
        transaction.set(newDocRef, {
          id: newDocRef.id,
          createUserID,
          groupID,
          name,
          status: "active",
          shoppingLocationID: shoppingLocationID ?? null,
          duplicatedFromGroupShoppingListID:
            duplicatedFromGroupShoppingListID ?? null,
          ttlExpiresDateTime: null,
          serverCreatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
          serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      logger.info(
        `Created shopping list ${newDocRef.id} in group ${groupID}`
      );

      return {
        result: "OK" as const,
        data: {
          shoppingListID: newDocRef.id,
        },
      } as z.infer<typeof ResponseSchema>;
    } catch (error) {
      logger.error(error);
      return {
        result: "NG" as const,
        error: {
          message:
            error instanceof Error
              ? error.message
              : "買い物リストの作成に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("createShoppingList"),
  },
  createShoppingListFlow
);
