---
feature: auth
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# auth QA

## 1. 初期表示

- [ ] **未認証時にAuthPageが表示される**: オンボーディング完了後・未サインイン時にAuthPageが表示され、キャッチコピー「家族の買い物を、ひとつのリストへ」、説明文、Apple/Googleサインインボタン、利用規約・プライバシーポリシーへのリンク文が表示される。maestro/flows/auth_page_test_01.yaml で確認。
- [ ] **匿名サインインボタンはデバッグビルドのみ表示される**: 「匿名サインイン（デバッグ用）」ボタンは `kDebugMode` の時だけ画面下部に表示される。

---

## 2. サインイン

- [ ] **匿名サインイン（デバッグ用）でサインインできる**: ボタンをタップすると `FirebaseAuth.instance.signInAnonymously()` が成功し、グループ未参加のためGroupJoinOrCreatePageへ遷移する。maestro/flows/auth_page_test_04_anon_signin.yaml で確認。
- [ ] **Apple/Googleサインインボタンの表示とタップ動作**: 実OAuth（実アカウント・外部認証UIへの遷移）を伴うためSimulator上でのサインイン完了までの自動確認はできない。ボタンが表示されタップ可能であることをmobile-mcpで確認し、それ以降のサインイン後の挙動確認は匿名サインインで代替する。
- [ ] **サインイン処理中は画面全体にローディングが重なる**: ボタンタップ直後からサインイン完了まで、Stackで重ねた全面ローディング（LaunchLoading）が表示され、裏のサインインボタンはunmountされず処理完了後も操作可能な状態に戻る。

---

## 3. 規約・プライバシーリンク

- [ ] **利用規約リンクをタップすると外部ブラウザで開く**: フッターの「利用規約」をタップすると `https://bannzai.github.io/shoppinglist/Terms` が外部ブラウザで開く（`tap_auth_terms_of_service` イベント発火）。maestro/flows/auth_page_test_03_terms.yaml で確認。
- [ ] **プライバシーポリシーリンクをタップすると外部ブラウザで開く**: フッターの「プライバシーポリシー」をタップすると `https://bannzai.github.io/shoppinglist/PrivacyPolicy` が外部ブラウザで開く（`tap_auth_privacy_policy` イベント発火）。maestro/flows/auth_page_test_02_privacy.yaml で確認。

---

## 4. サインイン状態の永続化

- [ ] **サインイン後にFirestoreへユーザーデータが作成される**: 匿名サインイン後、設定 > 開発者オプション > Firestoreデータ確認でAppUserドキュメントが存在し展開できることを確認する。maestro/flows/auth_page_test_05_firestore_dump.yaml で確認。
- [ ] **アプリを再起動してもAuthPageを経由せずホーム画面に直接遷移する**: `clearState: false` で再起動した場合、既存のサインイン状態を引き継ぎ、ホーム画面（上部バーの「リスト設定」アイコン）が直接表示される。maestro/flows/auth_page_test_06_idempotency.yaml で確認。
- [ ] **再起動前後でUID・defaultGroupIDが変化しない（冪等性）**: 開発者オプション画面に表示されるUID/defaultGroupIDを再起動前後で比較し一致することを確認する。maestro/flows/auth_page_test_05b_devopt_info.yaml, maestro/flows/auth_page_test_06_idempotency.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **サインイン後にFirestoreへユーザーデータが作成される**: 匿名サインイン後、設定 > 開発者オプション > Firestoreデータ確認でAppUserドキュメントが存在し展開できることを確認する。maestro/flows/auth_page_test_05_firestore_dump.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **アプリを再起動してもAuthPageを経由せずホーム画面に直接遷移する**: `clearState: false` で再起動した場合、既存のサインイン状態を引き継ぎ、ホーム画面（上部バーの「リスト設定」アイコン）が直接表示される。maestro/flows/auth_page_test_06_idempotency.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **再起動前後でUID・defaultGroupIDが変化しない（冪等性）**: 開発者オプション画面に表示されるUID/defaultGroupIDを再起動前後で比較し一致することを確認する。maestro/flows/auth_page_test_05b_devopt_info.yaml, maestro/flows/auth_page_test_06_idempotency.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
