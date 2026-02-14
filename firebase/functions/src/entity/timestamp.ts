import { z } from "zod";
import { Timestamp } from "firebase-admin/firestore";

export const zTimestamp = z.instanceof(Timestamp);
