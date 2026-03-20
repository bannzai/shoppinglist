---
name: multi-device-group-invite-test
description: |
  iOS SimulatorとAndroid Emulatorの2台でMaestroテストを実行し、
  グループ招待→参加→データ同期をE2Eで検証するスキル。
  mobile-mcpで招待コードの読み取り・アプリ再起動・同期確認を行う。
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

# iOS・Android 同時 Maestro テスト（グループ招待→参加→同期）

2台のデバイス（iOS Simulator + Android Emulator）でグループ招待・参加・データ同期をE2Eで検証する。
iOS/Android両方でMaestroを使い、mobile-mcpはデバイス間の招待コード受け渡しとアプリ再起動・同期確認に使用する。

## 前提条件

- iOS Simulator と Android Emulator が利用可能であること
- **Android APKはdebugビルドを使用する**（`匿名サインイン`ボタンが`kDebugMode`で囲まれているため）
- **Android EmulatorはAPI 35以下を推奨**（API 36はMaestro `inputText`の既知バグあり: [#2718](https://github.com/mobile-dev-inc/Maestro/issues/2718)）
- Flutter SDK がインストール済みであること
- Maestro CLI がインストール済みであること
- Firebase Emulator または本番環境に接続可能であること

## ワークフロー

### Step 1: デバイス準備

`setup_devices.sh` を実行してiOS SimulatorとAndroid Emulatorを起動し、アプリをビルド・インストールする。

```bash
bash .claude/skills/multi-device-group-invite-test/scripts/setup_devices.sh
```

スクリプトが出力するデバイスID（iOS_DEVICE_ID, ANDROID_DEVICE_ID）を後続ステップで使用する。

### Step 2: デバイスA（iOS/Maestro）でサインイン＋グループ作成＋招待コード生成

Maestroフローを `--device` 指定で実行する。

```bash
maestro test --device <iOS_DEVICE_ID> maestro/flows/multi_device/device_a_setup_and_invite.yaml
```

フロー完了後、mobile-mcpの `list_elements_on_screen` で招待コードダイアログからコードを読み取る。
- 招待コードは `SelectableText`（fontSize: 28、letterSpacing: 4）で表示される8桁の英数字
- 文字セット: `ABCDEFGHJKMNPQRSTVWXY3456789`（紛らわしい文字は除外）
- フォールバック: `take_screenshot` でスクリーンショットを撮影し、画像からコードを読み取る

読み取ったコードをメモリ上に保持し、Step 4で使用する。

### Step 3: デバイスA（iOS/Maestro）でグループ切り替え＋アイテム追加

Maestroフローを実行する。

```bash
maestro test --device <iOS_DEVICE_ID> maestro/flows/multi_device/device_a_add_item.yaml
```

このフローは以下を実行する:
- 招待コードダイアログを閉じ、設定画面から買い物リストタブに戻る
- GroupSwitcherで「TestSyncGroup」に切り替え
- shoppingListの自動作成を待機（`AppEntityPrepareResolver` が `defaultGroupID` 変更時に自動作成）
- 「milk_sync_test」アイテムを追加

### Step 4: デバイスB（Android/Maestro）でサインイン＋招待コード入力＋グループ参加

まず匿名サインインを実行する。

```bash
maestro test --device <ANDROID_DEVICE_ID> maestro/flows/multi_device/device_b_sign_in.yaml
```

次に、Step 2で取得した招待コードを環境変数で渡してグループ参加フローを実行する。

```bash
maestro test --device <ANDROID_DEVICE_ID> -e INVITATION_CODE=<招待コード> maestro/flows/multi_device/device_b_join_group.yaml
```

### Step 5: デバイスBでアプリ再起動＋同期確認

グループ参加後、`HomePage` の `currentGroupID`（`useState` で保持）が旧グループのままのため、
アプリを再起動して `defaultGroupID`（参加時に更新済み）を反映させる。

Android debugビルドはDart VM + Impeller初期化が重く、通常の再起動では起動タイムアウト（10秒）で
強制終了されることがある。以下の手順でクリーンに再起動する:

1. `adb shell am force-stop com.bannzai.shoppinglist` で完全停止
2. `adb shell pm clear --cache-only com.bannzai.shoppinglist` でキャッシュクリア（アプリデータは保持）
3. mobile-mcpの `launch_app` でアプリを再起動
4. `extendedWaitUntil` 相当で起動完了を待機（最大30秒）
5. `take_screenshot` で画面を撮影し、「milk_sync_test」が表示されていることを確認

表示されていない場合:
1. さらに5秒待機してリトライ（最大30秒）
2. `list_elements_on_screen` で画面要素を詳細に確認

## 検証チェックリスト

各ステップでスクリーンショットを撮影し、以下を確認する:

1. [ ] `setup_devices.sh` でiOS SimulatorとAndroid Emulatorが起動する
2. [ ] 両デバイスにアプリがインストールされる
3. [ ] デバイスA (iOS/Maestro): 匿名サインインが成功する
4. [ ] デバイスA: グループ「TestSyncGroup」が作成される
5. [ ] デバイスA: 招待コードダイアログに8桁コードが表示される
6. [ ] mobile-mcpで招待コードが正しく読み取れる
7. [ ] デバイスA: GroupSwitcherで「TestSyncGroup」切り替え成功
8. [ ] デバイスA: shoppingList自動作成 →「アイテムを追加」表示
9. [ ] デバイスA:「milk_sync_test」アイテムが追加される
10. [ ] デバイスB (Android/Maestro): 匿名サインインが成功する
11. [ ] デバイスB (Maestro): 招待コード入力→グループ参加成功
12. [ ] デバイスB (mobile-mcp): アプリ再起動後、TestSyncGroupのリスト表示
13. [ ] デバイスB:「milk_sync_test」が同期表示される

## 注意事項

- `maestro/config.yaml` でテスト出力先が `maestro/test-results/` に設定されている
- **MaestroとMobile-MCPの競合回避**: Maestroフローが完全に終了してからmobile-mcpで操作する。同時操作はしない
- **Android Emulator未作成時**: `setup_devices.sh` でAVDが見つからない場合はエラーメッセージが表示される。`sdkmanager` と `avdmanager` でAVDを作成してから再実行する
- **Maestroの `--device` オプション**: iOS SimulatorにはUDID、Android EmulatorにはEmulator名（例: `emulator-5554`）を指定する
- **テストデータは英数字のみ**: AndroidのMaestro `inputText` が日本語未対応のため、グループ名・アイテム名は英数字を使用する

## トラブルシューティング

### Maestroがデバイスを見つけられない
```bash
maestro hierarchy  # 接続確認
adb devices        # Android接続確認
xcrun simctl list devices booted  # iOS接続確認
```

### 招待コードが読み取れない
`take_screenshot` でスクリーンショットを撮影し、画像から直接読み取る。

### 同期が遅い
Firebase Emulator使用時は同期が即座に行われるが、本番環境では1-3秒の遅延がある。最大30秒まで待機してリトライする。

### Androidでアプリが白画面のまま
`anonymous_sign_in.yaml` は `extendedWaitUntil` でサインイン画面の表示を最大15秒待機する。それでも表示されない場合はアプリの再インストールを試す。

### Android API 36での問題
API 36（Android 16）では以下の既知の問題がある:
- **Maestro `inputText` が動作しない**: 1キーストロークに10-20秒かかるバグ（[GitHub #2718](https://github.com/mobile-dev-inc/Maestro/issues/2718)）
- **debugビルドの起動タイムアウト**: ActivityManagerの`PROC_START_TIMEOUT = 10秒`がハードコードされており、Flutter debugビルドのDart VM + Impeller初期化がこれを超過する
- **解決策**: API 35以下のエミュレータを使用する。`setup_devices.sh` がAVD未存在時にAPI 35のAVDを自動作成する
