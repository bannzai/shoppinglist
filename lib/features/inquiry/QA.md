---
feature: inquiry
verification: mobile-mcp
last_verified_commit: null
last_verified_at: null
---

# inquiry QA

お問い合わせフォーム（`lib/features/inquiry/page.dart`）。設定画面の「お問い合わせ」から遷移する。メールアドレス・種類・内容を入力して送信すると `functions.submitInquiry` 経由で Firebase Functions が Firestore 保存と Slack 通知を行う。プラットフォームとアプリバージョンは送信時に自動付与される。専用の maestro flow は無いが、フォーム構成とボタン活性はウィジェットテスト `test/features/inquiry/page_test.dart` でカバーされている。

## 1. フォーム表示

- [ ] **説明文と入力欄が表示される**: 冒頭に「いただいた内容は開発の参考に…」の説明文、メールアドレス入力欄、内容入力欄（複数行）、送信ボタン（AppPill）が表示される（既存 widget test: test/features/inquiry/page_test.dart）
- [ ] **お問い合わせの種類が 4 つ表示される**: 「不具合報告」「操作方法について」「ご要望・改善要望」「その他」のチップが表示される（`InquiryCategory` の全要素、既存 widget test: test/features/inquiry/page_test.dart）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **説明文と入力欄が表示される**: 冒頭に「いただいた内容は開発の参考に…」の説明文、メールアドレス入力欄、内容入力欄（複数行）、送信ボタン（AppPill）が表示される（既存 widget test: test/features/inquiry/page_test.dart）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **お問い合わせの種類が 4 つ表示される**: 「不具合報告」「操作方法について」「ご要望・改善要望」「その他」のチップが表示される（`InquiryCategory` の全要素、既存 widget test: test/features/inquiry/page_test.dart）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. カテゴリ選択

- [ ] **チップタップで単一選択できる**: 種類チップをタップすると選択状態（accent 枠・accentSoft 背景・太字）になり、別のチップをタップすると選択が移る（単一選択）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **チップタップで単一選択できる**: 種類チップをタップすると選択状態（accent 枠・accentSoft 背景・太字）になり、別のチップをタップすると選択が移る（単一選択）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. 送信ボタンの活性制御

- [ ] **必須 3 項目が未入力の間は送信ボタンが無効**: メールアドレス・種類・内容のいずれかが未入力の間は送信ボタンが無効（onPressed=null）になる（既存 widget test: test/features/inquiry/page_test.dart）
- [ ] **3 項目が揃うと送信ボタンが有効になる**: メール・内容・種類がすべて入力されると送信ボタンが有効になる（既存 widget test: test/features/inquiry/page_test.dart）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **必須 3 項目が未入力の間は送信ボタンが無効**: メールアドレス・種類・内容のいずれかが未入力の間は送信ボタンが無効（onPressed=null）になる（既存 widget test: test/features/inquiry/page_test.dart）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **3 項目が揃うと送信ボタンが有効になる**: メール・内容・種類がすべて入力されると送信ボタンが有効になる（既存 widget test: test/features/inquiry/page_test.dart）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. バリデーション

- [ ] **メールアドレスの形式不正はエラー表示する**: メール・種類・内容が揃って送信ボタンが有効な状態でも、メールの形式が不正な場合は送信せず「メールアドレスの形式が正しくありません」を表示する
  - なお「メールアドレスを入力してください」「お問い合わせの種類を選択してください」「お問い合わせ内容を入力してください」の各メッセージは submit 内の防御的チェックだが、送信ボタンの活性条件（3 項目必須）で先に遮断されるため通常の操作では到達しない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **メールアドレスの形式不正はエラー表示する**: メール・種類・内容が揃って送信ボタンが有効な状態でも、メールの形式が不正な場合は送信せず「メールアドレスの形式が正しくありません」を表示する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. 送信

- [ ] **送信成功でトーストを出して画面を閉じる**: 「送信する」タップで `functions.submitInquiry`（email / categoryType / content / platform / appVersion）を呼び、成功するとグローバルトースト「お問い合わせを送信しました」を表示して画面を閉じる（トーストは画面を閉じた後も見える OverlayEntry 方式）
- [ ] **送信中はボタン表示が「送信中...」になる**: 送信処理中はボタンラベルが「送信中...」になり、二重送信を防ぐため無効化される
- [ ] **送信失敗時はエラーをそのまま表示する**: 送信が失敗した場合、例外メッセージ（`e.toString()`）を加工せずフォーム内のエラー枠に表示する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **送信成功でトーストを出して画面を閉じる**: 「送信する」タップで `functions.submitInquiry`（email / categoryType / content / platform / appVersion）を呼び、成功するとグローバルトースト「お問い合わせを送信しました」を表示して画面を閉じる（トーストは画面を閉じた後も見える OverlayEntry 方式）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **送信中はボタン表示が「送信中...」になる**: 送信処理中はボタンラベルが「送信中...」になり、二重送信を防ぐため無効化される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **送信失敗時はエラーをそのまま表示する**: 送信が失敗した場合、例外メッセージ（`e.toString()`）を加工せずフォーム内のエラー枠に表示する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
