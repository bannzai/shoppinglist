---
feature: receipt
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# receipt QA

## 1. 導線ボタンの表示条件

- [ ] **チェック済み1件以上で出現**: 買い物リストのアイテムを1件以上チェック（`checkedCount > 0`）すると、AIカテゴリ分けボタンの直上に `ReceiptAddButton`（soft トーンの全幅 pill、`receipt_long` アイコン）が現れること（既存 E2E: maestro/flows/premium_receipt_image_upload.yaml）
- [ ] **ラベルの出し分け**: レシート未登録時は「レシートを追加」、プレミアムかつ登録済み（`receipts.isNotEmpty`）時は「レシートを編集」と表示されること
- [ ] **非プレミアムの王冠アイコン**: 非プレミアムユーザーではボタン末尾に `workspace_premium`（王冠）アイコンが表示され、ラベルは常に「レシートを追加」であること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **チェック済み1件以上で出現**: 買い物リストのアイテムを1件以上チェック（`checkedCount > 0`）すると、AIカテゴリ分けボタンの直上に `ReceiptAddButton`（soft トーンの全幅 pill、`receipt_long` アイコン）が現れること（既存 E2E: maestro/flows/premium_receipt_image_upload.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **ラベルの出し分け**: レシート未登録時は「レシートを追加」、プレミアムかつ登録済み（`receipts.isNotEmpty`）時は「レシートを編集」と表示されること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **非プレミアムの王冠アイコン**: 非プレミアムユーザーではボタン末尾に `workspace_premium`（王冠）アイコンが表示され、ラベルは常に「レシートを追加」であること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. 非プレミアムゲート

- [ ] **タップで Paywall へ誘導**: 非プレミアムユーザーが「レシートを追加」をタップすると編集シートは開かず `showPaywall` でペイウォールに誘導されること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **タップで Paywall へ誘導**: 非プレミアムユーザーが「レシートを追加」をタップすると編集シートは開かず `showPaywall` でペイウォールに誘導されること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. レシート追加（新規登録）

- [ ] **編集シートの表示**: プレミアムユーザーが「レシートを追加」をタップすると編集シート（タイトル「レシートを追加」、画像フィールド・金額・メモ・保存ボタン）が開くこと（プレミアムは開発者オプション →「プレミアム付与（1日）」で付与。既存 E2E: maestro/flows/premium_receipt_image_upload.yaml）
- [ ] **写真必須と選択**: 新規は写真未選択の間は保存ボタンが非活性（`canSave == false`）で、「レシートを撮影 / 選択」→ カメラ／フォトライブラリで画像を選ぶと保存が活性化すること
- [ ] **保存でアップロード→登録**: 「保存」で `receiptID` 採番 → `uploadReceiptImage`（画像は JPEG 圧縮・最大 10MB）→ `addReceipt.call` の順に実行され、金額（数字のみ）・メモが Firestore に登録されること。保存後シートが閉じ、ボタンが「レシートを編集」に変わること（既存 E2E: maestro/flows/premium_receipt_image_upload.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **編集シートの表示**: プレミアムユーザーが「レシートを追加」をタップすると編集シート（タイトル「レシートを追加」、画像フィールド・金額・メモ・保存ボタン）が開くこと（プレミアムは開発者オプション →「プレミアム付与（1日）」で付与。既存 E2E: maestro/flows/premium_receipt_image_upload.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **写真必須と選択**: 新規は写真未選択の間は保存ボタンが非活性（`canSave == false`）で、「レシートを撮影 / 選択」→ カメラ／フォトライブラリで画像を選ぶと保存が活性化すること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **保存でアップロード→登録**: 「保存」で `receiptID` 採番 → `uploadReceiptImage`（画像は JPEG 圧縮・最大 10MB）→ `addReceipt.call` の順に実行され、金額（数字のみ）・メモが Firestore に登録されること。保存後シートが閉じ、ボタンが「レシートを編集」に変わること（既存 E2E: maestro/flows/premium_receipt_image_upload.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. レシート編集

- [ ] **既存レシートの編集**: 登録済みで「レシートを編集」をタップすると既存の画像・金額・メモが入った編集シート（タイトル「レシート」）が開くこと。編集時は画像未差し替えでも保存できる（`canSave == true`）
- [ ] **画像差し替え・メタ更新**: 画像を差し替えると同じ `receiptID` の storage パスを上書きアップロードし、`updateReceipt.call` で金額・メモが更新されること。削除機能は提供しない（登録・編集のみ）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **既存レシートの編集**: 登録済みで「レシートを編集」をタップすると既存の画像・金額・メモが入った編集シート（タイトル「レシート」）が開くこと。編集時は画像未差し替えでも保存できる（`canSave == true`）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **画像差し替え・メタ更新**: 画像を差し替えると同じ `receiptID` の storage パスを上書きアップロードし、`updateReceipt.call` で金額・メモが更新されること。削除機能は提供しない（登録・編集のみ）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. 画像表示・エラー処理

- [ ] **保存済み画像の表示**: `ReceiptImage` が `storagePath` から `getDownloadURL` で取得した URL を `CachedNetworkImage` で表示し、取得失敗時は `broken_image` アイコンを表示すること
- [ ] **保存失敗時のトースト**: 画像アップロードや登録が失敗した場合は `showGlobalErrorToast` で前面トーストにエラーがそのまま表示されること。デプロイ済み Functions の inputSchema 不一致による `[firebase_functions/internal] INTERNAL` が出ないこと（既存 E2E: maestro/flows/premium_receipt_image_upload.yaml の `assertNotVisible: .*INTERNAL.*`）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **保存済み画像の表示**: `ReceiptImage` が `storagePath` から `getDownloadURL` で取得した URL を `CachedNetworkImage` で表示し、取得失敗時は `broken_image` アイコンを表示すること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **保存失敗時のトースト**: 画像アップロードや登録が失敗した場合は `showGlobalErrorToast` で前面トーストにエラーがそのまま表示されること。デプロイ済み Functions の inputSchema 不一致による `[firebase_functions/internal] INTERNAL` が出ないこと（既存 E2E: maestro/flows/premium_receipt_image_upload.yaml の `assertNotVisible: .*INTERNAL.*`）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---
