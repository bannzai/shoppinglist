import admin from "firebase-admin";
import { defineSecret } from "firebase-functions/params";

/// 開発者識別用トークン。
/// `firebase functions:secrets:set SHOPPINGLIST_DEVELOPER_TOKEN` で値を設定する。
/// クライアント側 (Environment.developerToken) が users/{uid}.developerToken に
/// upsert した値と一致するかで Cloud Functions の dev only 関数を認可する。
export const developerToken = defineSecret("SHOPPINGLIST_DEVELOPER_TOKEN");

/** users コレクションのドキュメントスキーマ（開発者判定に必要なフィールドのみ）。 */
interface AppUserData {
  developerToken?: string;
}

/// 指定された userID が登録された開発者かを判定する。
/// users/{userID}.developerToken が Secret Manager の SHOPPINGLIST_DEVELOPER_TOKEN と
/// 一致する場合のみ true を返す。Secret 側が空文字／未設定の場合は常に false。
export async function isDeveloper(userID: string): Promise<boolean> {
  const expected = developerToken.value();
  if (!expected) {
    return false;
  }
  const appUserData = (
    await admin.firestore().collection("users").doc(userID).get()
  ).data() as AppUserData | undefined;
  return (
    typeof appUserData?.developerToken === "string" &&
    appUserData.developerToken === expected
  );
}
