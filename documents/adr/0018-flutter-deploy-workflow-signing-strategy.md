# 0018. 配布ワークフローの署名・配布戦略

## Status
Accepted

## Context
shoppinglist には CI（`flutter-ci.yml` で lint / codegen / test）はあるが、ストアへ配布する GitHub Actions が存在しなかった。
同じ Flutter + Firebase 構成の別アプリ Riamo には実運用済みの `flutter-deploy.yml`（iOS→TestFlight、Android→Google Play）があり、これを参考に導入する。

ただし shoppinglist には Riamo と異なる構成差分があり、そのまま流用できない:

- **iOS 署名が Automatic**（`CODE_SIGN_STYLE = Automatic`）。Riamo は手動署名前提で committed 済み。
- **iOS に Widget 拡張**（`com.bannzai.shoppinglist.ShoppingListWidget`）があり、配布には Runner と Widget の 2 つの provisioning profile が必要。
- **Android の release 署名が `signingConfigs.debug` のまま**。Google Play は debug 署名 AAB を受け付けない。
- **秘匿情報は `make secret`**（Firebase 設定 / `Secret.xcconfig` / AdMob / RevenueCat）で復元する独自方式。
- **dev/prod flavor が無い単一環境**。

これらを踏まえ、ローカル開発（特に日常の `flutter run`）への影響を抑えつつ、CI からストア配布できる方式を決める必要がある。

## Decision

### 1. iOS は project.pbxproj に手動署名(Manual)をコミットする
Runner / Widget の Release 構成を Xcode で Manual 署名に設定し、配布 provisioning profile（Runner = `ShoppingList.Prod.AppStore` 等）を `PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]` に指定して `project.pbxproj` に commit する。
これにより CI は追加の署名書き換え無しで `flutter build ipa` できる。CI は P12 証明書と配布 profile をインストールし、ExportOptions.plist（profile 名は workflow の `env`: `IOS_RUNNER_PROFILE_NAME` / `IOS_WIDGET_PROFILE_NAME` を参照）で export する。

当初は「ローカルの Automatic を壊さないよう CI 実行時のみ Ruby スクリプトで `project.pbxproj` を書き換える」案を採用したが、(1) CI 時に project を書き換える暗黙処理が分かりにくい、(2) `project.pbxproj` = CI の挙動を一致させたい、という理由で Manual をコミットする方式へ変更した。トレードオフとしてローカルの release / archive ビルドには配布 profile + 証明書が必要になる（Debug の `flutter run` は影響なし）。

### 2. Android は key.properties の有無で署名を分岐する
`android/app/build.gradle` に release 署名 config を追加し、`key.properties` が存在する場合（= CI で Secrets から復元済み）のみリリース署名、存在しないローカルでは debug 署名にフォールバックする。これにより `flutter run --release` を含むローカルビルドを壊さない。

### 3. 配布構成は Riamo 踏襲・単一環境
`workflow_dispatch` 手動起動（`platform` で ios / android / both を選択）。
iOS は `altool` + App Store Connect API Key で **TestFlight** へ、Android は `r0adkll/upload-google-play` で **Google Play internal トラック**へアップロードする。
dev/prod flavor が無いため environment 入力は設けず、bundle id / packageName / ExportOptions を単一化する。ビルド番号は `github.run_number + BUILD_NUMBER_OFFSET`。

## Consequences

**良い点**
- `project.pbxproj` の署名設定がそのまま CI に効くため挙動が透明で、署名失敗時の切り分けがしやすい（CI 時に project を書き換える暗黙処理が無い）。
- Android はローカルで `flutter run --release` が従来どおり動く（debug フォールバック）。
- 既存の `make secret` をそのまま再利用でき、シークレット管理が CI 全体で一貫する。

**トレードオフ / 注意点**
- ローカルの release / archive ビルドには配布 profile + Apple Distribution 証明書が必要になる（Debug の `flutter run` は影響なし）。
- profile 名が `project.pbxproj`（`PROVISIONING_PROFILE_SPECIFIER`）と workflow の `env`（ExportOptions 用）の 2 箇所に存在するため、変更時は両方を一致させる必要がある。
- Widget 拡張も同様に Manual 署名 + 専用配布 profile の設定が必要（Runner / Widget で 2 つの profile / App ID / App Group を管理）。
- `Runner.entitlements` の `aps-environment` が `development` のままのため、本番 / TestFlight で Push 通知を使う場合は別途 `production` へ変更が必要（本 ADR の範囲外）。
- 初回はストア未登録のため、App Store Connect のアプリレコード作成、および Google Play の初回 AAB 手動アップロードが前提となる。

## 参照
- `.github/workflows/flutter-deploy.yml`
- `ios/Runner.xcodeproj/project.pbxproj`（Runner / Widget Release の手動署名設定）
- `android/app/build.gradle`（release 署名 config）
- 準備手順の完全版（Apple / Google / GitHub Secrets）は PR #344 の説明、およびローカルの `.plans/flutter-deploy-workflow.md` にまとめる
- Riamo `flutter-deploy.yml`（参考元）
