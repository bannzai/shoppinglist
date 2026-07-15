import { defineString } from "firebase-functions/params";

// Functions Emulator ではパラメータ未充足だと対話プロンプトで起動が止まり、
// クリーンな checkout や CI での非対話 E2E (emulators:start/exec) が実行できない。
// そのため emulator 実行時 (FUNCTIONS_EMULATOR=true) のみ既定値 "dev" を与える。
// デプロイ時は従来どおり .env.<projectId> 等での明示指定を必須のままにする (default なし)。
const _env = defineString(
  "APP_ENV",
  process.env.FUNCTIONS_EMULATOR === "true" ? { default: "dev" } : {}
);
export function appEnv(): string {
  return _env.value();
}
