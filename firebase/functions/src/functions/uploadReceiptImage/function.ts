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
      storagePath: z.string(),
    }),
  }),
  ErrorResponseSchema,
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
 *   "base64Image": "<base64エンコードされた画像データ>"
 * }
 * ```
 *
 * ## 制限
 * - 認証必須・プレミアムユーザーのみ
 * - グループメンバーのみ
 * - 対象の買い物リストが存在すること
 * - 画像: 10MB以下（クライアントで JPEG 圧縮済み）
 *
 * 画像は storage path に保存し、download URL は返さず storagePath を返す。
 * クライアントは storagePath から（storage.rules でグループメンバーに read 許可）取得する。
 */
const uploadReceiptImageFlow = ai.defineFlow(
  {
    name: "uploadReceiptImage",
    inputSchema: z.object({
      groupID: z.string().regex(firestoreIDPattern),
      shoppingListID: z.string().regex(firestoreIDPattern),
      receiptID: z.string().regex(firestoreIDPattern),
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
      const storagePath = `groups/${input.groupID}/shoppingLists/${input.shoppingListID}/receipts/${input.receiptID}.jpeg`;
      const file = admin.storage().bucket().file(storagePath);

      await file.save(imageBuffer, {
        metadata: {
          // クライアントは base64CompressImage で常に JPEG を送るため固定。
          contentType: "image/jpeg",
        },
      });

      // Admin SDK の file.save() は firebaseStorageDownloadTokens を生成しないため、
      // このままだとクライアントの getDownloadURL(storagePath) がトークンの無い URL を返し、
      // CachedNetworkImage の取得が 403 で失敗して画像が表示できない（レシートが
      // broken_image アイコンになる原因）。getDownloadURL を呼んでダウンロードトークンを
      // 生成しておくことで、クライアントは storagePath からトークン付き URL を取得できる。
      // uploadShoppingListItemImage と同じ仕組み。戻り値の URL は Firestore に保存せず、
      // 表示時にクライアントが storagePath から都度取得する設計のため破棄する。
      await getDownloadURL(file);

      return {
        result: "OK" as const,
        data: { storagePath },
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
