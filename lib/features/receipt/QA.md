---
feature: receipt
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-15
---

# receipt QA

## 1. 導線ボタンの表示条件

- [x] **チェック済み1件以上で出現**: 買い物リストのアイテムを1件以上チェック（`checkedCount > 0`）すると、AIカテゴリ分けボタンの直上に `ReceiptAddButton`（soft トーンの全幅 pill、`receipt_long` アイコン）が現れること（既存 E2E: maestro/flows/premium_receipt_image_upload.yaml）
  - ⚠️ 注記: `maestro/flows/premium_receipt_image_upload.yaml` は `appId` が `${APP_ID}` ではなく `com.bannzai.shoppinglist`（prod固定）にハードコードされており、dev ビルドのみインストールされた環境では実行できない（他の全 flow は `${APP_ID}` 変数化済みで、この flow と `group_join_or_create.yaml` のみ例外）。mobile-mcp による手動操作で代替確認した
- [x] **ラベルの出し分け**: レシート未登録時は「レシートを追加」、プレミアムかつ登録済み（`receipts.isNotEmpty`）時は「レシートを編集」と表示されること
- [x] **非プレミアムの王冠アイコン**: 非プレミアムユーザーではボタン末尾に `workspace_premium`（王冠）アイコンが表示され、ラベルは常に「レシートを追加」であること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **チェック済み1件以上で出現**: 買い物リストのアイテムを1件以上チェック（`checkedCount > 0`）すると、AIカテゴリ分けボタンの直上に `ReceiptAddButton`（soft トーンの全幅 pill、`receipt_long` アイコン）が現れること（既存 E2E: maestro/flows/premium_receipt_image_upload.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/089298ee-80c0-4f53-be67-7605764f1e55.png" width="320">

</details>

### **ラベルの出し分け**: レシート未登録時は「レシートを追加」、プレミアムかつ登録済み（`receipts.isNotEmpty`）時は「レシートを編集」と表示されること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
プレミアム・未登録時「レシートを追加」:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/84389909-d379-48d3-8c0c-bf5dfb830fe8.png" width="320">

保存後（登録済み）「レシートを編集」に変化:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/9616c317-3ac5-4e41-bcd7-691510d27c35.png" width="320">

</details>

### **非プレミアムの王冠アイコン**: 非プレミアムユーザーではボタン末尾に `workspace_premium`（王冠）アイコンが表示され、ラベルは常に「レシートを追加」であること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/089298ee-80c0-4f53-be67-7605764f1e55.png" width="320">

</details>

</details>

---

## 2. 非プレミアムゲート

- [x] **タップで Paywall へ誘導**: 非プレミアムユーザーが「レシートを追加」をタップすると編集シートは開かず `showPaywall` でペイウォールに誘導されること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **タップで Paywall へ誘導**: 非プレミアムユーザーが「レシートを追加」をタップすると編集シートは開かず `showPaywall` でペイウォールに誘導されること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/adb192b1-97b2-408a-8c2b-c70f604c98e4.png" width="320">

</details>

</details>

---

## 3. レシート追加（新規登録）

- [x] **編集シートの表示**: プレミアムユーザーが「レシートを追加」をタップすると編集シート（タイトル「レシートを追加」、画像フィールド・金額・メモ・保存ボタン）が開くこと（プレミアムは開発者オプション →「プレミアム付与（1日）」で付与。既存 E2E: maestro/flows/premium_receipt_image_upload.yaml）
- [x] **写真必須と選択**: 新規は写真未選択の間は保存ボタンが非活性（`canSave == false`）で、「レシートを撮影 / 選択」→ カメラ／フォトライブラリで画像を選ぶと保存が活性化すること
- [x] **保存でアップロード→登録**: 「保存」で `receiptID` 採番 → `uploadReceiptImage`（画像は JPEG 圧縮・最大 10MB）→ `addReceipt.call` の順に実行され、金額（数字のみ）・メモが Firestore に登録されること。保存後シートが閉じ、ボタンが「レシートを編集」に変わること（既存 E2E: maestro/flows/premium_receipt_image_upload.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **編集シートの表示**: プレミアムユーザーが「レシートを追加」をタップすると編集シート（タイトル「レシートを追加」、画像フィールド・金額・メモ・保存ボタン）が開くこと（プレミアムは開発者オプション →「プレミアム付与（1日）」で付与。既存 E2E: maestro/flows/premium_receipt_image_upload.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/3518fcea-3f3f-45fe-9aa8-1199f4379420.png" width="320">

</details>

### **写真必須と選択**: 新規は写真未選択の間は保存ボタンが非活性（`canSave == false`）で、「レシートを撮影 / 選択」→ カメラ／フォトライブラリで画像を選ぶと保存が活性化すること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/3d54791e-273a-4c36-8216-1afefb21d9fb.png" width="320">

</details>

### **保存でアップロード→登録**: 「保存」で `receiptID` 採番 → `uploadReceiptImage`（画像は JPEG 圧縮・最大 10MB）→ `addReceipt.call` の順に実行され、金額（数字のみ）・メモが Firestore に登録されること。保存後シートが閉じ、ボタンが「レシートを編集」に変わること（既存 E2E: maestro/flows/premium_receipt_image_upload.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
金額「¥1980」・メモ「スーパーマート」で保存 → シートが閉じボタンが「レシートを編集」に変化:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/9616c317-3ac5-4e41-bcd7-691510d27c35.png" width="320">

</details>

</details>

---

## 4. レシート編集

- [x] **既存レシートの編集**: 登録済みで「レシートを編集」をタップすると既存の画像・金額・メモが入った編集シート（タイトル「レシート」）が開くこと。編集時は画像未差し替えでも保存できる（`canSave == true`）
- [x] **画像差し替え・メタ更新**: 画像を差し替えると同じ `receiptID` の storage パスを上書きアップロードし、`updateReceipt.call` で金額・メモが更新されること。削除機能は提供しない（登録・編集のみ）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **既存レシートの編集**: 登録済みで「レシートを編集」をタップすると既存の画像・金額・メモが入った編集シート（タイトル「レシート」）が開くこと。編集時は画像未差し替えでも保存できる（`canSave == true`）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
タイトル「レシート」、既存データ入りで保存ボタンが最初から活性化:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/09c55396-a80e-4380-a1fe-f863e1c43c8c.png" width="320">

</details>

### **画像差し替え・メタ更新**: 画像を差し替えると同じ `receiptID` の storage パスを上書きアップロードし、`updateReceipt.call` で金額・メモが更新されること。削除機能は提供しない（登録・編集のみ）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
画像を差し替え・メモに追記して保存 → 再度開くと更新後の画像・メモが反映されていることを確認:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/9cfff319-7456-4d3a-a70d-3fd39a130d28.png" width="320">

</details>

</details>

---

## 5. 画像表示・エラー処理

- [x] **保存済み画像の表示**: `ReceiptImage` が `storagePath` から `getDownloadURL` で取得した URL を `CachedNetworkImage` で表示し、取得失敗時は `broken_image` アイコンを表示すること
  - ⏭️ スキップ（`broken_image` フォールバック部分のみ）: 正常系（画像取得成功時の表示）は確認済み。取得失敗時のフォールバック表示は、意図的に `storagePath` を不正な値にする操作が UI から行えず、コード修正なしでは再現できないため未検証（`receipt_image.dart` のコードレビューでロジック自体は確認済み: `snapshot.hasError` または `path` が null/空で `broken_image` アイコンを表示する分岐がある）
- [ ] **保存失敗時のトースト**: 画像アップロードや登録が失敗した場合は `showGlobalErrorToast` で前面トーストにエラーがそのまま表示されること。デプロイ済み Functions の inputSchema 不一致による `[firebase_functions/internal] INTERNAL` が出ないこと（既存 E2E: maestro/flows/premium_receipt_image_upload.yaml の `assertNotVisible: .*INTERNAL.*`）
  - ⏭️ スキップ: 新規登録・編集（画像差し替え含む）の一連の保存操作でエラートーストは一度も表示されず、`INTERNAL` エラーも発生しなかったことを確認済み（正常系）。意図的な保存失敗（アップロード/登録エラー）の発生はネットワーク遮断やサーバー側改変が必要で、QA セッション内でのコード修正無しには再現できないため、エラートースト表示自体の検証はスキップ

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **保存済み画像の表示**: `ReceiptImage` が `storagePath` から `getDownloadURL` で取得した URL を `CachedNetworkImage` で表示し、取得失敗時は `broken_image` アイコンを表示すること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/9cfff319-7456-4d3a-a70d-3fd39a130d28.png" width="320">

</details>

### **保存失敗時のトースト**: 画像アップロードや登録が失敗した場合は `showGlobalErrorToast` で前面トーストにエラーがそのまま表示されること。デプロイ済み Functions の inputSchema 不一致による `[firebase_functions/internal] INTERNAL` が出ないこと（既存 E2E: maestro/flows/premium_receipt_image_upload.yaml の `assertNotVisible: .*INTERNAL.*`）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---
