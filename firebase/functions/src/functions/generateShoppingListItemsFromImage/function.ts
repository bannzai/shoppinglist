import { GoogleGenerativeAI, SchemaType } from "@google/generative-ai";
import { GoogleAIFileManager } from "@google/generative-ai/server";
import admin from "firebase-admin";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { appAuthPolicy } from "../utils/authPolicy";
import { DataResponseSchema, ErrorResponseSchema } from "../../entity/response";
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
      const shoppingListItems = (functionCalls[0].args as { shoppingListItems: string[] })
        .shoppingListItems;

      return {
        result: "OK",
        status: 200,
        data: {
          shoppingListItems,
        },
      } as z.infer<typeof ResponseSchema>;
    } catch (error) {
      logger.error(error);
      return {
        result: "NG",
        status: 500,
        error: error,
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
  model: "gemini-2.0-flash-exp",
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
    const file = uploadResult.file;
    console.log(`Uploaded file ${file.displayName} as: ${file.name}`);
    return file;
  } catch (error) {
    console.error("Error uploading image:", error);
    throw error; // エラーを上流に伝播
  }
}
