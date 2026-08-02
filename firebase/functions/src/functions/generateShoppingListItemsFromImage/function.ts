import { GoogleGenerativeAI, SchemaType } from "@google/generative-ai";
import { GoogleAIFileManager } from "@google/generative-ai/server";
import admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import { getDownloadURL } from "firebase-admin/storage";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { currentAuthUID } from "../utils/currentAuthUID";
import { appAuthPolicy } from "../utils/authPolicy";
import {
  hasPremiumEntitlement,
  revenueCatSecretApiKey,
} from "../utils/premium";
import { DataResponseSchema, ErrorResponseSchema } from "../../entity/response";
import { UserAIUsageData } from "../../entity/ai_usage";
import fs from "fs";
import { defineSecret } from "firebase-functions/params";

/// Gemini API Key。Secret Manager 経由で取得する。
const googleAIApiKey = defineSecret("GOOGLE_GENAI_API_KEY");

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      shoppingListItems: z.array(z.string()),
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

/** 無料ユーザーのAI画像認識月次上限。 */
const freeMonthlyImageRecognitionLimit = 5;

/** プレミアムユーザーのAI画像認識月次上限。 */
const premiumMonthlyImageRecognitionLimit = 50;

/** Firestore document IDに使える文字のみ許可（`/` を拒否）。 */
const firestoreIDPattern = /^[A-Za-z0-9_-]{1,128}$/;

/** 1つの買い物リストに保存する元画像の上限枚数（Issue #530 の仕様）。超過分は古い順に削除する。 */
const maxSourceImagesPerShoppingList = 5;

/** グループメンバーシップ検証用。 */
interface GroupData {
  memberUserIDs: string[];
}

// 一時ファイルを削除する関数
async function cleanupTemporaryImage(filePath: string): Promise<void> {
  try {
    const bucket = admin.storage().bucket();
    await bucket.file(filePath).delete();
    logger.info(`Cleaned up temporary file: ${filePath}`);
  } catch (error) {
    logger.error(`Error cleaning up file ${filePath}:`, error);
  }
}

/**
 * 手書きメモ画像から買い物リストアイテムを生成するFunction。
 *
 * ## 検証用パラメータ例
 * ```json
 * {
 *   "mimeType": "image/jpeg",
 *   "base64Image": "<base64エンコードされた画像データ>",
 *   "groupID": "group-id",
 *   "shoppingListID": "list-id"
 * }
 * ```
 *
 * ## 制限
 * - 認証必須
 * - 画像: JPEG/PNG/WebP/HEIC/HEIF、10MB以下
 * - 月次利用上限: 無料5回、プレミアム50回（UTC基準）
 * - groupID / shoppingListID（任意・両方セットで指定）: 指定すると生成に使った
 *   元画像を買い物リストに保存する（Issue #530）。グループメンバーのみ。
 *   保存済みの元画像が上限（5枚）を超えると古い順に削除される。
 */
const generateShoppingListItemsFromImageFlow = ai.defineFlow(
  {
    name: "generateShoppingListItemsFromImage",
    inputSchema: z.object({
      mimeType: z.string(),
      base64Image: z.string(),
      // 元画像の保存先の買い物リスト。旧バージョンのクライアントは送らないため optional。
      groupID: z.string().regex(firestoreIDPattern).optional(),
      shoppingListID: z.string().regex(firestoreIDPattern).optional(),
    }),
    outputSchema: ResponseSchema,
  },
  async (input: {
    mimeType: string;
    base64Image: string;
    groupID?: string;
    shoppingListID?: string;
  }) => {
    const { mimeType, base64Image, groupID, shoppingListID } = input;
    const tempFilePath: string | null = null;

    // 認証チェック（クライアントからの回避を防ぐため Function 側で強制）
    const uid = currentAuthUID();
    if (!uid) {
      return {
        result: "NG" as const,
        error: { message: "認証されていません" },
      };
    }

    // 入力検証: MIME type
    if (!allowedMimeTypes.has(mimeType)) {
      return {
        result: "NG" as const,
        error: { message: "画像形式がサポートされていません" },
      };
    }

    // 入力検証: 画像サイズ
    const imageBytes = Buffer.from(base64Image, "base64");
    if (imageBytes.length === 0 || imageBytes.length > maxImageBytes) {
      return {
        result: "NG" as const,
        error: { message: "画像サイズが制限を超えています" },
      };
    }

    const firestore = admin.firestore();

    // 元画像の保存先が指定された場合は、AI利用回数を消費する前に
    // グループメンバーであることと対象リストの存在を検証する。
    if ((groupID == null) !== (shoppingListID == null)) {
      return {
        result: "NG" as const,
        error: { message: "groupID と shoppingListID は両方指定してください" },
      };
    }
    if (groupID != null && shoppingListID != null) {
      const groupDoc = await firestore
        .collection("groups")
        .doc(groupID)
        .get();
      const groupData = groupDoc.data() as GroupData | undefined;
      if (!groupData || !groupData.memberUserIDs.includes(uid)) {
        return {
          result: "NG" as const,
          error: { message: "グループのメンバーではありません" },
        };
      }

      const listDoc = await firestore
        .collection("groups")
        .doc(groupID)
        .collection("shoppingLists")
        .doc(shoppingListID)
        .get();
      if (!listDoc.exists) {
        return {
          result: "NG" as const,
          error: { message: "対象の買い物リストが存在しません" },
        };
      }
    }

    // サーバー管理データからプレミアム判定（クライアントの申告値は信用しない）
    const isPremium = await hasPremiumEntitlement(uid);
    const monthlyLimit = isPremium
      ? premiumMonthlyImageRecognitionLimit
      : freeMonthlyImageRecognitionLimit;

    const now = new Date();
    const yearMonth = now.toISOString().slice(0, 7);
    const aiUsageRef = firestore
      .collection("users")
      .doc(uid)
      .collection("aiUsage")
      .doc(yearMonth);

    // 上限判定とカウント更新は同一トランザクション内で実施
    // 冪等にしない理由: 月次利用上限を正確に適用するため、成功リクエストごとに1回だけ加算する必要がある。
    const limitCheckResult = await firestore.runTransaction(async (tx) => {
      const aiUsageDoc = await tx.get(aiUsageRef);
      const aiUsageData = aiUsageDoc.data() as UserAIUsageData | undefined;
      const used = aiUsageData?.imageRecognitionCount ?? 0;
      if (used >= monthlyLimit) {
        return { isLimitReached: true as const };
      }

      if (aiUsageDoc.exists) {
        tx.update(aiUsageRef, {
          imageRecognitionCount: FieldValue.increment(1),
          serverUpdatedDateTime: FieldValue.serverTimestamp(),
        });
      } else {
        tx.set(aiUsageRef, {
          id: yearMonth,
          userID: uid,
          imageRecognitionCount: 1,
          serverCreatedDateTime: FieldValue.serverTimestamp(),
          serverUpdatedDateTime: FieldValue.serverTimestamp(),
        });
      }
      return { isLimitReached: false as const };
    });

    if (limitCheckResult.isLimitReached) {
      // 月次上限の発動を Cloud Logging から確認できるように記録する (Issue #524)。
      logger.warn("generateShoppingListItemsFromImage: monthly limit reached", {
        uid,
        yearMonth,
        monthlyLimit,
        isPremium,
      });
      return {
        result: "NG" as const,
        error: {
          message: `画像読み取りの月間利用回数（${monthlyLimit}回）に達しました`,
        },
      };
    }

    // Secret Manager から API Key を取得し、Gemini クライアントを初期化する
    const apiKey = googleAIApiKey.value();
    const genAI = new GoogleGenerativeAI(apiKey);
    const fileManager = new GoogleAIFileManager(apiKey);
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash",
    });
    // gemini-2.0-flash 提供終了に伴い gemini-2.5-flash へ移行した（2026-06）。
    // 2.5 系は thinking がデフォルト ON で、thinking トークンが maxOutputTokens を
    // 消費し、function call が args 空（{}）の状態で返る事象が発生する。
    // thinkingBudget: 0 で thinking を無効化し、出力トークンを抽出結果に充てる。
    // 旧 SDK(@google/generative-ai 0.24) の GenerationConfig 型には thinkingConfig が
    // 無いが、generationConfig は REST API へ素通しで転送されるため実行時に有効。
    const generationConfig = {
      temperature: 1,
      topP: 0.95,
      topK: 40,
      maxOutputTokens: 8192,
      responseMimeType: "text/plain",
      thinkingConfig: { thinkingBudget: 0 },
    };

    try {
      const imageFile = await uploadBase64ImageToGemini(
        fileManager,
        base64Image,
        mimeType
      );

      const chatSession = await model.startChat({
        generationConfig,
        history: [
          {
            role: "user",
            parts: [
              {
                fileData: {
                  mimeType: imageFile.mimeType,
                  fileUri: imageFile.uri,
                },
              },
              {
                text: "この画像の手書きの箇条書きの買い物リストの内容を文字列の配列で出力してください。内容は買い物リストです",
              },
            ],
          },
        ],
        tools: [
          {
            functionDeclarations: [
              {
                name: "generateShoppingListItemsFromImage",
                description:
                  "この画像の手書きの箇条書きの買い物リストの内容を文字列の配列で出力してください。内容は買い物リストです",
                parameters: {
                  type: SchemaType.OBJECT,
                  properties: {
                    shoppingListItems: {
                      type: SchemaType.ARRAY,
                      items: {
                        type: SchemaType.STRING,
                      },
                    },
                  },
                },
              },
            ],
          },
        ],
      });

      const result = await chatSession.sendMessage(""); //空文字列を送信
      const functionCalls = result.response.functionCalls();
      if (!functionCalls || functionCalls.length === 0) {
        throw new Error("Function call not found");
      }
      // 画像から何も読み取れなかった場合、モデルは function call を返しつつ args を
      // 空（{}）にすることがある。その場合 shoppingListItems は undefined になり、
      // そのまま返すと JSON 化で data: {} となって outputSchema の必須
      // shoppingListItems 検証に失敗し、クライアントへ INTERNAL が返る。
      // 「読み取り 0 件」として空配列にフォールバックする。
      const shoppingListItems =
        (functionCalls[0].args as { shoppingListItems?: string[] })
          .shoppingListItems ?? [];

      // 生成に使った元画像を買い物リストに保存する（Issue #530）。
      // 主目的のアイテム抽出を巻き添えにしないため、保存の失敗はログに残して
      // 抽出結果はそのまま返す。
      if (groupID != null && shoppingListID != null) {
        try {
          await saveSourceImage({ groupID, shoppingListID, uid, imageBytes });
        } catch (error) {
          logger.error(
            "generateShoppingListItemsFromImage: saveSourceImage failed",
            {
              uid,
              groupID,
              shoppingListID,
              errorName: error instanceof Error ? error.name : "unknown",
              errorMessage:
                error instanceof Error ? error.message : String(error),
            }
          );
        }
      }

      return {
        result: "OK",
        status: 200,
        data: {
          shoppingListItems,
        },
      } as z.infer<typeof ResponseSchema>;
    } catch (error) {
      // 機密データ（base64Image / APIキー）はログに出力しない
      logger.error("generateShoppingListItemsFromImage failed", {
        uid,
        yearMonth,
        errorName: error instanceof Error ? error.name : "unknown",
        errorMessage: error instanceof Error ? error.message : String(error),
      });
      return {
        result: "NG",
        error: {
          message:
            error instanceof Error
              ? error.message
              : "買い物リストの生成に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    } finally {
      // 一時ファイルのクリーンアップ
      if (tempFilePath) {
        await cleanupTemporaryImage(tempFilePath);
      }
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("generateShoppingListItemsFromImage"),
    secrets: [googleAIApiKey, revenueCatSecretApiKey],
  },
  generateShoppingListItemsFromImageFlow
);

/**
 * 「写真から追加」の元画像を Storage に保存し、メタデータを買い物リストの
 * sourceImages サブコレクションに作成する（Issue #530）。
 * 保存後、作成日時の新しい順で maxSourceImagesPerShoppingList 枚を超えた分
 * （古い元画像）をドキュメント・Storage ファイルともに削除する。
 *
 * 冪等ではない: 呼び出しごとに新しい sourceImageID を採番して保存する。
 * 同一画像の再送を判別する手段がなく、超過分の削除で総量を抑える設計のため。
 */
async function saveSourceImage({
  groupID,
  shoppingListID,
  uid,
  imageBytes,
}: {
  groupID: string;
  shoppingListID: string;
  uid: string;
  imageBytes: Buffer;
}): Promise<void> {
  const sourceImagesRef = admin
    .firestore()
    .collection("groups")
    .doc(groupID)
    .collection("shoppingLists")
    .doc(shoppingListID)
    .collection("sourceImages");
  const sourceImageRef = sourceImagesRef.doc();
  const storagePath = `groups/${groupID}/shoppingLists/${shoppingListID}/sourceImages/${sourceImageRef.id}.jpeg`;
  const file = admin.storage().bucket().file(storagePath);
  await file.save(imageBytes, {
    // クライアントは base64CompressImage で常に JPEG に圧縮して送るため固定。
    metadata: { contentType: "image/jpeg" },
  });
  // Admin SDK の file.save() は firebaseStorageDownloadTokens を生成しないため、
  // getDownloadURL を呼んでダウンロードトークンを生成しておく（uploadReceiptImage と
  // 同じ仕組み。これを省くとクライアントの getDownloadURL がトークン無し URL を返し
  // 画像が表示できない）。戻り値の URL は Firestore に保存せず、表示時にクライアントが
  // storagePath から都度取得する設計のため破棄する。
  // Storage Emulator では Admin SDK の getDownloadURL が
  // "Permission denied. No READ permission." で失敗する既知の制約があるためスキップする。
  // Emulator ではクライアント側の getDownloadURL がトークンを生成するため表示に支障はない。
  if (process.env.FUNCTIONS_EMULATOR !== "true") {
    await getDownloadURL(file);
  }
  await sourceImageRef.set({
    id: sourceImageRef.id,
    groupID,
    shoppingListID,
    userID: uid,
    storagePath,
    createdDateTime: FieldValue.serverTimestamp(),
    updatedDateTime: FieldValue.serverTimestamp(),
    serverCreatedDateTime: FieldValue.serverTimestamp(),
    serverUpdatedDateTime: FieldValue.serverTimestamp(),
  });

  // 上限を超えた古い元画像を削除する。Storage → Firestore の順で消し、
  // Storage 削除に失敗した場合はドキュメントを残して次回の保存時に再削除できるようにする。
  const snapshot = await sourceImagesRef
    .orderBy("createdDateTime", "desc")
    .get();
  for (const excessDoc of snapshot.docs.slice(maxSourceImagesPerShoppingList)) {
    const excessStoragePath = (excessDoc.data() as { storagePath?: string })
      .storagePath;
    if (excessStoragePath != null) {
      await admin
        .storage()
        .bucket()
        .file(excessStoragePath)
        .delete({ ignoreNotFound: true });
    }
    await excessDoc.ref.delete();
  }
}

async function uploadBase64ImageToGemini(
  fileManager: GoogleAIFileManager,
  base64Image: string,
  mimeType: string
) {
  // base64データをデコードして一時ファイルに保存
  const buffer = Buffer.from(base64Image, "base64");
  const tempFilePath = `/tmp/image.${mimeType.split("/")[1]}`; // 一時ファイルパス

  await new Promise<void>((resolve, reject) => {
    fs.writeFile(tempFilePath, buffer, (err) => {
      if (err) reject(err);
      else resolve();
    });
  });

  try {
    const uploadResult = await fileManager.uploadFile(tempFilePath, {
      mimeType,
      displayName: "uploaded_image",
    });
    return uploadResult.file;
  } catch (error) {
    logger.error("Error uploading image to Gemini");
    throw error;
  }
}
