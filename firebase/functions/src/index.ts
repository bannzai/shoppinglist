import admin = require("firebase-admin");

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
