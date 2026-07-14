---
feature: home
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# home QA

HomePage（`lib/features/home/page.dart`）は薄いラッパで、本体は `ShoppingListPage` に委譲する。認証済みユーザーはリゾルバ連鎖（`AppResolvers` → `AppUserCreateResolver` → `ForceUpdateResolver` → `AppEntityPrepareResolver` → `CurrentGroupResolver` → `HomeWidgetSync`）を経てホームへ到達する（`lib/root.dart`）。ここでは「アプリ起動時にホームへ到達する入口挙動」とヘッダーからのナビゲーションを対象にする。買い物リストの追加・チェック・削除等の中身の操作は shopping_list feature の QA で扱う。

## 1. アプリ起動時の入口

- [ ] **起動後に買い物リスト画面が表示される**: 認証済みユーザーはリゾルバ連鎖を経て ShoppingListPage が表示される。空リスト時は「タップで入力開始」が表示される（既存 E2E: maestro/flows/home_page_test.yaml, maestro/flows/auth_page_test_04_anon_signin.yaml）
- [ ] **下部タブは表示されない**: 旧デザインの下部ナビゲーションタブは廃止済みで、ホームは買い物リスト単一画面になっている（既存 E2E: maestro/flows/home_page_test.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **起動後に買い物リスト画面が表示される**: 認証済みユーザーはリゾルバ連鎖を経て ShoppingListPage が表示される。空リスト時は「タップで入力開始」が表示される（既存 E2E: maestro/flows/home_page_test.yaml, maestro/flows/auth_page_test_04_anon_signin.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **下部タブは表示されない**: 旧デザインの下部ナビゲーションタブは廃止済みで、ホームは買い物リスト単一画面になっている（既存 E2E: maestro/flows/home_page_test.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. ヘッダーからのナビゲーション

- [ ] **設定アイコンで設定画面へ遷移する**: ヘッダー右上の設定アイコン（tooltip「設定」）タップで SettingPage が push 遷移し、「プロフィール」等が表示される（既存 E2E: maestro/flows/home_page_test.yaml）
- [ ] **設定画面の閉じる（×）でホームへ戻る**: 設定画面左上の閉じるアイコン（Navigator.pop）で買い物リスト画面に戻る（既存 E2E: maestro/flows/home_page_test.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **設定アイコンで設定画面へ遷移する**: ヘッダー右上の設定アイコン（tooltip「設定」）タップで SettingPage が push 遷移し、「プロフィール」等が表示される（既存 E2E: maestro/flows/home_page_test.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **設定画面の閉じる（×）でホームへ戻る**: 設定画面左上の閉じるアイコン（Navigator.pop）で買い物リスト画面に戻る（既存 E2E: maestro/flows/home_page_test.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. リゾルバのローディング・リトライ

- [ ] **認証解決中はローディングが表示される**: 認証状態の解決中は LaunchLoading が表示され、解決後にホームへ遷移する
- [ ] **認証エラー時に再試行できる**: 認証ストリームがエラーになった場合は RetryPage が表示され、再試行で `firebaseUserChangesProvider` を invalidate してやり直せる
  - permission-denied 由来で「Retry」ボタンが表示される場合があり、タップで復帰する（既存 E2E: maestro/flows/auth_page_test_04_anon_signin.yaml の Retry ハンドリング）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **認証解決中はローディングが表示される**: 認証状態の解決中は LaunchLoading が表示され、解決後にホームへ遷移する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **認証エラー時に再試行できる**: 認証ストリームがエラーになった場合は RetryPage が表示され、再試行で `firebaseUserChangesProvider` を invalidate してやり直せる

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
