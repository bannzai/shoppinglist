/**
 * composite ID: PremiumEntitlement_users_{userID}
 * firestore.rules の isPremiumUser も同じ形式で文書を参照する。
 */
export function premiumEntitlementDocumentID({
  userID,
}: {
  userID: string;
}): string {
  return `PremiumEntitlement_users_${userID}`;
}
