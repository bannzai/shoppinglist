import { GoogleGenerativeAI, SchemaType } from "@google/generative-ai";
import { GoogleAIFileManager } from "@google/generative-ai/server";
import admin from "firebase-admin";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { appAuthPolicy } from "../utils/authPolicy";
import { DataResponseSchema, ErrorResponseSchema } from "../../entity/response";
import { AIUsageData } from "../../entity/ai_usage";
import fs from "fs";
import { defineString } from "firebase-functions/params";

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

/** Firebase Auth Custom Claimsからプレミアム判定を行う。 */
async function hasPremiumEntitlement(uid: string): Promise<boolean> {
  try {
    const userRecord = await admin.auth().getUser(uid);
    return userRecord.customClaims?.["premium"] === true;
  } catch (error) {
    logger.error("hasPremiumEntitlement failed", {
      uid,
      errorName: error instanceof Error ? error.name : "unknown",
    });
    return false;
  }
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
 *   "base64Image": "<base64エンコードされた画像データ>"
 * }
 * ```
 *
 * ## 制限
 * - 認証必須
 * - 画像: JPEG/PNG/WebP/HEIC/HEIF、10MB以下
 * - 月次利用上限: 無料5回、プレミアム50回（UTC基準）
 */
const generateShoppingListItemsFromImageFlow = ai.defineFlow(
  {
    name: "generateShoppingListItemsFromImage",
    inputSchema: z.object({
      mimeType: z.string(),
      base64Image: z.string(),
    }),
    outputSchema: ResponseSchema,
  },
  async (input: { mimeType: string; base64Image: string }) => {
    const { mimeType, base64Image } = input;
    const tempFilePath: string | null = null;

    // 認証チェック（クライアントからの回避を防ぐため Function 側で強制）
    const context = ai.currentContext();
    const uid = context?.auth?.uid;
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

    // サーバー管理データからプレミアム判定（クライアントの申告値は信用しない）
    const isPremium = await hasPremiumEntitlement(uid);
    const monthlyLimit = isPremium
      ? premiumMonthlyImageRecognitionLimit
      : freeMonthlyImageRecognitionLimit;

    const firestore = admin.firestore();
    const now = new Date();
    const yearMonth = `${now.getUTCFullYear()}-${String(now.getUTCMonth() + 1).padStart(2, "0")}`;
    const aiUsageRef = firestore
      .collection("users")
      .doc(uid)
      .collection("aiUsage")
      .doc(yearMonth);

    // 上限判定とカウント更新は同一トランザクション内で実施
    // 冪等にしない理由: 月次利用上限を正確に適用するため、成功リクエストごとに1回だけ加算する必要がある。
    const limitCheckResult = await firestore.runTransaction(async (tx) => {
      const aiUsageDoc = await tx.get(aiUsageRef);
      const aiUsageData = aiUsageDoc.data() as AIUsageData | undefined;
      const used = aiUsageData?.imageRecognitionCount ?? 0;
      if (used >= monthlyLimit) {
        return { isLimitReached: true as const };
      }

      if (aiUsageDoc.exists) {
        tx.update(aiUsageRef, {
          imageRecognitionCount: admin.firestore.FieldValue.increment(1),
          serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        tx.set(aiUsageRef, {
          id: yearMonth,
          userID: uid,
          imageRecognitionCount: 1,
          serverCreatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
          serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      return { isLimitReached: false as const };
    });

    if (limitCheckResult.isLimitReached) {
      return {
        result: "NG" as const,
        error: {
          message: `AI画像認識の月間利用回数（${monthlyLimit}回）に達しました`,
        },
      };
    }

    try {
      const imageFile = await uploadBase64ImageToGemini(base64Image, mimeType);

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
      const shoppingListItems = (
        functionCalls[0].args as { shoppingListItems: string[] }
      ).shoppingListItems;

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
  },
  generateShoppingListItemsFromImageFlow
);

const apiKey = defineString("GOOGLE_GENAI_API_KEY").value();
const genAI = new GoogleGenerativeAI(apiKey);
const fileManager = new GoogleAIFileManager(apiKey);

const model = genAI.getGenerativeModel({
  model: "gemini-2.5-flash",
});

const generationConfig = {
  temperature: 1,
  topP: 0.95,
  topK: 40,
  maxOutputTokens: 8192,
  responseMimeType: "text/plain",
};

async function uploadBase64ImageToGemini(
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
