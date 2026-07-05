---
feature: shopping_location
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# shopping_location QA

> 現行リリースでは `lib/utils/config/feature_flags.dart` の `shoppingLocationFeatureEnabled` が
> false（issue #465）のため、この画面はグループ設定画面の「買い物する場所」セルから通常は
> 到達できない。テストする場合はフラグを一時的にtrueにしてビルドし直す必要がある
> （本番相当ビルドでは QA 対象外）。関連 maestro flow は `maestro/flows/` 直下ではなく
> `maestro/flows/disabled_shopping_location/` に退避されている。

## 1. 場所一覧表示

- [x] **場所一覧の表示**: 登録済みの買い物する場所が一覧表示され、位置情報設定済みの場所には地図ピンアイコンと「位置情報設定済み」ラベルが付く
- [x] **空状態の表示**: 登録場所が0件の場合「買い物する場所がまだありません」と表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **場所一覧の表示**: 登録済みの買い物する場所が一覧表示され、位置情報設定済みの場所には地図ピンアイコンと「位置情報設定済み」ラベルが付く

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcp で feature flag 有効化ビルドを操作。「駅前スーパー」を地図で位置設定して追加した結果、一覧で地図ピンアイコン＋「位置情報設定済み」ラベルが表示されることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/96f4ba12-4223-4e75-9d21-97a58a3d3789.png" width="320">

</details>

### **空状態の表示**: 登録場所が0件の場合「買い物する場所がまだありません」と表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

ShoppingLocationPage を開いた直後（場所未登録状態）の表示。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/eb647f39-1f3a-4bdd-b3e7-f286285adc21.png" width="320">

</details>

</details>

---

## 2. 場所の追加

- [x] **名前のみで場所を追加（無料機能）**: FAB→「場所を追加」ダイアログで名前のみ入力し「追加」すると場所が一覧に追加される。maestro/flows/disabled_shopping_location/category_location_order.yaml で確認できる（要 feature flag 有効化）
- [x] **名前未入力では追加できない**: 名前が空文字のまま「追加」をタップしても場所は追加されない
- [ ] **地図で位置設定は非プレミアムでロック**: 非プレミアムユーザーが「地図で場所を設定」をタップすると鍵アイコンが表示され、「位置情報リマインダーはプレミアム機能です」のトースト＋「アップグレード」導線からペイウォールが開ける
- [x] **地図で位置設定（プレミアム）**: プレミアムユーザーが「地図で場所を設定」をタップするとLocationPickerPageに遷移し、位置確定後に住所と緯度経度がダイアログに反映される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **名前のみで場所を追加（無料機能）**: FAB→「場所を追加」ダイアログで名前のみ入力し「追加」すると場所が一覧に追加される。maestro/flows/disabled_shopping_location/category_location_order.yaml で確認できる（要 feature flag 有効化）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcp で「コンビニ」を名前のみ入力して追加。地図ピンなしの店舗アイコンで一覧に追加されることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/5c3fdfdc-c731-4a09-bc5a-2aba575ddb21.png" width="320">

</details>

### **名前未入力では追加できない**: 名前が空文字のまま「追加」をタップしても場所は追加されない

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

名前を空欄のまま「追加」をタップしてもダイアログが閉じず、場所が追加されないことを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/ae974fcc-9d87-4200-8168-bed2e21e253d.png" width="320">

</details>

### **地図で位置設定は非プレミアムでロック**: 非プレミアムユーザーが「地図で場所を設定」をタップすると鍵アイコンが表示され、「位置情報リマインダーはプレミアム機能です」のトースト＋「アップグレード」導線からペイウォールが開ける

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 検証用シミュレータの匿名ユーザーが直前の QA セッションで「プレミアム付与（1日）」済みで、開発者オプションの「プレミアム剥奪」を実行してもクライアント側の Premium 判定が非プレミアムに戻らなかった（Cloud Function は成功応答を返すが `customerInfoProvider` が Premium のまま。フルアプリ再起動後も同様）。この場では非プレミアムの状態を再現できず本項目は未検証。デバッグ機能側の不具合として issue #474 を起票した: https://github.com/bannzai/shoppinglist/issues/474

</details>

### **地図で位置設定（プレミアム）**: プレミアムユーザーが「地図で場所を設定」をタップするとLocationPickerPageに遷移し、位置確定後に住所と緯度経度がダイアログに反映される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

プレミアムユーザー（開発者オプションで付与済み）が「地図で場所を設定」をタップするとLocationPickerPageに遷移し（鍵アイコンなし）、位置確定後にダイアログへ「位置設定済み」＋住所が反映されることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/83dfca81-0911-4680-b425-eaed741f4883.png" width="320">

</details>

</details>

---

## 3. 場所の編集・削除

- [x] **場所名の編集**: 編集アイコン→名前を変更して「保存」すると一覧に反映される
- [x] **場所の削除**: 削除アイコン→確認ダイアログ「削除」で場所が一覧から消える。ダイアログに「この場所を削除しても、この場所が設定されている買い物リストには影響しません」の案内が表示される
- [x] **削除確認ダイアログのキャンセル**: 「キャンセル」で場所は削除されない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **場所名の編集**: 編集アイコン→名前を変更して「保存」すると一覧に反映される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

「コンビニ」を編集アイコン→Select All→「薬局」に変更して保存し、一覧に反映されることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/6c5ea665-3674-4e6b-b84f-dd88f760188d.png" width="320">

</details>

### **場所の削除**: 削除アイコン→確認ダイアログ「削除」で場所が一覧から消える。ダイアログに「この場所を削除しても、この場所が設定されている買い物リストには影響しません」の案内が表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

「薬局」を削除アイコン→確認ダイアログ（「この場所を削除しても、この場所が設定されている買い物リストには影響しません」の案内込み）で「削除」をタップし、一覧から消えることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/25c57999-ff6b-4615-8af4-e3f945f3ed2d.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/b0bfeabf-4609-41d3-a713-f9106f3876de.png" width="320">

</details>

### **削除確認ダイアログのキャンセル**: 「キャンセル」で場所は削除されない

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

削除確認ダイアログ（案内文言込み）で「キャンセル」をタップし、場所が一覧に残ることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/90cab2d5-6c2d-48f2-acf5-01960a1accbd.png" width="320">

</details>

</details>

---

## 4. LocationPickerPage（地図選択）

- [x] **地図の初期表示**: 既存座標がない場合は現在地取得を試み、取得できない場合は東京駅をデフォルト位置として表示する。iOS Simulatorでは `xcrun simctl location <udid> set <lat>,<lng>` で位置をシミュレートし、取得成功/失敗どちらのケースも確認できる
- [x] **地図中央固定ピンと逆ジオコーディング**: 地図をパン/ズームしても中央のピンは固定表示され、カメラ停止後（onCameraIdle）に住所テキストがカード下部に表示される
- [x] **「この場所を設定」で確定**: ボタンタップで緯度経度・住所が呼び出し元に返り、場所追加ダイアログに反映される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **地図の初期表示**: 既存座標がない場合は現在地取得を試み、取得できない場合は東京駅をデフォルト位置として表示する。iOS Simulatorでは `xcrun simctl location <udid> set <lat>,<lng>` で位置をシミュレートし、取得成功/失敗どちらのケースも確認できる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

LocationPickerPage を開いた直後、シミュレータの位置情報（現在地）を基準に地図中央にピンが表示され、逆ジオコードされた住所（東京都新宿区西新宿）がカード下部に表示されることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/069eb50b-5760-4118-a96e-66e4ccc96787.png" width="320">

</details>

### **地図中央固定ピンと逆ジオコーディング**: 地図をパン/ズームしても中央のピンは固定表示され、カメラ停止後（onCameraIdle）に住所テキストがカード下部に表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

地図を上方向にパンし、ピンが画面中央に固定表示されたまま、住所表示が「東京都渋谷区代々木」に更新されることを確認（onCameraIdle での逆ジオコーディング再実行）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/154b202e-7b8a-4552-bff7-a137c6370347.png" width="320">

</details>

### **「この場所を設定」で確定**: ボタンタップで緯度経度・住所が呼び出し元に返り、場所追加ダイアログに反映される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

「この場所を設定」タップ後、場所追加ダイアログに戻り「位置設定済み」チェックマークと住所テキストが反映されることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/83dfca81-0911-4680-b425-eaed741f4883.png" width="320">

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

⏭️ スキップ: `shoppingLocationsProvider` を意図的にエラーにする開発者オプション機能が無く、dev環境のFirestoreは正常稼働中のため通常操作ではエラーを再現できない（オフラインにしてもFirestore SDKはローカルキャッシュに自動フォールバックしエラーにならない）。ロジックは静的検証で確認済み: `page.dart` の `locationsAsync.when(... error: (e, st) => ErrorView(error: e, stackTrace: st) ...)` 分岐（他機能のAsyncError分岐と同一パターン。`lib/features/group_list/QA.md` の同項目も同じ理由でスキップ済み）。

</details>

</details>
