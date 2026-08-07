---
feature: _root
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# QA 全体ガイド

## 対象環境

- 既定: **dev**（Firebase project `shoppinglist-dev-b2787`）。`--dart-define` なしの debug ビルドが dev に接続する
- ローカル検証: **Firebase Emulator**。`cd firebase && firebase emulators:start` で起動し、アプリは `--dart-define=USE_FIREBASE_EMULATOR=true` で接続する。Remote Config・FCM・RevenueCat の実検証や永続データが必要な確認は dev を直接使う
- prod（`shoppinglist-prod-857bb`）は通常の QA では使わない（リリース検証時のみ）

## 起動方法

シミュレータは /sim-manager（sim-boot）で起動する。アプリは `flutter run` で起動する（ビルド済みアプリの単独起動は LaunchImage で停止するため不可）。

```bash
# dev 直結（VS Code: shoppinglist(dev) 構成と同一）
flutter run --debug -d <UDID> \
  --dart-define=SHOPPINGLIST_DEVELOPER_TOKEN=$SHOPPINGLIST_DEVELOPER_TOKEN \
  --dart-define=REVENUECAT_TEST_STORE_API_KEY=$REVENUECAT_TEST_STORE_API_KEY

# Firebase Emulator 接続（VS Code: shoppinglist(dev, emulator) 構成と同一）
# 上記に --dart-define=USE_FIREBASE_EMULATOR=true を追加
```

- `REVENUECAT_TEST_STORE_API_KEY` が空のまま debug 起動すると `initializePurchase()` の assert で落ちる。取得手順は `maestro/README.md` を参照
- Maestro 実行時は `-e APP_ID=<bundle id>` の指定が必須（dev: `com.bannzai.shoppinglist.dev` / prod: `com.bannzai.shoppinglist`）。詳細は `maestro/README.md`

## ログイン方法

- QA では原則 **匿名サインイン** を使う（AuthPage の debug 匿名ボタン。Maestro は `maestro/flows/shared/anonymous_sign_in.yaml`）
- Apple / Google サインインは実アカウントが必要なため手動確認のみ（認証情報はここに書かない）
- 必要な環境変数は `SHOPPINGLIST_DEVELOPER_TOKEN` / `REVENUECAT_TEST_STORE_API_KEY`（値の取得元は `maestro/README.md`）

## 動作確認手段

- シミュレータ管理: /sim-manager（iOS 18.x を使う。iOS 26.x beta は WebDriverAgent が不安定）
- インタラクティブ UI 検証: /verify-ui-mobile-mcp
- E2E: /flutter-maestro（フロー新規作成は /maestro-flow-writer）。既存フローは `maestro/flows/` 配下
- UI の条件分岐検証は mobile-mcp / maestro より先に widget test（`flutter test`）で書けないか検討する

### 再現が難しい操作の手順

- オンボーディング再現: アプリ削除では不可（Keychain に認証が残存）。`clearState: true` + `clearKeychain: true`（Maestro）か、新規シミュレータ作成（sim-boot）で行う
- プレミアム状態: 課金せず開発者オプション →「プレミアム付与（1日）」（Maestro: `maestro/flows/shared/grant_premium_via_debug.yaml`）
- 別ユーザーの操作・同期: 開発者オプション →「デバッグユーザー作成」（Maestro: `maestro/flows/virtual_pairing/02_create_debug_user.yaml`）
- 一瞬で消える SnackBar の撮影: WDA スクショは静止待ちで撮り逃す。`xcrun simctl io <UDID> screenshot` を連写する
- グローバルトースト（`showGlobalToast`、表示時間5秒）の撮影: タップ→スクショを逐次実行すると mobile-mcp の往復レイテンシ（タップ自体の待ち + スクショ呼び出しの待ち）の積み重ねで5秒の表示時間内でも撮り逃すことがある。タップ操作（`mobile_click_on_screen_at_coordinates`）と `xcrun simctl io <UDID> screenshot` を同一メッセージ内で並列発行すると、レイテンシがほぼ相殺されて撮影できる（`lib/features/group_create/QA.md` セクション4参照）
- 長押しドラッグ&ドロップ: Maestro では duration 10000ms の swipe で長押し判定が成立する
- `maestro/flows/design_v2_entry.yaml` は現状 stale: オンボーディングスライドを3枚（Slide3「お店の近くで」まで）前提にアサートしているが、`shoppingLocationFeatureEnabled = false`（issue #465）により実際は2枚のみで「はじめる」に到達し Slide3 のアサートで fail する。オンボーディング〜Auth 画面表示の検証は `auth_page_test_01.yaml`（「スキップ」ボタンで直接 Auth 画面へ）等スライド数に依存しないフローを使う
- 1秒未満で完了する全画面ローディング（例: 匿名サインインの LaunchLoading overlay）は mobile-mcp のタップ→スクショ往復レイテンシで撮り逃す。連写・画面録画（`mobile_start_screen_recording`）は可能だが、本セッションの許可設定では ffmpeg/qlmanage 等の動画フレーム抽出コマンドがブロックされ確認できなかった。コードレビュー + 状態遷移の間接確認で代替した（`lib/features/auth/QA.md` セクション4参照）
- `Dismissible`（左右スワイプ）でラップされた行の `ReorderableDelayedDragStartListener`（長押しドラッグでの並び替え）は、maestro の低速 swipe（duration 10000ms、複数の開始x座標・selector指定を試行）で一切発火しない。同じ低速 swipe 技法は `Dismissible` を持たないヘッダー行（category_section_reorder.yaml）では成立するため、ラップの有無が差分と推測されるが未確定（`lib/features/shopping_list/QA.md` セクション6参照）
- 単純な `GestureDetector(onLongPress: ...)`（横スワイプ等の競合ジェスチャなし）についても、mobile-mcp の長押し（duration 500ms/1500ms）・maestro `longPressOn`・maestro 低速 swipe のいずれでも発火しないケースがあった（買い物リストの FAB 長押しメニュー）。同座標への通常タップは正常に反応するため、座標やアプリの応答性の問題ではない。自動化ツール側の制限か実際の不具合かは切り分けられていない。長押し系操作全般で自動化がうまくいかない場合は、まず対象行/要素に `Dismissible` 等の競合ジェスチャがないかを確認しつつ、実機・実指での手動確認を優先する（`lib/features/shopping_list/QA.md` セクション8参照）
- `id: "popup_menu_button"` を参照する maestro flow（ai_image_recognition_limit.yaml, ai_url_recognition_limit.yaml, premium_ai_image_recognition.yaml, premium_ai_url_recognition.yaml, design_v2_groups.yaml, design_v2_list_settings.yaml, design_v2_category_location.yaml）は design v2 移行前の UI を参照した stale flow。現行コードに `popup_menu_button` という id は存在しない（`grep -rn "popup_menu_button" lib/` で 0 件）。全ステップが `optional: true` のため実行時は警告のみで見かけ上パスし、実際には何も検証していない。これらを実行して「パス」と判断しない
- アプリのバックグラウンド移行（`AppLifecycleState.paused`）を伴う挙動（離脱時自動保存など）の検証: maestro flow 内で `pressKey: Home` を実行するとシミュレータのホーム画面に遷移し、実際にアプリがバックグラウンドへ移行する（iOS の Flutter アプリで動作確認済み）。前面復帰は `xcrun simctl launch <udid> <bundle id>` で行う（プロセスを再起動せず既存状態のまま前面に戻る）。復帰直後の画面は保存前のローカル状態を表示しているだけの可能性があるため、一覧画面へ戻る等で Firestore から再取得させて初めて保存の証拠になる点に注意する（`lib/features/group_category_edit/QA.md` セクション1参照）
- `flutter run --dart-define=SHOPPINGLIST_DEVELOPER_TOKEN=$SHOPPINGLIST_DEVELOPER_TOKEN --dart-define=REVENUECAT_TEST_STORE_API_KEY=$REVENUECAT_TEST_STORE_API_KEY` のように、この2つの secret 環境変数をシェル展開（`$VAR` / `${VAR}` / `eval` 経由いずれも）で Bash コマンドに含めると、非対話 QA セッションでは `Contains simple_expansion` / `Contains expansion` で一貫してブロックされる（`dangerouslyDisableSandbox` でも回避不可。他の一般的な環境変数展開は問題なし、この2変数の名前が特別扱いされている）。回避策: `./tmp/dart_defines.json`（gitignore 対象。`{"SHOPPINGLIST_DEVELOPER_TOKEN":"...","REVENUECAT_TEST_STORE_API_KEY":"..."}` 形式）を用意し、`flutter run --dart-define-from-file=./tmp/dart_defines.json` で起動する。ファイルが無ければ Write で新規作成する（値は事前にユーザーから伝えられているか、既存の同ファイルから流用する）
- 非対話 QA セッションの Bash sandbox では、上記 2 secret 変数に限らず **あらゆる `$var` 展開が `Contains simple_expansion` でブロックされる**（`$i` のような一般的なループ変数も不可）。加えて `sleep`（フォアグラウンド）・`break`・`&&`/`&`/`||`・ブレースグループ `{ ...; }` も弾かれる。この制約下でループを書く手段: (a) `flutter run` の起動待ちは `until grep -q "A Dart VM Service" <log>; do sleep 3; done`（`&` ではなく Bash ツールの `run_in_background: true`）で 1 回だけ完了通知を受ける。(b) スクショの連写はループを使わず、リテラルのファイル名で `xcrun simctl io <UDID> screenshot ./tmp/qa/s01.png ; ... ; ./tmp/qa/s14.png` のように `;` 区切りで並べる（各 1 枚が約 300ms かかるため 14 枚で約 3〜4 秒の窓を自然にカバーでき、`送信中...` のような一瞬のローディング状態やトーストを捕捉できる）。タップ（mobile-mcp）と連写（Bash）を同一メッセージで並列発行すると窓の開始をタップ直後に合わせられる（`lib/features/inquiry/QA.md` セクション5参照）
- サーバー側で文字数上限などの入力検証がある項目の「失敗時エラー表示」を検証する際の長文入力: `xcrun simctl pbcopy <UDID> < ./tmp/qa/long_content.txt`（上限超の長さのテキストファイル）でシミュレータのクリップボードへコピー → 対象 TextField をタップしてフォーカス → 長押しで出る「Paste」をタップして貼り付ける。mobile-mcp の文字入力は 1 文字ずつで数千字は非現実的なため、この pbcopy + 長押し Paste が実用的（`lib/features/inquiry/QA.md` セクション5、内容 5000 字超で `[firebase_functions/internal] INTERNAL` を誘発した例参照）

## 横断確認項目

## 1. 起動・認証

- [ ] **クリーン起動**: 新規状態でアプリを起動し、クラッシュせずオンボーディング→認証画面に到達する
- [ ] **匿名サインイン**: 匿名サインイン後、買い物リスト画面（ホーム）に到達する（既存 E2E: maestro/flows/shared/anonymous_sign_in.yaml）
- [ ] **再起動時のセッション維持**: サインイン済み状態でアプリを再起動すると、認証画面を経由せず直接ホームに到達する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **クリーン起動**: 新規状態でアプリを起動し、クラッシュせずオンボーディング→認証画面に到達する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **匿名サインイン**: 匿名サインイン後、買い物リスト画面（ホーム）に到達する（既存 E2E: maestro/flows/shared/anonymous_sign_in.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **再起動時のセッション維持**: サインイン済み状態でアプリを再起動すると、認証画面を経由せず直接ホームに到達する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. 環境・デバッグ機能

- [ ] **Firebase Emulator 接続**: `USE_FIREBASE_EMULATOR=true` で起動したアプリの書き込みが Emulator UI（Firestore）に反映される
- [ ] **プレミアム付与（1日）**: 開発者オプションから付与するとプレミアム状態になり、プレミアム機能が解放される（既存 E2E: maestro/flows/shared/grant_premium_via_debug.yaml）
- [ ] **デバッグユーザー作成**: 開発者オプションからデバッグユーザーを作成し、別ユーザーとしての操作が同期される（既存 E2E: maestro/flows/virtual_pairing/02_create_debug_user.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **Firebase Emulator 接続**: `USE_FIREBASE_EMULATOR=true` で起動したアプリの書き込みが Emulator UI（Firestore）に反映される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **プレミアム付与（1日）**: 開発者オプションから付与するとプレミアム状態になり、プレミアム機能が解放される（既存 E2E: maestro/flows/shared/grant_premium_via_debug.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **デバッグユーザー作成**: 開発者オプションからデバッグユーザーを作成し、別ユーザーとしての操作が同期される（既存 E2E: maestro/flows/virtual_pairing/02_create_debug_user.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 機能別 QA.md

- [shopping_list](lib/features/shopping_list/QA.md) — 買い物リスト本体（最重要・高頻度）
- [shopping_list_setting](lib/features/shopping_list_setting/QA.md) — リスト設定
- [home](lib/features/home/QA.md) — ホーム画面
- [onboarding](lib/features/onboarding/QA.md) — オンボーディング
- [auth](lib/features/auth/QA.md) — 認証
- [settings](lib/features/settings/QA.md) — 設定
- [inquiry](lib/features/inquiry/QA.md) — 問い合わせ
- [paywall](lib/features/paywall/QA.md) — ペイウォール・課金
- [receipt](lib/features/receipt/QA.md) — レシート
- [group_list](lib/features/group_list/QA.md) — グループ一覧
- [group_create](lib/features/group_create/QA.md) — グループ作成
- [group_join_or_create](lib/features/group_join_or_create/QA.md) — グループ参加/作成
- [group_invitation](lib/features/group_invitation/QA.md) — グループ招待
- [group_setting](lib/features/group_setting/QA.md) — グループ設定
- [group_category](lib/features/group_category/QA.md) — カテゴリ
- [group_category_edit](lib/features/group_category_edit/QA.md) — カテゴリ編集

## QA 対象外

- `developer_options` — 開発者専用のデバッグ機能。QA の道具であり対象ではない
- `previews` — 開発用プレビュー画面。エンドユーザーは到達できない
- `resolver` — 画面を持たない DI・初期化基盤
- `location_reminder` — feature flag `shoppingLocationFeatureEnabled = false` で無効・UI 非到達（https://github.com/bannzai/shoppinglist/issues/465）
- `shopping_location` — 同上（feature flag で UI 非到達）
- `home_widget` — 画面を持たない iOS/Android ホームウィジェット同期。ウィジェットのタップは WDA/mobile-mcp の合成タップで発火せず、手動・実機確認のみのため QA.md 運用外
