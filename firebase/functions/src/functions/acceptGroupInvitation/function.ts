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
import { groupUserProfileDocumentID } from "../../entity/group_user_profile";

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
          serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
        return {
          result: "NG" as const,
          error: { message: "招待の有効期限が切れています" },
        };
      }

      const groupID = invitationData.groupID;
      const groupRef = firestore.collection("groups").doc(groupID);

      // トランザクションを使用して、グループへの参加と招待ステータスの更新をアトミックに行います。
      // 招待ドキュメントもトランザクション内で再読み込みし、レースコンディションを防ぎます。
      const joined = await firestore.runTransaction(async (transaction) => {
        const [groupDoc, invitationDocSnapshot] = await Promise.all([
          transaction.get(groupRef),
          transaction.get(invitationDoc.ref),
        ]);

        if (!groupDoc.exists) {
          throw new Error("グループが見つかりません");
        }

        // トランザクション内で招待ステータスを再検証（同時利用によるレースコンディション対策）
        const currentInvitationData = invitationDocSnapshot.data();
        if (!currentInvitationData || currentInvitationData.status !== "pending") {
          throw new Error("この招待コードは既に使用されています");
        }

        const groupData = groupDoc.data();
        const memberUserIDs: string[] = groupData?.memberUserIDs ?? [];

        // 冪等性: 既にメンバーの場合は何もしない
        if (memberUserIDs.includes(uid)) {
          return false;
        }

        transaction.update(groupDoc.ref, {
          memberUserIDs: admin.firestore.FieldValue.arrayUnion(uid),
          updatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
          serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });
        transaction.update(invitationDoc.ref, {
          status: "accepted",
          updatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
          serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });

        // 参加ユーザーのプロフィールを作成
        const userRecord = await admin.auth().getUser(uid);
        const profileID = groupUserProfileDocumentID({ groupID, userID: uid });
        const profileRef = groupRef
          .collection("userProfiles")
          .doc(profileID);
        transaction.set(profileRef, {
          id: profileID,
          userID: uid,
          displayName: userRecord.displayName || null,
          createdDateTime: admin.firestore.FieldValue.serverTimestamp(),
          updatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
          serverCreatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
          serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });

        return true;
      });

      if (joined) {
        logger.info(`User ${uid} joined group ${groupID} via invitation`);
      } else {
        logger.info(
          `User ${uid} is already a member of group ${groupID}. Skipping.`
        );
      }

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
