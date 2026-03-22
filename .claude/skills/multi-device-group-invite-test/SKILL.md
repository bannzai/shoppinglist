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

**MaestroはiOS Simulatorで実行する。** Android Emulatorは使用しない。
仮想ペアリング機能（開発者オプション）を使い、1台のiOS Simulatorで「別ユーザーがアイテムを追加した」シナリオを検証する。

## 方式

設定画面に `kDebugMode` 限定の「開発者オプション」タイルを配置。Maestroから直接タップして開発者オプション画面に遷移し、各操作を実行する。各操作は同期的に実行され、結果（「完了」or「エラー:」）が画面上に表示される。

## 前提条件

- iOS Simulator が利用可能であること（iPhone 16 Plus推奨）
- Flutter SDK がインストール済みであること
- Maestro CLI がインストール済みであること
- アプリがdebugビルドでインストール済みであること（開発者オプション機能は `kDebugMode` のみ有効）

## ワークフロー

### Step 1: デバイス準備・アプリビルド

```bash
bash .claude/skills/multi-device-group-invite-test/scripts/setup_devices.sh
```

### Step 2: Maestro E2Eテスト実行

6つの独立したMaestroフローを順次実行する。各フェーズは `launchApp: clearState: false` でアプリを再起動し、設定タブ→開発者オプションへ遷移して操作を実行する。

```bash
bash maestro/scripts/run_group_sync_test.sh
```

### テストフェーズ概要

| Phase | 内容 | 検証ポイント |
|---|---|---|
| 1 | サインイン + グループ作成 | グループ「VirtualPairTestGroup」が作成される |
| 2 | 設定→開発者オプション→デバッグユーザー作成 | Firestoreにデバッグユーザーが作成される |
| 3 | 設定→開発者オプション→グループにデバッグユーザー追加 | memberUserIDsにデバッグユーザーが追加される |
| 4 | 設定→開発者オプション→デバッグユーザーとしてアイテム追加 | アイテム「debug_item_test」が追加される |
| 5 | 買い物リストタブでリアルタイム同期確認 | 画面にアイテムが反映される（核心テスト） |
| 6 | 設定→開発者オプション→クリーンアップ | デバッグデータが削除される |

### 各フローの共通パターン（設定画面→開発者オプション）

```yaml
# 設定タブに切り替え
- tapOn:
    text: "設定.*"
    index: 0
- waitForAnimationToEnd
# 設定画面下部までスクロールして「開発者オプション」をタップ
- swipe:
    start: "50%,80%"
    end: "50%,20%"
- swipe:
    start: "50%,80%"
    end: "50%,20%"
- tapOn: "開発者オプション"
- waitForAnimationToEnd
# 操作を実行し「完了」テキストを待つ
- extendedWaitUntil:
    visible: ".*完了"
    timeout: 15000
```

## 検証チェックリスト

1. [ ] iOS Simulator でアプリがdebugビルドで起動する
2. [ ] 設定画面に「開発者オプション」タイルが表示される
3. [ ] デバッグユーザー作成が成功する（Firestoreにドキュメント作成）
4. [ ] グループへのデバッグユーザー追加が成功する（memberUserIDs更新）
5. [ ] デバッグユーザーとしてのアイテム追加が成功する
6. [ ] 追加されたアイテム「debug_item_test」がリアルタイム同期で画面に反映される
7. [ ] クリーンアップでデバッグデータが削除される

## トラブルシューティング

| 問題 | 対策 |
|---|---|
| Maestroがテキストを検出しない | `Semantics(label:, excludeSemantics: true)` でListTileをラップ |
| `launchApp: clearState: false` でアプリが再起動される | 期待動作。各操作は同期的に完了し結果を画面に表示するため、再起動後も問題なし |
| 同期が間に合わない | `extendedWaitUntil` のtimeoutは15秒に設定済み |
| `pressKey: back` がiOSで効かない | `tapOn: "Back"` でAppBarの戻るボタンをタップ |
| BottomNavigationBarのラベルが検出不可 | 座標 `point: "25%,93%"` でタップ |
| Maestroが前回のプロセスと衝突 | `pkill -f "maestro"` で事前にクリア |

## 注意事項

- 開発者オプション機能は `kDebugMode` のみで有効。リリースビルドでは動作しない
- デバッグユーザーID形式: `{実UID}_debug_1`
- Firestoreセキュリティルールの `isDebugUserOf()` で `{uid}_debug_[0-9]+` パターンを許可
- Firestoreルールにデバッグユーザー用の `allow delete` ルールが必要（`/users/{userID}` と `/userProfiles/{profileID}`）

## リファレンス: Android E2E テストの既知問題

以下の理由により、Android Emulatorでの Maestro E2E テストは現時点で安定しない:

| 問題 | 詳細 |
|---|---|
| API 36 inputText不具合 | 1キーストロークに10-20秒かかる ([Maestro #2718](https://github.com/mobile-dev-inc/Maestro/issues/2718)) |
| debugビルド起動タイムアウト | ActivityManagerの `PROC_START_TIMEOUT = 10秒` がハードコード。Flutter debugビルドのDart VM + Impeller初期化がこれを超過しANRが発生 |
| Maestro `-e` 環境変数展開不具合 | `${VARIABLE}` 形式の展開が不安定 |
| `hideKeyboard` iOS非対応 | Maestroの `hideKeyboard` コマンドがiOSで動作しない |
