# 0011. dev only Cloud Functions の認可を user 単位開発者トークンで行う

## Status
Accepted

## Context
`grantPromotionalPremium` / `revokePromotionalPremium` / `setupTestCategoryLocationOrder` の dev only Cloud Functions は本番ユーザーから守る必要がある。当初は `appEnv() === "dev"` というプロジェクト全体の `APP_ENV` 環境変数で守っていたが、以下の問題があった:

- prod プロジェクトの `.env.shopping-list-prod-a615c` で `APP_ENV=dev` が誤ってコミットされていた状態が見過ごされていた（Issue #239 検証時に手動切替えする運用が原因）。一度ミスると本番でも素通しになる潜在バグ。
- ADR 0008 の `grantPromotionalPremium` は dev project 検証で動作確認したいが、本番 prod に対する開発者だけの検証手段が `.env` 手書き換え依存。

Issue #242 では Firebase dev/prod project 完全分離（iOS Bundle ID `.dev` suffix / Android applicationId 分離 / Flutter エントリポイント分離 / `flutterfire` 設定二重化）で解決を計画したが、本来の目的（dev only Functions を本番ユーザーから守る）に対して工数が過大と判断し、user 単位識別方式へ方針変更した（Issue #244）。

## Decision

user ごとの "開発者トークン" で識別する方式を採用する。

**環境変数命名**は 3 階層すべて `SHOPPINGLIST_DEVELOPER_TOKEN` で統一する:

| レイヤー | 名前 |
|---|---|
| ローカル環境変数（direnv `.envrc`） | `SHOPPINGLIST_DEVELOPER_TOKEN` |
| Flutter dart-define key | `SHOPPINGLIST_DEVELOPER_TOKEN` |
| Firebase Secret Manager secret name | `SHOPPINGLIST_DEVELOPER_TOKEN` |

**実装フロー**:

1. **Flutter ランタイム**: `Environment.developerToken = String.fromEnvironment('SHOPPINGLIST_DEVELOPER_TOKEN')` で dart-define から受け取る。空文字なら本番ユーザービルド扱い。
2. **Firestore upsert**: `UserDeveloperTokenSync.call()` がアプリ起動直後（`AppUserCreateResolver` の useEffect で `AppUserCreate` の後）に `users/{userID}.developerToken` フィールドを差分検出して update する。
3. **Cloud Functions ガード**: `firebase/functions/src/core/developer.ts` の `isDeveloper(uid)` ヘルパーが `users/{uid}.developerToken` を取得して Secret Manager の値と一致比較。各 dev only Function の冒頭で `if (!(await isDeveloper(uid)))` でガード。
4. **Secret 管理**: `defineSecret('SHOPPINGLIST_DEVELOPER_TOKEN')` を `onCallGenkit` の `secrets: [...]` 配列で明示的に登録（ADR 0008 では `defineString` を使っているが、今回は本物の Secret なので `defineSecret` を使用）。
5. **Security Rules**: `users/{userID}` は本人のみ read/write 可能（`isUserAuth(userID) || isDebugUserOf(userID)`）で既にカバー済み。`developerToken` フィールド向けの追加ルールは不要、説明コメントのみ追記。

**`appEnv()` / `defineString("APP_ENV")` / `src/core/env.ts` は完全削除する**。`authPolicy.ts` の dev デバッグログは `process.env.FUNCTIONS_EMULATOR === "true"` ガードに置換し、emulator 検証時のみ uid をログ出力する形へ変更。

## Consequences

**利点:**
- Firebase dev/prod project 作成、iOS Bundle ID 分離、Android applicationId 分離、Flutter エントリポイント分離が **すべて不要**。既存 prod プロジェクト 1 つで開発・検証・本番運用すべてカバー。
- token rotation が容易: Secret Manager の値変更 + 開発者ビルド再起動で `UserDeveloperTokenSync` が自動 upsert する。
- 環境変数命名を `SHOPPINGLIST_DEVELOPER_TOKEN` に統一したことで「ローカル環境変数 vs dart-define vs Secret」のミスマッチが起きにくい。
- 「prod プロジェクトに `APP_ENV=dev` が混入する」タイプの運用ミスは構造的に発生しなくなる（`APP_ENV` 自体を廃止）。

**考慮点・トレードオフ:**
- dev only Function の各リクエストごとに `users/{uid}` の Firestore read が 1 回追加される。本番ユーザーは normal flow でこの read を発生させないので、コスト影響はほぼゼロ。
- 本番ユーザーが何らかの方法でトークン値を取得すると dev only Functions を叩ける。多層防御として:
  - Firestore Security Rules で他人の `users/{userID}` ドキュメントは read 不可
  - dart-define が空文字なら upsert しない（本番リリースビルドにトークンを焼き込まない）
  - 開発者オプション画面自体が `kDebugMode` ガードで本番ビルド非表示
- `developerToken` フィールドを誤って `kDebugMode` 外で書き込むコードを書くと non-developer ユーザーにトークンが付与される。`UserDeveloperTokenSync` で集約しているため発生しにくいが、新規実装時は `Environment.developerToken.isEmpty` の早期 return を必須とする。
- 開発者個人（`SHOPPINGLIST_DEVELOPER_TOKEN` を持つ）と本番ユーザーが同一 Firestore に共存するため、開発者 user に対して prod データが書き込まれる可能性がある。本格的な dev project 分離が必要になる検証要件が出たら別 ADR で再検討する。

## Alternatives Considered

### A. Firebase dev/prod project 完全分離（Issue #242）
- iOS Bundle ID `.dev` suffix、Android applicationId 分離、Flutter エントリポイント分離、`flutterfire` 設定二重化、Pilll パターンの Makefile + base64 復元等を含む大規模な構造変更。
- 工数が本来の目的（dev only Functions のガード強化）に対して過大。Issue #242 を Close して本 ADR の方式へ方針変更した。

### B. Firebase Custom Claims (`developerMode: true`)
- token rotation のたびに admin SDK 経由で claim 更新が必要。
- 現状コードベースに Custom Claims を能動的に設定する admin 系コードは未整備（`firestoreIsPremiumProvider` で読み取りはしているが、`grantPromotionalPremium` が RevenueCat 経由で `isPremium` を設定するパスのみ）。
- claim 反映には ID token 再発行が必要で、即時切替えが効かない。

### C. `process.env.FUNCTIONS_EMULATOR === "true"` のみでガード
- emulator 検証はカバーできるが、開発者の実機検証（本番 Firebase に対して dev only Functions を叩く）はできない。
- `grantPromotionalPremium` は本番 RevenueCat に対して Promotional Entitlement を付与する都合上、emulator のみでは検証完結しない（ADR 0008 参照）。

## Related
- ADR 0008: RC Promotions API経由でのプレミアム付与（テスト用）
- Issue #239: Promotional Entitlement 移行
- Issue #241 Task 3: dev/prod 環境分離（元の動機）
- Issue #242: dev project 分離計画 → 本 ADR で方針変更（Close 済み）
- Issue #244: 本 ADR の実装
