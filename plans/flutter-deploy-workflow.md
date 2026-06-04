# flutter-deploy 配布ワークフロー導入プラン

Riamo の `flutter-deploy.yml` を参考に、shoppinglist に手動起動の配布ワークフローを新規作成する。

- iOS: 手動署名で IPA をビルド → **TestFlight (App Store Connect)** へアップロード
- Android: リリース署名で AAB をビルド → **Google Play internal トラック**へアップロード
- 単一環境（dev/prod flavor 無し）・FVM 無し・Flutter 3.41.9 stable（flutter-ci.yml と同一）
- 手動起動 `workflow_dispatch`（`platform` で ios / android / both を選択）

## 設計上の判断（shoppinglist と Riamo の差分）

| 観点 | Riamo | shoppinglist | 本プランの対応 |
| --- | --- | --- | --- |
| 環境 | dev/prod 2 環境 | 単一環境 | environment 入力を廃止、ExportOptions/packageName を単一化 |
| iOS 署名 | Manual（commit 済み + awk で specifier 注入） | Automatic（Widget 拡張あり） | CI 専用 Ruby スクリプトで Release のみ Manual 化（ローカルは Automatic 据え置き） |
| iOS profile | Runner のみ | Runner + Widget の 2 つ | profile を 2 つインストール、ExportOptions に両 bundle id を記載 |
| Android 署名 | release 署名済み | `signingConfigs.debug` のまま | `build.gradle` に release 署名 config を追加（key.properties 無ければ debug にフォールバック） |
| シークレット | flutterfire 等 | `make secret`（Firebase/xcconfig/AdMob/RevenueCat） | 両 job に `make secret` 用 env を付与 |

## 作成・変更ファイル

### 1. `.github/workflows/flutter-deploy.yml`（新規）
本体。`prepare-version` / `build-ios` / `build-android` / `notify` の 4 job。
ビルド番号 = `github.run_number + BUILD_NUMBER_OFFSET`（初期値 0）。
profile 名は workflow の `env` に定義し ExportOptions と Ruby スクリプトの両方が参照（SSOT）:

```yaml
env:
  BUILD_NUMBER_OFFSET: 0
  IOS_DEVELOPMENT_TEAM: TQPN82UBBY
  IOS_RUNNER_PROFILE_NAME: 'Shoppinglist AppStore'
  IOS_WIDGET_PROFILE_NAME: 'Shoppinglist Widget AppStore'
```

### 2. `ios/scripts/configure_signing_for_ci.rb`（新規）
CI のチェックアウトコピーに対してのみ、Release 構成（Runner / Widget の 2 bundle id）を手動署名に切替。
`xcodeproj` gem を使用（macOS runner では CocoaPods 経由で利用可能）。bundle id でターゲットを判定するため RunnerTests 等は対象外。

```ruby
config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Distribution'
config.build_settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = 'Apple Distribution'
config.build_settings['DEVELOPMENT_TEAM'] = team_id
config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = profile
```

### 3. `android/app/build.gradle`（変更）
release 署名 config を追加。`key.properties` が無いローカルでは debug にフォールバックして `flutter run --release` を維持（冪等）。

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
// ...
    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties['keyAlias']
                keyPassword = keystoreProperties['keyPassword']
                storeFile = keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
                storePassword = keystoreProperties['storePassword']
            }
        }
    }
    buildTypes {
        release {
            signingConfig = keystorePropertiesFile.exists() ? signingConfigs.release : signingConfigs.debug
        }
    }
```

> `.gitignore` は `key.properties` / `**/*.jks` / `google-services.json` を既に無視済みのため変更不要。

---

## workflow 定義後に準備するもの

### A. Apple（iOS / TestFlight）

1. **Apple Developer Program**（Team `TQPN82UBBY`）が有効であること。
2. **App ID 登録**（Certificates, Identifiers & Profiles > Identifiers）。entitlements に合わせ Capability を有効化:
   - `com.bannzai.shoppinglist`: Push Notifications / Sign in with Apple / App Groups
   - `com.bannzai.shoppinglist.ShoppingListWidget`: App Groups
3. **App Group** `group.com.bannzai.shoppinglist` を作成し、上記 2 つの App ID に割り当て。
4. **配布証明書**（Apple Distribution）を作成し **`.p12` で書き出し**（パスワード付き）。
5. **Provisioning Profile（App Store）を 2 つ**作成。profile 名は workflow の env と一致させる:
   - `Shoppinglist AppStore` → `com.bannzai.shoppinglist`
   - `Shoppinglist Widget AppStore` → `com.bannzai.shoppinglist.ShoppingListWidget`
   - （別名にしたい場合は `.github/workflows/flutter-deploy.yml` の `IOS_RUNNER_PROFILE_NAME` / `IOS_WIDGET_PROFILE_NAME` を変更）
6. **App Store Connect でアプリレコードを作成**（bundle id `com.bannzai.shoppinglist`）。TestFlight アップロードの前提。※今回「両方未登録」のため最初に必要。
7. **App Store Connect API Key** を発行（Users and Access > Integrations）。`Key ID` / `Issuer ID` / `AuthKey_xxx.p8` を取得（App Manager 権限）。
8. ⚠️ `ios/Runner/Runner.entitlements` の `aps-environment` が `development`。TestFlight / 本番で Push 通知を使う場合は `production` が必要。本ワークフローはそのままビルドするので、Push 検証時に留意（必要なら別途修正）。

### B. Google（Android / Play internal）

1. **Google Play Console** 開発者アカウント。
2. **アプリを作成**（applicationId `com.bannzai.shoppinglist`）。
3. **Play App Signing** を有効化し、**アップロード鍵（keystore）** を作成（例: `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`）。
4. ⚠️ **新規アプリの初回 AAB は Play Console から手動アップロードが必要**（API 経由の初回アップロードは不可）。一度 internal トラックへ手動アップロードして以降、CI からの API アップロードが可能になる。※今回「両方未登録」のため初回は手動。
5. **サービスアカウント**を Google Cloud で作成し JSON キーを発行 → Play Console > Users and permissions で招待し、リリース権限（Release manager 等）を付与。

### C. GitHub Secrets（Settings > Secrets and variables > Actions）

base64 化は macOS なら `base64 -i <file> | pbcopy`。

**iOS:**
| Secret | 内容 |
| --- | --- |
| `IOS_P12_CERTIFICATE_BASE64` | 配布証明書 `.p12` の base64 |
| `IOS_P12_PASSWORD` | `.p12` のパスワード |
| `IOS_PROVISIONING_PROFILE_BASE64` | Runner 用 `.mobileprovision` の base64 |
| `IOS_WIDGET_PROVISIONING_PROFILE_BASE64` | Widget 用 `.mobileprovision` の base64 |
| `IOS_APPSTORE_CONNECT_KEY_ID` | ASC API Key ID |
| `IOS_APPSTORE_CONNECT_ISSUER_ID` | ASC API Issuer ID |
| `IOS_APPSTORE_CONNECT_API_KEY_P8_BASE64` | `AuthKey_xxx.p8` の base64 |

**Android:**
| Secret | 内容 |
| --- | --- |
| `ANDROID_KEY_PROPERTIES_BASE64` | `key.properties` の base64（下記内容） |
| `ANDROID_RELEASE_JKS_BASE64` | `upload-keystore.jks` の base64 |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64` | サービスアカウント JSON の base64 |

`key.properties` の中身（CI で `android/key.properties` に復元され、keystore は `android/app/upload-keystore.jks` に復元される）:
```
storePassword=<keystoreのパスワード>
keyPassword=<keyのパスワード>
keyAlias=upload
storeFile=upload-keystore.jks
```

**アプリ内シークレット（`make secret` 用 / flutter-ci.yml と共通）:**
`FIREBASE_BASE64_IOS` / `FIREBASE_BASE64_ANDROID` / `XCCONFIG_SECRET` / `REVENUE_CAT_PUBLIC_API_KEY` / `IOS_ADMOB_NATIVE_ADVANCE_IDENTIFIER` / `ANDROID_ADMOB_NATIVE_ADVANCE_IDENTIFIER` / `IOS_ADMOB_BANNER_IDENTIFIER` / `ANDROID_ADMOB_BANNER_IDENTIFIER`

**任意:**
`SLACK_WEBHOOK_URL_DEPLOY`（未設定なら通知はスキップされる）

---

## チェックリスト

### 実装内容
- [x] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [x] 既存コードのパターン・構成を確認し、同じパターンで実装している（Riamo flutter-deploy.yml / make secret / flutter-ci.yml の Flutter version）

### Flutter（lib/ に変更がある場合）
- [x] lib/ への変更なし（Dart コード生成・analyze・test は対象外。N/A）
- [ ] Android ビルド: `flutter build appbundle --release`（Secrets 復元が必要なため CI 実行で検証）
- [ ] iOS ビルド: `flutter build ipa`（証明書・profile が必要なため CI 実行で検証）

### Firebase（firebase/ に変更がある場合）
- [x] firebase/ への変更なし（N/A）

### 共通
- [x] エラーメッセージはそのまま表示（加工なし。altool / gradle の出力をそのまま使用）
- [x] `build.gradle` は configuration phase 評価成功（`./android/gradlew -p android :app:help` exit 0）
- [x] workflow YAML 構文検証 OK（psych でパース成功）
- [x] `configure_signing_for_ci.rb` 構文検証 OK（`ruby -c`）
- [ ] 実際の配布（TestFlight / Play）は A〜C の準備完了後に `workflow_dispatch` で検証
