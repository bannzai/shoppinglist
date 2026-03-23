/**
 * composite ID: user_{userID}_private_{userID}
 */
export function appUserPrivateDocumentID({
  userID,
}: {
  userID: string;
}): string {
  return `user_${userID}_private_${userID}`;
}
