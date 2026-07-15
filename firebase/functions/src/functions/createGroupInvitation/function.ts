import admin from "firebase-admin";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import * as crypto from "crypto";
import { ai } from "../utils/genkit";
import { currentAuthUID } from "../utils/currentAuthUID";
import { appAuthPolicy } from "../utils/authPolicy";
import {
  DataResponseSchema,
  ErrorResponseSchema,
} from "../../entity/response";
import { day } from "../../core/foundation";

// 紛らわしい文字（O,0,I,1,L,2,U,Z）を除外した28文字のアルファベット
const ALPHABET = "ABCDEFGHJKMNPQRSTVWXY3456789";
const CODE_LENGTH = 8;
const INVITATION_EXPIRY_DAYS = 7;

function generateInvitationCode(): string {
  let code = "";
  const alphabetLength = ALPHABET.length;
  const limit = 256 - (256 % alphabetLength);
  while (code.length < CODE_LENGTH) {
    const randomByte = crypto.randomBytes(1)[0];
    if (randomByte < limit) {
      code += ALPHABET[randomByte % alphabetLength];
    }
  }
  return code;
}

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      invitationCode: z.string(),
      // 招待コードの有効期限を ISO8601 文字列で返す。
      // クライアントで `DateTime.parse` して残り時間表示に使う。
      expiresDateTime: z.string(),
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
      const uid = currentAuthUID();
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

      // コード重複チェック付きで招待コードを生成
      let invitationCode: string;
      let attempts = 0;
      const maxAttempts = 10;
      do {
        invitationCode = generateInvitationCode();
        const existing = await firestore
          .collection("groupInvitations")
          .where("invitationCode", "==", invitationCode)
          .limit(1)
          .get();
        if (existing.empty) break;
        attempts++;
      } while (attempts < maxAttempts);

      if (attempts >= maxAttempts) {
        return {
          result: "NG" as const,
          error: { message: "招待コードの生成に失敗しました。再度お試しください" },
        };
      }

      const now = Timestamp.now();
      const expiresDateTime = Timestamp.fromMillis(
        now.toMillis() + day * INVITATION_EXPIRY_DAYS
      );

      const invitationRef = firestore.collection("groupInvitations").doc();
      await invitationRef.set({
        id: invitationRef.id,
        groupID,
        inviterUserID: uid,
        invitationCode,
        status: "pending",
        expiresDateTime,
        createdDateTime: FieldValue.serverTimestamp(),
        updatedDateTime: FieldValue.serverTimestamp(),
        serverCreatedDateTime: FieldValue.serverTimestamp(),
        serverUpdatedDateTime: FieldValue.serverTimestamp(),
      });

      logger.info(
        `Created invitation for group ${groupID}: code=${invitationCode}`
      );

      return {
        result: "OK" as const,
        data: {
          invitationCode,
          expiresDateTime: expiresDateTime.toDate().toISOString(),
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
