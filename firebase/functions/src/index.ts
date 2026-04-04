import admin = require("firebase-admin");
import { defineString } from "firebase-functions/params";

console.log("THIS IS NOT TEST ENVIRONMENT");
if (process.env.ENV === "local") {
  console.log("THIS IS LOCAL ENVIRONMENT");
  admin.initializeApp({
    storageBucket: "gs://shopping-list-prod-a615c.firebasestorage.app",
  });
} else {
  admin.initializeApp({
    storageBucket: "gs://shopping-list-prod-a615c.firebasestorage.app",
  });
}

// https://github.com/firebase/firebase-functions/issues/1567#issue-2303336877
// 本当はdefineSecretを使いたい
// defineSecret("GOOGLE_GENAI_API_KEY");
defineString("GOOGLE_GENAI_API_KEY");

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
  process.env.FUNCTION_NAME === "createShoppingList"
) {
  exports.createShoppingList = require("./functions/createShoppingList/function");
}

if (
  !process.env.FUNCTION_NAME ||
  process.env.FUNCTION_NAME === "createGroup"
) {
  exports.createGroup = require("./functions/createGroup/function");
}
