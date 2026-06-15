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
 * 買い物リストのレシート画像をFirebase Storageから削除するFunction。
 *
 * レシートのメタデータドキュメント自体の削除はクライアントが行う。
 * 本Functionは Storage 上の画像のみを削除し、対象が存在しなくても成功扱いとする（冪等）。
 *
 * ## 検証用パラメータ例
 * ```json
 * {
 *   "groupID": "group-id",
 *   "shoppingListID": "list-id",
 *   "receiptID": "receipt-id"
 * }
 * ```
 */
const deleteReceiptImageFlow = ai.defineFlow(
  {
    name: "deleteReceiptImage",
    inputSchema: z.object({
      groupID: z.string().regex(firestoreIDPattern),
      shoppingListID: z.string().regex(firestoreIDPattern),
      receiptID: z.string().regex(firestoreIDPattern),
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
      const storagePath = `groups/${input.groupID}/shoppingLists/${input.shoppingListID}/receipts/${input.receiptID}/photo`;
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
      logger.error("deleteReceiptImage failed", {
        uid,
        groupID: input.groupID,
        receiptID: input.receiptID,
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
    authPolicy: appAuthPolicy("deleteReceiptImage"),
  },
  deleteReceiptImageFlow
);
