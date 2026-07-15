---
feature: home
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-14
---

# home QA

HomePage（`lib/features/home/page.dart`）は薄いラッパで、本体は `ShoppingListPage` に委譲する。認証済みユーザーはリゾルバ連鎖（`AppResolvers` → `AppUserCreateResolver` → `ForceUpdateResolver` → `AppEntityPrepareResolver` → `CurrentGroupResolver` → `HomeWidgetSync`）を経てホームへ到達する（`lib/root.dart`）。ここでは「アプリ起動時にホームへ到達する入口挙動」とヘッダーからのナビゲーションを対象にする。買い物リストの追加・チェック・削除等の中身の操作は shopping_list feature の QA で扱う。

## 1. アプリ起動時の入口

- [x] **起動後に買い物リスト画面が表示される**: 認証済みユーザーはリゾルバ連鎖を経て ShoppingListPage が表示される。空リスト時は「タップで入力開始」が表示される（既存 E2E: maestro/flows/home_page_test.yaml, maestro/flows/auth_page_test_04_anon_signin.yaml）
- [x] **下部タブは表示されない**: 旧デザインの下部ナビゲーションタブは廃止済みで、ホームは買い物リスト単一画面になっている（既存 E2E: maestro/flows/home_page_test.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **起動後に買い物リスト画面が表示される**: 認証済みユーザーはリゾルバ連鎖を経て ShoppingListPage が表示される。空リスト時は「タップで入力開始」が表示される（既存 E2E: maestro/flows/home_page_test.yaml, maestro/flows/auth_page_test_04_anon_signin.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/a0fd02fe-d5c7-4b34-a516-36975c4ed725.png" width="320">

maestro/flows/home_page_test.yaml 実行（匿名サインイン→「自分のリストを作る」→ホーム到達）で確認。

</details>

### **下部タブは表示されない**: 旧デザインの下部ナビゲーションタブは廃止済みで、ホームは買い物リスト単一画面になっている（既存 E2E: maestro/flows/home_page_test.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/a0fd02fe-d5c7-4b34-a516-36975c4ed725.png" width="320">

上記スクショの通り、画面下部にナビゲーションタブは存在しない（AppBar + リスト本体のみ）。

</details>

</details>

---

## 2. ヘッダーからのナビゲーション

- [x] **設定アイコンで設定画面へ遷移する**: ヘッダー右上の設定アイコン（tooltip「設定」）タップで SettingPage が push 遷移し、「プロフィール」等が表示される（既存 E2E: maestro/flows/home_page_test.yaml）
- [x] **設定画面の閉じる（×）でホームへ戻る**: 設定画面左上の閉じるアイコン（Navigator.pop）で買い物リスト画面に戻る（既存 E2E: maestro/flows/home_page_test.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **設定アイコンで設定画面へ遷移する**: ヘッダー右上の設定アイコン（tooltip「設定」）タップで SettingPage が push 遷移し、「プロフィール」等が表示される（既存 E2E: maestro/flows/home_page_test.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/babfae11-ca7b-416a-874a-fbba387b5907.png" width="320">

</details>

### **設定画面の閉じる（×）でホームへ戻る**: 設定画面左上の閉じるアイコン（Navigator.pop）で買い物リスト画面に戻る（既存 E2E: maestro/flows/home_page_test.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/c5449737-925a-4cbc-ba77-fe39a3d079b1.png" width="320">

</details>

</details>

---

## 3. リゾルバのローディング・リトライ

- [x] **認証解決中はローディングが表示される**: 認証状態の解決中は LaunchLoading が表示され、解決後にホームへ遷移する
- [ ] **認証エラー時に再試行できる**: 認証ストリームがエラーになった場合は RetryPage が表示され、再試行で `firebaseUserChangesProvider` を invalidate してやり直せる
  - permission-denied 由来で「Retry」ボタンが表示される場合があり、タップで復帰する（既存 E2E: maestro/flows/auth_page_test_04_anon_signin.yaml の Retry ハンドリング）
  - ⏭️ スキップ: permission-denied 相当のエラーは環境依存で不定期にしか発生せず、今回のセッションでは `maestro/flows/home_page_test.yaml` 実行時に2回とも "Retry" 非表示で意図的な再現手段もないため実機確認できなかった。`lib/components/error/retry_page.dart` / `lib/features/resolver/auth.dart:56` のコードレビューでは、Retry ボタンが `firebaseUserChangesProvider` を invalidate して再購読する実装になっていることを確認済み（詳細は下記動作確認エビデンス参照）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **認証解決中はローディングが表示される**: 認証状態の解決中は LaunchLoading が表示され、解決後にホームへ遷移する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

dev 環境ではローカルに永続化された Firebase Auth セッションの復元が高速（1秒未満）で完了し、mobile-mcp/simctl のタップ→スクショ往復レイテンシを上回るため、`LaunchLoading` overlay 自体の直接撮影は今回も撮り逃した（`lib/features/auth/QA.md` セクション4と同様の制約）。

代わりに以下で確認:
- コードレビュー: `lib/features/resolver/auth.dart:73` の `loading: () => LaunchLoading.shared()`（`firebaseUserChangesProvider` の解決待ち中に表示される分岐）
- 挙動確認: `maestro/flows/home_page_test.yaml` 実行時、アプリ起動から一度も画面がスタックせずオンボーディング/認証/ホームへ順に遷移したことを確認済み（loading→resolved の状態遷移自体は成立している）

</details>

### **認証エラー時に再試行できる**: 認証ストリームがエラーになった場合は RetryPage が表示され、再試行で `firebaseUserChangesProvider` を invalidate してやり直せる

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: `firebaseUserChangesProvider` の permission-denied 相当のエラーは環境依存で不定期にしか発生せず、今回のセッションでは `maestro/flows/home_page_test.yaml` 実行時に2回とも "Retry" は非表示（`Run flow when "Retry" is visible... SKIPPED`）で、意図的に発生させる手段も確立していないため実機での再現ができなかった。

コードレビューでの確認: `lib/components/error/retry_page.dart` の `RetryPage` は `FilledButton` に「Retry」ラベルを表示し、`onPressed` で `Retry.of(context).retry()`（`lib/features/resolver/auth.dart:56` で `() => ref.invalidate(firebaseUserChangesProvider)` として注入）を呼ぶ。`firebaseUserChangesProvider` invalidate 後は `AuthResolver` が stream を再購読し、`loading` → `data`/`error` に遷移する構造になっており、実装上は再試行が成立する。

</details>

</details>
