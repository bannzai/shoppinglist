# Issue #242: Firebase dev/prod 環境分離（Pilll パターン準拠）

## Context

現状、`shoppinglist` の Firebase プロジェクトは prod の 1 個 (`shopping-list-prod-a615c`) のみ。検証時に `firebase/functions/.env.shopping-list-prod-a615c` の `APP_ENV` を手動書き換えて deploy する運用が必要で、本番環境に `APP_ENV=dev` が残るリスクがある（実際、現時点で `APP_ENV=dev` のままコミットされている）。

dev/prod を完全分離し、`npm run deploy:dev` / `npm run deploy:prod` のワンコマンドでミスなく切替できる仕組みを構築する。
Flutter / iOS / Android 側も同時に dev/prod アプリを別アプリとして同時インストール可能にする。

参考実装は **Pilll プロジェクト** (`/Users/bannzai/ghq/github.com/bannzai/pilll` + `/Users/bannzai/ghq/github.com/bannzai/PilllBackend`)。Pilll は標準 Flutter `--flavor` を使わず、`--dart-define-from-file=environment/{flavor}.json` + エントリポイント分離 (`main.dev.dart` / `main.prod.dart`) + iOS xcconfig 変数 + Android Gradle タスクで `google-services.json` を切替えるハイブリッド方式を採用している。本プランはこの方式を準拠する。

ただし Functions 側は Pilll の旧 API (`firebase-functions v4` + `functions.config()`) ではなく、`shoppinglist` の現状 (`firebase-functions v7` + `defineString("APP_ENV")` + `.env.<projectId>`) を継続する（こちらの方がモダンで Firebase 公式の推奨パス）。

## 採用方針サマリ

| 項目 | 方針 | 採用元 |
|---|---|---|
| Firebase project alias | `.firebaserc` に `dev` / `prod` 定義 | Pilll |
| Functions env 値 | `.env.<projectId>` ファイル + `defineString("APP_ENV")` | shoppinglist 現状 |
| Functions 個別 deploy | `firebase deploy --only functions:<name> --project <alias>` | Pilll |
| デプロイスクリプト | `firebase/functions/scripts/deploy.sh dev\|prod` 新設 | Issue 記載 |
| Flutter エントリポイント | `lib/main.dev.dart` / `lib/main.prod.dart` + 共通 `lib/entrypoint.dart` | Pilll |
| Flutter env 注入 | `--dart-define-from-file=environment/{dev,prod}.json` | Pilll |
| iOS Bundle ID | dev: `com.bannzai.shoppinglist.dev` / prod: 既存 | 確定済 |
| iOS 切替メカニズム | `ios/Flutter/Secret.xcconfig` で `IOS_PRODUCT_BUNDLE_IDENTIFIER` 等を変数化、Info.plist は `$(変数)` 参照 | Pilll |
| iOS GoogleService-Info.plist | `ios/Firebase/{dev,prod}/GoogleService-Info.plist` 配置 + Build Phase で Configuration ごとにコピー | Pilll 改良版 |
| Android applicationId | dev: `com.bannzai.shoppinglist.dev` / prod: 既存 | iOS と統一 |
| Android 切替メカニズム | `android/app/build.gradle` で `dart-defines` を読み `applicationId` を動的化 + `selectGoogleServicesJson` タスクで `app/src/{flavor}/google-services.json` を `app/` にコピー | Pilll |
| 秘密情報・配置ファイル管理 | gitignore + `Makefile` の `make secret` ターゲットで base64 環境変数から復元 | Pilll |
| 復元対象ファイル | `Secret-{dev,prod}.xcconfig` / `ios/Firebase/{dev,prod}/GoogleService-Info.plist` / `android/app/src/{dev,prod}/google-services.json` / `environment/{dev,prod}.json` / `firebase/functions/.env.<projectId>` | Pilll |

## 実装範囲と PR 分割

各 Phase は独立 PR で進行可能。Phase A から順に着手。

- **Phase A**: Firebase Functions 側のみ（`.firebaserc` / `.env` / `deploy.sh` / `package.json` / Functions コード微修正 / README）
- **Phase B**: iOS ネイティブ flavor 対応（xcconfig / Build Configuration / Build Phase / GoogleService-Info.plist 切替 / Sign in with Apple OAuth / App Group / Keychain access group / Widget Extension）
- **Phase C**: Android ネイティブ flavor 対応（build.gradle / src/dev・src/prod・google-services.json 配置）
- **Phase D**: Flutter side エントリポイント分離 + dart-define-from-file + .vscode/launch.json + 開発者オプションガード移行 + maestro flow 起動コマンド更新

---

## Phase A: Firebase Functions 環境分離

### A-1. ⚠️ `.env.shopping-list-prod-a615c` の APP_ENV を緊急修正

**ファイル**: `firebase/functions/.env.shopping-list-prod-a615c`

```diff
 GOOGLE_GENAI_API_KEY=<REDACTED>
-APP_ENV=dev
+APP_ENV=prod
 REVENUECAT_SECRET_API_KEY=<REDACTED>
```

理由: `firebase deploy` 時に `firebase-functions/params` の `defineString("APP_ENV")` がプロジェクト名一致の `.env.<projectId>` を自動読み込みする。現状は prod プロジェクト名のファイルなのに `APP_ENV=dev` のため、prod デプロイ時に `appEnv() === "dev"` ガードが効かなくなり、`grantPromotionalPremium` 等が prod でも動作可能になる。

### A-2. `firebase/.firebaserc` に alias 追加

**ファイル**: `firebase/.firebaserc`

```json
{
  "projects": {
    "default": "shopping-list-prod-a615c",
    "prod": "shopping-list-prod-a615c",
    "dev": "shoppinglist-dev-2c189"
  }
}
```

`shoppinglist-dev-2c189` はユーザーが Firebase Console から手動作成後に置換。

### A-3. dev 用 .env ファイル新規作成

**ファイル**: `firebase/functions/.env.shoppinglist-dev-2c189`（新規・gitignore・`make secret` で base64 環境変数 `FIREBASE_FUNCTIONS_ENV_DEV` から復元）

```
GOOGLE_GENAI_API_KEY=<dev用キー>
APP_ENV=dev
REVENUECAT_SECRET_API_KEY=<dev用キー or prod共有でOK>
```

`.gitignore` の既存設定 (`.env.*`) で git 管理外。値はユーザーが base64 化して GitHub Secrets / direnv 等で `FIREBASE_FUNCTIONS_ENV_DEV` に保管。同様に prod は `FIREBASE_FUNCTIONS_ENV_PROD` に。

### A-4. デプロイスクリプト新設

**ファイル**: `firebase/functions/scripts/deploy.sh`（新規・実行権限付与 `chmod +x`）

```bash
#!/bin/bash
set -euo pipefail

# Usage:
#   scripts/deploy.sh dev                    # dev プロジェクトに全 functions deploy
#   scripts/deploy.sh prod                   # prod プロジェクトに全 functions deploy
#   scripts/deploy.sh dev grantPromotionalPremium  # 個別 function のみ deploy

ENV="${1:?Usage: deploy.sh <dev|prod> [function-name]}"
FUNCTION_NAME="${2:-}"

if [[ "$ENV" != "dev" && "$ENV" != "prod" ]]; then
  echo "Error: ENV must be 'dev' or 'prod', got: $ENV" >&2
  exit 1
fi

# scripts/ から見た親 (functions/) で実行
cd "$(dirname "$0")/.."

npm run lint
npm run build

if [[ -n "$FUNCTION_NAME" ]]; then
  firebase deploy --only "functions:${FUNCTION_NAME}" --project "$ENV"
else
  firebase deploy --only functions --project "$ENV"
fi
```

冪等: 同じ引数で何度叩いても同じ結果（lint/build/deploy はそれぞれ冪等）。

### A-5. package.json scripts 追加

**ファイル**: `firebase/functions/package.json` の `scripts` セクション差分

```diff
   "scripts": {
     "lint": "eslint --ext .js,.ts .",
     "lint:fix": "eslint --ext .js,.ts . --fix",
     "build": "tsc",
     "build:watch": "tsc --watch",
     "serve": "npm run build && firebase emulators:start --only functions",
     "shell": "npm run build && firebase functions:shell",
     "start": "npm run shell",
     "deploy": "firebase deploy --only functions",
+    "deploy:dev": "scripts/deploy.sh dev",
+    "deploy:prod": "scripts/deploy.sh prod",
     "logs": "firebase functions:log",
     "genkit:start": "GENKIT_ENV=dev genkit start -- tsx --watch src/index.ts",
     "test": "jest"
   },
```

既存 `deploy` script は後方互換のため残す。

### A-6. `index.ts` の storageBucket ハードコード見直し

**ファイル**: `firebase/functions/src/index.ts`

現状は `storageBucket: 'gs://shopping-list-prod-a615c.firebasestorage.app'` がベタ書き。dev でデプロイすると prod のバケットを参照してしまう。`process.env.GCLOUD_PROJECT` から動的化する。

```diff
- storageBucket:
-   process.env.ENV === "local"
-     ? "gs://shopping-list-prod-a615c.firebasestorage.app"
-     : "gs://shopping-list-prod-a615c.firebasestorage.app",
+ // GCLOUD_PROJECT は Firebase Functions ランタイムで自動設定される (dev / prod のプロジェクト ID)
+ // emulator 実行時は process.env.GCLOUD_PROJECT が無いので prod fallback
+ storageBucket: `gs://${process.env.GCLOUD_PROJECT ?? "shopping-list-prod-a615c"}.firebasestorage.app`,
```

### A-7. README / ドキュメント整備

**ファイル**: `firebase/functions/README.md`（新規）

```markdown
# Firebase Functions

## dev / prod 切替

`.firebaserc` に `dev` / `prod` の alias を定義済み。Functions の `APP_ENV` は `.env.<projectId>` で `firebase-functions/params` 経由で注入される。

### Deploy

\`\`\`bash
# dev プロジェクトに全 functions deploy
npm run deploy:dev

# prod プロジェクトに全 functions deploy
npm run deploy:prod

# 個別 function のみ deploy（例: grantPromotionalPremium）
scripts/deploy.sh dev grantPromotionalPremium
scripts/deploy.sh prod grantPromotionalPremium
\`\`\`

### Emulator

\`\`\`bash
npm run serve   # build + emulator 起動
npm run genkit:start  # GenKit Dev Server 起動
\`\`\`

emulator は `default` プロジェクトを使う。`firebase use dev` で alias を切替えれば emulator も dev プロジェクトを参照する。

### env ファイル一覧

| ファイル | 用途 |
|---|---|
| `.env` | 共通（GENKIT_ENV のみ） |
| `.env.local` | emulator 起動時 |
| `.env.shopping-list-prod-a615c` | prod デプロイ時自動読込 (`APP_ENV=prod`) |
| `.env.shoppinglist-dev-2c189` | dev デプロイ時自動読込 (`APP_ENV=dev`) |

### appEnv() のガード

`grantPromotionalPremium`, `revokePromotionalPremium`, `setupTestCategoryLocationOrder` は `appEnv() !== "dev"` で 403 を返す。dev プロジェクトでのみ動作する。
```

**ファイル**: `documents/firebase-environments.md`（新規）

```markdown
# Firebase Environments

shoppinglist は dev / prod の 2 つの Firebase プロジェクトを持つ。

## プロジェクト一覧

| 環境 | Project ID | iOS Bundle ID | Android applicationId |
|---|---|---|---|
| dev | `shoppinglist-dev-2c189` | `com.bannzai.shoppinglist.dev` | `com.bannzai.shoppinglist.dev` |
| prod | `shopping-list-prod-a615c` | `com.bannzai.shoppinglist` | `com.bannzai.shoppinglist` |

## 切替メカニズム

### Functions 側

- `firebase/.firebaserc` の alias で project 切替
- `firebase deploy --project <alias>` 時に `.env.<projectId>` を Firebase が自動読込
- `defineString("APP_ENV")` で `appEnv()` 関数経由で参照

### Flutter 側

- `lib/main.dev.dart` / `lib/main.prod.dart` の 2 エントリポイント
- `--dart-define-from-file=environment/{dev,prod}.json` で値を注入
- iOS は `ios/Flutter/Secret.xcconfig` で xcconfig 変数化、Info.plist の各キーが `$(変数)` 参照
- Android は `app/build.gradle` で `dart-defines` を読み `applicationId` を動的化、`selectGoogleServicesJson` Gradle タスクで `app/src/{flavor}/google-services.json` を `app/` にコピー

## dev only 機能

`grantPromotionalPremium` / `revokePromotionalPremium` / `setupTestCategoryLocationOrder` は dev project でのみ動作。Flutter 側の開発者オプション画面は `Environment.isDevelopment` でガード（Release ビルドの dev flavor でも動作可能）。
```

### A-8. Makefile 新設（base64 環境変数から設定ファイル復元）

**ファイル**: リポジトリルート `Makefile`（新規）

Pilll 流儀。CI / ローカルで `make secret` 一発で gitignore 対象の設定ファイルを base64 環境変数から復元する。

```makefile
.PHONY: secret secret-functions secret-ios secret-android secret-flutter

# 全設定ファイルを base64 環境変数から復元
# 必要な環境変数は documents/firebase-environments.md 参照
secret: secret-functions secret-ios secret-android secret-flutter

secret-functions:
	@echo "$$FIREBASE_FUNCTIONS_ENV_DEV" | base64 -d > firebase/functions/.env.shoppinglist-dev-2c189
	@echo "$$FIREBASE_FUNCTIONS_ENV_PROD" | base64 -d > firebase/functions/.env.shopping-list-prod-a615c
	@echo "$$SERVICE_ACCOUNT_JSON" | base64 -d > firebase/functions/service-account-key.json

secret-ios:
	@mkdir -p ios/Firebase/dev ios/Firebase/prod
	@echo "$$FILE_FIREBASE_IOS_DEV" | base64 -d > ios/Firebase/dev/GoogleService-Info.plist
	@echo "$$FILE_FIREBASE_IOS_PROD" | base64 -d > ios/Firebase/prod/GoogleService-Info.plist
	@echo "$$XCCONFIG_SECRET_DEV" | base64 -d > ios/Flutter/Secret-dev.xcconfig
	@echo "$$XCCONFIG_SECRET_PROD" | base64 -d > ios/Flutter/Secret-prod.xcconfig

secret-android:
	@mkdir -p android/app/src/dev android/app/src/prod
	@echo "$$FILE_FIREBASE_ANDROID_DEV" | base64 -d > android/app/src/dev/google-services.json
	@echo "$$FILE_FIREBASE_ANDROID_PROD" | base64 -d > android/app/src/prod/google-services.json

secret-flutter:
	@mkdir -p environment
	@echo "$$DART_DEFINE_FROM_FILE_DEV" | base64 -d > environment/dev.json
	@echo "$$DART_DEFINE_FROM_FILE_PROD" | base64 -d > environment/prod.json
```

冪等: 同じ環境変数で何度実行しても同じ結果。

### A-9. .gitignore 更新

**ファイル**: ルート `.gitignore`（追記）

```
# dev/prod 環境設定ファイル（make secret で復元）
ios/Firebase/dev/GoogleService-Info.plist
ios/Firebase/prod/GoogleService-Info.plist
ios/Flutter/Secret-dev.xcconfig
ios/Flutter/Secret-prod.xcconfig
android/app/src/dev/google-services.json
android/app/src/prod/google-services.json
android/app/google-services.json
environment/dev.json
environment/prod.json
```

`firebase/functions/.env.*` は既存 `.gitignore` で除外済み。

### A-10. 必要な環境変数一覧

| 環境変数名 | 復元先 | 内容 |
|---|---|---|
| `FIREBASE_FUNCTIONS_ENV_DEV` | `firebase/functions/.env.shoppinglist-dev-2c189` | dev Functions の `.env`（`APP_ENV=dev` / `GOOGLE_GENAI_API_KEY` / `REVENUECAT_SECRET_API_KEY`） |
| `FIREBASE_FUNCTIONS_ENV_PROD` | `firebase/functions/.env.shopping-list-prod-a615c` | prod Functions の `.env`（`APP_ENV=prod` / 既存値） |
| `SERVICE_ACCOUNT_JSON` | `firebase/functions/service-account-key.json` | Functions 用 service account（既存・dev/prod 共通か個別かは TBD） |
| `FILE_FIREBASE_IOS_DEV` | `ios/Firebase/dev/GoogleService-Info.plist` | dev project の iOS App `GoogleService-Info.plist`（Firebase Console から取得） |
| `FILE_FIREBASE_IOS_PROD` | `ios/Firebase/prod/GoogleService-Info.plist` | 既存 prod の plist（移動元 `ios/Firebase/GoogleService-Info.plist`） |
| `FILE_FIREBASE_ANDROID_DEV` | `android/app/src/dev/google-services.json` | dev project の Android App `google-services.json` |
| `FILE_FIREBASE_ANDROID_PROD` | `android/app/src/prod/google-services.json` | 既存 prod の json |
| `XCCONFIG_SECRET_DEV` | `ios/Flutter/Secret-dev.xcconfig` | dev iOS 用 xcconfig（`IOS_PRODUCT_BUNDLE_IDENTIFIER=com.bannzai.shoppinglist.dev` 等） |
| `XCCONFIG_SECRET_PROD` | `ios/Flutter/Secret-prod.xcconfig` | prod iOS 用 xcconfig |
| `DART_DEFINE_FROM_FILE_DEV` | `environment/dev.json` | Flutter dev 起動用 JSON |
| `DART_DEFINE_FROM_FILE_PROD` | `environment/prod.json` | Flutter prod 起動用 JSON |

base64 化コマンド例: `base64 -i ios/Firebase/dev/GoogleService-Info.plist | pbcopy`（macOS）

---

## Phase B: iOS ネイティブ flavor 対応

### B-1. `ios/Flutter/Secret.xcconfig` 新設

`Debug.xcconfig` / `Release.xcconfig` から Configuration 別に **`Secret-dev.xcconfig` / `Secret-prod.xcconfig` を `#include` 切替**する。両ファイルとも gitignore + `make secret` で復元。

**ファイル**: `ios/Flutter/Secret-dev.xcconfig`（新規・gitignore・`XCCONFIG_SECRET_DEV` から復元）

```
FLAVOR=dev
APP_NAME=買い物リスト(dev)
IOS_PRODUCT_BUNDLE_IDENTIFIER=com.bannzai.shoppinglist.dev
APP_GROUP_KEY=group.com.bannzai.shoppinglist.dev
KEYCHAIN_ACCESS_GROUP=TQPN82UBBY.com.bannzai.shoppinglist.dev
FIREBASE_GOOGLE_REVERSE_CLIENT_ID=<dev project の REVERSED_CLIENT_ID>
SIWA_SERVICE_IDENTIFIER=com.bannzai.shoppinglist.dev.siwa
```

**ファイル**: `ios/Flutter/Secret-prod.xcconfig`（新規・gitignore・`XCCONFIG_SECRET_PROD` から復元）

```
FLAVOR=prod
APP_NAME=買い物リスト
IOS_PRODUCT_BUNDLE_IDENTIFIER=com.bannzai.shoppinglist
APP_GROUP_KEY=group.com.bannzai.shoppinglist
KEYCHAIN_ACCESS_GROUP=TQPN82UBBY.com.bannzai.shoppinglist
FIREBASE_GOOGLE_REVERSE_CLIENT_ID=<現状 Info.plist にハードコードされている値>
SIWA_SERVICE_IDENTIFIER=<既存値>
```

### B-2. Build Configuration 追加

**ファイル**: `ios/Runner.xcodeproj/project.pbxproj`

`Debug` / `Release` / `Profile` の 3 Configuration に加え、dev 用の `Debug-dev` / `Release-dev` / `Profile-dev` を追加（Pilll は Configuration を増やさず Secret 切替の base64 復元で対応していたが、shoppinglist は Xcode から普通に Configuration 切替で動かしたいので Configuration を分ける）。

新 Configuration の `BASE_CONFIGURATION_REFERENCE` を以下のようにマップ:

| Configuration | xcconfig |
|---|---|
| Debug | `Flutter/Debug.xcconfig` (既存) → 内部で `Secret-prod.xcconfig` を `#include` |
| Debug-dev | `Flutter/Debug-dev.xcconfig` (新規) → 内部で `Secret-dev.xcconfig` を `#include` |
| Release | `Flutter/Release.xcconfig` (既存) → 内部で `Secret-prod.xcconfig` を `#include` |
| Release-dev | `Flutter/Release-dev.xcconfig` (新規) → 内部で `Secret-dev.xcconfig` を `#include` |
| Profile | `Flutter/Release.xcconfig` (既存) → `Secret-prod.xcconfig` |
| Profile-dev | `Flutter/Release-dev.xcconfig` (新規) → `Secret-dev.xcconfig` |

**ファイル**: `ios/Flutter/Debug-dev.xcconfig`（新規）

```
#include "Generated.xcconfig"
#include "Secret-dev.xcconfig"
#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"
```

**ファイル**: `ios/Flutter/Release-dev.xcconfig`（新規）

```
#include "Generated.xcconfig"
#include "Secret-dev.xcconfig"
#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
```

既存の `ios/Flutter/Debug.xcconfig` / `Release.xcconfig` も `#include "Secret-prod.xcconfig"` を追加。

### B-3. PRODUCT_BUNDLE_IDENTIFIER 等を変数化

**ファイル**: `ios/Runner.xcodeproj/project.pbxproj`

全 Configuration の Runner target で:

```diff
- PRODUCT_BUNDLE_IDENTIFIER = com.bannzai.shoppinglist;
+ PRODUCT_BUNDLE_IDENTIFIER = "$(IOS_PRODUCT_BUNDLE_IDENTIFIER)";
```

Widget Extension target:

```diff
- PRODUCT_BUNDLE_IDENTIFIER = com.bannzai.shoppinglist.ShoppingListWidget;
+ PRODUCT_BUNDLE_IDENTIFIER = "$(IOS_PRODUCT_BUNDLE_IDENTIFIER).ShoppingListWidget";
```

### B-4. Info.plist の各キー変数化

**ファイル**: `ios/Runner/Info.plist`

```diff
- <key>CFBundleDisplayName</key>
- <string>Shoppinglist</string>
+ <key>CFBundleDisplayName</key>
+ <string>$(APP_NAME)</string>
```

`REVERSED_CLIENT_ID` (`CFBundleURLSchemes` 内) も `$(FIREBASE_GOOGLE_REVERSE_CLIENT_ID)` に置換。`GIDClientID` も同様。

### B-5. GoogleService-Info.plist の Configuration 別配置

**配置**（両方とも gitignore + `make secret` で base64 環境変数から復元）:
- `ios/Firebase/dev/GoogleService-Info.plist`（`FILE_FIREBASE_IOS_DEV` から復元）
- `ios/Firebase/prod/GoogleService-Info.plist`（`FILE_FIREBASE_IOS_PROD` から復元・既存 `ios/Firebase/GoogleService-Info.plist` を base64 化したもの）

**ファイル**: `ios/Runner.xcodeproj` に Build Phase 追加

Run Script Build Phase（Pre-actions ではなく Build Phases の最初に挿入）:

```bash
# Copy GoogleService-Info.plist for current Configuration
set -e
ENV="prod"
if [[ "$CONFIGURATION" == *"-dev" ]]; then
  ENV="dev"
fi
SRC="${SRCROOT}/Firebase/${ENV}/GoogleService-Info.plist"
DST="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
if [[ ! -f "$SRC" ]]; then
  echo "error: GoogleService-Info.plist not found for env=${ENV} at ${SRC}" >&2
  exit 1
fi
cp -f "$SRC" "$DST"
echo "Copied GoogleService-Info.plist for ${ENV}"
```

旧 `ios/Firebase/GoogleService-Info.plist` の Xcode 参照は削除（Build Phase でコピーするため Xcode に登録不要）。

### B-6. Entitlements の dev/prod App Group 両方列挙

**ファイル**: `ios/Runner/Runner.entitlements`, `ios/WidgetExtension.entitlements`（新設 or 編集）

Pilll 流儀で **dev / prod 両方の App Group を列挙**（プロビジョニングプロファイル側で両方許可しておけば、実行時はビルドした側のみ有効）。

```xml
<key>com.apple.security.application-groups</key>
<array>
  <string>group.com.bannzai.shoppinglist</string>
  <string>group.com.bannzai.shoppinglist.dev</string>
</array>
<key>keychain-access-groups</key>
<array>
  <string>$(AppIdentifierPrefix)com.bannzai.shoppinglist</string>
  <string>$(AppIdentifierPrefix)com.bannzai.shoppinglist.dev</string>
</array>
```

### B-7. main.dart のハードコード除去

**ファイル**: `lib/main.dart` (Phase D で main.dev/prod に分割される直前段階での暫定修正、または D で同時対応)

```diff
- userAccessGroup: 'TQPN82UBBY.com.bannzai.shoppinglist',
+ userAccessGroup: const String.fromEnvironment('KEYCHAIN_ACCESS_GROUP'),
```

App Group も同様に `String.fromEnvironment('APP_GROUP_KEY')` で取得。

### B-8. xcscheme 追加

**ファイル**: `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner-dev.xcscheme`（新規）

既存 `Runner.xcscheme` をコピーし、`buildConfiguration` を `Debug-dev` / `Release-dev` / `Profile-dev` に置換。Xcode で「Runner-dev」を選択すれば dev、「Runner」で prod。

### B-9. Sign in with Apple / OAuth 設定

iOS dev 用 Firebase project で Sign in with Apple を有効化（手動・Firebase Console + Apple Developer）。OAuth Client ID / Service ID は dev 用に新規発行し、`Secret-dev.xcconfig` の `FIREBASE_GOOGLE_REVERSE_CLIENT_ID` / `SIWA_SERVICE_IDENTIFIER` に反映。

---

## Phase C: Android ネイティブ flavor 対応

### C-1. `android/app/build.gradle` 修正

**ファイル**: `android/app/build.gradle`

```groovy
// 上部に追加: dart-defines を読み込む処理（Pilll 流儀）
def dartDefines = [
    FLAVOR: 'prod',
    ANDROID_APPLICATION_ID: 'com.bannzai.shoppinglist',
    APP_NAME: '買い物リスト',
];
if (project.hasProperty('dart-defines')) {
    dartDefines = dartDefines + project.property('dart-defines')
        .split(',')
        .collectEntries { entry ->
            def pair = new String(entry.decodeBase64(), 'UTF-8').split('=', 2)
            [(pair.first()): pair.last()]
        }
}

android {
    namespace 'com.bannzai.shoppinglist'  // 固定（applicationId と分離）
    // ...

    defaultConfig {
        applicationId dartDefines.ANDROID_APPLICATION_ID  // 動的化
        // 既存の minSdkVersion 等はそのまま
        resValue "string", "app_name", dartDefines.APP_NAME
    }
    // ...
}

// flavor ディレクトリ (src/dev/, src/prod/) から google-services.json を選択コピー
task selectGoogleServicesJson(type: Copy) {
    doFirst {
        from "src/${dartDefines.FLAVOR}/google-services.json"
        into './'
    }
}

afterEvaluate {
    tasks.findByName('processDebugGoogleServices')?.dependsOn selectGoogleServicesJson
    tasks.findByName('processReleaseGoogleServices')?.dependsOn selectGoogleServicesJson
    tasks.findByName('processProfileGoogleServices')?.dependsOn selectGoogleServicesJson
}
```

### C-2. google-services.json の配置

**配置**（gitignore + `make secret` で復元）:
- `android/app/src/dev/google-services.json`（`FILE_FIREBASE_ANDROID_DEV` から復元）
- `android/app/src/prod/google-services.json`（`FILE_FIREBASE_ANDROID_PROD` から復元・既存 `android/app/google-services.json` を base64 化したもの）
- `android/app/google-services.json` は `selectGoogleServicesJson` Gradle タスクで自動生成（gitignore）
- `android/app/src/google-services.json`（重複コピー）は削除

`.gitignore`（ルート）の `secret` セクションに以下を追加（A-9 でまとめて記載済み）:

```
android/app/google-services.json
android/app/src/dev/google-services.json
android/app/src/prod/google-services.json
```

`android/app/.gitignore` の独立ファイルは作らない（ルート `.gitignore` で集中管理）。

### C-3. AndroidManifest 共通化チェック

`android/app/src/main/AndroidManifest.xml` の `package` 属性は AGP 8 で `namespace` に統合済みの想定。`applicationId` の動的化により、ランタイムの `BuildConfig.APPLICATION_ID` が dev/prod で切替わる。

---

## Phase D: Flutter Side エントリポイント分離

### D-1. `lib/entrypoint.dart` 新設

**ファイル**: `lib/entrypoint.dart`（新規）

```dart
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
// 既存 main.dart の import を移植

/// dev / prod 共通の起動処理。各 main.{flavor}.dart から呼ぶ。
Future<void> entrypoint() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runZonedGuarded(() async {
    await Firebase.initializeApp();
    // 既存 main.dart の中身（Provider 設定 / runApp 等）をここに移植
    // ...
  }, (error, stack) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
  });
}
```

### D-2. `lib/main.dev.dart` / `lib/main.prod.dart` 新設

**ファイル**: `lib/main.dev.dart`（新規）

```dart
import 'package:shoppinglist/entrypoint.dart';
import 'package:shoppinglist/utils/config/environment.dart';

Future<void> main() async {
  Environment.flavor = Flavor.DEVELOP;
  await entrypoint();
}
```

**ファイル**: `lib/main.prod.dart`（新規）

```dart
import 'package:shoppinglist/entrypoint.dart';
import 'package:shoppinglist/utils/config/environment.dart';

Future<void> main() async {
  Environment.flavor = Flavor.PRODUCTION;
  await entrypoint();
}
```

`Environment.flavor` の代入は `entrypoint()` を呼ぶ前（同期）に行うことが必須。

### D-3. `lib/main.dart` 廃止

既存 `lib/main.dart` は削除。CLAUDE.md / launch.json / iOS pbxproj / Android build.gradle の起動ターゲットを `lib/main.dev.dart` / `lib/main.prod.dart` に切替。

### D-4. `lib/utils/config/environment.dart` 既存活用 + 微修正

**ファイル**: `lib/utils/config/environment.dart`

既存の `Flavor` enum / `Environment` static class を流用。`kDebugMode` ベースの初期化ロジックは `lib/main.dart` に依存していたが、今後は `main.{flavor}.dart` で明示的に代入する形になるので変更不要。

```dart
// 既存ファイル変更なし。Flavor enum と Environment.flavor / isProduction / isDevelopment を活用
```

### D-5. `environment/dev.json` / `environment/prod.json` 新設

**ファイル**: `environment/dev.json`（新規・gitignore・`DART_DEFINE_FROM_FILE_DEV` から復元）

```json
{
  "FLAVOR": "dev",
  "APP_NAME": "買い物リスト(dev)",
  "IOS_PRODUCT_BUNDLE_IDENTIFIER": "com.bannzai.shoppinglist.dev",
  "ANDROID_APPLICATION_ID": "com.bannzai.shoppinglist.dev",
  "APP_GROUP_KEY": "group.com.bannzai.shoppinglist.dev",
  "KEYCHAIN_ACCESS_GROUP": "TQPN82UBBY.com.bannzai.shoppinglist.dev",
  "SIWA_SERVICE_IDENTIFIIER": "com.bannzai.shoppinglist.dev.siwa",
  "ANDROID_SIWA_REDIRECT_URL": "https://us-central1-shoppinglist-dev-2c189.cloudfunctions.net/siwaAndroid",
  "REVENUECAT_TEST_STORE_API_KEY": ""
}
```

**ファイル**: `environment/prod.json`（新規・gitignore・`DART_DEFINE_FROM_FILE_PROD` から復元）

```json
{
  "FLAVOR": "prod",
  "APP_NAME": "買い物リスト",
  "IOS_PRODUCT_BUNDLE_IDENTIFIER": "com.bannzai.shoppinglist",
  "ANDROID_APPLICATION_ID": "com.bannzai.shoppinglist",
  "APP_GROUP_KEY": "group.com.bannzai.shoppinglist",
  "KEYCHAIN_ACCESS_GROUP": "TQPN82UBBY.com.bannzai.shoppinglist",
  "SIWA_SERVICE_IDENTIFIIER": "<既存 prod 値>",
  "ANDROID_SIWA_REDIRECT_URL": "https://us-central1-shopping-list-prod-a615c.cloudfunctions.net/siwaAndroid",
  "REVENUECAT_TEST_STORE_API_KEY": ""
}
```

`REVENUECAT_TEST_STORE_API_KEY` は秘密情報のため **空にして git 管理しない**（既存 launch.json は環境変数 `${env:REVENUECAT_TEST_STORE_API_KEY}` を使用しているので、引き続き launch.json で個別 inject する）。

### D-6. `.vscode/launch.json` 更新

**ファイル**: `.vscode/launch.json`

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "shoppinglist(dev)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dev.dart",
      "args": [
        "--debug",
        "--dart-define-from-file=environment/dev.json",
        "--dart-define=REVENUECAT_TEST_STORE_API_KEY=${env:REVENUECAT_TEST_STORE_API_KEY}"
      ]
    },
    {
      "name": "shoppinglist(prod)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.prod.dart",
      "args": [
        "--debug",
        "--dart-define-from-file=environment/prod.json",
        "--dart-define=REVENUECAT_TEST_STORE_API_KEY=${env:REVENUECAT_TEST_STORE_API_KEY}"
      ]
    },
    {
      "name": "shoppinglist(dev profile)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dev.dart",
      "args": [
        "--profile",
        "--dart-define-from-file=environment/dev.json"
      ]
    },
    {
      "name": "shoppinglist(prod release)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.prod.dart",
      "args": [
        "--release",
        "--dart-define-from-file=environment/prod.json"
      ]
    }
  ]
}
```

CLAUDE.md ルール（実行時引数の `.vscode/launch.json` 同期）に従う。

### D-7. 開発者オプションのガード移行

**ファイル**: `lib/features/developer_options/page.dart` および `lib/utils/shake_detector.dart`, `lib/features/settings/page.dart`

`if (kDebugMode)` ガードを `if (Environment.isDevelopment)` に置換。Release ビルドの dev flavor でも動作可能になる。

```diff
- if (kDebugMode) {
+ if (Environment.isDevelopment) {
    // 開発者オプション表示
  }
```

シェイク検出も同様。

### D-8. maestro flow 起動コマンド更新

**ファイル**: `maestro/README.md`

```diff
- flutter build ios --simulator --debug --dart-define=REVENUECAT_TEST_STORE_API_KEY=...
+ flutter build ios --simulator --debug \
+   --target lib/main.dev.dart \
+   --dart-define-from-file=environment/dev.json \
+   --dart-define=REVENUECAT_TEST_STORE_API_KEY=...
```

`maestro/flows/*.yaml` の `appId:` は `com.bannzai.shoppinglist.dev` に変更（dev でテスト実行する想定）。

### D-9. `lib/main_preview.dart` の調整

`lib/main_preview.dart` も `Environment.flavor = Flavor.DEVELOP;` を冒頭に追加するか、entrypoint と独立した preview 用 main として現状維持。プランでは現状維持で進める（preview はビルド対象外）。

---

## 検証方法

### Phase A 検証

```bash
# Functions のビルド・テスト
cd firebase/functions
npm run lint
npm run build
npm test

# .env の自動読み込みを確認 (dry-run)
firebase deploy --only functions --project dev --dry-run  # APP_ENV=dev が読まれるか
firebase deploy --only functions --project prod --dry-run # APP_ENV=prod が読まれるか

# deploy.sh の冪等性確認
scripts/deploy.sh dev --help  # （実際の deploy はユーザーが実施）

# emulator 起動
npm run serve
```

dev project 作成後、実 deploy:

```bash
npm run deploy:dev   # dev project に deploy
npm run deploy:prod  # prod project に deploy
```

`grantPromotionalPremium` を本番 (prod) で呼ぶと `appEnv() !== "dev"` で 403 が返ることを確認。dev では成功すること。

### Phase B 検証

```bash
# iOS dev ビルド
flutter build ios --simulator --debug \
  --target lib/main.dev.dart \
  --dart-define-from-file=environment/dev.json

# iOS prod ビルド
flutter build ios --simulator --release \
  --target lib/main.prod.dart \
  --dart-define-from-file=environment/prod.json

# Bundle ID 確認
defaults read $(find build/ios/iphonesimulator -name "Info.plist" | head -1) CFBundleIdentifier
# → com.bannzai.shoppinglist.dev / com.bannzai.shoppinglist になっているか
```

Xcode で「Runner-dev」スキームを選択 → Build → Bundle Identifier が `.dev` になっているか確認。同時に Runner（prod）も別アプリとしてシミュレータにインストールできるか確認。

### Phase C 検証

```bash
# Android dev ビルド
flutter build apk --debug \
  --target lib/main.dev.dart \
  --dart-define-from-file=environment/dev.json

# Android prod ビルド
flutter build apk --release \
  --target lib/main.prod.dart \
  --dart-define-from-file=environment/prod.json

# applicationId 確認
aapt dump badging build/app/outputs/flutter-apk/app-debug.apk | grep package
# → com.bannzai.shoppinglist.dev / com.bannzai.shoppinglist
```

Android Studio から dev/prod の APK を同時インストール可能か確認。

### Phase D 検証

```bash
# 静的解析
flutter analyze

# テスト
flutter test

# dev 起動
flutter run --target lib/main.dev.dart --dart-define-from-file=environment/dev.json

# prod 起動（dev project が dev project に書き込みされていないことを確認）
flutter run --target lib/main.prod.dart --dart-define-from-file=environment/prod.json
```

`Environment.isDevelopment` が dev 起動時 true / prod 起動時 false になることを確認。開発者オプション画面が dev のみで表示されることを確認。

### Maestro E2E

```bash
maestro test maestro/flows/login_flow.yaml
```

dev アプリで E2E が通ることを確認。

---

## ファイル一覧（変更・新規）

### Phase A
- 編集: `firebase/.firebaserc`
- 編集: `firebase/functions/.env.shopping-list-prod-a615c`（APP_ENV=prod に修正、`FIREBASE_FUNCTIONS_ENV_PROD` を再生成）
- 新規（gitignore）: `firebase/functions/.env.shoppinglist-dev-2c189`（`make secret` で復元）
- 新規: `firebase/functions/scripts/deploy.sh`
- 編集: `firebase/functions/package.json`
- 編集: `firebase/functions/src/index.ts`（storageBucket 動的化）
- 新規: `firebase/functions/README.md`
- 新規: `documents/firebase-environments.md`
- 新規: `Makefile`（`make secret` で全設定ファイル復元）
- 編集: `.gitignore`（環境ファイル群を除外）

### Phase B
- 新規（gitignore・`make secret` 復元）: `ios/Flutter/Secret-dev.xcconfig`
- 新規（gitignore・`make secret` 復元）: `ios/Flutter/Secret-prod.xcconfig`
- 新規: `ios/Flutter/Debug-dev.xcconfig`
- 新規: `ios/Flutter/Release-dev.xcconfig`
- 編集: `ios/Flutter/Debug.xcconfig`（`#include "Secret-prod.xcconfig"` 追加）
- 編集: `ios/Flutter/Release.xcconfig`（同上）
- 編集: `ios/Runner.xcodeproj/project.pbxproj`（Configuration 追加 / Bundle ID 変数化 / Build Phase 追加）
- 編集: `ios/Runner/Info.plist`（CFBundleDisplayName / REVERSED_CLIENT_ID 変数化）
- 編集: `ios/Runner/Runner.entitlements`（dev/prod App Group / Keychain group 両方列挙）
- 編集: `ios/WidgetExtension.entitlements`（同上）
- 削除: `ios/Firebase/GoogleService-Info.plist`（base64 化して `FILE_FIREBASE_IOS_PROD` に保管後）
- 新規（gitignore・`make secret` 復元）: `ios/Firebase/dev/GoogleService-Info.plist`
- 新規（gitignore・`make secret` 復元）: `ios/Firebase/prod/GoogleService-Info.plist`
- 新規: `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner-dev.xcscheme`

### Phase C
- 編集: `android/app/build.gradle`（dart-defines 読込 / applicationId 動的化 / selectGoogleServicesJson タスク）
- 削除: `android/app/google-services.json`（base64 化して `FILE_FIREBASE_ANDROID_PROD` に保管後、`make secret` で復元）
- 削除: `android/app/src/google-services.json`（重複）
- 新規（gitignore・`make secret` 復元）: `android/app/src/dev/google-services.json`
- 新規（gitignore・`make secret` 復元）: `android/app/src/prod/google-services.json`

### Phase D
- 新規: `lib/entrypoint.dart`
- 新規: `lib/main.dev.dart`
- 新規: `lib/main.prod.dart`
- 削除: `lib/main.dart`
- 編集: `.vscode/launch.json`
- 編集: `lib/features/developer_options/page.dart`（`kDebugMode` → `Environment.isDevelopment`）
- 編集: `lib/utils/shake_detector.dart`（同上）
- 編集: `lib/features/settings/page.dart`（同上）
- 新規（gitignore・`make secret` 復元）: `environment/dev.json`
- 新規（gitignore・`make secret` 復元）: `environment/prod.json`
- 編集: `maestro/README.md`
- 編集: `maestro/flows/*.yaml`（`appId` を dev に変更）

---

## 既知の手動作業（プラン外・ユーザー作業）

### 完了済
- ✅ Firebase Console で `shoppinglist-dev-2c189` プロジェクト作成

### 未完了
1. dev project に iOS App (`com.bannzai.shoppinglist.dev`) / Android App (`com.bannzai.shoppinglist.dev`) 登録 → `GoogleService-Info.plist` / `google-services.json` ダウンロード
2. dev project の Firestore Database 作成（Native mode / `asia-northeast1`）
3. dev project の Storage bucket 作成 / Storage rules deploy
4. dev project の Firestore rules deploy
5. dev project の Authentication で Apple Sign In / Google 有効化、OAuth client 発行
6. APNs 認証キー (Apple Developer) を dev project にアップロード
7. App Store Connect / Play Console での dev アプリ別登録（必要に応じて）
8. **base64 環境変数の準備**（A-10 の表参照）。各設定ファイルを `base64 -i <file> | pbcopy` で base64 化し、direnv `.envrc` または GitHub Secrets に登録
9. ローカルで `make secret` を実行して全設定ファイルが復元されることを確認

---

## チェックリスト

### 実装内容
- [x] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [x] 既存コードのパターン・構成を確認し、同じパターンで実装している（Pilll を参考）

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios --target lib/main.dev.dart --dart-define-from-file=environment/dev.json` 成功
- [ ] iOS ビルド: `flutter build ios --target lib/main.prod.dart --dart-define-from-file=environment/prod.json` 成功
- [ ] Android ビルド: `flutter build apk --target lib/main.dev.dart --dart-define-from-file=environment/dev.json` 成功
- [ ] Android ビルド: `flutter build apk --target lib/main.prod.dart --dart-define-from-file=environment/prod.json` 成功
- [ ] 新規・変更機能に対するテストが存在する（なければ新規作成）
- [ ] Maestro E2E: `maestro test maestro/flows/` 全件パス（dev アプリで実行）
- [ ] Entity命名: フィールド名が省略されていない（該当なし）
- [ ] DB操作: Firestore操作は `call` クラスのProvider経由（該当なし）
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり（該当なし）
- [ ] ref使い分け: build内は `ref.watch`、コールバック・操作は `ref.read`（該当なし）
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（該当なし）

### Firebase（firebase/ に変更がある場合）
- [ ] Lint: `npm run lint` パス（firebase/functions/ で実行）
- [ ] ビルド: `npm run build` 成功
- [ ] テスト: `npm test` 全件パス
- [ ] クライアント呼び出し関数はGenKitで定義（該当なし、既存維持）
- [ ] onDocumentCreated/onDocumentUpdated トリガーを使っていない（該当なし）
- [ ] 新規・変更機能に対するテストが存在する（`storageBucket` 動的化のテスト追加）

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
- [ ] dev/prod 両プロジェクトで `npm run deploy:{dev,prod}` 実行できることをユーザーが確認
- [ ] dev/prod の iOS アプリが同時インストール可能なことをシミュレータで確認
- [ ] dev/prod の Android アプリが同時インストール可能なことをエミュレータで確認
- [ ] `appEnv()` ガード機能 (`grantPromotionalPremium` 等) が prod で 403 を返すことを確認
- [ ] `make secret` が冪等（複数回実行しても同じ結果）
- [ ] `make secret` で全設定ファイルが復元される（`ls` で存在確認）
- [ ] gitignore 対象ファイルが誤って commit されないことを `git status` で確認
