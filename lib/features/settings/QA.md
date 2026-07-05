---
feature: settings
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# settings QA

## 1. プロフィール

- [x] **表示名を編集すると自動保存される**: 「自分の表示名」欄に入力しキーボードのEnter/完了でフォーカスを外すと自動保存され、「表示名を更新しました」SnackBarが表示される（保存ボタンはなく、blurが保存トリガー）。maestro/flows/settings_profile.yaml で確認。
- [x] **保存済みの値と同じ場合は更新処理をスキップする**: 表示名を変更せずフォーカスを外した場合、更新処理が走らず「表示名を更新しました」SnackBarも表示されないことを確認する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **表示名を編集すると自動保存される**: 「自分の表示名」欄に入力しキーボードのEnter/完了でフォーカスを外すと自動保存され、「表示名を更新しました」SnackBarが表示される（保存ボタンはなく、blurが保存トリガー）。maestro/flows/settings_profile.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/settings_profile.yaml` 実行。「表示名を入力」欄に「テストユーザー」を入力しEnterキーでフォーカスを外すと、「表示名を更新しました」SnackBarが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/6b38ec6a-fba2-4c1e-845e-c1b003e1865c.png" width="320">

</details>

### **保存済みの値と同じ場合は更新処理をスキップする**: 表示名を変更せずフォーカスを外した場合、更新処理が走らず「表示名を更新しました」SnackBarも表示されないことを確認する。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

アドホックMaestroフロー（`zz_adhoc_settings_name_noop.yaml`）で、「テストユーザー」を保存後にSnackBarが消えるまで待機し、同じ値のまま表示名欄にフォーカス→Enterでフォーカスを外しても「表示名を更新しました」SnackBarが再表示されないことを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/2191563b-2450-42fa-b599-321c41a23d76.png" width="320">

</details>

</details>

---

## 2. グループ

- [x] **「グループ管理」から一覧画面に遷移する**: 「グループ」セクションのAppCellタップでGroupListPageに遷移する。maestro/flows/settings_profile.yaml で確認。
- [x] **「招待コードでグループに参加」から参加画面に遷移する**: AppCellタップでGroupInvitationAcceptPageに遷移する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **「グループ管理」から一覧画面に遷移する**: 「グループ」セクションのAppCellタップでGroupListPageに遷移する。maestro/flows/settings_profile.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/settings_profile.yaml` 実行。「グループ管理」タップでGroupListPage（自グループ「名前未設定」「デフォルト」「メンバー 1人」表示）に遷移することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/1ca020a9-653e-457e-872e-8d2493f59cc4.png" width="320">

</details>

### **「招待コードでグループに参加」から参加画面に遷移する**: AppCellタップでGroupInvitationAcceptPageに遷移する。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

アドホックMaestroフロー（`zz_adhoc_settings_invite_nav.yaml`）で、「招待コードでグループに参加」タップ後にGroupInvitationAcceptPage（AppBarタイトル「招待コードで参加」、見出し「招待コードを入力してください」、8桁コード入力欄、「参加する」「キャンセル」ボタン）に遷移することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/d12bab4c-33fc-4c27-b965-f3fc90e0f611.png" width="320">

</details>

</details>

---

## 3. 外観・通知（プレミアムゲート）

- [x] **プレミアム会員はテーマカラー設定画面に遷移できる**: 「テーマカラー」ListTileタップでThemeColorSelectionPageに遷移し、非プレミアム時のSnackBarが出ないことを確認する。maestro/flows/premium_theme_color_setting.yaml で確認。
- [x] **非プレミアム会員はテーマカラー変更がSnackBarでブロックされる**: 「テーマカラー」タップで「テーマカラーの変更はプレミアム機能です」SnackBarが表示され、「アップグレード」アクションでPaywallPageに遷移する。maestro/flows/theme_color_setting_non_premium.yaml で確認。
- [x] **現在のfeature flag設定では「通知」セクション（位置情報リマインダー）が表示されない**: `shoppingLocationFeatureEnabled = false`（ファーストリリースでは非表示、issue #465）のため、設定画面をスクロールしても「通知」セクション自体が存在しないことを確認する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **プレミアム会員はテーマカラー設定画面に遷移できる**: 「テーマカラー」ListTileタップでThemeColorSelectionPageに遷移し、非プレミアム時のSnackBarが出ないことを確認する。maestro/flows/premium_theme_color_setting.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/premium_theme_color_setting.yaml` 実行（開発者オプションでプレミアム付与後）。「テーマカラー」タップでThemeColorSelectionPage（朱・抹茶・藍・墨・朽葉の5色）に遷移し、「テーマカラーの変更はプレミアム機能です」SnackBarが表示されないことを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/8e552702-f237-43aa-b796-fec0686e1e36.png" width="320">

</details>

### **非プレミアム会員はテーマカラー変更がSnackBarでブロックされる**: 「テーマカラー」タップで「テーマカラーの変更はプレミアム機能です」SnackBarが表示され、「アップグレード」アクションでPaywallPageに遷移する。maestro/flows/theme_color_setting_non_premium.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/theme_color_setting_non_premium.yaml` 実行。非プレミアム状態で「テーマカラー」タップ→「テーマカラーの変更はプレミアム機能です」SnackBar（「アップグレード」アクション付き）が表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/acdcd17c-9782-4752-87f3-97d20df8238d.png" width="320">

追加でアドホックMaestroフロー（`zz_adhoc_theme_upgrade_action.yaml`）でSnackBarの「アップグレード」アクションをタップし、PaywallPage（「プレミアムにアップグレード」見出し・Monthly/Yearly/Lifetimeプラン・購入ボタン）に遷移することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/5b5bcf51-a1dd-498b-9fff-ef90c8f6b2f1.png" width="320">

</details>

### **現在のfeature flag設定では「通知」セクション（位置情報リマインダー）が表示されない**: `shoppingLocationFeatureEnabled = false`（ファーストリリースでは非表示、issue #465）のため、設定画面をスクロールしても「通知」セクション自体が存在しないことを確認する。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`lib/utils/config/feature_flags.dart` で `shoppingLocationFeatureEnabled = false` であることを確認（`lib/features/settings/page.dart:206` の `if (shoppingLocationFeatureEnabled)` で「通知」セクションごと非表示になる）。上記スクショ群でも「外観」セクションの直後に「通知」セクションを挟まず「プレミアムにアップグレード」カードが続いており、実機表示でも「通知」セクションが存在しないことを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/6b38ec6a-fba2-4c1e-845e-c1b003e1865c.png" width="320">

</details>

</details>

---

## 4. プレミアム会員カード

- [x] **非プレミアム時はカードに「はじめる」ボタンが表示されPaywallPageに遷移する**: `surface2` 背景（グラデーションなし）のカードに「プレミアムにアップグレード」の見出しと「はじめる」ボタンが表示され、タップでPaywallPageに遷移する。maestro/flows/shared/mock_purchase.yaml で確認。
- [x] **プレミアム加入後はカードがグラデーション表示に切り替わる**: 加入済みの場合、カードがaccentグラデーション背景になり「プレミアム会員」「すべての機能が利用できます」の表示に変わり「はじめる」ボタンが消える。maestro/flows/iap_purchase_monthly.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **非プレミアム時はカードに「はじめる」ボタンが表示されPaywallPageに遷移する**: `surface2` 背景（グラデーションなし）のカードに「プレミアムにアップグレード」の見出しと「はじめる」ボタンが表示され、タップでPaywallPageに遷移する。maestro/flows/shared/mock_purchase.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/iap_purchase_monthly.yaml`（内部で`shared/mock_purchase.yaml`を実行）で、非プレミアム状態の設定画面で「プレミアムにアップグレード」見出し＋グラデーションなしのカードに「はじめる」ボタンが表示されることを確認（下記スクショ）。同フロー内で「はじめる」タップ→PaywallPage（「購入」ボタン表示）へ遷移することも確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/6b38ec6a-fba2-4c1e-845e-c1b003e1865c.png" width="320">

</details>

### **プレミアム加入後はカードがグラデーション表示に切り替わる**: 加入済みの場合、カードがaccentグラデーション背景になり「プレミアム会員」「すべての機能が利用できます」の表示に変わり「はじめる」ボタンが消える。maestro/flows/iap_purchase_monthly.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/iap_purchase_monthly.yaml` 実行。RC Test Storeでのmonthly購入完了後、設定画面のカードがaccentグラデーション背景に変わり「プレミアム会員」「すべての機能が利用できます」表示になり「はじめる」ボタンが消えていることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/333f8b35-aee2-43d9-8069-c53410aa8d1f.png" width="320">

</details>

</details>

---

## 5. アプリについて

- [ ] **利用規約・プライバシーポリシー・特定商法に基づく表記のリンクが外部ブラウザで開く**: 「アプリについて」セクションの3セルがそれぞれ対応するURLを外部ブラウザで開く。
  - ⏭️ 一部確認不可: 「プライバシーポリシー」は外部ブラウザ（Safari）で正しく開くことを確認した。一方「利用規約」（`https://bannzai.github.io/shoppinglist/TermsOfService`）と「特定商法取引法に基づく表記」（`https://bannzai.github.io/shoppinglist/SpecifiedCommercialTransactionAct`）は外部ブラウザは開くもののGitHub Pagesの404ページが表示された（リポジトリ側のファイル名が`Terms.md`/`SpecifiedCommercialTransactionAct-ja.md`でURLと不一致）。
  - ❌ 失敗: 「利用規約」「特定商法取引法に基づく表記」タップ後、Safariで404 (File not found) が表示される。再現手順: 設定画面→「アプリについて」→該当セルタップ。 https://github.com/bannzai/shoppinglist/issues/476
- [x] **「お問い合わせ」セルからInquiryPageに遷移する**: タップでinquiry機能のフォーム画面に遷移する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **利用規約・プライバシーポリシー・特定商法に基づく表記のリンクが外部ブラウザで開く**: 「アプリについて」セクションの3セルがそれぞれ対応するURLを外部ブラウザで開く。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで3セルをそれぞれタップし確認。「プライバシーポリシー」は外部ブラウザで正しくコンテンツが表示された。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/d066fc97-313e-48c5-9234-7dbefe9b4e04.png" width="320">

「利用規約」は404。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/8a443b0a-dd70-4d73-9cab-ac8394e77827.png" width="320">

「特定商法取引法に基づく表記」も404。issue化: https://github.com/bannzai/shoppinglist/issues/476

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/28c08b7c-845d-404d-84d5-1b424c5394a8.png" width="320">

</details>

### **「お問い合わせ」セルからInquiryPageに遷移する**: タップでinquiry機能のフォーム画面に遷移する。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで「お問い合わせ」セルをタップし、InquiryPage（AppBarタイトル「お問い合わせ」、メールアドレス欄・問い合わせ種類選択・本文欄・「送信する」ボタン）に遷移することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/99588eb9-32cf-4063-8218-d915713eee2d.png" width="320">

</details>

</details>

---

## 6. デバッグメニュー（デバッグビルドのみ）

- [x] **「開発者オプション」セルはデバッグビルドのみ表示され、タップでDeveloperOptionsPageに遷移する**: `kDebugMode` の時だけ「デバッグ」セクションが表示される。E2Eでシェイクジェスチャーが使えないSimulator向けの代替導線。maestro/flows/auth_page_test_05_firestore_dump.yaml, auth_page_test_05b_devopt_info.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **「開発者オプション」セルはデバッグビルドのみ表示され、タップでDeveloperOptionsPageに遷移する**: `kDebugMode` の時だけ「デバッグ」セクションが表示される。E2Eでシェイクジェスチャーが使えないSimulator向けの代替導線。maestro/flows/auth_page_test_05_firestore_dump.yaml, auth_page_test_05b_devopt_info.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/auth_page_test_05b_devopt_info.yaml` 実行。DEBUGバナー表示状態で設定画面に「デバッグ」セクション「開発者オプション」セルが表示され、タップでDeveloperOptionsPage（UID/defaultGroupID/Premium状態/Offering構成等の表示）に遷移することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/39614ae8-8222-460e-9e69-451674cad558.png" width="320">

</details>

</details>

---

## 7. サインアウト・アカウント削除

- [x] **サインアウトは確認ダイアログを経由し、キャンセルでサインアウトされない**: 「サインアウト」ボタンタップで確認ダイアログ（「サインアウトしますか?」）が表示され、「キャンセル」で閉じてサインアウトされないことを確認する。maestro/flows/design_v2_settings_paywall.yaml で確認。
- [x] **デバッグビルドではサインアウト確定後に終了アラートが出ない**: 確認ダイアログで「サインアウト」を選ぶとサインアウトされるが、デバッグビルドでは「サインアウトしました」の終了アラートが出ずアプリも終了しない（`kDebugMode` ガードの回帰防止）。maestro/flows/auth_sign_out.yaml で確認。
- [x] **アカウント削除は確認ダイアログを経由し、削除実行後は完了ダイアログが表示される**: 「アカウントを削除する」→確認ダイアログの「キャンセル」では削除されず、「削除する」確定後は `FirebaseAuth.instance.currentUser?.delete()` が成功し「アカウントを削除しました」ダイアログが表示される。`requires-recent-login` で再認証が必要になるケースはApple/Google連携時のみ発生し実OAuth操作を要するため、Simulatorでの完全な確認は代替困難（匿名サインインアカウントで正常系のみ確認する）。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **サインアウトは確認ダイアログを経由し、キャンセルでサインアウトされない**: 「サインアウト」ボタンタップで確認ダイアログ（「サインアウトしますか?」）が表示され、「キャンセル」で閉じてサインアウトされないことを確認する。maestro/flows/design_v2_settings_paywall.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/design_v2_settings_paywall.yaml` 実行。「サインアウト」タップで「サインアウトしますか?」確認ダイアログが表示され、「キャンセル」タップでダイアログが閉じ設定画面に留まる（サインアウトされない）ことを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/e1504b75-e4a9-4c5a-9abf-36fdd3c08fe4.png" width="320">

</details>

### **デバッグビルドではサインアウト確定後に終了アラートが出ない**: 確認ダイアログで「サインアウト」を選ぶとサインアウトされるが、デバッグビルドでは「サインアウトしました」の終了アラートが出ずアプリも終了しない（`kDebugMode` ガードの回帰防止）。maestro/flows/auth_sign_out.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/auth_sign_out.yaml` 実行。確認ダイアログで「サインアウト」を確定した後、「終了する」アラートが表示されない（`assertNotVisible: "終了する"`）ことを確認した。mobile-mcpで直後の画面を確認し、設定画面のまま（DEBUGバナー表示）でアプリが終了していないことも確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/7c0ad609-0fe5-4a93-82db-ad4b99c3505d.png" width="320">

</details>

### **アカウント削除は確認ダイアログを経由し、削除実行後は完了ダイアログが表示される**: 「アカウントを削除する」→確認ダイアログの「キャンセル」では削除されず、「削除する」確定後は `FirebaseAuth.instance.currentUser?.delete()` が成功し「アカウントを削除しました」ダイアログが表示される。`requires-recent-login` で再認証が必要になるケースはApple/Google連携時のみ発生し実OAuth操作を要するため、Simulatorでの完全な確認は代替困難（匿名サインインアカウントで正常系のみ確認する）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

アドホックMaestroフロー（`zz_adhoc_account_delete.yaml`）で、匿名サインインアカウントに対し「アカウントを削除する」→「ユーザー情報を削除します」確認ダイアログ→「キャンセル」で削除されないことを確認後、再度「アカウントを削除する」→「削除する」確定で`FirebaseAuth.instance.currentUser?.delete()`が成功し「アカウントを削除しました」ダイアログが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/3074bba2-1097-4d34-bff0-307f3896d22e.png" width="320">

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/fb0d2286-a5b9-49d6-b2a2-150ece1f950b.png" width="320">

なお本項目の検証中に別件のバグを発見した: 完了ダイアログの「終了する」ボタンは`kDebugMode`の区別なく無条件に`exit(0)`を呼び出す実装になっており、サインアウト側（本セクション2項目目）が持つデバッグ時の終了抑止と方針が食い違っている。issue化: https://github.com/bannzai/shoppinglist/issues/477

</details>

</details>
