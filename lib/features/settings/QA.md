---
feature: settings
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# settings QA

設定画面（`lib/features/settings/page.dart`）。プロフィール・グループ・外観（テーマカラー）・プレミアム・アプリについて・（debug のみ）デバッグ・サインアウト・アカウント削除の各セクションで構成される。位置情報リマインダー（「通知」セクションの `LocationReminderToggle`）は `shoppingLocationFeatureEnabled = false` で非表示のため対象外。プレミアム状態が必要な項目は開発者オプション →「プレミアム付与（1日）」で付与して確認する。

## 1. プロフィール（表示名）

- [ ] **表示名を編集してフォーカスを外すと自動保存される**: 「自分の表示名」欄に入力しフォーカスを外す（blur / キーボードの完了キー）と `GroupUserProfileUpdate` で保存され、「表示名を更新しました」の SnackBar が表示される。保存値と同一なら書き込みをスキップする（既存 E2E: maestro/flows/settings_profile.yaml）
- [ ] **既存の表示名が初期表示される**: 設定を開いた際、入力欄が空なら Firestore の既存 displayName を反映する（入力中の値は上書きしない）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **表示名を編集してフォーカスを外すと自動保存される**: 「自分の表示名」欄に入力しフォーカスを外す（blur / キーボードの完了キー）と `GroupUserProfileUpdate` で保存され、「表示名を更新しました」の SnackBar が表示される（既存 E2E: maestro/flows/settings_profile.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **保存済みと同じ値なら書き込みしない**: 表示名が現在の保存値と同一の場合は Firestore への書き込みをスキップする（冪等）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **初回読み込み時に既存の表示名が反映される**: Firestore からプロフィールを読み込んだ際、入力欄が空なら既存 displayName を反映する（入力中の値は上書きしない）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. グループ

- [ ] **「グループ管理」でグループ一覧へ遷移する**: 「グループ管理」タップで GroupListPage が push 遷移する（既存 E2E: maestro/flows/settings_profile.yaml）
- [ ] **「招待コードでグループに参加」で参加画面へ遷移する**: 「招待コードでグループに参加」タップで GroupInvitationAcceptPage が push 遷移する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **「グループ管理」でグループ一覧へ遷移する**: 「グループ管理」タップで GroupListPage が push 遷移する（既存 E2E: maestro/flows/settings_profile.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **「招待コードでグループに参加」で参加画面へ遷移する**: 「招待コードでグループに参加」タップで GroupInvitationAcceptPage が push 遷移する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. 外観（テーマカラー）

- [ ] **非プレミアムはテーマカラーがロックされる**: 非プレミアム時はテーマカラー行に鍵アイコンが表示され、タップすると「テーマカラーの変更はプレミアム機能です」の SnackBar と「アップグレード」アクション（Paywall 表示）が出る。選択画面へは遷移しない（既存 E2E: maestro/flows/theme_color_setting_non_premium.yaml）
- [ ] **プレミアムはテーマカラー選択画面へ遷移する**: プレミアム時はタップで ThemeColorSelectionPage へ遷移し、SnackBar は出ない（既存 E2E: maestro/flows/premium_theme_color_setting.yaml）
- [ ] **テーマカラーを選択するとアプリ全体の差し色が変わる**: 選択画面で 5 色プリセットのいずれかをタップすると `ThemeColorUpdate` が実行され、「テーマカラーを変更しました」の SnackBar が表示され、選択中スウォッチにチェックが付く

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **非プレミアムはテーマカラーがロックされる**: 非プレミアム時はテーマカラー行に鍵アイコンが表示され、タップすると「テーマカラーの変更はプレミアム機能です」の SnackBar と「アップグレード」アクション（Paywall 表示）が出る。選択画面へは遷移しない（既存 E2E: maestro/flows/theme_color_setting_non_premium.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **プレミアムはテーマカラー選択画面へ遷移する**: プレミアム時はタップで ThemeColorSelectionPage へ遷移し、SnackBar は出ない（既存 E2E: maestro/flows/premium_theme_color_setting.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **テーマカラーを選択するとアプリ全体の差し色が変わる**: 選択画面で 5 色プリセットのいずれかをタップすると `ThemeColorUpdate` が実行され、「テーマカラーを変更しました」の SnackBar が表示され、選択中スウォッチにチェックが付く

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. プレミアムカード

- [ ] **非プレミアム時はアップグレード導線が表示される**: 「プレミアムにアップグレード」カード（surface2 背景）と「はじめる」ピルが表示され、タップで Paywall が開く（既存 E2E: maestro/flows/design_v2_settings_paywall.yaml）
- [ ] **プレミアム時は会員カードが表示される**: プレミアム付与後は accent → #7C2A07 のグラデーションカードに「プレミアム会員」「すべての機能が利用できます」が表示され、「はじめる」ピルは表示されない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **非プレミアム時はアップグレード導線が表示される**: 「プレミアムにアップグレード」カード（surface2 背景）と「はじめる」ピルが表示され、タップで Paywall が開く（既存 E2E: maestro/flows/design_v2_settings_paywall.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **プレミアム時は会員カードが表示される**: プレミアム付与後は accent → #7C2A07 のグラデーションカードに「プレミアム会員」「すべての機能が利用できます」が表示され、「はじめる」ピルは表示されない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. アプリについて

- [ ] **利用規約・プライバシーポリシー・特商法が外部ページで開く**: 各セルタップで `https://bannzai.github.io/shoppinglist/` 配下の該当ページ（Terms / PrivacyPolicy / SpecifiedCommercialTransactionAct-ja）を外部ブラウザで開く
- [ ] **「お問い合わせ」でお問い合わせ画面へ遷移する**: 「お問い合わせ」タップで InquiryPage が push 遷移する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **利用規約・プライバシーポリシー・特商法が外部ページで開く**: 各セルタップで `https://bannzai.github.io/shoppinglist/` 配下の該当ページ（Terms / PrivacyPolicy / SpecifiedCommercialTransactionAct-ja）を外部ブラウザで開く

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **「お問い合わせ」でお問い合わせ画面へ遷移する**: 「お問い合わせ」タップで InquiryPage が push 遷移する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 6. サインアウト

- [ ] **確認ダイアログを経てサインアウトする**: 「サインアウト」タップで「サインアウトしますか?」ダイアログ（danger 色の確定ボタン）が開く。確定で `FirebaseAuth.instance.signOut()` が実行される（既存 E2E: maestro/flows/auth_sign_out.yaml）
- [ ] **キャンセルで設定画面に留まる**: ダイアログの「キャンセル」でサインアウトせず設定画面に留まる（既存 E2E: maestro/flows/design_v2_settings_paywall.yaml）
- [ ] **debug ビルドでは終了アラートを出さない**: debug ビルドではサインアウト確定後に終了アラート（「終了する」）を表示せず exit もしない。release/profile では「サインアウトしました」アラート→「終了する」で `exit(0)` する（既存 E2E: maestro/flows/auth_sign_out.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **確認ダイアログを経てサインアウトする**: 「サインアウト」タップで「サインアウトしますか?」ダイアログ（danger 色の確定ボタン）が開く。確定で `FirebaseAuth.instance.signOut()` が実行される（既存 E2E: maestro/flows/auth_sign_out.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **キャンセルで設定画面に留まる**: ダイアログの「キャンセル」でサインアウトせず設定画面に留まる（既存 E2E: maestro/flows/design_v2_settings_paywall.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **debug ビルドでは終了アラートを出さない**: debug ビルドではサインアウト確定後に終了アラート（「終了する」）を表示せず exit もしない。release/profile では「サインアウトしました」アラート→「終了する」で `exit(0)` する（既存 E2E: maestro/flows/auth_sign_out.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 7. アカウント削除

- [ ] **確認ダイアログを経てアカウントを削除する**: 「アカウントを削除する」タップで「ユーザー情報を削除します」確認ダイアログが開き、「削除する」で `currentUser.delete()` を実行。成功で「アカウントを削除しました」完了ダイアログ→「終了する」で `exit(0)`（debug/release 問わず）
- [ ] **再認証が必要な場合は再ログインを促す**: 削除時に `requires-recent-login` が返る場合は「再ログインしてください」ダイアログを表示し、Apple / Google で再認証後に削除を再実行する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **確認ダイアログを経てアカウントを削除する**: 「アカウントを削除する」タップで「ユーザー情報を削除します」確認ダイアログが開き、「削除する」で `currentUser.delete()` を実行。成功で「アカウントを削除しました」完了ダイアログ→「終了する」で `exit(0)`（debug/release 問わず）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **再認証が必要な場合は再ログインを促す**: 削除時に `requires-recent-login` が返る場合は「再ログインしてください」ダイアログを表示し、Apple / Google で再認証後に削除を再実行する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 8. その他

- [ ] **開発者オプションは debug ビルドのみ表示**: 「デバッグ」セクションの「開発者オプション」は kDebugMode でのみ表示され、タップで開発者オプション画面へ遷移する
- [ ] **アプリバージョンが表示される**: 画面下部に `vX.Y.Z (build N)` 形式のバージョンが mono フォントで表示される
- [ ] **閉じる（×）でホームへ戻る**: AppBar 左上の閉じるアイコン（Navigator.pop）で買い物リスト画面に戻る

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **開発者オプションは debug ビルドのみ表示**: 「デバッグ」セクションの「開発者オプション」は kDebugMode でのみ表示され、タップで開発者オプション画面へ遷移する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **アプリバージョンが表示される**: 画面下部に `vX.Y.Z (build N)` 形式のバージョンが mono フォントで表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **閉じる（×）でホームへ戻る**: AppBar 左上の閉じるアイコン（Navigator.pop）で買い物リスト画面に戻る

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
