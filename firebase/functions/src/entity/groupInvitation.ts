import * as z from "zod";
import { zTimestamp } from "./timestamp";

export const GroupInvitationStatusSchema = z.enum([
  "pending",
  "accepted",
  "expired",
]);

export type GroupInvitationStatus = z.infer<typeof GroupInvitationStatusSchema>;

export const GroupInvitationSchema = z.object({
  id: z.string(),
  groupID: z.string(),
  inviterUserID: z.string(),
  token: z.string(),
  status: GroupInvitationStatusSchema,
  expiresDateTime: zTimestamp,
  createdDateTime: zTimestamp.optional(),
  updatedDateTime: zTimestamp.optional(),
});

export type GroupInvitation = z.infer<typeof GroupInvitationSchema>;
