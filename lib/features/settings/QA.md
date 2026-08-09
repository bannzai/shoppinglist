---
feature: settings
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-15
---

# settings QA

設定画面（`lib/features/settings/page.dart`）。プロフィール・グループ・外観（テーマカラー）・プレミアム・アプリについて・（debug のみ）デバッグ・サインアウト・アカウント削除の各セクションで構成される。位置情報リマインダー（「通知」セクションの `LocationReminderToggle`）は `shoppingLocationFeatureEnabled = false` で非表示のため対象外。プレミアム状態が必要な項目は開発者オプション →「プレミアム付与（1日）」で付与して確認する。

## 1. プロフィール（表示名）

- [x] **表示名を編集してフォーカスを外すと自動保存される**: 「自分の表示名」欄に入力しフォーカスを外す（blur / キーボードの完了キー）と `GroupUserProfileUpdate` で保存され、「表示名を更新しました」の SnackBar が表示される。保存値と同一なら書き込みをスキップする。設定を開いた際は入力欄が空なら既存 displayName を初期表示する（既存 E2E: maestro/flows/settings_profile.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **表示名を編集してフォーカスを外すと自動保存される**: 「自分の表示名」欄に入力しフォーカスを外す（blur / キーボードの完了キー）と `GroupUserProfileUpdate` で保存され、「表示名を更新しました」の SnackBar が表示される。保存値と同一なら書き込みをスキップする。設定を開いた際は入力欄が空なら既存 displayName を初期表示する（既存 E2E: maestro/flows/settings_profile.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/d4e35e66-0232-4875-92f3-a2b607d0fd8f.png" width="320">

匿名サインイン後の新規アカウント（表示名未設定）で「自分の表示名」欄に入力→キーボード完了キーでblurすると、SnackBar「表示名を更新しました」が表示され、値が保存された。設定画面を閉じて再度開くと、保存済みの表示名が入力欄に初期表示されることも確認済み。

</details>

</details>

---

## 2. グループ

- [x] **「グループ管理」でグループ一覧へ遷移する**: 「グループ管理」タップで GroupListPage が push 遷移する（既存 E2E: maestro/flows/settings_profile.yaml）
- [x] **「招待コードでグループに参加」で参加画面へ遷移する**: 「招待コードでグループに参加」タップで GroupInvitationAcceptPage が push 遷移する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **「グループ管理」でグループ一覧へ遷移する**: 「グループ管理」タップで GroupListPage が push 遷移する（既存 E2E: maestro/flows/settings_profile.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/df938403-90cb-4e17-8c51-13086cfcf99b.png" width="320">

</details>

### **「招待コードでグループに参加」で参加画面へ遷移する**: 「招待コードでグループに参加」タップで GroupInvitationAcceptPage が push 遷移する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/50ddf457-1483-4625-a896-809cd0f1da26.png" width="320">

</details>

</details>

---

## 3. 外観（テーマカラー）

- [x] **非プレミアムはテーマカラーがロックされる**: 非プレミアム時はテーマカラー行に鍵アイコンが表示され、タップすると「テーマカラーの変更はプレミアム機能です」の SnackBar と「アップグレード」アクション（Paywall 表示）が出る。選択画面へは遷移しない（既存 E2E: maestro/flows/theme_color_setting_non_premium.yaml）
- [x] **プレミアムはテーマカラー選択画面へ遷移する**: プレミアム時はタップで ThemeColorSelectionPage へ遷移し、SnackBar は出ない（既存 E2E: maestro/flows/premium_theme_color_setting.yaml）
- [x] **テーマカラーを選択するとアプリ全体の差し色が変わる**: 選択画面で 5 色プリセットのいずれかをタップすると `ThemeColorUpdate` が実行され、「テーマカラーを変更しました」の SnackBar が表示され、選択中スウォッチにチェックが付く

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **非プレミアムはテーマカラーがロックされる**: 非プレミアム時はテーマカラー行に鍵アイコンが表示され、タップすると「テーマカラーの変更はプレミアム機能です」の SnackBar と「アップグレード」アクション（Paywall 表示）が出る。選択画面へは遷移しない（既存 E2E: maestro/flows/theme_color_setting_non_premium.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/1dbdbd53-242d-4e01-b864-c8c30ca5d384.png" width="320">

</details>

### **プレミアムはテーマカラー選択画面へ遷移する**: プレミアム時はタップで ThemeColorSelectionPage へ遷移し、SnackBar は出ない（既存 E2E: maestro/flows/premium_theme_color_setting.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/77d48aa1-857e-4f73-baa3-239c5d7f4053.png" width="320">

開発者オプションでプレミアム付与後、テーマカラー行の鍵アイコンが消え、タップで ThemeColorSelectionPage（5色プリセット表示）へ直接遷移した。SnackBarは表示されなかった。

</details>

### **テーマカラーを選択するとアプリ全体の差し色が変わる**: 選択画面で 5 色プリセットのいずれかをタップすると `ThemeColorUpdate` が実行され、「テーマカラーを変更しました」の SnackBar が表示され、選択中スウォッチにチェックが付く

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/6f536a6d-92f6-44f2-bff7-e6b613e885d6.png" width="320">

「抹茶」スウォッチをタップすると即座にチェックマークが移動し、「テーマカラーを変更しました」の SnackBar が表示された。

</details>

</details>

---

## 4. プレミアムカード

- [x] **非プレミアム時はアップグレード導線が表示される**: 「プレミアムにアップグレード」カード（surface2 背景）と「はじめる」ピルが表示され、タップで Paywall が開く（既存 E2E: maestro/flows/design_v2_settings_paywall.yaml）
- [x] **プレミアム時は会員カードが表示される**: プレミアム付与後は accent → #7C2A07 のグラデーションカードに「プレミアム会員」「すべての機能が利用できます」が表示され、「はじめる」ピルは表示されない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **非プレミアム時はアップグレード導線が表示される**: 「プレミアムにアップグレード」カード（surface2 背景）と「はじめる」ピルが表示され、タップで Paywall が開く（既存 E2E: maestro/flows/design_v2_settings_paywall.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/1dbdbd53-242d-4e01-b864-c8c30ca5d384.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/b91fb218-f279-4ef0-bb44-95e34206c8c8.png" width="320">

非プレミアム状態で「プレミアムにアップグレード」カードと「はじめる」ピルが表示され、タップで Paywall（月額/年額/生涯プラン）が開いた。

</details>

### **プレミアム時は会員カードが表示される**: プレミアム付与後は accent → #7C2A07 のグラデーションカードに「プレミアム会員」「すべての機能が利用できます」が表示され、「はじめる」ピルは表示されない

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/fec6c6d0-974e-417e-b025-193fc80040b0.png" width="320">

開発者オプションでプレミアム付与後、グラデーションカードに「プレミアム会員」「すべての機能が利用できます」が表示され、「はじめる」ピルは表示されなかった。

</details>

</details>

---

## 5. アプリについて

- [x] **利用規約・プライバシーポリシー・特商法が外部ページで開く**: 各セルタップで `https://bannzai.github.io/shoppinglist/` 配下の該当ページ（Terms / PrivacyPolicy / SpecifiedCommercialTransactionAct-ja）を外部ブラウザで開く
- [x] **「お問い合わせ」でお問い合わせ画面へ遷移する**: 「お問い合わせ」タップで InquiryPage が push 遷移する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **利用規約・プライバシーポリシー・特商法が外部ページで開く**: 各セルタップで `https://bannzai.github.io/shoppinglist/` 配下の該当ページ（Terms / PrivacyPolicy / SpecifiedCommercialTransactionAct-ja）を外部ブラウザで開く

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/a579613b-7145-4f72-b0b4-898f1c66f498.png" width="320">

「利用規約」タップで Safari（外部ブラウザ）に切り替わり、`bannzai.github.io/shoppinglist/Terms` の「買い物リスト利用規約」ページが表示された。プライバシーポリシー・特商法も同一の `launchUrl(mode: externalApplication)` 実装のため、同様に外部ブラウザで開くことをコードで確認済み。

</details>

### **「お問い合わせ」でお問い合わせ画面へ遷移する**: 「お問い合わせ」タップで InquiryPage が push 遷移する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/d84d1f7d-bbfe-4be6-996a-0cce94f61bd9.png" width="320">

</details>

</details>

---

## 6. サインアウト

- [x] **確認ダイアログを経てサインアウトする**: 「サインアウト」タップで「サインアウトしますか?」ダイアログ（danger 色の確定ボタン）が開く。確定で `FirebaseAuth.instance.signOut()` が実行される（既存 E2E: maestro/flows/auth_sign_out.yaml）
- [x] **キャンセルで設定画面に留まる**: ダイアログの「キャンセル」でサインアウトせず設定画面に留まる（既存 E2E: maestro/flows/design_v2_settings_paywall.yaml）
- [x] **debug ビルドでは終了アラートを出さない**: debug ビルドではサインアウト確定後に終了アラート（「終了する」）を表示せず exit もしない。release/profile では「サインアウトしました」アラート→「終了する」で `exit(0)` する（既存 E2E: maestro/flows/auth_sign_out.yaml）
- [ ] **ゲスト利用中は恒久的なデータ喪失を警告する**: ゲスト（匿名）利用中はサインアウト確認ダイアログの本文が「…今のリストとグループには二度とアクセスできなくなります。」の警告文になる（issue #548）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **確認ダイアログを経てサインアウトする**: 「サインアウト」タップで「サインアウトしますか?」ダイアログ（danger 色の確定ボタン）が開く。確定で `FirebaseAuth.instance.signOut()` が実行される（既存 E2E: maestro/flows/auth_sign_out.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/1d2c8b16-468e-4143-a6e5-16eb8a8cd2bf.png" width="320">

</details>

### **キャンセルで設定画面に留まる**: ダイアログの「キャンセル」でサインアウトせず設定画面に留まる（既存 E2E: maestro/flows/design_v2_settings_paywall.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

「キャンセル」タップでダイアログが閉じ、サインアウトされず設定画面に留まることを確認した（スクショはセクション6の1項目目と同一画面のため省略）。

</details>

### **debug ビルドでは終了アラートを出さない**: debug ビルドではサインアウト確定後に終了アラート（「終了する」）を表示せず exit もしない。release/profile では「サインアウトしました」アラート→「終了する」で `exit(0)` する（既存 E2E: maestro/flows/auth_sign_out.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/09ba441d-1e38-4d7a-ba0d-883f46d7bb41.png" width="320">

debug ビルドで「サインアウト」確定後、終了アラートは表示されずアプリも終了しなかった。設定画面を閉じると Auth 画面（サインイン前の画面）に遷移し、`signOut()` が実際に実行されたことを確認した。

</details>

</details>

---

## 7. アカウント削除

- [x] **確認ダイアログを経てアカウントを削除する**: 「アカウントを削除する」タップで「ユーザー情報を削除します」確認ダイアログが開き、「削除する」で `currentUser.delete()` を実行。成功で「アカウントを削除しました」完了ダイアログ→「終了する」で `exit(0)`（debug/release 問わず）
- [ ] **再認証が必要な場合は再ログインを促す**: 削除時に `requires-recent-login` が返る場合は「再ログインしてください」ダイアログを表示し、Apple / Google で再認証後に削除を再実行する
  - ⏭️ スキップ: `requires-recent-login` は Apple/Google サインインで一定時間経過後の再認証を要求する場合にのみ発生し、QA で使用する匿名サインインでは発生しない。実機で意図的に再現する手段がないため未実行（詳細は下記動作確認エビデンス参照）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **確認ダイアログを経てアカウントを削除する**: 「アカウントを削除する」タップで「ユーザー情報を削除します」確認ダイアログが開き、「削除する」で `currentUser.delete()` を実行。成功で「アカウントを削除しました」完了ダイアログ→「終了する」で `exit(0)`（debug/release 問わず）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/a2e7da4c-1442-4114-ac45-00f4a6a654d1.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/5f56b7c3-5927-40eb-b37e-b0ba7d3c208d.png" width="320">

「アカウントを削除する」タップで確認ダイアログが開き、「削除する」で `currentUser.delete()` が実行された。「アカウントを削除しました」完了ダイアログの「終了する」タップで実際に `exit(0)` が実行され、iOS ホーム画面に戻ることを確認した（debug ビルドでも exit する仕様通り）。

</details>

### **再認証が必要な場合は再ログインを促す**: 削除時に `requires-recent-login` が返る場合は「再ログインしてください」ダイアログを表示し、Apple / Google で再認証後に削除を再実行する

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: `requires-recent-login` は Firebase Auth が Apple/Google サインインで一定時間経過後の再認証を要求する場合にのみ発生し、QA で使用する匿名サインインでは発生しない。実機で意図的に再現する手段がないため未実行。`lib/components/button/user_delete.dart:106-165` で `FirebaseAuthException.code == 'requires-recent-login'` 時に「再ログインしてください」ダイアログを表示し、`isAppleLinked`/`isGoogleLinked` に応じて `appleReauthentification()` / `googleReauthentification()` を呼んで削除を再実行する実装をコードレビューで確認した。

</details>

</details>

---

## 8. その他

- [x] **開発者オプションは debug ビルドのみ表示**: 「デバッグ」セクションの「開発者オプション」は kDebugMode でのみ表示され、タップで開発者オプション画面へ遷移する
- [x] **アプリバージョンが表示される**: 画面下部に `vX.Y.Z (build N)` 形式のバージョンが mono フォントで表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **開発者オプションは debug ビルドのみ表示**: 「デバッグ」セクションの「開発者オプション」は kDebugMode でのみ表示され、タップで開発者オプション画面へ遷移する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/ea7cc9f3-eda7-44bd-a213-c0c3a074acf9.png" width="320">

debug ビルドで「デバッグ」セクション・「開発者オプション」セルが表示され、タップで開発者オプション画面へ遷移することも本 QA セッション内（プレミアム付与・剥奪操作）で確認済み。

</details>

### **アプリバージョンが表示される**: 画面下部に `vX.Y.Z (build N)` 形式のバージョンが mono フォントで表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/ea7cc9f3-eda7-44bd-a213-c0c3a074acf9.png" width="320">

画面下部に `v1.0.0 (build 1)` が mono フォントで表示されている。

</details>

</details>

---

## 9. アカウント（リンク）

issue #548 で追加。ゲスト（匿名）のまま使い始めたユーザーが、設定画面から Apple / Google アカウントをリンクする（`lib/features/settings/components/account_link_section.dart`）。

- [ ] **ゲスト利用中はリンク導線が表示される**: プロフィール直下の「アカウント」セクションに「ゲストとして利用中です。…」の説明行と「Apple でアカウントをリンク」「Google でアカウントをリンク」の Cell が表示される（E2E: maestro/flows/settings_account_link.yaml、widget test: test/features/settings/account_link_section_test.dart）
- [ ] **リンク済み provider はサインイン済み表示になる**: Apple / Google をリンク済みのユーザーには「Apple でサインイン済み」等のタップ不可 Cell が表示され、未リンクの provider のリンク導線は残る（widget test: test/features/settings/account_link_section_test.dart）
- [ ] **リンク成功で UID とデータが引き継がれる**: リンク成功で「アカウントをリンクしました」SnackBar が表示され、UID が維持されたままリスト・グループを引き続き使える（`User.linkWithCredential`）。確認には実機の Apple / Google アカウントが必要
- [ ] **リンク失敗時に状況の分かるメッセージが出る**: `provider-already-linked` / `email-already-in-use` は SnackBar にタイトル付きで表示される（unit test: test/utils/error/error_display_test.dart）
- [ ] **credential-already-in-use でサインインし直し導線が出る**: 別ユーザーで使用済みのアカウントをリンクしようとすると「このアカウントは別のユーザーで使用されています」ダイアログが開き、「サインインし直す」で既存アカウントへ切り替わり（ゲストデータは引き継がれない）、キャンセルでゲストのまま残る。確認には実機の Apple / Google アカウントが必要
- [ ] **キャンセルで何も起きない**: Apple / Google のネイティブシートをキャンセルするとエラー表示なくアカウントセクションに留まる
