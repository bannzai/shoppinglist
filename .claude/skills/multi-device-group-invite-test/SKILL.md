---
name: multi-device-group-invite-test
description: |
  iOS SimulatorでMaestroテストを実行し、仮想ペアリング（開発者オプション）を使って
  グループ招待→参加→データ同期をE2Eで検証するスキル。
  デバッグユーザー機能により1台のiOS Simulatorで「別ユーザーの操作」をシミュレーションする。
  使用例: "/multi-device-group-invite-test"
allowed-tools:
  - mcp__mobile__mobile_list_available_devices
  - mcp__mobile__mobile_take_screenshot
  - mcp__mobile__mobile_list_elements_on_screen
  - mcp__mobile__mobile_click_on_screen_at_coordinates
  - mcp__mobile__mobile_long_press_on_screen_at_coordinates
  - mcp__mobile__mobile_press_button
  - mcp__mobile__mobile_launch_app
  - mcp__mobile__mobile_install_app
  - mcp__mobile__mobile_swipe_on_screen
  - mcp__mobile__mobile_type_keys
  - mcp__mobile__mobile_terminate_app
  - Bash
  - Read
---

# iOS Simulator + 仮想ペアリングによるグループ同期 E2E テスト

**MaestroはiOS Simulatorで実行する。** Android Emulatorは使用しない（後述のリファレンス参照）。
仮想ペアリング機能（開発者オプション）を使い、1台のiOS Simulatorで「別ユーザーがアイテムを追加した」シナリオを検証する。

## 前提条件

- iOS Simulator が利用可能であること（iPhone 16 Plus推奨）
- Flutter SDK がインストール済みであること
- Maestro CLI がインストール済みであること
- アプリがdebugビルドでインストール済みであること（開発者オプション機能は `kDebugMode` のみ有効）

## ワークフロー

### Step 1: デバイス準備・アプリビルド

```bash
# iOS Simulatorを起動
xcrun simctl boot "iPhone 16 Plus" || true

# debugビルド・インストール
flutter build ios --simulator --debug
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
```

### Step 2: Maestroで通常フロー実行（サインイン→グループ作成→アイテム追加）

```bash
maestro test maestro/flows/multi_device/device_a_setup_and_invite.yaml
```

### Step 3: 仮想ペアリング操作（シェイク→開発者オプション）

iOS Simulatorでシェイクをトリガーして開発者オプションモーダルを開く:

```bash
# Maestro runScript または直接実行
xcrun simctl io booted shake
```

モーダルが表示されたら:
1. 「デバッグユーザー作成」をタップ
2. 「グループにデバッグユーザーを追加」をタップ
3. アイテムメッセージを入力（例: `milk_sync_test`）
4. 「デバッグユーザーとしてアイテム追加」をタップ（遅延3秒）
5. モーダルが閉じ、3秒後にアイテムがリアルタイム同期で画面に表示される

### Step 4: 同期確認

- `take_screenshot` で画面を撮影し、デバッグユーザーが追加したアイテムが表示されていることを確認

### Step 5: クリーンアップ

再度シェイクして開発者オプションを開き、「デバッグデータクリーンアップ」をタップ。

## 検証チェックリスト

1. [ ] iOS Simulator でアプリがdebugビルドで起動する
2. [ ] シェイクで開発者オプションモーダルが表示される
3. [ ] デバッグユーザー作成が成功する（Firestoreにドキュメント作成）
4. [ ] グループへのデバッグユーザー追加が成功する（memberUserIDs更新）
5. [ ] デバッグユーザーとしてのアイテム追加が遅延後に実行される
6. [ ] 追加されたアイテムがリアルタイム同期で画面に反映される
7. [ ] クリーンアップでデバッグデータが削除される

## 注意事項

- 開発者オプション機能は `kDebugMode` のみで有効。リリースビルドでは動作しない
- デバッグユーザーID形式: `{実UID}_debug_1`
- Firestoreセキュリティルールの `isDebugUserOf()` で `{uid}_debug_[0-9]+` パターンを許可

## リファレンス: Android E2E テストの既知問題

以下の理由により、Android Emulatorでの Maestro E2E テストは現時点で安定しない:

| 問題 | 詳細 |
|---|---|
| API 36 inputText不具合 | 1キーストロークに10-20秒かかる ([Maestro #2718](https://github.com/mobile-dev-inc/Maestro/issues/2718)) |
| debugビルド起動タイムアウト | ActivityManagerの `PROC_START_TIMEOUT = 10秒` がハードコード。Flutter debugビルドのDart VM + Impeller初期化がこれを超過しANRが発生 |
| Maestro `-e` 環境変数展開不具合 | `${VARIABLE}` 形式の展開が不安定 |
| `hideKeyboard` iOS非対応 | Maestroの `hideKeyboard` コマンドがiOSで動作しない |
| データ同期問題 | `AppEntityPrepareResolver` が新規ユーザーのために新しい `ShoppingList` を自動作成し、既存グループのデータと競合する |
