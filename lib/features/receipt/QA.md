---
feature: receipt
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# receipt QA

## 1. 表示条件

- [x] **レシート導線の表示条件**: 買い物リストのアイテムを1件以上チェックすると、リスト上部（AIカテゴリ分けボタンの直上）に「レシートを追加」ボタンが出現する。チェック済みアイテムが0件の間は表示されない。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **レシート導線の表示条件**: 買い物リストのアイテムを1件以上チェックすると、リスト上部（AIカテゴリ分けボタンの直上）に「レシートを追加」ボタンが出現する。チェック済みアイテムが0件の間は表示されない。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで買い物リストのアイテム「牛乳」をチェック→「自動でカテゴリ分け」ボタン直上に「レシートを追加」ボタンが出現することを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/d186c2a1-051f-466b-bd6f-f22a70f9504d.png" width="320">

</details>

</details>

---

## 2. 新規登録（プレミアム限定機能）

- [x] **非プレミアムはPaywallへ誘導**: 非プレミアムユーザーが「レシートを追加」をタップするとPaywallが表示され、登録シートは開かない。
- [x] **プレミアムでの新規登録**: プレミアムユーザーが「レシートを追加」→写真を撮影/選択（Simulatorではフォトライブラリのみ利用可）→金額・メモを入力→保存すると、画像がアップロードされレシートが登録される。写真が未選択のままでは保存ボタンが無効化される。maestro/flows/premium_receipt_image_upload.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **非プレミアムはPaywallへ誘導**: 非プレミアムユーザーが「レシートを追加」をタップするとPaywallが表示され、登録シートは開かない。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

非プレミアム状態で「レシートを追加」をタップ→Paywallが表示され、レシート登録シート（「レシートを撮影 / 選択」ボタン等）は開かないことを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/6716b7da-e4ff-4a8f-ad5d-5112781438e1.png" width="320">

</details>

### **プレミアムでの新規登録**: プレミアムユーザーが「レシートを追加」→写真を撮影/選択（Simulatorではフォトライブラリのみ利用可）→金額・メモを入力→保存すると、画像がアップロードされレシートが登録される。写真が未選択のままでは保存ボタンが無効化される。maestro/flows/premium_receipt_image_upload.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

開発者オプションの「プレミアム付与（1日）」でプレミアムを付与→「レシートを追加」タップ→写真未選択時は保存ボタンが無効化されていることを確認→フォトライブラリから写真選択で保存ボタンが活性化→金額¥1980・メモ入力→保存でレシートが登録され、ボタンラベルが「レシートを編集」に変わることを確認。

なお `maestro/flows/premium_receipt_image_upload.yaml` は `appId` が `${APP_ID}` ではなく `com.bannzai.shoppinglist`（prod bundle）にハードコードされており、dev環境で実行すると prod ビルドを起動してしまうため、本セッションでは実行せず mobile-mcp で代替検証した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/f2f74c87-b8a5-4341-8582-1a65fbd81101.png" width="320">

</details>

</details>

---

## 3. 編集

- [x] **登録済みレシートの編集**: レシートが1件でもあるとボタンラベルが「レシートを編集」に変わり、タップすると既存の画像・金額・メモが表示された編集シートが開く。画像を選択し直すと既存画像が差し替えられ、未選択なら既存画像のまま金額・メモだけ保存できる。
- [x] **レシート画像の表示**: 編集シートのプレビューにStorageから取得したレシート画像が表示される（取得に失敗した場合は破損画像アイコンにフォールバックする）。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **登録済みレシートの編集**: レシートが1件でもあるとボタンラベルが「レシートを編集」に変わり、タップすると既存の画像・金額・メモが表示された編集シートが開く。画像を選択し直すと既存画像が差し替えられ、未選択なら既存画像のまま金額・メモだけ保存できる。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

登録済みレシートがある状態で「レシートを編集」をタップ→既存の画像・金額（¥1980）・メモが表示された編集シートが開くことを確認。まず画像を変更せず金額を¥2500・メモを「QAテスト用レシート（編集済み）」に変更して保存→再度開いて画像はそのまま、金額・メモのみ更新されていることを確認。続けて画像編集アイコンから別の写真（滝の写真）を選択し直して保存→再度開いて画像が新しい写真に差し替わっていることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/571847ad-e0e9-4f2b-b547-7f172687b5e4.png" width="320">

</details>

### **レシート画像の表示**: 編集シートのプレビューにStorageから取得したレシート画像が表示される（取得に失敗した場合は破損画像アイコンにフォールバックする）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

画像差し替え→保存→編集シートを再度開くたびに、Firebase Storageの`getDownloadURL`経由で最新の画像（アップロード直後の花の写真、差し替え後は滝の写真）が正しくプレビュー表示されることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/18650d64-9710-4103-8e3c-67c85ccaa80b.png" width="320">

</details>

</details>

---

## 4. エッジケース

- [x] **削除機能が無いこと**: レシート編集シートには削除ボタンが存在せず、登録・編集のみ可能であることを確認する（`firestore.rules` でも create/update のみ許可）。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **削除機能が無いこと**: レシート編集シートには削除ボタンが存在せず、登録・編集のみ可能であることを確認する（`firestore.rules` でも create/update のみ許可）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

編集シートのアクセシビリティ要素一覧を確認したところ、Dismiss（ドラッグハンドル）・金額/メモ TextField・保存ボタンのみで削除に相当するボタンは存在しないことを確認。`firebase/firestore.rules` の `receipts/{receiptID}` も `allow read, create, update` のみで `delete` は許可されていない。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/18650d64-9710-4103-8e3c-67c85ccaa80b.png" width="320">

</details>

</details>

---
