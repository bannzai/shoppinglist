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

これらを踏まえ、ローカル開発（Automatic 署名・`flutter run`）を壊さずに CI からストア配布できる方式を決める必要がある。

## Decision

### 1. iOS は CI 実行時のみ手動署名へ切り替える
`project.pbxproj` はローカル開発用に **Automatic のまま維持**し、commit はしない。
CI でチェックアウトした作業コピーに対してのみ `ios/scripts/configure_signing_for_ci.rb`（`xcodeproj` gem）を実行し、Release 構成の対象ターゲットを bundle id で判定して手動署名（Manual / Apple Distribution / profile specifier）へ書き換える。
provisioning profile は Runner / Widget の 2 つをインストールし、profile 名は workflow の `env`（`IOS_RUNNER_PROFILE_NAME` / `IOS_WIDGET_PROFILE_NAME`）を SSOT として ExportOptions.plist と Ruby スクリプトの双方が参照する。

代替案として Riamo 同様に手動署名を `project.pbxproj` に commit する案もあったが、ローカルの Automatic 署名運用を壊すため不採用。

### 2. Android は key.properties の有無で署名を分岐する
`android/app/build.gradle` に release 署名 config を追加し、`key.properties` が存在する場合（= CI で Secrets から復元済み）のみリリース署名、存在しないローカルでは debug 署名にフォールバックする。これにより `flutter run --release` を含むローカルビルドを壊さない。

### 3. 配布構成は Riamo 踏襲・単一環境
`workflow_dispatch` 手動起動（`platform` で ios / android / both を選択）。
iOS は `altool` + App Store Connect API Key で **TestFlight** へ、Android は `r0adkll/upload-google-play` で **Google Play internal トラック**へアップロードする。
dev/prod flavor が無いため environment 入力は設けず、bundle id / packageName / ExportOptions を単一化する。ビルド番号は `github.run_number + BUILD_NUMBER_OFFSET`。

## Consequences

**良い点**
- ローカル開発の署名設定（Automatic）を一切変更せずにストア配布が可能。
- Android はローカルで `flutter run --release` が従来どおり動く（debug フォールバック）。
- 既存の `make secret` をそのまま再利用でき、シークレット管理が CI 全体で一貫する。
- profile 名を env に集約することで ExportOptions と pbxproj 書換の値ズレを防ぐ。

**トレードオフ / 注意点**
- CI 実行時に `project.pbxproj` を書き換える「暗黙的な前提」が増える。署名失敗時は `configure_signing_for_ci.rb` と committed の pbxproj の差を意識して切り分ける必要がある。
- provisioning profile 名を Apple Developer 上の実体と workflow の env で**手動一致**させる運用が必要（不一致で署名失敗）。
- Widget 拡張のぶん profile / App ID / App Group の管理対象が増える。
- `Runner.entitlements` の `aps-environment` が `development` のままのため、本番 / TestFlight で Push 通知を使う場合は別途 `production` へ変更が必要（本 ADR の範囲外）。
- 初回はストア未登録のため、App Store Connect のアプリレコード作成、および Google Play の初回 AAB 手動アップロードが前提となる。

## 参照
- `.github/workflows/flutter-deploy.yml`
- `ios/scripts/configure_signing_for_ci.rb`
- `android/app/build.gradle`（release 署名 config）
- 準備手順の完全版（Apple / Google / GitHub Secrets）は PR #344 の説明、およびローカルの `.plans/flutter-deploy-workflow.md` にまとめる
- Riamo `flutter-deploy.yml`（参考元）
