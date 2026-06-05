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

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({}),
  }),
  ErrorResponseSchema,
]);

/** グループメンバーシップ検証用。 */
interface GroupData {
  memberUserIDs: string[];
}

/** Firestore document IDに使える文字のみ許可（`/` を拒否）。 */
const firestoreIDPattern = /^[A-Za-z0-9_-]{1,128}$/;

/**
 * 買い物リストアイテムの商品写真をFirebase Storageから削除するFunction。
 *
 * ## 検証用パラメータ例
 * ```json
 * {
 *   "groupID": "group-id",
 *   "shoppingListID": "list-id",
 *   "itemID": "item-id"
 * }
 * ```
 */
const deleteShoppingListItemImageFlow = ai.defineFlow(
  {
    name: "deleteShoppingListItemImage",
    inputSchema: z.object({
      groupID: z.string().regex(firestoreIDPattern),
      shoppingListID: z.string().regex(firestoreIDPattern),
      itemID: z.string().regex(firestoreIDPattern),
    }),
    outputSchema: ResponseSchema,
  },
  async (input) => {
    const uid = currentAuthUID();
    if (!uid) {
      return {
        result: "NG" as const,
        error: { message: "認証されていません" },
      };
    }

    const groupDoc = await admin
      .firestore()
      .collection("groups")
      .doc(input.groupID)
      .get();
    const groupData = groupDoc.data() as GroupData | undefined;
    if (!groupData || !groupData.memberUserIDs.includes(uid)) {
      return {
        result: "NG" as const,
        error: { message: "グループのメンバーではありません" },
      };
    }

    try {
      const storagePath = `groups/${input.groupID}/shoppingLists/${input.shoppingListID}/items/${input.itemID}/photo`;
      await admin
        .storage()
        .bucket()
        .file(storagePath)
        .delete()
        .catch(() => {
          // ファイルが存在しない場合は無視
        });

      return {
        result: "OK" as const,
        data: {},
      };
    } catch (error) {
      logger.error("deleteShoppingListItemImage failed", {
        uid,
        groupID: input.groupID,
        itemID: input.itemID,
        errorName: error instanceof Error ? error.name : "unknown",
      });
      return {
        result: "NG" as const,
        error: {
          message: "画像の削除に失敗しました",
        },
      };
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("deleteShoppingListItemImage"),
  },
  deleteShoppingListItemImageFlow
);
