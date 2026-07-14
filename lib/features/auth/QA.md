---
feature: auth
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# auth QA

認証画面（`lib/features/auth/page.dart`）はオンボーディング完了後の未認証ユーザーに表示される（`lib/features/resolver/auth.dart`）。kDebugMode 時は匿名ユーザーも認証済みとして通過するため、Maestro / デバッグビルドでは「匿名サインイン（デバッグ用）」ボタンが利用できる。再表示（サインアウト後・未認証への復帰）には `clearState` + `clearKeychain`、または新規シミュレータで未認証状態を作る必要がある。

## 1. 認証画面の表示

- [ ] **タイトルと説明文が表示される**: 「家族の買い物を、ひとつのリストへ」の見出しと、「サインインすると端末をまたいでリストが同期します。広告もメールマガジンもありません。」の説明文が表示される（既存 E2E: maestro/flows/design_v2_entry.yaml, maestro/flows/auth_page_test_01.yaml）
- [ ] **アート画像とサインインボタンが表示される**: 上部に `images/auth/auth_art.png`、下部に Apple サインインボタンと「Google でサインイン」ボタンが表示される
- [ ] **匿名サインインは debug ビルドのみ表示**: 「匿名サインイン（デバッグ用）」ボタンは kDebugMode でのみ表示され、release/profile ビルドでは表示されない
- [ ] **ゲスト導線を UI に出さない**: 「ゲストとして使う」等のゲストリンクは本番 UI に表示されない（既存 E2E: maestro/flows/design_v2_entry.yaml）
- [ ] **規約同意文が表示される**: 「続けることで 利用規約 と プライバシーポリシー に同意したものとみなされます。」が表示され、利用規約・プライバシーポリシーがリンク（accent 色・下線）になっている（既存 E2E: maestro/flows/design_v2_entry.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **タイトルと説明文が表示される**: 「家族の買い物を、ひとつのリストへ」の見出しと、「サインインすると端末をまたいでリストが同期します。広告もメールマガジンもありません。」の説明文が表示される（既存 E2E: maestro/flows/design_v2_entry.yaml, maestro/flows/auth_page_test_01.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **アート画像とサインインボタンが表示される**: 上部に `images/auth/auth_art.png`、下部に Apple サインインボタンと「Google でサインイン」ボタンが表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **匿名サインインは debug ビルドのみ表示**: 「匿名サインイン（デバッグ用）」ボタンは kDebugMode でのみ表示され、release/profile ビルドでは表示されない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **ゲスト導線を UI に出さない**: 「ゲストとして使う」等のゲストリンクは本番 UI に表示されない（既存 E2E: maestro/flows/design_v2_entry.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **規約同意文が表示される**: 「続けることで 利用規約 と プライバシーポリシー に同意したものとみなされます。」が表示され、利用規約・プライバシーポリシーがリンク（accent 色・下線）になっている（既存 E2E: maestro/flows/design_v2_entry.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. サインイン操作

- [ ] **匿名サインインでホームへ到達する**: debug ビルドで「匿名サインイン（デバッグ用）」をタップすると `FirebaseAuth.instance.signInAnonymously()` が実行され、以降のリゾルバ連鎖を経てホーム（買い物リスト）に到達する（既存 E2E: maestro/flows/auth_page_test_04_anon_signin.yaml）
- [ ] **Apple サインインが実行できる**: Apple ボタンで `signInWithApple()`（nonce 付き）が実行され、成功すると認証済みとしてホームへ遷移する
- [ ] **Google サインインが実行できる**: 「Google でサインイン」ボタンで `signInWithGoogle()` が実行され、成功するとホームへ遷移する
- [ ] **サインインのキャンセルで画面に留まる**: Apple / Google のサインインをユーザーがキャンセルした場合（canceled）、エラー表示せずローディングを解除して認証画面に留まる。キャンセル以外の失敗は例外がそのまま送出される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **匿名サインインでホームへ到達する**: debug ビルドで「匿名サインイン（デバッグ用）」をタップすると `FirebaseAuth.instance.signInAnonymously()` が実行され、以降のリゾルバ連鎖を経てホーム（買い物リスト）に到達する（既存 E2E: maestro/flows/auth_page_test_04_anon_signin.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **Apple サインインが実行できる**: Apple ボタンで `signInWithApple()`（nonce 付き）が実行され、成功すると認証済みとしてホームへ遷移する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **Google サインインが実行できる**: 「Google でサインイン」ボタンで `signInWithGoogle()` が実行され、成功するとホームへ遷移する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **サインインのキャンセルで画面に留まる**: Apple / Google のサインインをユーザーがキャンセルした場合（canceled）、エラー表示せずローディングを解除して認証画面に留まる。キャンセル以外の失敗は例外がそのまま送出される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. 規約・プライバシーリンク

- [ ] **利用規約リンクで外部ページを開く**: 同意文の「利用規約」タップで `https://bannzai.github.io/shoppinglist/Terms` を外部ブラウザで開く（既存 E2E: maestro/flows/auth_page_test_03_terms.yaml）
- [ ] **プライバシーポリシーリンクで外部ページを開く**: 「プライバシーポリシー」タップで `https://bannzai.github.io/shoppinglist/PrivacyPolicy` を外部ブラウザで開く（既存 E2E: maestro/flows/auth_page_test_02_privacy.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **利用規約リンクで外部ページを開く**: 同意文の「利用規約」タップで `https://bannzai.github.io/shoppinglist/Terms` を外部ブラウザで開く（既存 E2E: maestro/flows/auth_page_test_03_terms.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **プライバシーポリシーリンクで外部ページを開く**: 「プライバシーポリシー」タップで `https://bannzai.github.io/shoppinglist/PrivacyPolicy` を外部ブラウザで開く（既存 E2E: maestro/flows/auth_page_test_02_privacy.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. サインイン処理中の表示

- [ ] **処理中は全画面ローディングが重なる**: サインイン開始で画面全体に LaunchLoading が重なる。早期 return ではなく Stack で重ねる実装のため、実行中のサインインボタンは unmount されず、キャンセル / 失敗時に処理が固まらない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **処理中は全画面ローディングが重なる**: サインイン開始で画面全体に LaunchLoading が重なる。早期 return ではなく Stack で重ねる実装のため、実行中のサインインボタンは unmount されず、キャンセル / 失敗時に処理が固まらない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. 認証状態の永続化とサインアウト

- [ ] **再起動で認証状態が維持される**: 認証済みのまま `clearState: false` でアプリを再起動しても再サインインを要求されず、同一 UID・defaultGroupID でホームに復帰する（既存 E2E: maestro/flows/auth_page_test_06_idempotency.yaml）
- [ ] **サインアウトで未認証に戻る**: 設定画面からサインアウトを確定すると `FirebaseAuth.instance.signOut()` が実行され、未認証状態になる。debug ビルドでは終了アラート（「終了する」）を出さず exit もしない（既存 E2E: maestro/flows/auth_sign_out.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **再起動で認証状態が維持される**: 認証済みのまま `clearState: false` でアプリを再起動しても再サインインを要求されず、同一 UID・defaultGroupID でホームに復帰する（既存 E2E: maestro/flows/auth_page_test_06_idempotency.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **サインアウトで未認証に戻る**: 設定画面からサインアウトを確定すると `FirebaseAuth.instance.signOut()` が実行され、未認証状態になる。debug ビルドでは終了アラート（「終了する」）を出さず exit もしない（既存 E2E: maestro/flows/auth_sign_out.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
