/**
 * composite ID: group_{groupID}_userProfile_{userID}
 */
export function groupUserProfileDocumentID({
  groupID,
  userID,
}: {
  groupID: string;
  userID: string;
}): string {
  return `group_${groupID}_userProfile_${userID}`;
}
