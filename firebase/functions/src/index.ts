import admin = require("firebase-admin");
import { setGlobalOptions } from "firebase-functions/v2";

// Functions Emulator は未設定の secret (defineSecret) を ADC 経由で本番 Secret Manager へ
// 読みに行き、権限の無い環境では未解決のまま関数が動かなくなる
// (https://firebase.google.com/docs/functions/config-env#secrets_and_credentials_in_the_cloud_functions_emulator)。
// クリーンな checkout や CI でも本番非接触・非対話で emulator を起動できるよう、
// emulator 実行時のみ未設定の secret にダミー値を与える (premium 判定等は fail-closed で無料扱いになる)。
// 実値が必要な検証は firebase/functions/.secret.local (gitignore 済み) で上書きする。
if (process.env.FUNCTIONS_EMULATOR === "true") {
  const emulatorDummySecretNames = [
    "REVENUECAT_SECRET_API_KEY",
    "SHOPPINGLIST_DEVELOPER_TOKEN",
    "SLACK_BOT_TOKEN",
    "SLACK_INQUIRY_CHANNEL_ID",
    "GOOGLE_GENAI_API_KEY",
  ];
  for (const secretName of emulatorDummySecretNames) {
    process.env[secretName] ??= "dummy";
  }
}

// 全 Functions を東京リージョンにデプロイする。
// Firestore / Storage(asia-northeast1) とコロケーションしクロスリージョン往復を排除する。
// 各 function モジュールの require より前に呼ぶ必要があるため最上部に置く。
setGlobalOptions({ region: "asia-northeast1" });

console.log("THIS IS NOT TEST ENVIRONMENT");
// Functions ランタイムが設定する project id から Storage バケット名を導出し、
// プロジェクト(dev/prod)ごとに正しいバケットを参照する。ハードコードしない。
// gen2 では GCLOUD_PROJECT / GOOGLE_CLOUD_PROJECT のいずれかが設定されるためフォールバックする。
const projectId = process.env.GCLOUD_PROJECT ?? process.env.GOOGLE_CLOUD_PROJECT;
const storageBucket = `gs://${projectId}.firebasestorage.app`;
console.log(`initializeApp storageBucket=${storageBucket}`);
if (process.env.ENV === "local") {
  console.log("THIS IS LOCAL ENVIRONMENT");
  admin.initializeApp({ storageBucket });
} else {
  admin.initializeApp({ storageBucket });
}

admin.firestore().settings({ ignoreUndefinedProperties: true });

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "generateShoppingListItemsFromImage"
) {
  exports.generateShoppingListItemsFromImage = require("./functions/generateShoppingListItemsFromImage/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "createGroupInvitation"
) {
  exports.createGroupInvitation = require("./functions/createGroupInvitation/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "acceptGroupInvitation"
) {
  exports.acceptGroupInvitation = require("./functions/acceptGroupInvitation/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "removeGroupMember"
) {
  exports.removeGroupMember = require("./functions/removeGroupMember/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "updateGroupName"
) {
  exports.updateGroupName = require("./functions/updateGroupName/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "sendShoppingListUpdateNotification"
) {
  exports.sendShoppingListUpdateNotification = require("./functions/sendShoppingListUpdateNotification/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "generateShoppingListItemsFromURL"
) {
  exports.generateShoppingListItemsFromURL = require("./functions/generateShoppingListItemsFromURL/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "createGroup"
) {
  exports.createGroup = require("./functions/createGroup/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "uploadShoppingListItemImage"
) {
  exports.uploadShoppingListItemImage = require("./functions/uploadShoppingListItemImage/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "deleteShoppingListItemImage"
) {
  exports.deleteShoppingListItemImage = require("./functions/deleteShoppingListItemImage/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "deleteShoppingList"
) {
  exports.deleteShoppingList = require("./functions/deleteShoppingList/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "uploadReceiptImage"
) {
  exports.uploadReceiptImage = require("./functions/uploadReceiptImage/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "grantPromotionalPremium"
) {
  exports.grantPromotionalPremium = require("./functions/grantPromotionalPremium/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "revokePromotionalPremium"
) {
  exports.revokePromotionalPremium = require("./functions/revokePromotionalPremium/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "updateDebugUserGroupMembership"
) {
  exports.updateDebugUserGroupMembership = require("./functions/updateDebugUserGroupMembership/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "setupTestCategoryLocationOrder"
) {
  exports.setupTestCategoryLocationOrder = require("./functions/setupTestCategoryLocationOrder/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "categorizeShoppingListItems"
) {
  exports.categorizeShoppingListItems = require("./functions/categorizeShoppingListItems/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "submitInquiry"
) {
  exports.submitInquiry = require("./functions/submitInquiry/function");
}

// firebase-crashlytics-alert-setup begin (bannzai/castle の skill が管理する区間。手で編集しない)
exports.crashlyticsNewFatalIssueToSlack = require("./lib/crashlyticsAlert").crashlyticsNewFatalIssueToSlack;
exports.crashlyticsRegressionToSlack = require("./lib/crashlyticsAlert").crashlyticsRegressionToSlack;
exports.crashlyticsVelocityToSlack = require("./lib/crashlyticsAlert").crashlyticsVelocityToSlack;
// firebase-crashlytics-alert-setup end
