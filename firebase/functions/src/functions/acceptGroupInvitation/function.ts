import admin from "firebase-admin";
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
      groupID: z.string(),
    }),
  }),
  ErrorResponseSchema,
]);

// 検証用引数: { "invitationCode": "ABCD3456" }
const acceptGroupInvitationFlow = ai.defineFlow(
  {
    name: "acceptGroupInvitation",
    inputSchema: z.object({
      invitationCode: z.string(),
    }),
    outputSchema: ResponseSchema,
  },
  async (input: { invitationCode: string }) => {
    const { invitationCode } = input;

    try {
      const context = ai.currentContext();
      const uid = context?.auth?.uid;
      if (!uid) {
        return {
          result: "NG" as const,
          error: { message: "認証されていません" },
        };
      }

      const firestore = admin.firestore();

      // invitationCode + status == "pending" で招待を検索
      const invitationSnapshot = await firestore
        .collection("groupInvitations")
        .where("invitationCode", "==", invitationCode)
        .where("status", "==", "pending")
        .limit(1)
        .get();

      if (invitationSnapshot.empty) {
        return {
          result: "NG" as const,
          error: { message: "有効な招待が見つかりません" },
        };
      }

      const invitationDoc = invitationSnapshot.docs[0];
      const invitationData = invitationDoc.data();

      // 期限切れチェック
      const expiresDateTime = invitationData.expiresDateTime?.toDate();
      if (expiresDateTime && expiresDateTime < new Date()) {
        // ステータスを expired に更新
        await invitationDoc.ref.update({
          status: "expired",
          updatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
        return {
          result: "NG" as const,
          error: { message: "招待の有効期限が切れています" },
        };
      }

      const groupID = invitationData.groupID;

      // グループの存在確認
      const groupDoc = await firestore
        .collection("groups")
        .doc(groupID)
        .get();
      if (!groupDoc.exists) {
        return {
          result: "NG" as const,
          error: { message: "グループが見つかりません" },
        };
      }

      const groupData = groupDoc.data();
      const memberUserIDs: string[] = groupData?.memberUserIDs ?? [];

      // 冪等性: 既にメンバーの場合は正常終了
      if (memberUserIDs.includes(uid)) {
        logger.info(
          `User ${uid} is already a member of group ${groupID}. Skipping.`
        );
        return {
          result: "OK" as const,
          data: { groupID },
        } as z.infer<typeof ResponseSchema>;
      }

      // トランザクションを使用して、グループへの参加と招待ステータスの更新をアトミックに行います。
      await firestore.runTransaction(async (transaction) => {
        transaction.update(groupDoc.ref, {
          memberUserIDs: admin.firestore.FieldValue.arrayUnion(uid),
          updatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
        transaction.update(invitationDoc.ref, {
          status: "accepted",
          updatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      logger.info(`User ${uid} joined group ${groupID} via invitation`);

      return {
        result: "OK" as const,
        data: { groupID },
      } as z.infer<typeof ResponseSchema>;
    } catch (error) {
      logger.error(error);
      return {
        result: "NG" as const,
        error: {
          message:
            error instanceof Error
              ? error.message
              : "招待の受け入れに失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("acceptGroupInvitation"),
  },
  acceptGroupInvitationFlow
);
