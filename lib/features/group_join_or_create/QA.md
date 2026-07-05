---
feature: group_join_or_create
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# group_join_or_create QA

## 1. 画面表示

- [x] **初期表示**: 匿名サインイン直後などグループ未参加（defaultGroupID未設定）の場合、アイコン・見出し「はじめましょう」・説明文・「招待コードで参加」ボタン・「自分のリストを作る」ボタンの2択が表示される。maestro/flows/group_join_or_create.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **初期表示**: 匿名サインイン直後などグループ未参加（defaultGroupID未設定）の場合、アイコン・見出し「はじめましょう」・説明文・「招待コードで参加」ボタン・「自分のリストを作る」ボタンの2択が表示される。maestro/flows/group_join_or_create.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/group_join_or_create.yaml`（`-e APP_ID=com.bannzai.shoppinglist.dev`、`clearState: true` + `clearKeychain: true` でグループ未参加状態から）を実行。匿名サインイン後にグループ未参加（defaultGroupID未設定）の状態で GroupJoinOrCreatePage が表示され、人型アイコン・見出し「はじめましょう」・説明文・「招待コードで参加」（アクセント）・「自分のリストを作る」（ゴースト）の2択ボタンが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/95cbaeb3-6072-487e-a5f5-77c46013a701.png" width="320">

</details>

</details>

---

## 2. 招待コードで参加

- [x] **招待コードで参加ボタン→画面遷移**: 「招待コードで参加」をタップすると招待コード入力画面（「招待コードを入力してください」）へ遷移する。maestro/flows/group_join_or_create.yaml で確認。
- [x] **キャンセルで本画面へ戻る**: 招待コード入力画面で「キャンセル」をタップすると本画面（「自分のリストを作る」ボタンが表示された状態）に戻る。maestro/flows/group_join_or_create.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **招待コードで参加ボタン→画面遷移**: 「招待コードで参加」をタップすると招待コード入力画面（「招待コードを入力してください」）へ遷移する。maestro/flows/group_join_or_create.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

「招待コードで参加」をタップすると `GroupInvitationAcceptPage`（AppBar「招待コードで参加」・見出し「招待コードを入力してください」・8桁コード入力欄・「参加する」・「キャンセル」）へ遷移することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/b8cebf84-e9c2-47d9-a047-9d936ffaa925.png" width="320">

</details>

### **キャンセルで本画面へ戻る**: 招待コード入力画面で「キャンセル」をタップすると本画面（「自分のリストを作る」ボタンが表示された状態）に戻る。maestro/flows/group_join_or_create.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

招待コード入力画面で「キャンセル」をタップすると GroupJoinOrCreatePage（「はじめましょう」・「自分のリストを作る」ボタン表示）に戻ることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/e27514a2-133c-46c6-840a-933ab43e220e.png" width="320">

</details>

</details>

---

## 3. 自分のリストを作る（ソログループ作成）

- [x] **ソログループ作成成功→ホームへ自動遷移**: 「自分のリストを作る」をタップするとdefaultGroupIDがセットされ、本画面が自動的に空の買い物リスト画面（「タップで入力開始」表示）に置き換わる。本画面はNavigatorのルートではないため明示的なpopは発生しない。maestro/flows/group_join_or_create.yaml で確認。
- [x] **作成中の表示とボタン非活性**: タップ直後にボタンラベルが「作成中...」に変わり、「招待コードで参加」「自分のリストを作る」の両ボタンとも再タップできなくなる。
- [x] **作成失敗時のエラー表示**: グループ作成APIが失敗した場合、赤字のエラーメッセージが画面内に表示され、両ボタンが再度活性化して操作をやり直せる。意図的なAPI失敗の注入が難しいため、ネットワーク遮断等での再現かコードレビューでの確認に留める。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ソログループ作成成功→ホームへ自動遷移**: 「自分のリストを作る」をタップするとdefaultGroupIDがセットされ、本画面が自動的に空の買い物リスト画面（「タップで入力開始」表示）に置き換わる。本画面はNavigatorのルートではないため明示的なpopは発生しない。maestro/flows/group_join_or_create.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

「自分のリストを作る」をタップすると `createGroupProvider.call(setAsDefault: true)` により defaultGroupID がセットされ、`AppEntityPrepareResolver` の再ビルドで本画面が明示的な pop なしに空の買い物リスト画面（当日日付「2026-07-05」・「タップで入力開始」・使い方ヒントカード）へ置き換わることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/95cc77b8-a042-4bc6-bd44-5d4ba1af6ffe.png" width="320">

</details>

### **作成中の表示とボタン非活性**: タップ直後にボタンラベルが「作成中...」に変わり、「招待コードで参加」「自分のリストを作る」の両ボタンとも再タップできなくなる。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

コードレビューで確認（createGroup の応答が速く、この遷移状態を静止スクショで捉えるのは困難なため）。`lib/features/group_join_or_create/page.dart`: タップで `isCreating.value = true`（:121）となり、「自分のリストを作る」ボタンのラベルが `isCreating.value ? '作成中...' : '自分のリストを作る'`（:109）に切り替わる。「招待コードで参加」ボタンは `onPressed: isCreating.value ? null : ...`（:84-86）、「自分のリストを作る」ボタンも `onPressed: isCreating.value ? null : ...`（:113-115）で、作成中は両ボタンとも onPressed が null になり非活性化する。

</details>

### **作成失敗時のエラー表示**: グループ作成APIが失敗した場合、赤字のエラーメッセージが画面内に表示され、両ボタンが再度活性化して操作をやり直せる。意図的なAPI失敗の注入が難しいため、ネットワーク遮断等での再現かコードレビューでの確認に留める。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

項目定義どおりコードレビューで確認（意図的な API 失敗注入が困難なため）。`lib/features/group_join_or_create/page.dart`: `createGroupProvider.call` の catch（:135-138）で `errorMessage.value = describeError(e, st).message` をセットし `isCreating.value = false` に戻す。`errorMessage.value != null` のとき説明文の下に `neutral.danger`（赤字）でメッセージを表示（:65-73）。`isCreating` が false に戻ることで両ボタンの `onPressed` が再度有効化し操作をやり直せる。エラーメッセージは `describeError` の `.message` をそのまま表示しており加工していない。

</details>

</details>

---
