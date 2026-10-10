# 配布手順 (flutter-deploy)

iOS (TestFlight) と Android (Google Play internal トラック) への配布は、GitHub Actions の `flutter-deploy` ワークフロー (`.github/workflows/flutter-deploy.yml`) で行う。配布は prod 環境のみ (ADR 0030)。

## 起動方法

```sh
gh workflow run flutter-deploy.yml -f platform=both
```

`platform` は `ios` / `android` / `both` から選ぶ (ワークフローの `workflow_dispatch.inputs.platform`)。実行状況は次で確認する。

```sh
gh run list --workflow=flutter-deploy.yml --limit 5
gh run view <run id> --log-failed
```

公開後の無人ループからのリリースは、product-loop skill が release-app skill の QA ゲートを通してからこのワークフローを起動する。

## バージョンとビルド番号の決まり方

ワークフローの `prepare-version` job が決める (出典: `.github/workflows/flutter-deploy.yml` の `Resolve app version` step)。

| 値 | 由来 | 渡し先 |
| --- | --- | --- |
| バージョン (`CFBundleShortVersionString` / `versionName`) | `pubspec.yaml` の `version:` の `+` より前 (例: `1.0.1+1` なら `1.0.1`) | `flutter build` の `--build-name` |
| ビルド番号 (`CFBundleVersion` / `versionCode`) | `github.run_number` + `BUILD_NUMBER_OFFSET` | `flutter build` の `--build-number` |

`pubspec.yaml` の `+` 以降のビルド番号は CI では使われないため、`+1` のまま据え置いてよい。

## リリースのたびに `pubspec.yaml` の version を上げる

App Store Connect は、審査を通過したバージョンと同じ `CFBundleShortVersionString` のビルドを受け付けない。iOS で配布するたびに、`pubspec.yaml` の `version:` を審査済みのバージョンより大きい値に上げてから `flutter-deploy` を起動する。

出典 (計測した事実): 1.0.0 が審査を通過した後、`version: 1.0.0+1` のまま起動した 2026-09-01 の 2 回の run は、いずれも iOS の `Upload to TestFlight` step で `xcrun altool --upload-app` が次のエラーを返して失敗した。

- https://github.com/bannzai/shoppinglist/actions/runs/33464495116 (iOS 失敗・Android 成功)
- https://github.com/bannzai/shoppinglist/actions/runs/33464407511 (iOS 失敗)

```text
ERROR: [altool] Invalid Pre-Release Train. The train version '1.0.0' is closed for new build submissions (90186)
This bundle is invalid. The value for key CFBundleShortVersionString [1.0.0] in the Info.plist file must contain a higher version than that of the previously approved version [1.0.0]. (90062)
```

90062 のメッセージが案内する `CFBundleShortVersionString` の仕様: https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleshortversionstring

### 上げ方

1. `pubspec.yaml` の `version:` を上げる (例: `1.0.0+1` → `1.0.1+1`)。`+` 以降は変えない
2. Pull Request で main にマージする
3. 上の「起動方法」で `flutter-deploy` を起動する

### 未確認の点

Widget Extension (`ios/ShoppingListWidget/Info.plist`) の `CFBundleShortVersionString` は `$(MARKETING_VERSION)` で、`ios/Runner.xcodeproj/project.pbxproj` の `ShoppingListWidget` target に `MARKETING_VERSION = 1.0` と固定されている (本体の Runner は `$(FLUTTER_BUILD_NAME)` で `--build-name` に追従する)。本体 1.0.0 / Widget 1.0 の組み合わせでは 2026-08-18 の run https://github.com/bannzai/shoppinglist/actions/runs/32182952955 が `UPLOAD SUCCEEDED with no errors` で通っているが、本体 1.0.1 / Widget 1.0 の組み合わせで App Store Connect が何を返すかは未確認。拒否された時は、同 target の `MARKETING_VERSION` を本体に合わせて上げる。
