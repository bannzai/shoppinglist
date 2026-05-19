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

/// 無料ユーザーがソログループに加えて作成できるグループ数の上限。
/// NOTE: クライアント側(lib/entity/group.dart の freeAdditionalGroupCreationLimit)と同じ値を維持すること。
const FREE_ADDITIONAL_GROUP_CREATION_LIMIT = 1;

/// グループ名の最大文字数。
const MAX_GROUP_NAME_LENGTH = 100;

/// AppUserドキュメントの型定義。
interface AppUserData {
  defaultGroupID?: string | null;
}

const ResponseSchema = z.union([
  DataResponseSchema.extend({
    data: z.object({
      groupID: z.string(),
    }),
  }),
  ErrorResponseSchema,
]);

/// design_handoff_shoppinglist/preview/screens-groups.jsx#GroupCreatePage の
/// iconName で許容するアイコンプリセット。Group.iconName のスキーマ統制値。
const ALLOWED_ICON_NAMES = [
  "home",
  "cart",
  "fork",
  "cookie",
  "pets",
  "bag",
] as const;

// 検証用引数: { "createUserID": "test-user-id", "name": "テスト", "setAsDefault": false, "iconName": "home" }
const createGroupFlow = ai.defineFlow(
  {
    name: "createGroup",
    inputSchema: z.object({
      createUserID: z
        .string()
        .min(1)
        .refine((v) => !v.includes("/")),
      name: z.string().nullable(),
      setAsDefault: z.boolean(),
      iconName: z.enum(ALLOWED_ICON_NAMES).default("home"),
    }),
    outputSchema: ResponseSchema,
  },
  async ({ createUserID, name, setAsDefault, iconName }) => {
    try {
      const context = ai.currentContext();
      const uid = context?.auth?.uid;
      if (!uid) {
        return {
          result: "NG" as const,
          error: { message: "認証されていません" },
        };
      }

      if (uid !== createUserID) {
        return {
          result: "NG" as const,
          error: { message: "createUserIDが認証ユーザーと一致しません" },
        };
      }

      const normalizedName = name?.trim() ?? null;
      // eslint-disable-next-line no-control-regex
      if (normalizedName != null && /[\x00-\x1F\x7F]/.test(normalizedName)) {
        return {
          result: "NG" as const,
          error: { message: "グループ名に使用できない文字が含まれています" },
        };
      }
      if (
        normalizedName != null &&
        normalizedName.length > MAX_GROUP_NAME_LENGTH
      ) {
        return {
          result: "NG" as const,
          error: {
            message: `グループ名は${MAX_GROUP_NAME_LENGTH}文字以内で入力してください`,
          },
        };
      }

      const firestore = admin.firestore();
      const isPremium = context?.auth?.token?.isPremium === true;

      if (!isPremium) {
        const ownedGroupCountSnapshot = await firestore
          .collection("groups")
          .where("ownerUserID", "==", uid)
          .count()
          .get();
        if (
          ownedGroupCountSnapshot.data().count >=
          FREE_ADDITIONAL_GROUP_CREATION_LIMIT + 1
        ) {
          return {
            result: "NG" as const,
            error: {
              message: `無料プランではソログループ+${FREE_ADDITIONAL_GROUP_CREATION_LIMIT}グループまで作成できます。プレミアムにアップグレードすると無制限に作成できます`,
            },
          };
        }
      }

      // createGroup は新規ID払い出しを伴うため非冪等。重複作成は上限チェックとUIの二重送信防止で抑止する。
      const groupRef = firestore.collection("groups").doc();
      const userRef = firestore.collection("users").doc(uid);
      const profileRef = firestore
        .collection(`groups/${groupRef.id}/userProfiles`)
        .doc(`GroupUserProfile_groups_${groupRef.id}_users_${uid}`);

      await firestore.runTransaction(async (transaction) => {
        const userSnapshot = await transaction.get(userRef);
        const userData = userSnapshot.data() as AppUserData | undefined;
        const shouldSetDefault =
          setAsDefault || userData?.defaultGroupID == null;

        transaction.set(
          groupRef,
          {
            id: groupRef.id,
            ownerUserID: uid,
            memberUserIDs: [uid],
            name: normalizedName?.length ? normalizedName : null,
            iconName,
            createdDateTime: admin.firestore.FieldValue.serverTimestamp(),
            updatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
            serverCreatedDateTime:
              admin.firestore.FieldValue.serverTimestamp(),
            serverUpdatedDateTime:
              admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );

        transaction.set(
          profileRef,
          {
            id: profileRef.id,
            groupID: groupRef.id,
            userID: uid,
            serverCreatedDateTime:
              admin.firestore.FieldValue.serverTimestamp(),
            serverUpdatedDateTime:
              admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );

        if (shouldSetDefault) {
          transaction.set(
            userRef,
            {
              defaultGroupID: groupRef.id,
              serverUpdatedDateTime:
                admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
        }
      });

      logger.info(`Created group ${groupRef.id} by ${uid}`);

      return {
        result: "OK" as const,
        data: {
          groupID: groupRef.id,
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
              : "グループの作成に失敗しました",
        },
      } as z.infer<typeof ResponseSchema>;
    }
  }
);

module.exports = onCallGenkit(
  {
    authPolicy: appAuthPolicy("createGroup"),
  },
  createGroupFlow
);
