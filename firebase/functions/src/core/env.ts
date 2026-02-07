import { defineString } from "firebase-functions/params";

const _env = defineString("APP_ENV");
export function appEnv(): string {
  return _env.value();
}
