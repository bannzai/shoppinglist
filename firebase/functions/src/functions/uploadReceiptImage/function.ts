import admin from "firebase-admin";
import { getDownloadURL } from "firebase-admin/storage";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { currentAuthUID } from "../utils/currentAuthUID";
import {
  hasPremiumEntitlement,
  revenueCatSecretApiKey,
} from "../utils/premium";
import {
  DataResponseSchema,
  ErrorResponseSchema,
} from "../../entity/response";

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      imageURL: z.string(),
    }),
  }),
  ErrorResponseSchema,
]);

/** サポートする画像MIME typeの集合。 */
const allowedMimeTypes = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/heic",
  "image/heif",
]);

/** 画像の最大バイトサイズ（10MB）。 */
const maxImageBytes = 10 * 1024 * 1024;

/** base64文字列の最大文字数（10MB相当）。 */
const maxBase64Chars = Math.ceil((maxImageBytes * 4) / 3) + 4;

/** Firestore document IDに使える文字のみ許可（`/` を拒否）。 */
const firestoreIDPattern = /^[A-Za-z0-9_-]{1,128}$/;

/** base64文字列フォーマット（padding込み）。 */
const base64Pattern =
  /^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/;

/** グループメンバーシップ検証用。 */
interface GroupData {
  memberUserIDs: string[];
}

/**
 * 買い物リストにレシート画像をアップロードするFunction。
 *
 * レシートのメタデータ（金額・メモ）ドキュメントはクライアントが Firestore に
 * 作成するため、本Functionでは親の買い物リストの存在のみを確認し、画像を
 * Storage に保存してダウンロードURLを返す。
 *
 * ## 検証用パラメータ例
 * ```json
 * {
 *   "groupID": "group-id",
 *   "shoppingListID": "list-id",
 *   "receiptID": "receipt-id",
 *   "mimeType": "image/jpeg",
 *   "base64Image": "<base64エンコードされた画像データ>"
 * }
 * ```
 *
 * ## 制限
 * - 認証必須・プレミアムユーザーのみ
 * - グループメンバーのみ
 * - 対象の買い物リストが存在すること
 * - 画像: JPEG/PNG/WebP/HEIC/HEIF、10MB以下
 */
const uploadReceiptImageFlow = ai.defineFlow(
  {
    name: "uploadReceiptImage",
    inputSchema: z.object({
      groupID: z.string().regex(firestoreIDPattern),
      shoppingListID: z.string().regex(firestoreIDPattern),
      receiptID: z.string().regex(firestoreIDPattern),
      mimeType: z.string(),
      base64Image: z.string().max(maxBase64Chars),
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

    if (!(await hasPremiumEntitlement(uid))) {
      return {
        result: "NG" as const,
        error: { message: "レシートの保存はプレミアム機能です" },
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

    const listDoc = await admin
      .firestore()
      .collection("groups")
      .doc(input.groupID)
      .collection("shoppingLists")
      .doc(input.shoppingListID)
      .get();
    if (!listDoc.exists) {
      return {
        result: "NG" as const,
        error: { message: "対象の買い物リストが存在しません" },
      };
    }

    if (!allowedMimeTypes.has(input.mimeType)) {
      return {
        result: "NG" as const,
        error: { message: "画像形式がサポートされていません" },
      };
    }

    const normalizedBase64 = input.base64Image.trim();
    if (
      normalizedBase64.length === 0 ||
      normalizedBase64.length > maxBase64Chars ||
      normalizedBase64.length % 4 !== 0 ||
      !base64Pattern.test(normalizedBase64)
    ) {
      return {
        result: "NG" as const,
        error: { message: "画像データ形式が不正です" },
      };
    }

    const imageBuffer = Buffer.from(normalizedBase64, "base64");
    if (imageBuffer.length === 0 || imageBuffer.length > maxImageBytes) {
      return {
        result: "NG" as const,
        error: { message: "画像サイズが制限を超えています" },
      };
    }

    try {
      const storagePath = `groups/${input.groupID}/shoppingLists/${input.shoppingListID}/receipts/${input.receiptID}/photo`;
      const file = admin.storage().bucket().file(storagePath);

      await file.save(imageBuffer, {
        metadata: {
          contentType: input.mimeType,
        },
      });

      return {
        result: "OK" as const,
        data: { imageURL: await getDownloadURL(file) },
      };
    } catch (error) {
      logger.error("uploadReceiptImage failed", {
        uid,
        groupID: input.groupID,
        receiptID: input.receiptID,
        errorName: error instanceof Error ? error.name : "unknown",
      });
      return {
        result: "NG" as const,
        error: {
          message: "画像のアップロードに失敗しました",
        },
      };
    }
  }
);

module.exports = onCallGenkit(
  {
    secrets: [revenueCatSecretApiKey],
  },
  uploadReceiptImageFlow
);
