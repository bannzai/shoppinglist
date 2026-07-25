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
 * 買い物リストを削除するFunction。
 *
 * Firestore は親ドキュメントを削除してもサブコレクションを自動削除しないため、
 * クライアントの `docRef.delete()` ではリスト配下の items / receipts ドキュメントと
 * Storage の画像（レシート画像・商品写真）が残存する（Issue #421）。
 * Admin SDK の recursiveDelete と Storage の prefix 一括削除で、リスト配下を
 * まとめて削除する。
 *
 * ## 検証用パラメータ例
 * ```json
 * {
 *   "groupID": "group-id",
 *   "shoppingListID": "list-id"
 * }
 * ```
 *
 * ## 制限
 * - 認証必須・グループメンバーのみ
 * - リストが既に存在しない場合も OK を返す（冪等。削除に一部失敗した後の
 *   リトライで、残存データだけを再削除できるようにするため）
 */
const deleteShoppingListFlow = ai.defineFlow(
  {
    name: "deleteShoppingList",
    inputSchema: z.object({
      groupID: z.string().regex(firestoreIDPattern),
      shoppingListID: z.string().regex(firestoreIDPattern),
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
      // Storage → Firestore の順で削除する。逆順だと Storage 削除の失敗時に
      // リストドキュメントだけが先に消え、UI からリストを再削除（リトライ）する
      // 手段が無くなって画像が残存するため。
      // prefix はリスト配下全体で、レシート画像（receipts/{receiptID}.jpeg）と
      // 商品写真（items/{itemID}/photo）の両方が対象になる。
      await admin
        .storage()
        .bucket()
        .deleteFiles({
          prefix: `groups/${input.groupID}/shoppingLists/${input.shoppingListID}/`,
        });

      // リストドキュメント本体と items / receipts サブコレクションを再帰削除する。
      await admin
        .firestore()
        .recursiveDelete(
          admin
            .firestore()
            .collection("groups")
            .doc(input.groupID)
            .collection("shoppingLists")
            .doc(input.shoppingListID)
        );

      return {
        result: "OK" as const,
        data: {},
      };
    } catch (error) {
      logger.error("deleteShoppingList failed", {
        uid,
        groupID: input.groupID,
        shoppingListID: input.shoppingListID,
        errorName: error instanceof Error ? error.name : "unknown",
      });
      return {
        result: "NG" as const,
        error: {
          message: "リストの削除に失敗しました",
        },
      };
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("deleteShoppingList"),
  },
  deleteShoppingListFlow
);
