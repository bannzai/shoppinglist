---
feature: settings
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# settings QA

## 1. プロフィール

- [ ] **表示名を編集すると自動保存される**: 「自分の表示名」欄に入力しキーボードのEnter/完了でフォーカスを外すと自動保存され、「表示名を更新しました」SnackBarが表示される（保存ボタンはなく、blurが保存トリガー）。maestro/flows/settings_profile.yaml で確認。
- [ ] **保存済みの値と同じ場合は更新処理をスキップする**: 表示名を変更せずフォーカスを外した場合、更新処理が走らず「表示名を更新しました」SnackBarも表示されないことを確認する。

---

## 2. グループ

- [ ] **「グループ管理」から一覧画面に遷移する**: 「グループ」セクションのAppCellタップでGroupListPageに遷移する。maestro/flows/settings_profile.yaml で確認。
- [ ] **「招待コードでグループに参加」から参加画面に遷移する**: AppCellタップでGroupInvitationAcceptPageに遷移する。

---

## 3. 外観・通知（プレミアムゲート）

- [ ] **プレミアム会員はテーマカラー設定画面に遷移できる**: 「テーマカラー」ListTileタップでThemeColorSelectionPageに遷移し、非プレミアム時のSnackBarが出ないことを確認する。maestro/flows/premium_theme_color_setting.yaml で確認。
- [ ] **非プレミアム会員はテーマカラー変更がSnackBarでブロックされる**: 「テーマカラー」タップで「テーマカラーの変更はプレミアム機能です」SnackBarが表示され、「アップグレード」アクションでPaywallPageに遷移する。maestro/flows/theme_color_setting_non_premium.yaml で確認。
- [ ] **現在のfeature flag設定では「通知」セクション（位置情報リマインダー）が表示されない**: `shoppingLocationFeatureEnabled = false`（ファーストリリースでは非表示、issue #465）のため、設定画面をスクロールしても「通知」セクション自体が存在しないことを確認する。

---

## 4. プレミアム会員カード

- [ ] **非プレミアム時はカードに「はじめる」ボタンが表示されPaywallPageに遷移する**: `surface2` 背景（グラデーションなし）のカードに「プレミアムにアップグレード」の見出しと「はじめる」ボタンが表示され、タップでPaywallPageに遷移する。maestro/flows/shared/mock_purchase.yaml で確認。
- [ ] **プレミアム加入後はカードがグラデーション表示に切り替わる**: 加入済みの場合、カードがaccentグラデーション背景になり「プレミアム会員」「すべての機能が利用できます」の表示に変わり「はじめる」ボタンが消える。maestro/flows/iap_purchase_monthly.yaml で確認。

---

## 5. アプリについて

- [ ] **利用規約・プライバシーポリシー・特定商法に基づく表記のリンクが外部ブラウザで開く**: 「アプリについて」セクションの3セルがそれぞれ対応するURLを外部ブラウザで開く。
- [ ] **「お問い合わせ」セルからInquiryPageに遷移する**: タップでinquiry機能のフォーム画面に遷移する。

---

## 6. デバッグメニュー（デバッグビルドのみ）

- [ ] **「開発者オプション」セルはデバッグビルドのみ表示され、タップでDeveloperOptionsPageに遷移する**: `kDebugMode` の時だけ「デバッグ」セクションが表示される。E2Eでシェイクジェスチャーが使えないSimulator向けの代替導線。maestro/flows/auth_page_test_05_firestore_dump.yaml, auth_page_test_05b_devopt_info.yaml で確認。

---

## 7. サインアウト・アカウント削除

- [ ] **サインアウトは確認ダイアログを経由し、キャンセルでサインアウトされない**: 「サインアウト」ボタンタップで確認ダイアログ（「サインアウトしますか?」）が表示され、「キャンセル」で閉じてサインアウトされないことを確認する。maestro/flows/design_v2_settings_paywall.yaml で確認。
- [ ] **デバッグビルドではサインアウト確定後に終了アラートが出ない**: 確認ダイアログで「サインアウト」を選ぶとサインアウトされるが、デバッグビルドでは「サインアウトしました」の終了アラートが出ずアプリも終了しない（`kDebugMode` ガードの回帰防止）。maestro/flows/auth_sign_out.yaml で確認。
- [ ] **アカウント削除は確認ダイアログを経由し、削除実行後は完了ダイアログが表示される**: 「アカウントを削除する」→確認ダイアログの「キャンセル」では削除されず、「削除する」確定後は `FirebaseAuth.instance.currentUser?.delete()` が成功し「アカウントを削除しました」ダイアログが表示される。`requires-recent-login` で再認証が必要になるケースはApple/Google連携時のみ発生し実OAuth操作を要するため、Simulatorでの完全な確認は代替困難（匿名サインインアカウントで正常系のみ確認する）。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **サインアウトは確認ダイアログを経由し、キャンセルでサインアウトされない**: 「サインアウト」ボタンタップで確認ダイアログ（「サインアウトしますか?」）が表示され、「キャンセル」で閉じてサインアウトされないことを確認する。maestro/flows/design_v2_settings_paywall.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **デバッグビルドではサインアウト確定後に終了アラートが出ない**: 確認ダイアログで「サインアウト」を選ぶとサインアウトされるが、デバッグビルドでは「サインアウトしました」の終了アラートが出ずアプリも終了しない（`kDebugMode` ガードの回帰防止）。maestro/flows/auth_sign_out.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **アカウント削除は確認ダイアログを経由し、削除実行後は完了ダイアログが表示される**: 「アカウントを削除する」→確認ダイアログの「キャンセル」では削除されず、「削除する」確定後は `FirebaseAuth.instance.currentUser?.delete()` が成功し「アカウントを削除しました」ダイアログが表示される。`requires-recent-login` で再認証が必要になるケースはApple/Google連携時のみ発生し実OAuth操作を要するため、Simulatorでの完全な確認は代替困難（匿名サインインアカウントで正常系のみ確認する）。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
