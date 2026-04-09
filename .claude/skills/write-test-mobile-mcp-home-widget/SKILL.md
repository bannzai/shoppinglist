---
name: write-test-mobile-mcp-home-widget
description: |
  mobile-mcpを使ってiOSシミュレータ上でホーム画面ウィジェットの動作テストを行うスキル。
  ウィジェットの追加、表示確認、インタラクション（チェックボックス）、アプリ同期の検証。
  使用例: "/write-test-mobile-mcp-home-widget"
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
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/test_skill.sh:*)
  - Bash
  - Read
---

# ホーム画面ウィジェット mobile-mcp テスト

iOSシミュレータ上でFlutterアプリの**ホーム画面ウィジェット**をmobile-mcpで操作テストする手順。

## 前提条件
- アプリがシミュレータ用にビルド済み（`flutter build ios --simulator`）

## ワークフロー

### Step 1: テスト専用シミュレータの作成・アプリインストール
```
1. xcrun simctl list runtimes で利用可能なiOSランタイムを確認
2. xcrun simctl create "WidgetTest" <DeviceType> <Runtime> でテスト専用シミュレータを作成
   - 例: xcrun simctl create "WidgetTest" "iPhone 16 Pro" "iOS 18.2"
3. xcrun simctl shutdown all で他のシミュレータを全てシャットダウン
4. xcrun simctl boot <作成したUDID> で作成したシミュレータだけをboot
5. open -a Simulator でシミュレータを表示
6. xcrun simctl install <DEVICE_UDID> <APP_PATH> でアプリをインストール
```

### Step 1.5: アプリを起動して匿名サインイン
```
1. mobile_launch_app でアプリを起動（Bundle ID: アプリのBundle IDを指定）
2. mobile_list_elements_on_screen で画面要素を確認
3. 「匿名サインイン（デバッグ用）」ボタンの座標を取得してタップ
4. ホーム画面が表示されるのを待つ（mobile_take_screenshot で確認）
```

### Step 2: ホーム画面でジグルモードに入る
```
1. mobile_press_button HOME でホーム画面に戻る
2. mobile_long_press_on_screen_at_coordinates でアイコンのない空白エリアを長押し
   - 座標例: x=300, y=450〜500（画面下半分の空白）
   - duration: 2000ms
3. mobile_list_elements_on_screen で「編集」ボタンが出ていることを確認
```

### Step 3: ウィジェットギャラリーを開く
```
1. 「編集」ボタンをタップ（左上、座標例: x=40, y=30）
2. mobile_list_elements_on_screen でメニューを確認
3. 「ウィジェットを追加」ボタンをタップ（座標はlist_elementsの結果を使用）
   - 注意: ボタンの中心座標を正確にタップすること
```

### Step 4: ウィジェットを検索・選択
```
1. ギャラリーが開いたらmobile_list_elements_on_screenでウィジェット一覧を確認
2. アプリ名（例: "Shoppinglist"）のStaticTextをタップ
   - 検索バーはタップすると閉じることがあるので、リスト内のアプリ名を直接タップする方が安定
3. ウィジェットのプレビュー画面が表示される
```

### Step 5: ウィジェットを追加
```
1. プレビュー画面で「ウィジェットを追加」ボタンをタップ（画面下部、y=800付近）
2. ホーム画面のジグルモードに戻る
3. 「完了」ボタンをタップ（右上、座標例: x=340, y=30）
4. mobile_take_screenshot で追加されたウィジェットを確認
```

### Step 6: ウィジェット表示確認
```
1. mobile_list_elements_on_screen でウィジェットの要素を確認
2. ウィジェット内にアプリ名、アイコン、コンテンツが表示されていることを検証
```

### Step 7: ウィジェットインタラクション（チェックボックス等）
```
※ アプリにログイン済みでデータがある状態が必要
1. ウィジェット内のアイテム行の座標をlist_elementsで取得
2. mobile_click_on_screen_at_coordinates でチェックボックスをタップ
3. mobile_take_screenshot で状態変更を確認
```

### Step 8: アプリ側同期確認
```
1. mobile_launch_app でアプリを起動
2. mobile_take_screenshot でアイテムの状態がウィジェットと同期しているか確認
```

## 注意事項・Tips

### ウィジェットギャラリーが閉じる問題
- 検索バー（SearchField）をタップするとギャラリーが閉じることがある
- **対処法**: 検索を使わず、アプリ一覧をスクロールしてアプリ名を直接タップする

### WebDriverAgentの初回セットアップ
- WDA（WebDriverAgent）の初回セットアップに時間がかかり、タイムアウトすることがある（[mobile-mcp Issue #233](https://github.com/mobile-next/mobile-mcp/issues/233)）
- mobile-mcpの最近のバージョンではWDAの自動ダウンロード・インストール機能あり
- **対処法1**: 他のシミュレータを全てシャットダウン（`xcrun simctl shutdown all`）してから対象1台だけをbootする
- **対処法2**: シミュレータを再起動してリトライする

### ウィジェットが空の場合
- ログインしていない/データがない場合、ウィジェットはプレースホルダー表示になる
- データ同期はUserDefaults (App Group) 経由（例: `group.com.example.app`。プロジェクトのApp Group IDに合わせること）

### 座標の取得
- 必ず `mobile_list_elements_on_screen` で最新の座標を取得してから操作する
- スクリーンショットの見た目と実際の座標は異なる場合がある
- ボタンは `coordinates` の `x + width/2`, `y + height/2` を中心として使う

### ビルドエラー対処（Flutterプロジェクトでhome_widgetパッケージを使っている場合）
- Widget ExtensionでFlutter/home_widgetをimportしない（Widget Extensionからはアクセス不可）
- AppDelegateに `HomeWidgetPlugin.setConfigurationLookup` は不要（home_widget 0.7.0+1にはない）
- ビルドサイクルエラー: 「Embed Foundation Extensions」を「Thin Binary」の前に配置する

## 検証方法

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/test_skill.sh
```
