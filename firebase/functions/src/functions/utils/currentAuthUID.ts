import { ai } from "./genkit";

/** GenKit Flow 内で認証済みユーザーの uid を取得する。
 *
 * `npm run genkit:start` で起動する GenKit Dev Server では `GENKIT_ENV=dev` が
 * セットされ、API コンソール(Developer UI)からの呼び出しには認証コンテキストが
 * 渡らない。このため dev のときだけ検証用ダミー uid を返し、認証なしでも Flow を
 * 実行できるようにする（検証データは `users/genkit-dev-user/...` 配下に書かれる）。
 *
 * 本番(Cloud Functions)では `GENKIT_ENV` は "dev" にならないため、認証コンテキストの
 * uid をそのまま返し、無ければ undefined を返す（呼び出し側で「認証されていません」を返す）。 */
export function currentAuthUID(): string | undefined {
  const uid = ai.currentContext()?.auth?.uid;
  if (uid) {
    return uid;
  }
  if (process.env.GENKIT_ENV === "dev") {
    return "genkit-dev-user";
  }
  return undefined;
}
