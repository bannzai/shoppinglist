---
feature: group_invitation
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# group_invitation QA

## 1. 画面表示・遷移

- [ ] **招待コード入力画面の遷移**: `GroupJoinOrCreatePage` の「招待コードで参加」、および設定画面の同導線から `GroupInvitationAcceptPage` が push され、AppBar タイトル「招待コードで参加」で開くこと（既存 E2E: maestro/flows/group_join_or_create.yaml）
- [ ] **初期表示要素**: `group_add` アイコンの丸バッジ、見出し「招待コードを入力してください」、説明「グループのメンバーから共有された8桁のコードを入力してください」、8桁入力欄（hint `ABCD3456`）、「参加する」ボタン、「キャンセル」ボタンが表示されること
- [ ] **参加ボタンの初期状態**: コード未入力（無効）の状態では「参加する」ボタンが非活性であること（`isValidCode.value == false` で `onPressed: null`）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **招待コード入力画面の遷移**: `GroupJoinOrCreatePage` の「招待コードで参加」、および設定画面の同導線から `GroupInvitationAcceptPage` が push され、AppBar タイトル「招待コードで参加」で開くこと（既存 E2E: maestro/flows/group_join_or_create.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **初期表示要素**: `group_add` アイコンの丸バッジ、見出し「招待コードを入力してください」、説明「グループのメンバーから共有された8桁のコードを入力してください」、8桁入力欄（hint `ABCD3456`）、「参加する」ボタン、「キャンセル」ボタンが表示されること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **参加ボタンの初期状態**: コード未入力（無効）の状態では「参加する」ボタンが非活性であること（`isValidCode.value == false` で `onPressed: null`）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. コード入力・バリデーション

- [ ] **8桁で参加ボタンが活性化**: `isValidInvitationCode`（`^[A-HJKMNP-TV-Y3-9]{8}$`）を満たす8桁を入力すると「参加する」ボタンが活性化すること。8桁未満や許可外文字では非活性のままであること
- [ ] **大文字化・最大桁数**: 入力欄は `textCapitalization: characters` で大文字化され、`maxLength: 8` で9文字目以降は入力できないこと（counter は非表示）
- [ ] **有効コード入力時の枠色**: 有効コード入力中は入力欄の枠がアクセントカラーになること（エラー時は danger 色）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **8桁で参加ボタンが活性化**: `isValidInvitationCode`（`^[A-HJKMNP-TV-Y3-9]{8}$`）を満たす8桁を入力すると「参加する」ボタンが活性化すること。8桁未満や許可外文字では非活性のままであること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **大文字化・最大桁数**: 入力欄は `textCapitalization: characters` で大文字化され、`maxLength: 8` で9文字目以降は入力できないこと（counter は非表示）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **有効コード入力時の枠色**: 有効コード入力中は入力欄の枠がアクセントカラーになること（エラー時は danger 色）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. 参加処理

- [ ] **参加中オーバレイの表示**: 「参加する」タップで「招待コードを確認中」ダイアログ（`AppDialogShell` + プログレスインジケータ、`barrierDismissible: false`）が表示され、ボタンラベルが「参加中...」に変わること
- [ ] **参加成功でホームへ**: `acceptGroupInvitation.call` 成功後、verifying ダイアログを閉じてから `popUntil(route.isFirst)` でホームまで戻ること（参加したグループが `defaultGroupID` に設定される）。招待コードは `toUpperCase()` で送信される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **参加中オーバレイの表示**: 「参加する」タップで「招待コードを確認中」ダイアログ（`AppDialogShell` + プログレスインジケータ、`barrierDismissible: false`）が表示され、ボタンラベルが「参加中...」に変わること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **参加成功でホームへ**: `acceptGroupInvitation.call` 成功後、verifying ダイアログを閉じてから `popUntil(route.isFirst)` でホームまで戻ること（参加したグループが `defaultGroupID` に設定される）。招待コードは `toUpperCase()` で送信される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. エラー処理

- [ ] **期限切れ・無効コードのエラー表示**: 参加処理が失敗した場合、verifying ダイアログを閉じ、入力欄下に `describeError(e, st).message` を danger 色で表示すること（有効期限は7日間。加工せずそのまま表示）
- [ ] **入力変更でエラークリア**: エラー表示後に入力欄を編集すると `errorMessage` が null に戻りエラー表示が消えること（`onChanged` で `errorMessage.value = null`）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **期限切れ・無効コードのエラー表示**: 参加処理が失敗した場合、verifying ダイアログを閉じ、入力欄下に `describeError(e, st).message` を danger 色で表示すること（有効期限は7日間。加工せずそのまま表示）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **入力変更でエラークリア**: エラー表示後に入力欄を編集すると `errorMessage` が null に戻りエラー表示が消えること（`onChanged` で `errorMessage.value = null`）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. キャンセル

- [ ] **キャンセルで前画面へ戻る**: 「キャンセル」タップで `Navigator.pop` により前画面（`GroupJoinOrCreatePage` 等）へ戻ること（既存 E2E: maestro/flows/group_join_or_create.yaml）
- [ ] **参加中はキャンセル不可**: 参加処理中（`isAccepting.value == true`）は「キャンセル」ボタンが非活性になること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **キャンセルで前画面へ戻る**: 「キャンセル」タップで `Navigator.pop` により前画面（`GroupJoinOrCreatePage` 等）へ戻ること（既存 E2E: maestro/flows/group_join_or_create.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **参加中はキャンセル不可**: 参加処理中（`isAccepting.value == true`）は「キャンセル」ボタンが非活性になること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---
