/**
 * composite ID: UserPrivate_users_{userID}
 */
export function appUserPrivateDocumentID({
  userID,
}: {
  userID: string;
}): string {
  return `UserPrivate_users_${userID}`;
}
