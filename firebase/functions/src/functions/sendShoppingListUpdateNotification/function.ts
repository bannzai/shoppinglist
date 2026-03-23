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
      successCount: z.number(),
      failureCount: z.number(),
    }),
  }),
  ErrorResponseSchema,
]);

// 検証用引数: { "groupID": "test-group-id", "shoppingListID": "test-list-id", "shoppingListName": "テストリスト", "targetUserIDs": ["user-id-1"] }
const sendShoppingListUpdateNotificationFlow = ai.defineFlow(
  {
    name: "sendShoppingListUpdateNotification",
    inputSchema: z.object({
      groupID: z.string(),
      shoppingListID: z.string(),
      shoppingListName: z.string().nullable(),
      targetUserIDs: z.array(z.string()),
    }),
    outputSchema: ResponseSchema,
  },
  async (input: {
    groupID: string;
    shoppingListID: string;
    shoppingListName: string | null;
    targetUserIDs: string[];
  }) => {
    const { groupID, shoppingListID, shoppingListName, targetUserIDs } = input;

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

      // グループメンバーシップ検証
      const groupDoc = await firestore.collection("groups").doc(groupID).get();
      if (!groupDoc.exists) {
        return {
          result: "NG" as const,
          error: { message: "グループが見つかりません" },
        };
      }

      interface GroupData {
        memberUserIDs: string[];
      }
      const groupData = groupDoc.data() as GroupData | undefined;
      const memberUserIDs: string[] = groupData?.memberUserIDs ?? [];
      if (!memberUserIDs.includes(uid)) {
        return {
          result: "NG" as const,
          error: { message: "グループのメンバーではありません" },
        };
      }

      // 送信者のdisplayNameを取得
      const senderProfileDoc = await firestore
        .collection("groups")
        .doc(groupID)
        .collection("userProfiles")
        .doc(`group_${groupID}_userProfile_${uid}`)
        .get();

      interface UserProfileData {
        displayName: string | null;
      }
      const senderProfile = senderProfileDoc.data() as
        | UserProfileData
        | undefined;
      const senderName = senderProfile?.displayName ?? "メンバー";

      // 対象ユーザーのFCMトークンを取得
      const allTokens: string[] = [];
      const tokenToUserMap: Map<string, string> = new Map();

      for (const targetUserID of targetUserIDs) {
        if (targetUserID === uid) continue;
        if (!memberUserIDs.includes(targetUserID)) continue;

        const privateDocID = `user_${targetUserID}_private_${targetUserID}`;
        const privateDoc = await firestore
          .collection("users")
          .doc(targetUserID)
          .collection("privates")
          .doc(privateDocID)
          .get();

        if (!privateDoc.exists) continue;

        interface UserPrivateData {
          fcmTokens: string[];
        }
        const privateData = privateDoc.data() as UserPrivateData | undefined;
        const tokens = privateData?.fcmTokens ?? [];

        for (const token of tokens) {
          allTokens.push(token);
          tokenToUserMap.set(token, targetUserID);
        }
      }

      if (allTokens.length === 0) {
        return {
          result: "OK" as const,
          data: { successCount: 0, failureCount: 0 },
        } as z.infer<typeof ResponseSchema>;
      }

      // FCM送信
      const listName = shoppingListName || "買い物リスト";
      const message: admin.messaging.MulticastMessage = {
        tokens: allTokens,
        notification: {
          title: `${senderName}さんが買い物リストを更新しました`,
          body: `「${listName}」が更新されました`,
        },
        data: {
          groupID,
          shoppingListID,
          type: "shoppingListUpdate",
        },
      };

      const response = await admin.messaging().sendEachForMulticast(message);

      // 無効トークンのクリーンアップ
      const invalidTokens: Map<string, string[]> = new Map();
      response.responses.forEach((resp, index) => {
        if (
          !resp.success &&
          resp.error &&
          (resp.error.code === "messaging/invalid-registration-token" ||
            resp.error.code ===
              "messaging/registration-token-not-registered")
        ) {
          const token = allTokens[index];
          const userID = tokenToUserMap.get(token);
          if (userID) {
            const existing = invalidTokens.get(userID) ?? [];
            existing.push(token);
            invalidTokens.set(userID, existing);
          }
        }
      });

      // 無効トークンを一括削除
      for (const [userID, tokens] of invalidTokens.entries()) {
        const privateDocID = `user_${userID}_private_${userID}`;
        await firestore
          .collection("users")
          .doc(userID)
          .collection("privates")
          .doc(privateDocID)
          .update({
            fcmTokens: admin.firestore.FieldValue.arrayRemove(tokens),
            serverUpdatedDateTime:
              admin.firestore.FieldValue.serverTimestamp(),
          });
        logger.info(
          `Removed ${tokens.length} invalid FCM tokens for user ${userID}`
        );
      }

      logger.info(
        `Sent notifications for group ${groupID}: success=${response.successCount}, failure=${response.failureCount}`
      );

      return {
        result: "OK" as const,
        data: {
          successCount: response.successCount,
          failureCount: response.failureCount,
        },
      } as z.infer<typeof ResponseSchema>;
    } catch (error) {
      logger.error(error);
      return {
        result: "NG" as const,
        error: {
          message:
            error instanceof Error
              ? error.message
              : "通知の送信に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("sendShoppingListUpdateNotification"),
  },
  sendShoppingListUpdateNotificationFlow
);
