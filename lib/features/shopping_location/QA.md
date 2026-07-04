---
feature: shopping_location
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# shopping_location QA

> 現行リリースでは `lib/utils/config/feature_flags.dart` の `shoppingLocationFeatureEnabled` が
> false（issue #465）のため、この画面はグループ設定画面の「買い物する場所」セルから通常は
> 到達できない。テストする場合はフラグを一時的にtrueにしてビルドし直す必要がある
> （本番相当ビルドでは QA 対象外）。関連 maestro flow は `maestro/flows/` 直下ではなく
> `maestro/flows/disabled_shopping_location/` に退避されている。

## 1. 場所一覧表示

- [ ] **場所一覧の表示**: 登録済みの買い物する場所が一覧表示され、位置情報設定済みの場所には地図ピンアイコンと「位置情報設定済み」ラベルが付く
- [ ] **空状態の表示**: 登録場所が0件の場合「買い物する場所がまだありません」と表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **場所一覧の表示**: 登録済みの買い物する場所が一覧表示され、位置情報設定済みの場所には地図ピンアイコンと「位置情報設定済み」ラベルが付く

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **空状態の表示**: 登録場所が0件の場合「買い物する場所がまだありません」と表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. 場所の追加

- [ ] **名前のみで場所を追加（無料機能）**: FAB→「場所を追加」ダイアログで名前のみ入力し「追加」すると場所が一覧に追加される。maestro/flows/disabled_shopping_location/category_location_order.yaml で確認できる（要 feature flag 有効化）
- [ ] **名前未入力では追加できない**: 名前が空文字のまま「追加」をタップしても場所は追加されない
- [ ] **地図で位置設定は非プレミアムでロック**: 非プレミアムユーザーが「地図で場所を設定」をタップすると鍵アイコンが表示され、「位置情報リマインダーはプレミアム機能です」のトースト＋「アップグレード」導線からペイウォールが開ける
- [ ] **地図で位置設定（プレミアム）**: プレミアムユーザーが「地図で場所を設定」をタップするとLocationPickerPageに遷移し、位置確定後に住所と緯度経度がダイアログに反映される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **名前のみで場所を追加（無料機能）**: FAB→「場所を追加」ダイアログで名前のみ入力し「追加」すると場所が一覧に追加される。maestro/flows/disabled_shopping_location/category_location_order.yaml で確認できる（要 feature flag 有効化）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **名前未入力では追加できない**: 名前が空文字のまま「追加」をタップしても場所は追加されない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **地図で位置設定は非プレミアムでロック**: 非プレミアムユーザーが「地図で場所を設定」をタップすると鍵アイコンが表示され、「位置情報リマインダーはプレミアム機能です」のトースト＋「アップグレード」導線からペイウォールが開ける

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **地図で位置設定（プレミアム）**: プレミアムユーザーが「地図で場所を設定」をタップするとLocationPickerPageに遷移し、位置確定後に住所と緯度経度がダイアログに反映される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. 場所の編集・削除

- [ ] **場所名の編集**: 編集アイコン→名前を変更して「保存」すると一覧に反映される
- [ ] **場所の削除**: 削除アイコン→確認ダイアログ「削除」で場所が一覧から消える。ダイアログに「この場所を削除しても、この場所が設定されている買い物リストには影響しません」の案内が表示される
- [ ] **削除確認ダイアログのキャンセル**: 「キャンセル」で場所は削除されない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **場所名の編集**: 編集アイコン→名前を変更して「保存」すると一覧に反映される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **場所の削除**: 削除アイコン→確認ダイアログ「削除」で場所が一覧から消える。ダイアログに「この場所を削除しても、この場所が設定されている買い物リストには影響しません」の案内が表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **削除確認ダイアログのキャンセル**: 「キャンセル」で場所は削除されない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. LocationPickerPage（地図選択）

- [ ] **地図の初期表示**: 既存座標がない場合は現在地取得を試み、取得できない場合は東京駅をデフォルト位置として表示する。iOS Simulatorでは `xcrun simctl location <udid> set <lat>,<lng>` で位置をシミュレートし、取得成功/失敗どちらのケースも確認できる
- [ ] **地図中央固定ピンと逆ジオコーディング**: 地図をパン/ズームしても中央のピンは固定表示され、カメラ停止後（onCameraIdle）に住所テキストがカード下部に表示される
- [ ] **「この場所を設定」で確定**: ボタンタップで緯度経度・住所が呼び出し元に返り、場所追加ダイアログに反映される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **地図の初期表示**: 既存座標がない場合は現在地取得を試み、取得できない場合は東京駅をデフォルト位置として表示する。iOS Simulatorでは `xcrun simctl location <udid> set <lat>,<lng>` で位置をシミュレートし、取得成功/失敗どちらのケースも確認できる

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **地図中央固定ピンと逆ジオコーディング**: 地図をパン/ズームしても中央のピンは固定表示され、カメラ停止後（onCameraIdle）に住所テキストがカード下部に表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **「この場所を設定」で確定**: ボタンタップで緯度経度・住所が呼び出し元に返り、場所追加ダイアログに反映される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. エッジケース

- [ ] **エラー時の表示**: 場所一覧の取得に失敗した場合、エラービュー（ErrorView）が表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **エラー時の表示**: 場所一覧の取得に失敗した場合、エラービュー（ErrorView）が表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
