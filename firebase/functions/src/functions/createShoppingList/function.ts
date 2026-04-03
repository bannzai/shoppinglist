import admin from "firebase-admin";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
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
      const context = ai.currentContext();
      const uid = context?.auth?.uid;
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

      const isPremium = context?.auth?.token?.isPremium === true;

      if (!isPremium) {
        const activeSnapshot = await firestore
          .collection(`groups/${groupID}/shoppingLists`)
          .where("status", "==", "active")
          .count()
          .get();
        const activeCount = activeSnapshot.data().count;
        if (activeCount >= FREE_GROUP_ACTIVE_SHOPPING_LIST_LIMIT) {
          return {
            result: "NG" as const,
            error: {
              message: `無料プランでは1グループあたり${FREE_GROUP_ACTIVE_SHOPPING_LIST_LIMIT}個までリストを作成できます。プレミアムにアップグレードすると無制限に作成できます`,
            },
          };
        }
      }

      const shoppingListsRef = firestore.collection(
        `groups/${groupID}/shoppingLists`
      );
      const allCountSnapshot = await shoppingListsRef.count().get();
      const allCount = allCountSnapshot.data().count;
      const now = new Date();
      const dateStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`;
      const name = allCount === 0 ? dateStr : `${dateStr} (${allCount})`;

      const newDocRef = shoppingListsRef.doc();
      await newDocRef.set({
        id: newDocRef.id,
        createUserID,
        groupID,
        name,
        status: "active",
        shoppingLocationID: shoppingLocationID ?? null,
        duplicatedFromGroupShoppingListID:
          duplicatedFromGroupShoppingListID ?? null,
        ttlExpiresDateTime: null,
        createdDateTime: admin.firestore.FieldValue.serverTimestamp(),
        updatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        serverCreatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
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
