# 0019. GenKit Dev Server 検証時のみ認証をスキップする

## Status
Accepted

## Context
クライアントから呼ぶ Functions は GenKit (`onCallGenkit`) で定義しており、`npm run genkit:start` で起動する GenKit Dev Server (Developer UI, `http://localhost:4000`) から各 Flow を直接呼び出して検証できる。「API コンソールが付いて検証しやすい」ことが GenKit 採用の理由でもある。

しかし各 Flow は本体先頭で `ai.currentContext()?.auth?.uid` を必須チェックし、uid が無ければ `{ result: "NG", error: { message: "認証されていません" } }` を返す（クライアントからの認証回避を防ぐためサーバー側で強制している）。Developer UI から runFlow で呼ぶ場合、`onCallGenkit` のラッパー（`authPolicy`）を経由せず Flow 本体が直接実行されるため認証コンテキストが渡らず、**必ず「認証されていません」で弾かれて検証できなかった**。

この認証チェックは、認証を要する 14 個の GenKit Function すべてに同じパターンで存在する。

## Decision
GenKit Dev Server で起動したときだけ認証をスキップする共通ヘルパー `currentAuthUID()` を `firebase/functions/src/functions/utils/currentAuthUID.ts` に導入し、認証チェックを持つ 14 Function すべての uid 取得をこのヘルパーに統一する。

```ts
export function currentAuthUID(): string | undefined {
  const uid = ai.currentContext()?.auth?.uid;
  if (uid) return uid;
  if (process.env.GENKIT_ENV === "dev") return "genkit-dev-user";
  return undefined;
}
```

- 判定には `GENKIT_ENV` 環境変数を使う。これは `npm run genkit:start`（`GENKIT_ENV=dev genkit start ...`）でのみ "dev" にセットされ、本番デプロイ後の Cloud Functions ランタイムや `firebase emulators`、Jest 実行では "dev" にならない。
- dev のときは検証用ダミー uid `genkit-dev-user` を返し、認証コンテキスト無しでも Flow を実行できるようにする。
- 各 Function の `if (!uid) { ... "認証されていません" ... }` のエラー応答はそのまま維持する。

### なぜ `GENKIT_ENV=dev` か
判定変数の候補として `authPolicy.ts` が使う `process.env.ENV === "local"` も検討した。しかし `genkit:start` では `ENV` がセットされず、「GenKit Dev Server 上で動いているか」を素直に表すのは `genkit start` が必ず設定する `GENKIT_ENV=dev` である。用途（Dev Server 検証）と判定が 1:1 で対応するためこちらを採用した。

## Consequences
- **利点**: 認証を要する全 GenKit Function を Developer UI から認証コンテキスト無しで検証できるようになり、検証体験が一貫する。認証チェックが共通ヘルパーに集約され DRY になる。
- **利点（本番安全性）**: 本番 Cloud Functions では `GENKIT_ENV` が "dev" にならないため認証は従来どおり必須で、本番の安全性は維持される。Jest も `GENKIT_ENV` 未設定で走るため「認証されていません」のテストはそのまま通る（15 suites / 116 tests pass を確認済み）。
- **トレードオフ（検証データ）**: dev 検証時はダミー uid `genkit-dev-user` で本番 Firestore（`service-account-key.json` 経由）にアクセスし、月次利用上限などのデータが `users/genkit-dev-user/...` 配下に書かれる。検証データが残るため、必要に応じてエミュレータ併用やクリーンアップを行う。
- **dev only Function との関係**: developer token でガードする dev only Function（[0011](0011-developer-token-auth-for-dev-only-functions.md) の `grantPromotionalPremium` / `revokePromotionalPremium` / `setupTestCategoryLocationOrder`）は、本ヘルパーでダミー uid を得ても後段の `isDeveloper(uid)` ガードで弾かれる（`users/genkit-dev-user` に `developerToken` が無いため）。これは意図どおりで、これらを Dev Server で完全に検証するには別途トークン設定が必要。
- **注意**: `GENKIT_ENV=dev` でデプロイ経路を作らないこと。本番デプロイは `genkit start` を使わないため通常は発生しないが、CI/デプロイ設定で `GENKIT_ENV` を "dev" にしてはならない（本番で認証がスキップされる）。

## Related
- ADR 0011: dev only Cloud Functions の認可を user 単位開発者トークンで行う
