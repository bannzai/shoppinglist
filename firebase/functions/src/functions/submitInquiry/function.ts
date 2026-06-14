import admin from "firebase-admin";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { currentAuthUID } from "../utils/currentAuthUID";
import { appAuthPolicy } from "../utils/authPolicy";
import {
  slackBotToken,
  slackInquiryChannelID,
  postSlackMessage,
} from "../utils/slack";
import {
  InquiryCategorySchema,
  InquiryPlatformSchema,
  inquiryCollectionPath,
  Inquiry,
} from "../../entity/inquiry";
import { collectUserSnapshot } from "../../entity/snapshot";
import { buildInquirySlackBlocks, buildInquirySlackText } from "./message";
import {
  DataResponseSchema,
  ErrorResponseSchema,
} from "../../entity/response";

/** お問い合わせ本文の最大文字数。 */
const MAX_CONTENT_LENGTH = 5000;

/** スナップショット JSON をドキュメントへ格納できる上限(byte)。
 * Firestore の 1 ドキュメント上限は約 1MiB。本文や他フィールドの余白を見て 900KB に抑える。 */
const MAX_SNAPSHOT_JSON_BYTES = 900_000;

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      inquiryID: z.string(),
    }),
  }),
  ErrorResponseSchema,
]);

// 検証用引数: { "email": "test@example.com", "categoryType": "bugReport", "content": "アイテムが消えます", "platform": "ios", "appVersion": "1.0.0 (1)" }
const submitInquiryFlow = ai.defineFlow(
  {
    name: "submitInquiry",
    inputSchema: z.object({
      email: z.string().email(),
      categoryType: InquiryCategorySchema,
      content: z.string().min(1).max(MAX_CONTENT_LENGTH),
      platform: InquiryPlatformSchema,
      appVersion: z.string().min(1),
    }),
    outputSchema: ResponseSchema,
  },
  async ({ email, categoryType, content, platform, appVersion }) => {
    try {
      const uid = currentAuthUID();
      if (!uid) {
        return {
          result: "NG" as const,
          error: { message: "認証されていません" },
        };
      }

      const firestore = admin.firestore();

      // 送信時点のユーザー関連データをスナップショットし、復元コマンドで再現できるようにする。
      // スナップショット収集の失敗でお問い合わせ自体を失敗させないよう best-effort で握りつぶす。
      let snapshotJson: string | null = null;
      let snapshotOmittedReason: string | null = null;
      try {
        const serialized = JSON.stringify(
          await collectUserSnapshot(firestore, uid)
        );
        if (Buffer.byteLength(serialized, "utf8") > MAX_SNAPSHOT_JSON_BYTES) {
          snapshotOmittedReason = `snapshot exceeded ${MAX_SNAPSHOT_JSON_BYTES} bytes`;
        } else {
          snapshotJson = serialized;
        }
      } catch (error) {
        snapshotOmittedReason =
          error instanceof Error ? error.message : "snapshot failed";
        logger.error("collectUserSnapshot failed", error);
      }

      const inquiryRef = firestore.collection(inquiryCollectionPath).doc();
      const inquiry: Inquiry = {
        id: inquiryRef.id,
        userID: uid,
        email,
        categoryType,
        content,
        platform,
        appVersion,
        snapshotJson,
        snapshotOmittedReason,
        slackNotified: false,
      };

      // Slack 通知。失敗してもお問い合わせ保存自体は成立させ、結果は slackNotified に記録する。
      let slackNotified = false;
      try {
        await postSlackMessage({
          token: slackBotToken.value(),
          channel: slackInquiryChannelID.value(),
          text: buildInquirySlackText(inquiry),
          blocks: buildInquirySlackBlocks(inquiry),
        });
        slackNotified = true;
      } catch (error) {
        logger.error("postSlackMessage failed", error);
      }

      // inquiries はサーバー専用コレクション。サーバータイムスタンプを付与する。
      await inquiryRef.set({
        ...inquiry,
        slackNotified,
        createdDateTime: admin.firestore.FieldValue.serverTimestamp(),
        serverCreatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
      });

      logger.info(
        `Submitted inquiry ${inquiryRef.id} by ${uid} (slackNotified=${slackNotified})`
      );

      return {
        result: "OK" as const,
        data: { inquiryID: inquiryRef.id },
      } as z.infer<typeof ResponseSchema>;
    } catch (error) {
      logger.error(error);
      return {
        result: "NG" as const,
        error: {
          message:
            error instanceof Error
              ? error.message
              : "お問い合わせの送信に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("submitInquiry"),
    secrets: [slackBotToken, slackInquiryChannelID],
  },
  submitInquiryFlow
);
