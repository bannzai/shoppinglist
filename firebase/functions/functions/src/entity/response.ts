import * as z from "zod";

export const DataResponseSchema = z.object({
  result: z.literal("OK"),
  statusCode: z.number().optional(),
  data: z.unknown(),
});

export const ErrorResponseSchema = z.object({
  result: z.literal("NG"),
  statusCode: z.number().optional(),
  error: z.object({
    message: z.string(),
  }),
});

export const AppResponseSchema = z.union([
  DataResponseSchema,
  ErrorResponseSchema,
]);

export type AppResponse = z.infer<typeof AppResponseSchema>;
