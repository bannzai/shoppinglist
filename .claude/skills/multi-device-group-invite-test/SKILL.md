---
name: multi-device-group-invite-test
description: |
  iOS SimulatorとAndroid Emulatorの2台で同時にMaestroテストを実行し、
  グループ招待→参加→データ同期をE2Eで検証するスキル。
  mobile-mcpで招待コードの読み取り・入力を行い、デバイス間のデータ受け渡しを実現する。
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
Maestroで定型操作を実行し、mobile-mcpでデバイス間の招待コード受け渡しを行う。

## 前提条件

- iOS Simulator と Android Emulator が利用可能であること
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

### Step 2: デバイスA（iOS）でサインイン＋グループ作成＋招待コード生成

Maestroフローを `--device` 指定で実行する。

```bash
maestro test --device <iOS_DEVICE_ID> maestro/flows/multi_device/device_a_setup_and_invite.yaml
```

フロー完了後、mobile-mcpの `list_elements_on_screen` で招待コードダイアログからコードを読み取る。
- 招待コードは `SelectableText`（fontSize: 28、letterSpacing: 4）で表示される8桁の英数字
- 文字セット: `ABCDEFGHJKMNPQRSTVWXY3456789`（紛らわしい文字は除外）
- フォールバック: `take_screenshot` でスクリーンショットを撮影し、画像からコードを読み取る

読み取ったコードをメモリ上に保持し、Step 4で使用する。

### Step 3: デバイスB（Android）でサインイン

Maestroフローを実行する。

```bash
maestro test --device <ANDROID_DEVICE_ID> maestro/flows/multi_device/device_b_sign_in.yaml
```

### Step 4: デバイスBで招待コード入力＋グループ参加

mobile-mcpでAndroid Emulatorを操作する。以下の手順を順番に実行する。

1. `list_elements_on_screen` で画面要素を確認
2. 設定タブ（「設定」テキスト）をタップ
3. 「招待コードでグループに参加」をタップ
4. 「招待コードで参加」画面が表示されることを確認
5. テキスト入力欄をタップし、Step 2で取得した招待コードを `type_keys` で入力
6. 「参加する」ボタンをタップ
7. ホーム画面（「アイテムを追加」が表示される画面）に遷移することを確認
8. `take_screenshot` で確認用スクリーンショットを撮影

**注意**: 参加処理はFirestoreへの書き込みを含むため、「参加する」タップ後に数秒待機してから画面遷移を確認する。

### Step 5: デバイスAでアイテム追加

Maestroフローを実行する。

```bash
maestro test --device <iOS_DEVICE_ID> maestro/flows/multi_device/device_a_add_item.yaml
```

### Step 6: デバイスBで同期確認

Firestoreリアルタイム同期の遅延（1-3秒）を考慮し、5秒待機する。
その後、mobile-mcpの `take_screenshot` でAndroid Emulatorの画面を撮影し、「同期テスト牛乳」が表示されていることを確認する。

表示されていない場合:
1. さらに5秒待機してリトライ
2. `list_elements_on_screen` で画面要素を詳細に確認
3. アプリを再起動して確認

## 検証チェックリスト

各ステップでスクリーンショットを撮影し、以下を確認する:

1. [ ] `setup_devices.sh` でiOS SimulatorとAndroid Emulatorが起動する
2. [ ] 両デバイスにアプリがインストールされる
3. [ ] デバイスA: 匿名サインインが成功する
4. [ ] デバイスA: グループ「テスト共有グループ」が作成される
5. [ ] デバイスA: 招待コードダイアログに8桁コードが表示される
6. [ ] mobile-mcpで招待コードが正しく読み取れる
7. [ ] デバイスB: 匿名サインインが成功する
8. [ ] デバイスB: 招待コード入力画面に遷移できる
9. [ ] デバイスB: コード入力後「参加する」でグループ参加成功
10. [ ] デバイスA: 「同期テスト牛乳」アイテムが追加される
11. [ ] デバイスB: 「同期テスト牛乳」がリストに表示される（Firestore同期確認）

## 注意事項

- **MaestroとMobile-MCPの競合回避**: Maestroフローが完全に終了してからmobile-mcpで操作する。同時操作はしない。
- **Android Emulator未作成時**: `setup_devices.sh` でAVDが見つからない場合はエラーメッセージが表示される。`sdkmanager` と `avdmanager` でAVDを作成してから再実行する。
- **Maestroの `--device` オプション**: iOS SimulatorにはUDID、Android EmulatorにはEmulator名（例: `emulator-5554`）を指定する。

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
