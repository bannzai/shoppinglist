---
feature: inquiry
verification: mobile-mcp
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-15
---

# inquiry QA

お問い合わせフォーム（`lib/features/inquiry/page.dart`）。設定画面の「お問い合わせ」から遷移する。メールアドレス・種類・内容を入力して送信すると `functions.submitInquiry` 経由で Firebase Functions が Firestore 保存と Slack 通知を行う。プラットフォームとアプリバージョンは送信時に自動付与される。専用の maestro flow は無いが、フォーム構成とボタン活性はウィジェットテスト `test/features/inquiry/page_test.dart` でカバーされている。

## 1. フォーム表示

- [x] **説明文と入力欄が表示される**: 冒頭に「いただいた内容は開発の参考に…」の説明文、メールアドレス入力欄、内容入力欄（複数行）、送信ボタン（AppPill）が表示される（既存 widget test: test/features/inquiry/page_test.dart）
- [x] **お問い合わせの種類が 4 つ表示される**: 「不具合報告」「操作方法について」「ご要望・改善要望」「その他」のチップが表示される（`InquiryCategory` の全要素、既存 widget test: test/features/inquiry/page_test.dart）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **説明文と入力欄が表示される**: 冒頭に「いただいた内容は開発の参考に…」の説明文、メールアドレス入力欄、内容入力欄（複数行）、送信ボタン（AppPill）が表示される（既存 widget test: test/features/inquiry/page_test.dart）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/ba0636a7-4152-4e4b-8127-23ccaa003235.png" width="320">

設定画面の「お問い合わせ」から遷移。説明文・メールアドレス入力欄・お問い合わせ内容入力欄（複数行）・「送信する」ボタンが表示されている。

</details>

### **お問い合わせの種類が 4 つ表示される**: 「不具合報告」「操作方法について」「ご要望・改善要望」「その他」のチップが表示される（`InquiryCategory` の全要素、既存 widget test: test/features/inquiry/page_test.dart）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/ba0636a7-4152-4e4b-8127-23ccaa003235.png" width="320">

「不具合報告」「操作方法について」「ご要望・改善要望」「その他」の4チップが表示されている。

</details>

</details>

---

## 2. カテゴリ選択

- [x] **チップタップで単一選択できる**: 種類チップをタップすると選択状態（accent 枠・accentSoft 背景・太字）になり、別のチップをタップすると選択が移る（単一選択）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **チップタップで単一選択できる**: 種類チップをタップすると選択状態（accent 枠・accentSoft 背景・太字）になり、別のチップをタップすると選択が移る（単一選択）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/ddfaee79-d2f0-41af-bf69-aa6a50e75425.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/272f76f8-19a6-48c0-a130-4da55b07d387.png" width="320">

「不具合報告」タップで選択状態（accent枠・太字）になった後、「その他」をタップすると「不具合報告」の選択が解除され「その他」のみ選択状態になった（単一選択を確認）。

</details>

</details>

---

## 3. 送信ボタンの活性制御

- [x] **必須 3 項目が未入力の間は送信ボタンが無効**: メールアドレス・種類・内容のいずれかが未入力の間は送信ボタンが無効（onPressed=null）になる（既存 widget test: test/features/inquiry/page_test.dart）
- [x] **3 項目が揃うと送信ボタンが有効になる**: メール・内容・種類がすべて入力されると送信ボタンが有効になる（既存 widget test: test/features/inquiry/page_test.dart）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **必須 3 項目が未入力の間は送信ボタンが無効**: メールアドレス・種類・内容のいずれかが未入力の間は送信ボタンが無効（onPressed=null）になる（既存 widget test: test/features/inquiry/page_test.dart）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/356915a8-f842-49f7-83a1-7095a9da8792.png" width="320">

メール・種類・内容すべて未入力の状態で「送信する」ボタンが半透明（opacity 0.5、AppPillのdisabled表示）になっている。

</details>

### **3 項目が揃うと送信ボタンが有効になる**: メール・内容・種類がすべて入力されると送信ボタンが有効になる（既存 widget test: test/features/inquiry/page_test.dart）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/b3a60939-2621-4b38-804a-bfadd1835d05.png" width="320">

メールアドレス・種類（不具合報告）・内容をすべて入力すると「送信する」ボタンが不透明（opacity 1、活性状態）に変化した。

</details>

</details>

---

## 4. バリデーション

- [x] **メールアドレスの形式不正はエラー表示する**: メール・種類・内容が揃って送信ボタンが有効な状態でも、メールの形式が不正な場合は送信せず「メールアドレスの形式が正しくありません」を表示する
  - なお「メールアドレスを入力してください」「お問い合わせの種類を選択してください」「お問い合わせ内容を入力してください」の各メッセージは submit 内の防御的チェックだが、送信ボタンの活性条件（3 項目必須）で先に遮断されるため通常の操作では到達しない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **メールアドレスの形式不正はエラー表示する**: メール・種類・内容が揃って送信ボタンが有効な状態でも、メールの形式が不正な場合は送信せず「メールアドレスの形式が正しくありません」を表示する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/65bb2d0f-4947-44eb-ac49-7965d1f06f6e.png" width="320">

メールアドレスを `qa-test@example.com@@invalid`（種類・内容は入力済み、送信ボタンは活性）にして「送信する」をタップすると、送信されずにフォーム内エラー枠へ「メールアドレスの形式が正しくありません」が表示された。

</details>

</details>

---

## 5. 送信

- [x] **送信成功でトーストを出して画面を閉じる**: 「送信する」タップで `functions.submitInquiry`（email / categoryType / content / platform / appVersion）を呼び、成功するとグローバルトースト「お問い合わせを送信しました」を表示して画面を閉じる（トーストは画面を閉じた後も見える OverlayEntry 方式）
- [x] **送信中はボタン表示が「送信中...」になる**: 送信処理中はボタンラベルが「送信中...」になり、二重送信を防ぐため無効化される
- [x] **送信失敗時はエラーをそのまま表示する**: 送信が失敗した場合、例外メッセージ（`e.toString()`）を加工せずフォーム内のエラー枠に表示する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **送信成功でトーストを出して画面を閉じる**: 「送信する」タップで `functions.submitInquiry`（email / categoryType / content / platform / appVersion）を呼び、成功するとグローバルトースト「お問い合わせを送信しました」を表示して画面を閉じる（トーストは画面を閉じた後も見える OverlayEntry 方式）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/e7956c38-1cd1-4c86-a3b6-873c79e80ec2.png" width="320">

dev 環境（flutter run、`submitInquiry` はデプロイ済み）で、メール `qa-inquiry-test@example.com`・種類「不具合報告」・内容を入力して「送信する」をタップ。`flutter log` に `submitInquiry.result: {result: OK, data: {inquiryID: yUpLNoRNsODgjfKLo6MD}}` が出力され送信成功。画面が閉じて設定画面へ戻り、グローバルトースト「お問い合わせを送信しました」が画面下部に表示された（トーストは画面クローズ後も見える OverlayEntry 方式）。

</details>

### **送信中はボタン表示が「送信中...」になる**: 送信処理中はボタンラベルが「送信中...」になり、二重送信を防ぐため無効化される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/740bc6e8-9f3d-4d43-a2b1-2b7a04d10cd6.png" width="320">

送信タップ直後に `xcrun simctl io <UDID> screenshot` を `;` 区切りで連写（1枚あたり約 300ms で自然に間隔が空く）し、送信処理中の状態を捕捉。送信ボタンのラベルが「送信する」から「送信中...」に変わり、ボタンが半透明（AppPill の disabled 表示、`onPressed=null`）になっている＝二重送信防止のため無効化されている。

</details>

### **送信失敗時はエラーをそのまま表示する**: 送信が失敗した場合、例外メッセージ（`e.toString()`）を加工せずフォーム内のエラー枠に表示する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/0726584e-e38d-4c2a-b2b3-c1a8cde1ba5d.png" width="320">

サーバー側 `submitInquiry` の inputSchema `content: z.string().max(5000)` を超える 5011 文字（`あ` の繰り返し）を内容に貼り付けて送信し、失敗を誘発。Functions が入力検証で拒否し、クライアントの `catch (e)` が `errorMessage.value = e.toString()` を設定。フォーム内の danger 枠に例外メッセージ `[firebase_functions/internal] INTERNAL` とスタックトレース（`#0 CloudFunctionsHostApi.call (package:cloud_functions_platform_interface/...`）が加工されずそのまま表示された。

再現手順（長文入力）: `xcrun simctl pbcopy <UDID> < 5000字超のテキストファイル` でシミュレータのクリップボードへコピー → 内容欄をタップしてフォーカス → 長押しで表示される「Paste」をタップして貼り付け。

</details>

</details>
