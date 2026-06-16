# 0030. dev/prod を別 Firebase プロジェクトに分離し、識別子を環境ごとに分ける

## Status
Accepted (supersedes [[0028-dev-environment-firestore-named-database]], partially supersedes [[0029-restore-snapshot-uid-remapping]])

## Context
[[0028-dev-environment-firestore-named-database]] では、本番プロジェクト `shopping-list-prod-a615c` 内に Firestore named database `development` を作り、クライアントは dart-define `FIRESTORE_DATABASE_ID` で接続先 DB を切り替える方式(選択肢B)を採った。これは軽量だが、**バックエンド(Cloud Functions)が named DB に未対応**という致命的な不整合を残していた。`admin.firestore()` は常に `(default)`(本番)を見るため、dev クライアントから `submitInquiry` / `createGroup` 等を呼ぶと「Function は本番 `(default)` に書き、クライアントは `development` を読む」という状態になり、dev で挙動を再現できない。

ADR 0028 の選択肢A「別 Firebase プロジェクトで完全分離」へ寄せることで、クライアント・バックエンド・Auth・Firestore・Storage をすべて dev プロジェクト側に揃える。`admin.firestore()` は各 Function のデプロイ先プロジェクトの `(default)` を見るため、コード変更なしで dev/prod が正しく分離される(Issue #410)。

また prod プロジェクトIDの命名ミスを是正するため、`shopping-list-prod-a615c` を新規 `shoppinglist-prod` に作り直す(リリース前でユーザーデータ移行は不要)。dev は `shoppinglist-dev`。

iOS の Keychain access group / App Group は bundleId 由来で、dev/prod で bundleId を共通にすると認証状態が環境を跨いで残り、オンボーディング再現等を阻害する。これを避けるため**アプリ識別子も環境ごとに分離**する。

## Decision

### 1. dev/prod を別 Firebase プロジェクトに分離
- `shoppinglist-dev` / `shoppinglist-prod` の2プロジェクト。`firebase/.firebaserc` に `dev` / `prod` alias を持ち、`default` は誤爆防止のため `dev`。CI/手動 deploy は常に `--project` を明示する。
- `admin.firestore()`(14箇所)は無変更。`index.ts` の `storageBucket` のみハードコードを撤め、ランタイムの `GCLOUD_PROJECT` / `GOOGLE_CLOUD_PROJECT` から導出する。

### 2. 環境切替は build configuration / buildType 駆動(Flutter `--flavor` は不使用)
- 既存の `kDebugMode → Flavor.DEVELOP` と完全に一致させる。**Debug = dev / Release・Profile = prod**。
- iOS: `Debug.xcconfig`(dev) / `Release.xcconfig`(prod) に `APP_BUNDLE_IDENTIFIER` / `APP_GROUP_ID` / `KEYCHAIN_ACCESS_GROUP` を定義。Widget ターゲットはこれらの xcconfig を include しないため、3 つの build config に同変数を直接定義する。Swift 拡張は `#if DEBUG` で dev/prod を分岐。
- Android: `debug` buildType に `applicationIdSuffix = ".dev"`。`google-services.json` は plugin 探索順で `src/debug/`(dev) → module root `app/`(prod フォールバック)。
- Dart: `lib/utils/config/app_identity.dart` に `keychainAccessGroup` / `appGroupId` を集約し、`kDebugMode ? '.dev' : ''` で決定(SSOT)。

### 3. アプリ識別子を環境別に分離
- iOS bundleId / Android applicationId: dev = `com.bannzai.shoppinglist.dev` / prod = `com.bannzai.shoppinglist`。
- これに連動して Widget bundleId・App Group(`group.com.bannzai.shoppinglist[.dev]`)・Keychain access group(`$(AppIdentifierPrefix)com.bannzai.shoppinglist[.dev]`)も環境別になる。本体↔Widget は同一環境内で共有する関係を維持。

### 4. Firebase 設定ファイル / 認証情報は環境変数の「値」で dev/prod を切り替える
- `FIREBASE_BASE64_IOS` / `FIREBASE_BASE64_ANDROID` / `FIREBASE_SERVICE_ACCOUNT_BASE64` / `FILE_GOOGLE_APPLICATION_CREDENTIALS` は単一の名前のまま、実行する環境がその「値」を dev or prod に設定する。`_DEV`/`_PROD` のような名前分けや Makefile の `ENV=` パラメータ、pbxproj のビルドフェーズ追加(検証困難・ブレ込みリスク大)は設けない。
  - local 開発(debug=dev): direnv 等で dev の値を export。`make secret` が埋め込みパス(`ios/Firebase/GoogleService-Info.plist` / `android/app/google-services.json`)へ復元。
  - CI 配布(`flutter-deploy`, release=prod): repo Secrets に prod の値を登録。`make secret`。
  - CI deploy(`firebase-deploy`, dev/prod): GitHub Environments(dev / prod)で同名 Secret `FIREBASE_SERVICE_ACCOUNT_BASE64` を出し分ける。`--project` と `.env.<projectId>` は入力 project から導出。
- bundleId / App Group / Keychain group は build configuration 側(Debug=dev / Release=prod)で分離されるため、通常運用(local=debug=dev / CI release=prod)で識別子と設定ファイルが一致する。
- 既知の制約: local で `flutter build ipa --release`(prod bundleId)を行う場合は環境変数を prod 値にしてから `make secret` する必要がある。

### 5. named database 方式を廃止
- `lib/utils/firestore/firestore.dart` の `FIRESTORE_DATABASE_ID` 切替、`firebase/firebase.json` の `development` DB、`restoreInquirySnapshot.ts` の `getFirestore(..., 'development')` / `--db` / `ALLOW_PROD_RESTORE` を撤去。復元先は接続中プロジェクト(dev の SA 鍵で実行)の `(default)`。

## Consequences
- バックエンド含め dev/prod が完全分離する。`admin.firestore()` は無変更で正しく分離。
- Keychain / App Group が環境別になり、認証状態の混在が解消。dev/prod を同一端末に同時インストールできる。
- 反面、dev 用の Apple App ID / App Group(`group.com.bannzai.shoppinglist.dev`) / Provisioning Profile を Apple Developer Portal に追加する運用コストが増える。
- Functions Secret(`SLACK_BOT_TOKEN` / `SLACK_INQUIRY_CHANNEL_ID` / `REVENUECAT_SECRET_API_KEY` / `SHOPPINGLIST_DEVELOPER_TOKEN` / `GOOGLE_GENAI_API_KEY`)は両プロジェクトに設定が必要。prod の `SHOPPINGLIST_DEVELOPER_TOKEN` を空にすれば dev only 関数を本番で構造的に封じられる([[0011-developer-token-auth-for-dev-only-functions]] の事故防止)。
- GitHub Secret は名前を分けず(`_DEV`/`_PROD` にしない)。firebase-deploy は GitHub Environments(dev/prod)で同名 `FIREBASE_SERVICE_ACCOUNT_BASE64` を出し分け、flutter-deploy(prod のみ)は repo Secret の `FIREBASE_BASE64_*` に prod 値を登録する。Variable `APP_ENV` は廃止し deploy 対象 project から導出。Provisioning / 署名 / ASC / AdMob / RevenueCat / Play SA は prod の識別子不変のため影響なし。
- `restoreInquirySnapshot.ts` の uid 載せ替え([[0029-restore-snapshot-uid-remapping]])は継続利用するが、復元先が named database `development` から dev プロジェクトの `(default)` に変わる。

## 参照
- Issue #410(引き継ぎ指示書), PR #409(お問い合わせフォーム)
- [[0027-inquiry-slack-bot-token-and-db-snapshot-restore]], [[0028-dev-environment-firestore-named-database]], [[0029-restore-snapshot-uid-remapping]], [[0011-developer-token-auth-for-dev-only-functions]]
- 主要ソース: `lib/utils/config/app_identity.dart`, `lib/utils/firestore/firestore.dart`, `ios/Flutter/Debug.xcconfig` / `Release.xcconfig`, `ios/Runner.xcodeproj/project.pbxproj`, `Makefile`, `firebase/.firebaserc`, `.github/workflows/firebase-deploy.yml` / `flutter-deploy.yml`
