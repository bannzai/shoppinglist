import admin from "firebase-admin";
import { getDownloadURL } from "firebase-admin/storage";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { appAuthPolicy } from "../utils/authPolicy";
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

/** グループメンバーシップ検証用。 */
interface GroupData {
  memberUserIDs: string[];
}

/**
 * 買い物リストアイテムに商品写真をアップロードするFunction。
 *
 * ## 検証用パラメータ例
 * ```json
 * {
 *   "groupID": "group-id",
 *   "shoppingListID": "list-id",
 *   "itemID": "item-id",
 *   "mimeType": "image/jpeg",
 *   "base64Image": "<base64エンコードされた画像データ>"
 * }
 * ```
 *
 * ## 制限
 * - 認証必須・プレミアムユーザーのみ
 * - グループメンバーのみ
 * - 対象 item ドキュメントが存在すること
 * - 画像: JPEG/PNG/WebP/HEIC/HEIF、10MB以下
 */
const uploadShoppingListItemImageFlow = ai.defineFlow(
  {
    name: "uploadShoppingListItemImage",
    inputSchema: z.object({
      groupID: z.string().regex(firestoreIDPattern),
      shoppingListID: z.string().regex(firestoreIDPattern),
      itemID: z.string().regex(firestoreIDPattern),
      mimeType: z.string(),
      base64Image: z.string().max(maxBase64Chars),
    }),
    outputSchema: ResponseSchema,
  },
  async (input) => {
    const uid = ai.currentContext()?.auth?.uid;
    if (!uid) {
      return {
        result: "NG" as const,
        error: { message: "認証されていません" },
      };
    }

    if (!(await hasPremiumEntitlement(uid))) {
      return {
        result: "NG" as const,
        error: { message: "商品写真の添付はプレミアム機能です" },
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

    const itemDoc = await admin
      .firestore()
      .collection("groups")
      .doc(input.groupID)
      .collection("shoppingLists")
      .doc(input.shoppingListID)
      .collection("items")
      .doc(input.itemID)
      .get();
    if (!itemDoc.exists) {
      return {
        result: "NG" as const,
        error: { message: "対象のアイテムが存在しません" },
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
      const storagePath = `groups/${input.groupID}/shoppingLists/${input.shoppingListID}/items/${input.itemID}/photo`;
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
      logger.error("uploadShoppingListItemImage failed", {
        uid,
        groupID: input.groupID,
        itemID: input.itemID,
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
    authPolicy: appAuthPolicy("uploadShoppingListItemImage"),
  },
  uploadShoppingListItemImageFlow
);
