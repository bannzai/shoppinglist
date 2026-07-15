---
feature: group_invitation
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-14
---

# group_invitation QA

## 既知の問題（QA中に発見）

- 招待コード入力欄にフォーカスしソフトウェアキーボードが表示された状態だと、画面下部（キャンセルボタン付近）で `RenderFlex overflowed`（10px、エラーメッセージ表示時は39px）が発生する。チェック項目自体の合否には影響しない（参加処理・エラー表示・キャンセル遷移は正常動作）が、レイアウト上の不具合のため issue化した: https://github.com/bannzai/shoppinglist/issues/506

## 1. 画面表示・遷移

- [x] **招待コード入力画面の遷移**: `GroupJoinOrCreatePage` の「招待コードで参加」、および設定画面の同導線から `GroupInvitationAcceptPage` が push され、AppBar タイトル「招待コードで参加」で開くこと（既存 E2E: maestro/flows/group_join_or_create.yaml）
- [x] **初期表示要素**: `group_add` アイコンの丸バッジ、見出し「招待コードを入力してください」、説明「グループのメンバーから共有された8桁のコードを入力してください」、8桁入力欄（hint `ABCD3456`）、「参加する」ボタン、「キャンセル」ボタンが表示されること
- [x] **参加ボタンの初期状態**: コード未入力（無効）の状態では「参加する」ボタンが非活性であること（`isValidCode.value == false` で `onPressed: null`）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **招待コード入力画面の遷移**: `GroupJoinOrCreatePage` の「招待コードで参加」、および設定画面の同導線から `GroupInvitationAcceptPage` が push され、AppBar タイトル「招待コードで参加」で開くこと（既存 E2E: maestro/flows/group_join_or_create.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

GroupJoinOrCreatePage からの遷移（AppBarタイトル「招待コードで参加」）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/54578ba6-ff4f-4bec-9f63-023afecf33f1.png" width="320">

設定画面「招待コードでグループに参加」からの遷移（同じ画面に到達）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/5a038a2a-5379-4dcd-bdec-8a619a264865.png" width="320">

</details>

### **初期表示要素**: `group_add` アイコンの丸バッジ、見出し「招待コードを入力してください」、説明「グループのメンバーから共有された8桁のコードを入力してください」、8桁入力欄（hint `ABCD3456`）、「参加する」ボタン、「キャンセル」ボタンが表示されること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/54578ba6-ff4f-4bec-9f63-023afecf33f1.png" width="320">

</details>

### **参加ボタンの初期状態**: コード未入力（無効）の状態では「参加する」ボタンが非活性であること（`isValidCode.value == false` で `onPressed: null`）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

未入力時はボタンが薄いオレンジ色（非活性）。8桁の有効な形式を入力すると濃いオレンジ色（活性）に変化することを比較で確認（下記セクション2「8桁で参加ボタンが活性化」のスクショと比較）。
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/54578ba6-ff4f-4bec-9f63-023afecf33f1.png" width="320">

</details>

</details>

---

## 2. コード入力・バリデーション

- [x] **8桁で参加ボタンが活性化**: `isValidInvitationCode`（`^[A-HJKMNP-TV-Y3-9]{8}$`）を満たす8桁を入力すると「参加する」ボタンが活性化すること。8桁未満や許可外文字では非活性のままであること
- [x] **大文字化・最大桁数**: 入力欄は `textCapitalization: characters` で大文字化され、`maxLength: 8` で9文字目以降は入力できないこと（counter は非表示）
- [x] **有効コード入力時の枠色**: 有効コード入力中は入力欄の枠がアクセントカラーになること（エラー時は danger 色）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **8桁で参加ボタンが活性化**: `isValidInvitationCode`（`^[A-HJKMNP-TV-Y3-9]{8}$`）を満たす8桁を入力すると「参加する」ボタンが活性化すること。8桁未満や許可外文字では非活性のままであること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

許可外文字（I）を含む8桁 → 非活性のまま:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/04567a11-c6d5-444a-893e-73a189853fd1.png" width="320">

8桁未満（4桁）→ 非活性のまま:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/45bd4e6e-ce12-4976-9e7e-56eac137b90b.png" width="320">

許可文字のみの8桁（実在有無に関わらず形式が正しければ）→ 活性化（枠・ボタン色が濃いオレンジに変化）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/925e5a9d-40c7-4139-a664-69270dd10fbb.png" width="320">

</details>

### **大文字化・最大桁数**: 入力欄は `textCapitalization: characters` で大文字化され、`maxLength: 8` で9文字目以降は入力できないこと（counter は非表示）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

12文字（`ABCDEFGHIJKL`）を入力しても8文字目までしか反映されないこと（`maxLength: 8`）を確認:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/700be967-a3f9-4901-828f-2607ab537670.png" width="320">

補足: `textCapitalization: characters`（page.dart:73）はソフトウェアキーボードのシフト状態を制御するUIヒントであり、テキストを強制的に大文字変換する機能ではない。maestroの`inputText`はOSキーボードを介さず直接テキストを設定するため、実機での大文字化見た目を自動化で再現・撮影することはできなかった。ただし`isValidInvitationCode`は内部で`code.toUpperCase()`してから検証し（`lib/utils/invitation_code_validator.dart:4`）、送信時も`codeController.text.toUpperCase()`（page.dart:143）でサーバーに送るため、小文字入力でも機能的には正しく動作する。

</details>

### **有効コード入力時の枠色**: 有効コード入力中は入力欄の枠がアクセントカラーになること（エラー時は danger 色）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

有効な形式の8桁入力時、枠がアクセントカラーに変化:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/925e5a9d-40c7-4139-a664-69270dd10fbb.png" width="320">

エラー時、枠がdanger色（赤系）に変化（下記セクション4のスクショも参照）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/9634faf9-38fc-465b-96c9-40c590f1a1e5.png" width="320">

</details>

</details>

---

## 3. 参加処理

- [x] **参加中オーバレイの表示**: 「参加する」タップで「招待コードを確認中」ダイアログ（`AppDialogShell` + プログレスインジケータ、`barrierDismissible: false`）が表示され、ボタンラベルが「参加中...」に変わること
- [x] **参加成功でホームへ**: `acceptGroupInvitation.call` 成功後、verifying ダイアログを閉じてから `popUntil(route.isFirst)` でホームまで戻ること（参加したグループが `defaultGroupID` に設定される）。招待コードは `toUpperCase()` で送信される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **参加中オーバレイの表示**: 「参加する」タップで「招待コードを確認中」ダイアログ（`AppDialogShell` + プログレスインジケータ、`barrierDismissible: false`）が表示され、ボタンラベルが「参加中...」に変わること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

「招待コードを確認中」ダイアログ表示、背後のボタンラベルが「参加中...」に変化:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/ca3fc9a8-a7c7-49f2-a042-73ebbf5735fc.png" width="320">

</details>

### **参加成功でホームへ**: `acceptGroupInvitation.call` 成功後、verifying ダイアログを閉じてから `popUntil(route.isFirst)` でホームまで戻ること（参加したグループが `defaultGroupID` に設定される）。招待コードは `toUpperCase()` で送信される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

グループ設定画面（別アカウント/グループ）で発行した実在の招待コードを使って参加。成功後ホーム画面（買い物リスト）に自動遷移し、複数メンバーグループ用の通知ベルアイコンが追加表示されることを確認（参加先グループの`defaultGroupID`化）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/e3c5020c-c58a-4c92-be8b-dcce3816baa5.png" width="320">

</details>

</details>

---

## 4. エラー処理

- [x] **期限切れ・無効コードのエラー表示**: 参加処理が失敗した場合、verifying ダイアログを閉じ、入力欄下に `describeError(e, st).message` を danger 色で表示すること（有効期限は7日間。加工せずそのまま表示）
- [x] **入力変更でエラークリア**: エラー表示後に入力欄を編集すると `errorMessage` が null に戻りエラー表示が消えること（`onChanged` で `errorMessage.value = null`）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **期限切れ・無効コードのエラー表示**: 参加処理が失敗した場合、verifying ダイアログを閉じ、入力欄下に `describeError(e, st).message` を danger 色で表示すること（有効期限は7日間。加工せずそのまま表示）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

実在しない8桁コードで参加処理 → 「有効な招待が見つかりません」がdanger色（赤）で加工なしそのまま表示。有効期限「7日間」は招待コード発行ダイアログ側で表示を確認済み（グループ設定画面、下記備考参照）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/9634faf9-38fc-465b-96c9-40c590f1a1e5.png" width="320">

</details>

### **入力変更でエラークリア**: エラー表示後に入力欄を編集すると `errorMessage` が null に戻りエラー表示が消えること（`onChanged` で `errorMessage.value = null`）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

エラー表示状態（1回目の検証では`maxLength`到達済みの欄への追加入力が無視され値が変化せずエラーが残ったため、文字削除で実際に値を変化させて再検証した）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/0f713694-7b2c-4d42-83a6-374de30a7944.png" width="320">

1文字削除（値が変化）→ エラーメッセージが消えることを確認:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/6b7ba6d4-7c8c-402a-8557-cec61d72e452.png" width="320">

</details>

</details>

---

## 5. キャンセル

- [x] **キャンセルで前画面へ戻る**: 「キャンセル」タップで `Navigator.pop` により前画面（`GroupJoinOrCreatePage` 等）へ戻ること（既存 E2E: maestro/flows/group_join_or_create.yaml）
- [x] **参加中はキャンセル不可**: 参加処理中（`isAccepting.value == true`）は「キャンセル」ボタンが非活性になること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **キャンセルで前画面へ戻る**: 「キャンセル」タップで `Navigator.pop` により前画面（`GroupJoinOrCreatePage` 等）へ戻ること（既存 E2E: maestro/flows/group_join_or_create.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

「キャンセル」タップで `GroupJoinOrCreatePage`（「はじめましょう」画面）へ戻ることを確認:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/3c7e87bb-166e-4a39-991b-f392dfae4f29.png" width="320">

</details>

### **参加中はキャンセル不可**: 参加処理中（`isAccepting.value == true`）は「キャンセル」ボタンが非活性になること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

参加処理中は画面全体が `AppDialogShell`（`barrierDismissible: false`）のモーダルダイアログで覆われ、背後の「キャンセル」ボタンは視覚的に隠れ操作不可であることを確認。ボタン自体も `onPressed: isAccepting.value ? null : ...`（page.dart:174-176）でコード上も非活性化される:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/ca3fc9a8-a7c7-49f2-a042-73ebbf5735fc.png" width="320">

</details>

</details>

---
