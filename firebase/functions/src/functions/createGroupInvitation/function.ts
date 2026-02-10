import admin from "firebase-admin";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { v4 as uuidv4 } from "uuid";
import { ai } from "../utils/genkit";
import { appAuthPolicy } from "../utils/authPolicy";
import {
  DataResponseSchema,
  ErrorResponseSchema,
} from "../../entity/response";
import { day } from "../../core/foundation";

const INVITE_BASE_URL = "https://shopping-list-prod-a615c.web.app/invite";
const INVITATION_EXPIRY_DAYS = 7;

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      invitationURL: z.string(),
    }),
  }),
  ErrorResponseSchema,
]);

// 検証用引数: { "groupID": "test-group-id" }
const createGroupInvitationFlow = ai.defineFlow(
  {
    name: "createGroupInvitation",
    inputSchema: z.object({
      groupID: z.string(),
    }),
    outputSchema: ResponseSchema,
  },
  async (input: { groupID: string }) => {
    const { groupID } = input;

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
      const groupDoc = await firestore.collection("groups").doc(groupID).get();
      if (!groupDoc.exists) {
        return {
          result: "NG" as const,
          error: { message: "グループが見つかりません" },
        };
      }

      const groupData = groupDoc.data();
      const memberUserIDs: string[] = groupData?.memberUserIDs ?? [];
      if (!memberUserIDs.includes(uid)) {
        return {
          result: "NG" as const,
          error: { message: "グループのメンバーではありません" },
        };
      }

      const token = uuidv4();
      const now = admin.firestore.Timestamp.now();
      const expiresDateTime = admin.firestore.Timestamp.fromMillis(
        now.toMillis() + day * INVITATION_EXPIRY_DAYS
      );

      const invitationRef = firestore.collection("groupInvitations").doc();
      await invitationRef.set({
        id: invitationRef.id,
        groupID,
        inviterUserID: uid,
        token,
        status: "pending",
        expiresDateTime,
        createdDateTime: admin.firestore.FieldValue.serverTimestamp(),
        updatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
      });

      const invitationURL = `${INVITE_BASE_URL}?token=${token}`;
      logger.info(`Created invitation for group ${groupID}: ${invitationURL}`);

      return {
        result: "OK" as const,
        data: {
          invitationURL,
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
              : "招待の作成に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("createGroupInvitation"),
  },
  createGroupInvitationFlow
);
