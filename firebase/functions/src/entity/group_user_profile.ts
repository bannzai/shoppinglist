/**
 * composite ID: UserProfile_groups_{groupID}_users_{userID}
 */
export function groupUserProfileDocumentID({
  groupID,
  userID,
}: {
  groupID: string;
  userID: string;
}): string {
  return `UserProfile_groups_${groupID}_users_${userID}`;
}
