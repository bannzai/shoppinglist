import admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
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
import { groupUserProfileDocumentID } from "../../entity/group_user_profile";

interface GroupData {
  memberUserIDs: string[];
  ownerUserID: string | null;
  name: string | null;
  updatedDateTime?: FirebaseFirestore.Timestamp;
  serverUpdatedDateTime?: FirebaseFirestore.Timestamp;
}

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({}),
  }),
  ErrorResponseSchema,
]);

// 検証用引数: { "groupID": "test-group-id", "targetUserID": "target-user-id" }
const removeGroupMemberFlow = ai.defineFlow(
  {
    name: "removeGroupMember",
    inputSchema: z.object({
      groupID: z.string(),
      targetUserID: z.string(),
    }),
    outputSchema: ResponseSchema,
  },
  async (input: { groupID: string; targetUserID: string }) => {
    const { groupID, targetUserID } = input;

    try {
      const uid = currentAuthUID();
      if (!uid) {
        return {
          result: "NG" as const,
          error: { message: "認証されていません" },
        };
      }

      const firestore = admin.firestore();
      const groupRef = firestore.collection("groups").doc(groupID);
      const groupDoc = await groupRef.get();

      if (!groupDoc.exists) {
        return {
          result: "NG" as const,
          error: { message: "グループが見つかりません" },
        };
      }

      const groupData = groupDoc.data() as GroupData | undefined;
      const ownerUserID = groupData?.ownerUserID ?? null;

      if (ownerUserID === null) {
        return {
          result: "NG" as const,
          error: { message: "オーナーが設定されていないグループでは操作できません" },
        };
      }

      if (ownerUserID !== uid) {
        return {
          result: "NG" as const,
          error: { message: "グループのオーナーのみがメンバーを削除できます" },
        };
      }

      if (targetUserID === uid) {
        return {
          result: "NG" as const,
          error: { message: "オーナー自身を削除することはできません" },
        };
      }

      await firestore.runTransaction(async (transaction) => {
        const groupSnapshot = await transaction.get(groupRef);
        const currentData = groupSnapshot.data() as GroupData | undefined;
        const memberUserIDs: string[] = currentData?.memberUserIDs ?? [];

        // 冪等性: 既にメンバーでなければそのまま終了
        if (!memberUserIDs.includes(targetUserID)) {
          return;
        }

        // Firestoreトランザクションは全てのreadを全てのwriteより前に実行する必要があるため、
        // defaultGroupID判定に使う対象ユーザーと、失効させる招待のreadを書き込みより先に済ませる。
        const userRef = firestore.collection("users").doc(targetUserID);
        const [userDoc, pendingInvitationsSnapshot] = await Promise.all([
          transaction.get(userRef),
          transaction.get(
            firestore
              .collection("groupInvitations")
              .where("groupID", "==", groupID)
              .where("inviterUserID", "==", targetUserID)
              .where("status", "==", "pending")
          ),
        ]);

        transaction.update(groupRef, {
          memberUserIDs: FieldValue.arrayRemove(targetUserID),
          updatedDateTime: FieldValue.serverTimestamp(),
          serverUpdatedDateTime: FieldValue.serverTimestamp(),
        });

        // 対象ユーザーのプロフィールを削除
        const profileRef = groupRef
          .collection("userProfiles")
          .doc(groupUserProfileDocumentID({ groupID, userID: targetUserID }));
        transaction.delete(profileRef);

        // 外したユーザーが在籍中に発行した招待コードで戻れないよう、pending の招待を失効させる
        for (const invitationDoc of pendingInvitationsSnapshot.docs) {
          transaction.update(invitationDoc.ref, {
            status: "expired",
            updatedDateTime: FieldValue.serverTimestamp(),
            serverUpdatedDateTime: FieldValue.serverTimestamp(),
          });
        }

        // 対象ユーザーの defaultGroupID が当該グループの場合はnullに更新
        if (userDoc.exists) {
          const userData = userDoc.data();
          if (userData?.defaultGroupID === groupID) {
            transaction.update(userRef, {
              defaultGroupID: null,
              updatedDateTime: FieldValue.serverTimestamp(),
              serverUpdatedDateTime: FieldValue.serverTimestamp(),
            });
          }
        }
      });

      logger.info(
        `User ${targetUserID} removed from group ${groupID} by ${uid}`
      );

      return {
        result: "OK" as const,
        data: {},
      } as z.infer<typeof ResponseSchema>;
    } catch (error) {
      logger.error(error);
      return {
        result: "NG" as const,
        error: {
          message:
            error instanceof Error
              ? error.message
              : "メンバーの削除に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("removeGroupMember"),
  },
  removeGroupMemberFlow
);
