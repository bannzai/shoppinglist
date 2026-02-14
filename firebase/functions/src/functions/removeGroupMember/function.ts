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
      const context = ai.currentContext();
      const uid = context?.auth?.uid;
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

      const groupData = groupDoc.data();
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
        const currentData = groupSnapshot.data();
        const memberUserIDs: string[] = currentData?.memberUserIDs ?? [];

        // 冪等性: 既にメンバーでなければそのまま終了
        if (!memberUserIDs.includes(targetUserID)) {
          return;
        }

        transaction.update(groupRef, {
          memberUserIDs: admin.firestore.FieldValue.arrayRemove(targetUserID),
          updatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        });

        // 対象ユーザーのプロフィールを削除
        const profileRef = groupRef
          .collection("userProfiles")
          .doc(`group_${groupID}_userProfile_${targetUserID}`);
        transaction.delete(profileRef);

        // 対象ユーザーの defaultGroupID が当該グループの場合はnullに更新
        const userRef = firestore.collection("users").doc(targetUserID);
        const userDoc = await transaction.get(userRef);
        if (userDoc.exists) {
          const userData = userDoc.data();
          if (userData?.defaultGroupID === groupID) {
            transaction.update(userRef, {
              defaultGroupID: null,
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
