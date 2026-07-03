---
feature: group_join_or_create
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# group_join_or_create QA

## 1. 画面表示

- [ ] **初期表示**: 匿名サインイン直後などグループ未参加（defaultGroupID未設定）の場合、アイコン・見出し「はじめましょう」・説明文・「招待コードで参加」ボタン・「自分のリストを作る」ボタンの2択が表示される。maestro/flows/group_join_or_create.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 2. 招待コードで参加

- [ ] **招待コードで参加ボタン→画面遷移**: 「招待コードで参加」をタップすると招待コード入力画面（「招待コードを入力してください」）へ遷移する。maestro/flows/group_join_or_create.yaml で確認。
- [ ] **キャンセルで本画面へ戻る**: 招待コード入力画面で「キャンセル」をタップすると本画面（「自分のリストを作る」ボタンが表示された状態）に戻る。maestro/flows/group_join_or_create.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 3. 自分のリストを作る（ソログループ作成）

- [ ] **ソログループ作成成功→ホームへ自動遷移**: 「自分のリストを作る」をタップするとdefaultGroupIDがセットされ、本画面が自動的に空の買い物リスト画面（「タップで入力開始」表示）に置き換わる。本画面はNavigatorのルートではないため明示的なpopは発生しない。maestro/flows/group_join_or_create.yaml で確認。
- [ ] **作成中の表示とボタン非活性**: タップ直後にボタンラベルが「作成中...」に変わり、「招待コードで参加」「自分のリストを作る」の両ボタンとも再タップできなくなる。
- [ ] **作成失敗時のエラー表示**: グループ作成APIが失敗した場合、赤字のエラーメッセージが画面内に表示され、両ボタンが再度活性化して操作をやり直せる。意図的なAPI失敗の注入が難しいため、ネットワーク遮断等での再現かコードレビューでの確認に留める。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---
