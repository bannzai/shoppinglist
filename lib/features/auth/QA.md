---
feature: auth
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# auth QA

## 1. 初期表示

- [x] **未認証時にAuthPageが表示される**: オンボーディング完了後・未サインイン時にAuthPageが表示され、キャッチコピー「家族の買い物を、ひとつのリストへ」、説明文、Apple/Googleサインインボタン、利用規約・プライバシーポリシーへのリンク文が表示される。maestro/flows/auth_page_test_01.yaml で確認。
- [x] **匿名サインインボタンはデバッグビルドのみ表示される**: 「匿名サインイン（デバッグ用）」ボタンは `kDebugMode` の時だけ画面下部に表示される。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **未認証時にAuthPageが表示される**: オンボーディング完了後・未サインイン時にAuthPageが表示され、キャッチコピー「家族の買い物を、ひとつのリストへ」、説明文、Apple/Googleサインインボタン、利用規約・プライバシーポリシーへのリンク文が表示される。maestro/flows/auth_page_test_01.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/auth_page_test_01.yaml` 実行（`clearState: true` で未サインイン状態から起動、オンボーディングをスキップ）。キャッチコピー「家族の買い物を、ひとつのリストへ」、説明文、Apple/Googleサインインボタン、利用規約・プライバシーポリシーへのリンク文が表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/e1f1a462-ba42-4109-97c4-3ce5d526fa79.png" width="320">

</details>

### **匿名サインインボタンはデバッグビルドのみ表示される**: 「匿名サインイン（デバッグ用）」ボタンは `kDebugMode` の時だけ画面下部に表示される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

同上のスクショで、Debugビルド（右上に「DEBUG」バナー表示）にて「匿名サインイン（デバッグ用）」ボタンが画面下部に表示されていることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/e1f1a462-ba42-4109-97c4-3ce5d526fa79.png" width="320">

</details>

</details>

---

## 2. サインイン

- [x] **匿名サインイン（デバッグ用）でサインインできる**: ボタンをタップすると `FirebaseAuth.instance.signInAnonymously()` が成功し、グループ未参加のためGroupJoinOrCreatePageへ遷移する。maestro/flows/auth_page_test_04_anon_signin.yaml で確認。
- [x] **Apple/Googleサインインボタンの表示とタップ動作**: 実OAuth（実アカウント・外部認証UIへの遷移）を伴うためSimulator上でのサインイン完了までの自動確認はできない。ボタンが表示されタップ可能であることをmobile-mcpで確認し、それ以降のサインイン後の挙動確認は匿名サインインで代替する。
- [x] **サインイン処理中は画面全体にローディングが重なる**: ボタンタップ直後からサインイン完了まで、Stackで重ねた全面ローディング（LaunchLoading）が表示され、裏のサインインボタンはunmountされず処理完了後も操作可能な状態に戻る。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **匿名サインイン（デバッグ用）でサインインできる**: ボタンをタップすると `FirebaseAuth.instance.signInAnonymously()` が成功し、グループ未参加のためGroupJoinOrCreatePageへ遷移する。maestro/flows/auth_page_test_04_anon_signin.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/auth_page_test_04_anon_signin.yaml` 実行（`clearState: true` で未サインイン状態から起動）。匿名サインイン後 GroupJoinOrCreatePage で「自分のリストを作る」をタップし、Home（空状態「タップで入力開始」表示）まで到達することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/b384cf92-6ad2-4395-882e-04b439936c1a.png" width="320">

</details>

### **Apple/Googleサインインボタンの表示とタップ動作**: 実OAuth（実アカウント・外部認証UIへの遷移）を伴うためSimulator上でのサインイン完了までの自動確認はできない。ボタンが表示されタップ可能であることをmobile-mcpで確認し、それ以降のサインイン後の挙動確認は匿名サインインで代替する。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpでAuthPageの要素一覧を取得し、「Sign in with Apple」「Google でサインイン」がともにタップ可能な `Button` 要素として存在することを確認した。「Sign in with Apple」をタップすると実際に iOS ネイティブの「Apple Accountにサインインしてください」ダイアログが表示され、ボタンが正しく Sign in with Apple フローに配線されていることを確認した（Simulator に Apple Account 未設定のため、それ以降のOAuth完了は未確認。「Google でサインイン」もタップ後にクラッシュ・エラーなくAuthPageに留まることを確認した）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/856132e1-1534-4609-aaf7-62390fff2297.png" width="320">

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/752402ec-0e27-4bfd-beaa-bc1d685dd47f.png" width="320">

</details>

### **サインイン処理中は画面全体にローディングが重なる**: ボタンタップ直後からサインイン完了まで、Stackで重ねた全面ローディング（LaunchLoading）が表示され、裏のサインインボタンはunmountされず処理完了後も操作可能な状態に戻る。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

匿名サインインボタンタップ直後に `xcrun simctl io screenshot` で連写し、遷移の瞬間を捕捉した。買い物カゴアイコンのバウンスアニメーション・3つの波打つドット・「準備中...」テキストで構成される全面ローディング（`lib/components/loading/loading.dart` の `LaunchLoading`）が表示され、その後 GroupJoinOrCreatePage に遷移することを確認した。Apple/Googleボタンのタップ確認（本ページ「Apple/Googleサインインボタンの表示とタップ動作」項目）で、処理中断後もAuthPageのボタンが操作可能な状態に戻ることは別途確認済み。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/150e057c-02e3-4303-97fa-a13124c03a89.png" width="320">

</details>

</details>

---

## 3. 規約・プライバシーリンク

- [x] **利用規約リンクをタップすると外部ブラウザで開く**: フッターの「利用規約」をタップすると `https://bannzai.github.io/shoppinglist/Terms` が外部ブラウザで開く（`tap_auth_terms_of_service` イベント発火）。maestro/flows/auth_page_test_03_terms.yaml で確認。
- [x] **プライバシーポリシーリンクをタップすると外部ブラウザで開く**: フッターの「プライバシーポリシー」をタップすると `https://bannzai.github.io/shoppinglist/PrivacyPolicy` が外部ブラウザで開く（`tap_auth_privacy_policy` イベント発火）。maestro/flows/auth_page_test_02_privacy.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **利用規約リンクをタップすると外部ブラウザで開く**: フッターの「利用規約」をタップすると `https://bannzai.github.io/shoppinglist/Terms` が外部ブラウザで開く（`tap_auth_terms_of_service` イベント発火）。maestro/flows/auth_page_test_03_terms.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/auth_page_test_03_terms.yaml` 実行。「利用規約」タップで Safari（bannzai.github.io）に遷移し「買い物リスト利用規約」ページが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/b6dec4dc-99fd-4494-b680-8c20a5347744.png" width="320">

</details>

### **プライバシーポリシーリンクをタップすると外部ブラウザで開く**: フッターの「プライバシーポリシー」をタップすると `https://bannzai.github.io/shoppinglist/PrivacyPolicy` が外部ブラウザで開く（`tap_auth_privacy_policy` イベント発火）。maestro/flows/auth_page_test_02_privacy.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/auth_page_test_02_privacy.yaml` 実行。「プライバシーポリシー」タップで Safari（bannzai.github.io）に遷移し「プライバシーポリシー」ページが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/062c46c9-6a31-4b1a-847a-f05c69aa3303.png" width="320">

</details>

</details>

---

## 4. サインイン状態の永続化

- [x] **サインイン後にFirestoreへユーザーデータが作成される**: 匿名サインイン後、設定 > 開発者オプション > Firestoreデータ確認でAppUserドキュメントが存在し展開できることを確認する。maestro/flows/auth_page_test_05_firestore_dump.yaml で確認。
- [x] **アプリを再起動してもAuthPageを経由せずホーム画面に直接遷移する**: `clearState: false` で再起動した場合、既存のサインイン状態を引き継ぎ、ホーム画面（上部バーの「リスト設定」アイコン）が直接表示される。maestro/flows/auth_page_test_06_idempotency.yaml で確認。
- [x] **再起動前後でUID・defaultGroupIDが変化しない（冪等性）**: 開発者オプション画面に表示されるUID/defaultGroupIDを再起動前後で比較し一致することを確認する。maestro/flows/auth_page_test_05b_devopt_info.yaml, maestro/flows/auth_page_test_06_idempotency.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **サインイン後にFirestoreへユーザーデータが作成される**: 匿名サインイン後、設定 > 開発者オプション > Firestoreデータ確認でAppUserドキュメントが存在し展開できることを確認する。maestro/flows/auth_page_test_05_firestore_dump.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/auth_page_test_05_firestore_dump.yaml` 実行。匿名サインイン後、設定 > 開発者オプション > Firestoreデータ確認でAppUserドキュメントが `id` / `defaultGroupID` / `createdDateTime` 等を持って展開表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/f484c634-348b-4927-a9fe-62c98f53c1c5.png" width="320">

</details>

### **アプリを再起動してもAuthPageを経由せずホーム画面に直接遷移する**: `clearState: false` で再起動した場合、既存のサインイン状態を引き継ぎ、ホーム画面（上部バーの「リスト設定」アイコン）が直接表示される。maestro/flows/auth_page_test_06_idempotency.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`auth_page_test_05b_devopt_info.yaml` でサインイン後、`auth_page_test_06_idempotency.yaml` を `clearState: false` で実行。AuthPageを経由せずホーム画面（上部バー「リスト設定」アイコン）が直接表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/76a717ba-cc7d-466f-abb2-061b6dd8342a.png" width="320">

</details>

### **再起動前後でUID・defaultGroupIDが変化しない（冪等性）**: 開発者オプション画面に表示されるUID/defaultGroupIDを再起動前後で比較し一致することを確認する。maestro/flows/auth_page_test_05b_devopt_info.yaml, maestro/flows/auth_page_test_06_idempotency.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

再起動前（`auth_page_test_05b_devopt_info.yaml`）: UID `yGSGtTSgp8MYrCpUiNsDgLfzG4k2` / defaultGroupID `RV2x3fLug4kMF4rsYHKN`。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/f8e88221-162d-4117-9bf0-ab2fa1a0f0ae.png" width="320">

再起動後（`auth_page_test_06_idempotency.yaml`、`clearState: false`）: UID・defaultGroupIDとも同一の値であることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/55f3dd39-ec76-4085-9b01-2fa43a620c3d.png" width="320">

</details>

</details>
