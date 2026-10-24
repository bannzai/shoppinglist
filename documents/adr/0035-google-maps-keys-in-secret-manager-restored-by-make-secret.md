# 0035. Google Maps クライアントキーを GCP Secret Manager に置き、CI は Workload Identity Federation、ローカルは SecChain から `make secret` で復元する

## Status
Accepted (partially supersedes [[0030-separate-dev-prod-firebase-projects]] の決定 6)

## Context
[[0030-separate-dev-prod-firebase-projects]] の決定 6 は、Google Maps のクライアントキーを「アプリ制限 + API 制限をかけて埋め込む公開情報」として `Debug.xcconfig` / `Release.xcconfig` / `build.gradle` に直接コミットしていた。public 化の検討 (Issue #701) で次が分かった。

- prod 向けに直書きされていた 2 本は Maps 専用のキーではなく Firebase が自動生成した iOS / Android キーで (API 制限は Firebase 系 API のみ、Maps SDK を含まない)、prod プロジェクトには Maps 系 API が有効化されていなかった。コードに値を置くだけでは「制限が掛かった正しいキーか」が検証されず、ずれに気付けない
- リポジトリにコミットした `AIza` 形式の値は、制限の有無によらず secret scanning (GitHub・pre-publish-leak-check の git hook) が止める。ADR 0030 の「公開情報だから直書き」という扱いは、castle の `~/.claude/rules/no-personal-info-in-repositories.md` (Google API キーは誤検知として通さない) と両立しない
- secret の保管先は「誰が読むか」で決める方針 (castle の `~/.claude/documents/rules/secret-storage-by-reader.md`) が定まり、CI が読む値は GCP Secret Manager、Mac 上のプロセスが読む値は SecChain に置き、CI の GCP 認証は Workload Identity Federation (WIF) で行うことになった

Maps SDK for iOS / Android のキーは native SDK が Info.plist (`GMSApiKey`) / AndroidManifest (`geo.API_KEY`) から起動時に読むため、dart-define では注入できず、build config の変数で注入する必要がある (ADR 0030 の制約はそのまま)。

## Decision

### 1. 値の正は GCP Secret Manager、1 プロパティ 1 secret
- dev (`shoppinglist-dev-b2787`) と prod (`shoppinglist-prod-857bb`) の各プロジェクトに、同じ名前で `google-maps-sdk-ios-apikey` / `google-maps-sdk-android-apikey` を置く (命名は castle の env-secret-registry skill `references/naming-conventions.md`「GCP Secret Manager の secret 名」。環境は名前に含めずプロジェクトで分ける)
- ファイル (xcconfig / properties) を丸ごと secret にせず、プロパティ単位で置く。ローテーションと監査が値ごとにできるため
- prod のキーは Maps SDK for iOS / Android 専用に新規作成し、アプリ制限 (iOS = bundleId `com.bannzai.shoppinglist`、Android = package + Firebase に登録済みの SHA-1) と API 制限 (`maps-ios-backend` / `mapsios`、`maps-android-backend` / `mapsandroid`) を掛ける。prod で Maps SDK for iOS / Android の API を有効化する (ネイティブ SDK の地図表示は Maps SDK SKU として無料。出典: https://developers.google.com/maps/billing-and-pricing/faq )

### 2. リポジトリには値を置かず、`make secret` がローカルファイルへ書き出す
- `scripts/google-maps-secret.sh` が環境変数 `GOOGLE_MAPS_API_KEY_IOS_DEV` / `_IOS_PROD` / `_ANDROID_DEV` / `_ANDROID_PROD` から、gitignore 済みの `ios/Flutter/GoogleMaps.xcconfig` と `android/google-maps.properties` を書き出す。未設定は空で書き、ビルドは通る (地図は描画されない)
- `Debug.xcconfig` / `Release.xcconfig` は `#include? "GoogleMaps.xcconfig"` の上で `GOOGLE_MAPS_API_KEY = $(GOOGLE_MAPS_API_KEY_IOS_DEV|PROD)` を定義し、`build.gradle` は `google-maps.properties` を `getProperty(名前, "")` で読む。Debug = dev / Release (+Profile) = prod の切替は ADR 0030 のまま

### 3. CI は WIF で Secret Manager から取り出す
- `flutter-deploy.yml` の build job は `environment: prod` と `permissions: id-token: write` を持ち、`google-github-actions/auth` で Pool `github` / Provider `shoppinglist` (attribute 条件 `environment == 'prod'`) を通して `github-firebase-deployer@shoppinglist-prod-857bb` を impersonate し、`google-github-actions/get-secretmanager-secrets` (`export_to_environment: true`) で上の環境変数に取り出してから `make secret` を実行する。deployer SA には対象 secret ごとに `roles/secretmanager.secretAccessor` を付ける
- GitHub Actions secret には Maps キーを置かない。Pool / Provider / binding の作成は castle の firebase-functions-deploy-iam-setup skill の `setup-workload-identity.sh` (Issue #694 の `firebase-deploy.yml` と同じ構成を共有する)
- PR の lint / test (`flutter-ci.yml`) は認証せず `make secret` を空の環境変数で実行する。fork からの PR でも secret に触れない

### 4. ローカルは SecChain から渡す
- 開発者は `secchain run -- make secret` で復元する。SecChain の名前は上の環境変数名と同じで、`.secchain` に定義する。Secret Manager の値を SecChain へ写す操作 (`gcloud secrets versions access ... | secchain set <NAME>`) はユーザーが行う (agent は Secret Manager の値を読まない)
- `.envrc` に Maps キーを書かない

## Consequences
- リポジトリと履歴 (今回以降) に Maps キーが入らず、public 化と secret scanning の障害にならない。過去のコミットに残る旧キーは、アプリ制限付き (dev) または Firebase の自動生成キー (prod) で、公開しても使い道が無い
- 値のローテーションは Secret Manager の version 追加と CI の再実行で済み、コード変更を伴わない。誰がいつ読んだかは Secret Manager の Data Access 監査ログ (`DATA_READ`、両プロジェクトで有効) に残る
- `make secret` を通さないビルドでは地図が描画されない。ローカルの初回セットアップに `secchain run -- make secret` が増える
- `flutter-deploy.yml` が GitHub Environment `prod` に紐づく。Environment の保護ルールは無いため挙動は変わらないが、feature ブランチの改変した workflow から prod の SA を借りられる経路は Issue #694 と同じく残る (Environment のデプロイブランチ制限は別途)
- 同じ仕組みに `FIREBASE_BASE64_*` / `REVENUE_CAT_PUBLIC_API_KEY` 等の他のアプリ内 secret を載せ替えられるが、本 ADR の範囲は Maps キーだけ
