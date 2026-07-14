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
- E2E: /maestro-flutter（フロー新規作成は /maestro-flow-writer）。既存フローは `maestro/flows/` 配下
- UI の条件分岐検証は mobile-mcp / maestro より先に widget test（`flutter test`）で書けないか検討する

### 再現が難しい操作の手順

- オンボーディング再現: アプリ削除では不可（Keychain に認証が残存）。`clearState: true` + `clearKeychain: true`（Maestro）か、新規シミュレータ作成（sim-boot）で行う
- プレミアム状態: 課金せず開発者オプション →「プレミアム付与（1日）」（Maestro: `maestro/flows/shared/grant_premium_via_debug.yaml`）
- 別ユーザーの操作・同期: 開発者オプション →「デバッグユーザー作成」（Maestro: `maestro/flows/virtual_pairing/02_create_debug_user.yaml`）
- 一瞬で消える SnackBar の撮影: WDA スクショは静止待ちで撮り逃す。`xcrun simctl io <UDID> screenshot` を連写する
- 長押しドラッグ&ドロップ: Maestro では duration 10000ms の swipe で長押し判定が成立する

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
