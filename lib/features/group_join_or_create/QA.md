---
feature: group_join_or_create
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# group_join_or_create QA

## 1. 画面表示

- [ ] **未参加ユーザーへの表示**: 新規サインイン後、`defaultGroupID == null` を `AppEntityPrepareResolver` が検知したときに `GroupJoinOrCreatePage` が表示されること。見出し「はじめましょう」・説明文・「招待コードで参加」・「自分のリストを作る」の2ボタンが表示される（既存 E2E: maestro/flows/group_join_or_create.yaml）
- [ ] **`groups` アイコンと訴求文**: `groups` アイコンの丸バッジと「家族やパートナーから招待コードを受け取っていますか？…」の説明文が表示されること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **未参加ユーザーへの表示**: 新規サインイン後、`defaultGroupID == null` を `AppEntityPrepareResolver` が検知したときに `GroupJoinOrCreatePage` が表示されること。見出し「はじめましょう」・説明文・「招待コードで参加」・「自分のリストを作る」の2ボタンが表示される（既存 E2E: maestro/flows/group_join_or_create.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **`groups` アイコンと訴求文**: `groups` アイコンの丸バッジと「家族やパートナーから招待コードを受け取っていますか？…」の説明文が表示されること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. 招待コードで参加

- [ ] **招待コード入力画面へ遷移**: 「招待コードで参加」タップで `GroupInvitationAcceptPage` が push され「招待コードを入力してください」画面が開くこと（既存 E2E: maestro/flows/group_join_or_create.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **招待コード入力画面へ遷移**: 「招待コードで参加」タップで `GroupInvitationAcceptPage` が push され「招待コードを入力してください」画面が開くこと（既存 E2E: maestro/flows/group_join_or_create.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. 自分のリストを作る（ソログループ作成）

- [ ] **ソログループ作成でホームへ**: 「自分のリストを作る」タップで `createGroup.call(name: null, setAsDefault: true, iconName: 'home')` が実行され、`defaultGroupID` がセットされて `AppEntityPrepareResolver` の再ビルドにより本画面が置き換わり、空ホーム（「タップで入力開始」）に到達すること（既存 E2E: maestro/flows/group_join_or_create.yaml）
- [ ] **作成中の表示**: 作成処理中はボタンラベルが「作成中...」に変わり、両ボタンが非活性になること（`isCreating.value == true`）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ソログループ作成でホームへ**: 「自分のリストを作る」タップで `createGroup.call(name: null, setAsDefault: true, iconName: 'home')` が実行され、`defaultGroupID` がセットされて `AppEntityPrepareResolver` の再ビルドにより本画面が置き換わり、空ホーム（「タップで入力開始」）に到達すること（既存 E2E: maestro/flows/group_join_or_create.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **作成中の表示**: 作成処理中はボタンラベルが「作成中...」に変わり、両ボタンが非活性になること（`isCreating.value == true`）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. エラー処理

- [ ] **作成失敗時のエラー表示**: ソログループ作成が失敗した場合、説明文の下に `describeError(e, st).message` を danger 色で表示し、`isCreating` を false に戻してボタンを再度操作可能にすること（エラーメッセージは加工せずそのまま表示）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **作成失敗時のエラー表示**: ソログループ作成が失敗した場合、説明文の下に `describeError(e, st).message` を danger 色で表示し、`isCreating` を false に戻してボタンを再度操作可能にすること（エラーメッセージは加工せずそのまま表示）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---
