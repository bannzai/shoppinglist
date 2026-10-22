import admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { onCallGenkit } from "firebase-functions/https";
import * as z from "zod";
import { ai } from "../utils/genkit";
import { currentAuthUID } from "../utils/currentAuthUID";
import { appAuthPolicy } from "../utils/authPolicy";
import { developerToken, isDeveloper } from "../../core/developer";
import {
  DataResponseSchema,
  ErrorResponseSchema,
} from "../../entity/response";

/** groups コレクションのドキュメントスキーマ（メンバー判定に必要なフィールドのみ）。 */
interface GroupData {
  memberUserIDs: string[];
}

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({}),
  }),
  ErrorResponseSchema,
]);

/// 呼び出し元のデバッグユーザーID（`{uid}_debug_{数字}`）かを判定する。
/// firestore.rules の isDebugUserOf と同じ形式。任意の uid をメンバーに加えられないよう、
/// 呼び出し元本人のデバッグユーザーだけを操作対象にする。
function isDebugUserIDOf({
  debugUserID,
  uid,
}: {
  debugUserID: string;
  uid: string;
}): boolean {
  return (
    debugUserID.startsWith(`${uid}_debug_`) &&
    /^[0-9]+$/.test(debugUserID.slice(`${uid}_debug_`.length))
  );
}

// 検証用引数: { "groupID": "<groupID>", "debugUserID": "<uid>_debug_1", "membership": "join" }
const updateDebugUserGroupMembershipFlow = ai.defineFlow(
  {
    name: "updateDebugUserGroupMembership",
    inputSchema: z.object({
      groupID: z.string(),
      debugUserID: z.string(),
      membership: z.enum(["join", "leave"]),
    }),
    outputSchema: ResponseSchema,
  },
  async ({ groupID, debugUserID, membership }) => {
    try {
      const uid = currentAuthUID();
      if (!uid) {
        return {
          result: "NG" as const,
          error: { message: "認証されていません" },
        };
      }
      // 登録された開発者本人のみ実行可能。本番ユーザーが叩いても NG を返す。
      if (!(await isDeveloper(uid))) {
        return {
          result: "NG" as const,
          error: { message: "この機能は開発者のみ使用できます" },
        };
      }
      if (!isDebugUserIDOf({ debugUserID, uid })) {
        return {
          result: "NG" as const,
          error: { message: "自分のデバッグユーザーのみ操作できます" },
        };
      }

      const firestore = admin.firestore();
      const groupRef = firestore.collection("groups").doc(groupID);
      const errorMessage = await firestore.runTransaction(
        async (transaction) => {
          const groupDoc = await transaction.get(groupRef);
          if (!groupDoc.exists) {
            return "グループが見つかりません";
          }
          const groupData = groupDoc.data() as GroupData | undefined;
          if (!(groupData?.memberUserIDs ?? []).includes(uid)) {
            return "グループのメンバーではありません";
          }
          // arrayUnion / arrayRemove は既に追加・除去済みでも結果が変わらないため冪等。
          transaction.update(groupRef, {
            memberUserIDs:
              membership === "join"
                ? FieldValue.arrayUnion(debugUserID)
                : FieldValue.arrayRemove(debugUserID),
            updatedDateTime: FieldValue.serverTimestamp(),
            serverUpdatedDateTime: FieldValue.serverTimestamp(),
          });
          return null;
        }
      );
      if (errorMessage) {
        return {
          result: "NG" as const,
          error: { message: errorMessage },
        };
      }

      logger.info(
        `Debug user ${debugUserID} ${membership} group ${groupID} by ${uid}`
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
              : "デバッグユーザーのメンバー更新に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("updateDebugUserGroupMembership"),
    secrets: [developerToken],
  },
  updateDebugUserGroupMembershipFlow
);
