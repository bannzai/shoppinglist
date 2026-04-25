# Maestro E2E テスト手順

買い物リストアプリの E2E フロー群を iOS / Android で実行するためのローカル手順書。

## 前提

### 必須ツール
- Maestro CLI: https://docs.maestro.dev/
- iOS: Xcode 15+ / iOS 18.x シミュレータ（iPhone 16 Plus 推奨）
  - **iOS 26.x beta は WebDriverAgent が不安定。iOS 18.x を使うこと**
  - 詳細: `~/.claude/skills/maestro-flutter/SKILL.md`
- Android: Android Studio + API 35 emulator（`test_device_api35` 推奨）

### RC Test Store API Key（IAP E2E 実行時のみ必須）

`iap_purchase_*.yaml` / `premium_*.yaml` / `shared/mock_purchase.yaml` の実行には Test Store Key が必要:

1. Dashboard https://app.revenuecat.com/projects/a9466f75/apps/appd627c59489 から `test_xxx` 形式の Key を取得
2. シェル環境変数に `export REVENUECAT_TEST_STORE_API_KEY=test_xxx` して永続化（`.zshrc` 等）
3. `.vscode/launch.json` は `${env:REVENUECAT_TEST_STORE_API_KEY}` で環境変数を参照する設定済み

**Debug ビルドで Key が空のまま起動すると `initializePurchase()` の assert で落ちる**（PR #233 設計）。

## iOS 実行

### 1. シミュレータ起動 + アプリインストール

```bash
# iPhone 16 Plus (iOS 18.5) の Simulator を boot（存在すれば再利用）
bash ~/.claude/skills/sim-manager/scripts/create-and-boot-sim.sh "E2E-iPhone16Plus" "iPhone 16 Plus"

# 直近 booted な Simulator の UDID を取得
DEVICE_UDID=$(xcrun simctl list devices booted -j | jq -r '.devices|to_entries[0].value[0].udid')

# ビルド + install
flutter build ios --simulator --debug --dart-define=REVENUECAT_TEST_STORE_API_KEY=$REVENUECAT_TEST_STORE_API_KEY
xcrun simctl install $DEVICE_UDID build/ios/iphonesimulator/Runner.app
```

### 2. 購入 E2E（3 パッケージ）

```bash
for pkg in monthly annual lifetime; do
  bash ~/.claude/skills/maestro-flutter/scripts/run-maestro-flow.sh \
    maestro/flows/iap_purchase_${pkg}.yaml $DEVICE_UDID
done
```

### 3. 機能解除確認 E2E（10 フロー）

```bash
for f in maestro/flows/premium_*.yaml; do
  bash ~/.claude/skills/maestro-flutter/scripts/run-maestro-flow.sh "$f" $DEVICE_UDID
done

bash ~/.claude/skills/maestro-flutter/scripts/collect-results.sh
```

## Android 実行

```bash
# Emulator 起動（既に boot 済みならスキップ）
emulator -avd test_device_api35 -no-snapshot-load &

# ビルド + install
flutter build apk --debug --dart-define=REVENUECAT_TEST_STORE_API_KEY=$REVENUECAT_TEST_STORE_API_KEY
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# 全 IAP / premium フロー実行
for f in maestro/flows/iap_purchase_*.yaml maestro/flows/premium_*.yaml; do
  maestro --platform android test "$f" --debug-output tmp/maestro-android-results --flatten-debug-output
done
```

## mock purchase modal の要素調査（初回 / UI 変更時）

`shared/mock_purchase.yaml` は modal 内の購入確定ボタンを `tapOn: "Subscribe"` で暫定指定している。RC Test Store SDK の出す modal は OS ネイティブ dialog に近い UI で、iOS / Android で text / id が異なる可能性がある。初回実行で fail する場合は以下で実機調査:

```bash
# アプリを起動してペイウォールの購入ボタンを手動でタップし、mock purchase modal を表示
maestro hierarchy --output tmp/mock-purchase-modal-ios.xml
maestro --platform android hierarchy --output tmp/mock-purchase-modal-android.xml
```

出力の XML から `Subscribe` / `Buy` / `Confirm` に相当する text / resource-id を探し、`shared/mock_purchase.yaml` の `tapOn` 対象を差し替える。iOS と Android で別要素なら platform ごとにサブフローを分離する（例: `shared/mock_purchase_ios.yaml` / `shared/mock_purchase_android.yaml`）。

## トラブルシュート

- **iOS WDA 接続断**: `xcrun simctl erase $DEVICE_UDID` → boot → install → retry
- **Android ディスク不足**: 別 AVD に切り替え（`avdmanager list avd`）または `adb uninstall com.bannzai.shoppinglist` で空き確保
- **Android Unicode 入力エラー**: 該当 `inputText` を ASCII に置換（https://github.com/mobile-dev-inc/maestro/issues/146）
- **mock purchase modal で停止**: 上記「要素調査」セクションを参照
- **「REVENUECAT_TEST_STORE_API_KEY is required」で落ちる**: `--dart-define` を付けずにビルドしている。PR #233 の assert を参照
- **Test Store 購入履歴が残る**: `launchApp.clearState + clearKeychain` で消えるか未検証。消えない場合は RC Dashboard からの revoke が必要になる可能性あり

## フロー一覧

| フロー | 役割 | 前提 |
|---|---|---|
| `shared/anonymous_sign_in.yaml` | 匿名サインインまで到達する共通サブフロー | なし |
| `shared/open_developer_options.yaml` | 設定 → 開発者オプション画面を開く | 匿名サインイン後 |
| `shared/mock_purchase.yaml` | 設定 → プレミアム会員 → ペイウォール → 指定 Package 購入 → 購入完了まで | `PACKAGE_TYPE=monthly/annual/lifetime`、匿名サインイン後 |
| `iap_purchase_monthly.yaml` | monthly 購入後に「プレミアム会員: 有効」を assert | RC Test Store |
| `iap_purchase_annual.yaml` | annual 購入後に「プレミアム会員: 有効」を assert | RC Test Store |
| `iap_purchase_lifetime.yaml` | lifetime 購入後に「プレミアム会員: 有効」を assert | RC Test Store |
| `premium_theme_color_setting.yaml` | premium 後のテーマカラー画面遷移 | RC Test Store |
| `premium_export_shopping_list.yaml` | premium 後のリストエクスポート実行 | RC Test Store |
| `premium_group_creation.yaml` | premium 後の 2 個目グループ作成 | RC Test Store |
| `premium_item_photo_attachment.yaml` | premium 後のアイテム写真添付導線 | RC Test Store |
| `premium_location_reminder.yaml` | premium 後の位置情報リマインダー有効化 | RC Test Store |
| `premium_shopping_list_display_period.yaml` | premium 後の「プレミアム: 無制限」表示 | RC Test Store |
| `premium_shopping_list_limit.yaml` | premium 後の 6 個目リスト作成 | RC Test Store |
| `premium_shopping_list_limit_duplicate.yaml` | premium 後の複製で 6 個目作成 | RC Test Store |
| `premium_ai_image_recognition.yaml` | premium 後の AI 画像認識上限 50 | RC Test Store（事前データ任意） |
| `premium_ai_url_recognition.yaml` | premium 後の AI URL 認識上限 50 | RC Test Store（事前データ任意） |
