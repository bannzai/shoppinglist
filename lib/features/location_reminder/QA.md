---
feature: location_reminder
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# location_reminder QA

> 現行リリースでは `lib/utils/config/feature_flags.dart` の `shoppingLocationFeatureEnabled` が
> false（issue #465）のため、設定画面のトグル自体が表示されない。テストする場合はフラグを
> 一時的にtrueにしてビルドし直す必要がある（本番相当ビルドでは QA 対象外）。トグルUI実体は
> `lib/features/settings/components/location_reminder_toggle.dart` にある。関連 maestro flow は
> `maestro/flows/` 直下ではなく `maestro/flows/disabled_shopping_location/` に退避されている。

## 1. 設定画面のトグル表示

- [ ] **トグル表示**: 設定画面に「位置情報リマインダー」トグルが「店舗の近くに来たら買い物リストを通知」の説明文とともに表示される（feature flag有効時のみ）。maestro/flows/disabled_shopping_location/location_reminder_non_premium.yaml で確認できる（要 flag 有効化）
- [ ] **非プレミアムはロック表示・操作ブロック**: 非プレミアム時はアイコンがグレー表示され、トグルをタップしてもONにならずSnackBar「位置情報リマインダーはプレミアム機能です」＋「アップグレード」ボタンが表示される。maestro/flows/disabled_shopping_location/location_reminder_non_premium.yaml で確認できる

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **トグル表示**: 設定画面に「位置情報リマインダー」トグルが「店舗の近くに来たら買い物リストを通知」の説明文とともに表示される（feature flag有効時のみ）。maestro/flows/disabled_shopping_location/location_reminder_non_premium.yaml で確認できる（要 flag 有効化）

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: `lib/utils/config/feature_flags.dart` の `shoppingLocationFeatureEnabled` が現行リリースで `false` のため、設定画面にトグル自体が表示されない（2026-07-05 時点で `lib/features/settings/page.dart` 経由の実機確認でも該当UIなしを確認済み。項目9参照）。本項目を動作確認するにはフラグを一時的に `true` に変更してビルドし直す必要があるが、本 QA.md 冒頭の注記の通り「本番相当ビルドでは QA 対象外」と明記されている。加えて本セッションは worktree ではなく共有のメイン作業ディレクトリ・共有シミュレータ上で実行しており、フラグ変更を伴う再ビルドは同時実行中の他 feature QA に影響しうるため実施しなかった。フラグ有効化ビルドでの検証は、他の QA バッチと競合しないタイミングで別 worktree にて単独実施することを推奨する。

</details>

### **非プレミアムはロック表示・操作ブロック**: 非プレミアム時はアイコンがグレー表示され、トグルをタップしてもONにならずSnackBar「位置情報リマインダーはプレミアム機能です」＋「アップグレード」ボタンが表示される。maestro/flows/disabled_shopping_location/location_reminder_non_premium.yaml で確認できる

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 項目1と同じ理由（feature flag無効によりトグルUI自体が非表示）。フラグ有効化ビルドが必要なため本セッションでは未実施。

</details>

</details>

---

## 2. 有効化フロー（プレミアム）

- [ ] **権限リクエスト**: プレミアムユーザーがトグルをONにすると、Androidでは通知権限、共通で位置情報の「常に許可」権限をリクエストする
- [ ] **権限拒否時の案内**: 通知権限が拒否された場合「通知権限を許可すると利用できます」、バックグラウンド位置情報が「常に許可」にならない場合「バックグラウンドの位置情報を「常に許可」にすると利用できます」とSnackBarで案内され、トグルはONにならない
- [ ] **権限許可後にトグルON**: 全ての権限が許可されるとトグルがONになり保存される（`locationReminderEnabled`）。maestro/flows/disabled_shopping_location/premium_location_reminder.yaml で確認できる（要 flag 有効化）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **権限リクエスト**: プレミアムユーザーがトグルをONにすると、Androidでは通知権限、共通で位置情報の「常に許可」権限をリクエストする

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: feature flag無効によりトグルUI自体が表示されず、ONにする操作起点が存在しない。フラグ有効化ビルドが必要なため本セッションでは未実施（詳細理由は「1. 設定画面のトグル表示」項目参照）。

</details>

### **権限拒否時の案内**: 通知権限が拒否された場合「通知権限を許可すると利用できます」、バックグラウンド位置情報が「常に許可」にならない場合「バックグラウンドの位置情報を「常に許可」にすると利用できます」とSnackBarで案内され、トグルはONにならない

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 同上（トグルUI非表示のため権限リクエストフロー自体に到達できない）。

</details>

### **権限許可後にトグルON**: 全ての権限が許可されるとトグルがONになり保存される（`locationReminderEnabled`）。maestro/flows/disabled_shopping_location/premium_location_reminder.yaml で確認できる（要 flag 有効化）

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 同上。

</details>

</details>

---

## 3. ジオフェンス監視・通知

- [ ] **監視開始条件**: プレミアムかつトグルON、かつ所属グループに緯度経度設定済みの場所がある場合のみ監視が開始される（`geofenceMonitoringPlan`）
- [ ] **ジオフェンス進入時の通知**: 登録店舗の半径内（デフォルト半径）に入るとローカル通知「「店舗名」の近くにいます / 買い物リストを確認しましょう」が発行される。実位置情報での再現は困難なため、`xcrun simctl location <udid> set <lat>,<lng>` でSimulatorの位置を店舗座標に一致させて確認する
- [ ] **通知の重複防止（ヒステリシス）**: 一度通知した店舗は、半径の2倍以上離れるまで再通知されない。simctlで店舗座標→遠方→再度店舗座標、と位置を往復させて確認する
- [ ] **アクティブな買い物リストがない場合は通知しない**: 該当店舗に紐づくアクティブな買い物リストが無い場合は、ジオフェンス条件を満たしても通知が発行されない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **監視開始条件**: プレミアムかつトグルON、かつ所属グループに緯度経度設定済みの場所がある場合のみ監視が開始される（`geofenceMonitoringPlan`）

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: `lib/app.dart:36` を確認したところ、`geofenceMonitoringPlanProvider` を購読して監視サービスを起動する `ref.listenManual` 自体が `if (shoppingLocationFeatureEnabled)` で丸ごとガードされている。つまり現行ビルドでは SharedPreferences の `locationReminderEnabled` やグループの位置情報データの状態に関わらず、監視の配線自体が一切発生しない。フラグ有効化ビルドが必須のため本セッションでは未実施（フラグ変更の可否についての判断は「1. 設定画面のトグル表示」項目参照）。

</details>

### **ジオフェンス進入時の通知**: 登録店舗の半径内（デフォルト半径）に入るとローカル通知「「店舗名」の近くにいます / 買い物リストを確認しましょう」が発行される。実位置情報での再現は困難なため、`xcrun simctl location <udid> set <lat>,<lng>` でSimulatorの位置を店舗座標に一致させて確認する

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 同上（監視配線自体が現行ビルドで無効）に加え、バックグラウンドでの確実なジオフェンス検知には `ios/Runner/Info.plist` の `UIBackgroundModes: location` と Android の位置情報系4パーミッションの復元が必要（issue #465 対応でこれらは意図的に外されている）。フラグ有効化のみでは不十分なため本セッションでは未実施。

</details>

### **通知の重複防止（ヒステリシス）**: 一度通知した店舗は、半径の2倍以上離れるまで再通知されない。simctlで店舗座標→遠方→再度店舗座標、と位置を往復させて確認する

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 同上（監視配線自体が現行ビルドで無効なため、通知の重複防止ロジックも到達不能）。

</details>

### **アクティブな買い物リストがない場合は通知しない**: 該当店舗に紐づくアクティブな買い物リストが無い場合は、ジオフェンス条件を満たしても通知が発行されない

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 同上。

</details>

</details>

---

## 4. エッジケース

- [ ] **緯度経度未設定の場所は監視対象外**: 場所に緯度経度が設定されていない場合、その場所はジオフェンス監視対象から除外される
- [x] **機能フラグ無効時は非表示**: `shoppingLocationFeatureEnabled` がfalseの現行リリースでは、設定画面にトグル自体が表示されない（issue #465）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **緯度経度未設定の場所は監視対象外**: 場所に緯度経度が設定されていない場合、その場所はジオフェンス監視対象から除外される

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: `lib/provider/geofence.dart:84` にフィルタ実装（`.where((l) => l.latitude != null && l.longitude != null)`）自体は存在することをコードリーディングで確認したが、これをアプリ実機で挙動として動作確認するには監視配線（`lib/app.dart:36` の `shoppingLocationFeatureEnabled` ガード）が有効である必要があり、現行ビルドでは到達不能。フラグ有効化ビルドが必須のため本セッションでは未実施。

</details>

### **機能フラグ無効時は非表示**: `shoppingLocationFeatureEnabled` がfalseの現行リリースでは、設定画面にトグル自体が表示されない（issue #465）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

シミュレータ「shoppinglist-無名-iOS26.5」（UDID C183FCDA-9A46-41E5-8DD7-C798EB89FE08、HEAD 2d72174 ビルド）でアプリを起動し、設定画面（プロフィール／グループ／外観／プレミアムにアップグレード／アプリについて）を確認したところ、位置情報リマインダーに関するトグル・セクションは一切表示されないことを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/65abb345-8170-43ef-b60c-4e0cf7ecf9b0.png" width="320">

</details>

</details>
