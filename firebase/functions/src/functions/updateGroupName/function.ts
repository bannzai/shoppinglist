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

// 検証用引数: { "groupID": "test-group-id", "name": "新しい名前" }
const updateGroupNameFlow = ai.defineFlow(
  {
    name: "updateGroupName",
    inputSchema: z.object({
      groupID: z.string(),
      name: z.string(),
    }),
    outputSchema: ResponseSchema,
  },
  async (input: { groupID: string; name: string }) => {
    const { groupID, name } = input;

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
      const memberUserIDs: string[] = groupData?.memberUserIDs ?? [];

      if (!memberUserIDs.includes(uid)) {
        return {
          result: "NG" as const,
          error: { message: "グループのメンバーではありません" },
        };
      }

      const ownerUserID = groupData?.ownerUserID ?? null;

      // ownerUserIDがnullの場合はメンバーであれば許可（レガシーグループ対応）
      // ownerUserIDが存在する場合はオーナーのみ許可
      if (ownerUserID !== null && ownerUserID !== uid) {
        return {
          result: "NG" as const,
          error: { message: "グループのオーナーのみが名前を変更できます" },
        };
      }

      await groupRef.update({
        name,
        updatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
        serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
      });

      logger.info(`Group ${groupID} name updated to "${name}" by ${uid}`);

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
              : "グループ名の更新に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("updateGroupName"),
  },
  updateGroupNameFlow
);
