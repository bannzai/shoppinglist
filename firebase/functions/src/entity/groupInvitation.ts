import * as z from "zod";

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
  expiresDateTime: z.any(),
  createdDateTime: z.any().optional(),
  updatedDateTime: z.any().optional(),
});

export type GroupInvitation = z.infer<typeof GroupInvitationSchema>;
