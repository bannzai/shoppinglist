---
feature: location_reminder
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
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

</details>

### **非プレミアムはロック表示・操作ブロック**: 非プレミアム時はアイコンがグレー表示され、トグルをタップしてもONにならずSnackBar「位置情報リマインダーはプレミアム機能です」＋「アップグレード」ボタンが表示される。maestro/flows/disabled_shopping_location/location_reminder_non_premium.yaml で確認できる

<details><summary>動作確認スクショ</summary>

（未実行）

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

</details>

### **権限拒否時の案内**: 通知権限が拒否された場合「通知権限を許可すると利用できます」、バックグラウンド位置情報が「常に許可」にならない場合「バックグラウンドの位置情報を「常に許可」にすると利用できます」とSnackBarで案内され、トグルはONにならない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **権限許可後にトグルON**: 全ての権限が許可されるとトグルがONになり保存される（`locationReminderEnabled`）。maestro/flows/disabled_shopping_location/premium_location_reminder.yaml で確認できる（要 flag 有効化）

<details><summary>動作確認スクショ</summary>

（未実行）

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

</details>

### **ジオフェンス進入時の通知**: 登録店舗の半径内（デフォルト半径）に入るとローカル通知「「店舗名」の近くにいます / 買い物リストを確認しましょう」が発行される。実位置情報での再現は困難なため、`xcrun simctl location <udid> set <lat>,<lng>` でSimulatorの位置を店舗座標に一致させて確認する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **通知の重複防止（ヒステリシス）**: 一度通知した店舗は、半径の2倍以上離れるまで再通知されない。simctlで店舗座標→遠方→再度店舗座標、と位置を往復させて確認する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **アクティブな買い物リストがない場合は通知しない**: 該当店舗に紐づくアクティブな買い物リストが無い場合は、ジオフェンス条件を満たしても通知が発行されない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. エッジケース

- [ ] **緯度経度未設定の場所は監視対象外**: 場所に緯度経度が設定されていない場合、その場所はジオフェンス監視対象から除外される
- [ ] **機能フラグ無効時は非表示**: `shoppingLocationFeatureEnabled` がfalseの現行リリースでは、設定画面にトグル自体が表示されない（issue #465）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **緯度経度未設定の場所は監視対象外**: 場所に緯度経度が設定されていない場合、その場所はジオフェンス監視対象から除外される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **機能フラグ無効時は非表示**: `shoppingLocationFeatureEnabled` がfalseの現行リリースでは、設定画面にトグル自体が表示されない（issue #465）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
