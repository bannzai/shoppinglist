/**
 * composite ID: GroupUserProfile_groups_{groupID}_users_{userID}
 */
export function groupUserProfileDocumentID({
  groupID,
  userID,
}: {
  groupID: string;
  userID: string;
}): string {
  return `GroupUserProfile_groups_${groupID}_users_${userID}`;
}
