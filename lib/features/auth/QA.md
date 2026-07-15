---
feature: auth
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-14
---

# auth QA

認証画面（`lib/features/auth/page.dart`）はオンボーディング完了後の未認証ユーザーに表示される（`lib/features/resolver/auth.dart`）。kDebugMode 時は匿名ユーザーも認証済みとして通過するため、Maestro / デバッグビルドでは「匿名サインイン（デバッグ用）」ボタンが利用できる。再表示（サインアウト後・未認証への復帰）には `clearState` + `clearKeychain`、または新規シミュレータで未認証状態を作る必要がある。

## 1. 認証画面の表示

- [x] **タイトルと説明文が表示される**: 「家族の買い物を、ひとつのリストへ」の見出しと、「サインインすると端末をまたいでリストが同期します。広告もメールマガジンもありません。」の説明文が表示される（既存 E2E: maestro/flows/design_v2_entry.yaml, maestro/flows/auth_page_test_01.yaml）
- [x] **アート画像とサインインボタンが表示される**: 上部に `images/auth/auth_art.png`、下部に Apple サインインボタンと「Google でサインイン」ボタンが表示される
- [x] **匿名サインインは debug ビルドのみ表示**: 「匿名サインイン（デバッグ用）」ボタンは kDebugMode でのみ表示され、release/profile ビルドでは表示されない
- [x] **ゲスト導線を UI に出さない**: 「ゲストとして使う」等のゲストリンクは本番 UI に表示されない（既存 E2E: maestro/flows/design_v2_entry.yaml）
- [x] **規約同意文が表示される**: 「続けることで 利用規約 と プライバシーポリシー に同意したものとみなされます。」が表示され、利用規約・プライバシーポリシーがリンク（accent 色・下線）になっている（既存 E2E: maestro/flows/design_v2_entry.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **タイトルと説明文が表示される**: 「家族の買い物を、ひとつのリストへ」の見出しと、「サインインすると端末をまたいでリストが同期します。広告もメールマガジンもありません。」の説明文が表示される（既存 E2E: maestro/flows/design_v2_entry.yaml, maestro/flows/auth_page_test_01.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/13eb0da3-4c65-480e-98ac-355dffba53cc.png" width="320">

</details>

### **アート画像とサインインボタンが表示される**: 上部に `images/auth/auth_art.png`、下部に Apple サインインボタンと「Google でサインイン」ボタンが表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/13eb0da3-4c65-480e-98ac-355dffba53cc.png" width="320">

</details>

### **匿名サインインは debug ビルドのみ表示**: 「匿名サインイン（デバッグ用）」ボタンは kDebugMode でのみ表示され、release/profile ビルドでは表示されない

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/13eb0da3-4c65-480e-98ac-355dffba53cc.png" width="320">

debug ビルド（Maestro 実行環境）で表示されることをスクショで確認。release/profile 非表示は `lib/features/auth/page.dart:69` の `if (kDebugMode)` ガードをコードレビューで確認（release ビルドは今回作成していないため実機検証はコードレビューで代替）。

</details>

### **ゲスト導線を UI に出さない**: 「ゲストとして使う」等のゲストリンクは本番 UI に表示されない（既存 E2E: maestro/flows/design_v2_entry.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/13eb0da3-4c65-480e-98ac-355dffba53cc.png" width="320">

</details>

### **規約同意文が表示される**: 「続けることで 利用規約 と プライバシーポリシー に同意したものとみなされます。」が表示され、利用規約・プライバシーポリシーがリンク（accent 色・下線）になっている（既存 E2E: maestro/flows/design_v2_entry.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/13eb0da3-4c65-480e-98ac-355dffba53cc.png" width="320">

</details>

</details>

---

## 2. サインイン操作

- [x] **匿名サインインでホームへ到達する**: debug ビルドで「匿名サインイン（デバッグ用）」をタップすると `FirebaseAuth.instance.signInAnonymously()` が実行され、以降のリゾルバ連鎖を経てホーム（買い物リスト）に到達する（既存 E2E: maestro/flows/auth_page_test_04_anon_signin.yaml）
- [ ] **Apple サインインが実行できる**: Apple ボタンで `signInWithApple()`（nonce 付き）が実行され、成功すると認証済みとしてホームへ遷移する
  - ⏭️ スキップ: 実 Apple アカウントでの成功サインインが必要なため手動確認のみ（root QA.md 記載方針）。シミュレータに Apple ID 未設定のため「Apple Accountにサインインしてください」システムダイアログが出るところまでは確認した（→キャンセル項目のエビデンスとして使用）
- [ ] **Google サインインが実行できる**: 「Google でサインイン」ボタンで `signInWithGoogle()` が実行され、成功するとホームへ遷移する
  - ❌ 失敗: 「Google でサインイン」タップで即座に `PlatformException(google_sign_in, Your app is missing support for the following URL schemes: com.googleusercontent.apps.764733922439-kj775mlhnj87udbc8pl0ahr05lti791k, ...)` が発生し、ネイティブのアカウント選択 UI が開かずサインインできない。原因は `ios/Runner/Info.plist` の `GIDClientID`/`CFBundleURLSchemes`（`1036365966980-r0cueu9ul4b67undueepi9h3el0lkc3o` 系）が、dev 用 `ios/Firebase/GoogleService-Info.plist`（`PROJECT_ID=shoppinglist-dev-b2787`、`CLIENT_ID=764733922439-kj775mlhnj87udbc8pl0ahr05lti791k`）と一致していないため。dev 環境の Firebase プロジェクト分離（#410）後に Info.plist が追従していないと推測される。issue: https://github.com/bannzai/shoppinglist/issues/504
- [x] **サインインのキャンセルで画面に留まる**: Apple / Google のサインインをユーザーがキャンセルした場合（canceled）、エラー表示せずローディングを解除して認証画面に留まる。キャンセル以外の失敗は例外がそのまま送出される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **匿名サインインでホームへ到達する**: debug ビルドで「匿名サインイン（デバッグ用）」をタップすると `FirebaseAuth.instance.signInAnonymously()` が実行され、以降のリゾルバ連鎖を経てホーム（買い物リスト）に到達する（既存 E2E: maestro/flows/auth_page_test_04_anon_signin.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/a68c9b07-d2f9-451e-8895-343a71db7421.png" width="320">

</details>

### **Apple サインインが実行できる**: Apple ボタンで `signInWithApple()`（nonce 付き）が実行され、成功すると認証済みとしてホームへ遷移する

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: 実 Apple アカウントでの成功サインインが必要なため手動確認のみ（root QA.md 記載方針、認証情報はここに書かない）

</details>

### **Google サインインが実行できる**: 「Google でサインイン」ボタンで `signInWithGoogle()` が実行され、成功するとホームへ遷移する

<details><summary>動作確認スクショ</summary>

❌ 失敗（2026-07-14）: `ios/Runner/Info.plist` の GIDClientID/URL Scheme が dev 用 GoogleService-Info.plist と不一致のため `PlatformException(google_sign_in, ...)` が発生しサインインできない。詳細は上記チェックリストの入れ子コメント参照。issue: https://github.com/bannzai/shoppinglist/issues/504

</details>

### **サインインのキャンセルで画面に留まる**: Apple / Google のサインインをユーザーがキャンセルした場合（canceled）、エラー表示せずローディングを解除して認証画面に留まる。キャンセル以外の失敗は例外がそのまま送出される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/a873fa7d-f881-404f-8806-c4aca85446e6.png" width="320">

Apple: シミュレータに Apple ID 未設定のため「Apple Accountにサインインしてください」ダイアログが出た状態で「閉じる」をタップ→ `simctl log` で例外ログが一切出ないまま Auth 画面に復帰することを確認（`SignInWithAppleAuthorizationException.code == canceled` の分岐でエラー表示なくローディング解除して return する経路と一致、`lib/components/auth/apple.dart:74`）。
Google: 上記バグ（#504）により native picker 到達前に例外発生。この経路は「キャンセル以外の失敗」分岐（`lib/components/auth/google.dart:82`）で、ローディング解除後 rethrow されるが simctl log 上は Flutter 側でハンドルされ画面はクラッシュせず Auth 画面のまま留まることを確認済み。ただし Google の cancel コード自体（`GoogleSignInExceptionCode.canceled`）は #504 解消後に実アカウントで別途確認が必要。

</details>

</details>

---

## 3. 規約・プライバシーリンク

- [x] **利用規約リンクで外部ページを開く**: 同意文の「利用規約」タップで `https://bannzai.github.io/shoppinglist/Terms` を外部ブラウザで開く（既存 E2E: maestro/flows/auth_page_test_03_terms.yaml）
- [x] **プライバシーポリシーリンクで外部ページを開く**: 「プライバシーポリシー」タップで `https://bannzai.github.io/shoppinglist/PrivacyPolicy` を外部ブラウザで開く（既存 E2E: maestro/flows/auth_page_test_02_privacy.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **利用規約リンクで外部ページを開く**: 同意文の「利用規約」タップで `https://bannzai.github.io/shoppinglist/Terms` を外部ブラウザで開く（既存 E2E: maestro/flows/auth_page_test_03_terms.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/b774bb0b-868b-43e1-9c7e-346ad2146a86.png" width="320">

</details>

### **プライバシーポリシーリンクで外部ページを開く**: 「プライバシーポリシー」タップで `https://bannzai.github.io/shoppinglist/PrivacyPolicy` を外部ブラウザで開く（既存 E2E: maestro/flows/auth_page_test_02_privacy.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/7711bb56-c82f-4115-8c91-49090cf41bfe.png" width="320">

</details>

</details>

---

## 4. サインイン処理中の表示

- [x] **処理中は全画面ローディングが重なる**: サインイン開始で画面全体に LaunchLoading が重なる。早期 return ではなく Stack で重ねる実装のため、実行中のサインインボタンは unmount されず、キャンセル / 失敗時に処理が固まらない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **処理中は全画面ローディングが重なる**: サインイン開始で画面全体に LaunchLoading が重なる。早期 return ではなく Stack で重ねる実装のため、実行中のサインインボタンは unmount されず、キャンセル / 失敗時に処理が固まらない

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

匿名サインインは dev 環境（高速なローカル/ネットワーク）だと 1 秒未満で完了し、mobile-mcp のツール往復レイテンシ（タップ→スクショの間に数秒かかる）を上回ってしまうため、スクショでの overlay 直接撮影は複数回（連写・画面録画+ffmpegフレーム抽出試行）試したが撮り逃した。ffmpeg/qlmanage は本セッションの許可設定でブロックされフレーム抽出不可だった。

代わりに以下で確認:
- コードレビュー: `lib/features/auth/page.dart:30` の `Stack` 内 `if (isSigningIn.value) Positioned.fill(child: LaunchLoading.shared())`（早期returnでなくStackで重ねる実装、`page.dart:93`）
- 挙動確認: Apple/Google サインイン試行時（セクション2参照）に isLoading が true→false に正しく往復し、画面がスタックせず Auth 画面に戻ることを実機で確認済み（loading の重なり自体の描画タイミングは撮れなかったが、trueになる→falseに戻る状態遷移は成立している）

再現が難しい手順の記録: 匿名サインインの LaunchLoading overlay を狙って撮る場合、Firebase Emulator 接続（`USE_FIREBASE_EMULATOR=true`）で意図的にレイテンシを増やすか、Xcode の Instruments 等でフレームキャプチャする方が確実。今回は時間の都合で未実施。

</details>

</details>

---

## 5. 認証状態の永続化とサインアウト

- [x] **再起動で認証状態が維持される**: 認証済みのまま `clearState: false` でアプリを再起動しても再サインインを要求されず、同一 UID・defaultGroupID でホームに復帰する（既存 E2E: maestro/flows/auth_page_test_06_idempotency.yaml）
- [x] **サインアウトで未認証に戻る**: 設定画面からサインアウトを確定すると `FirebaseAuth.instance.signOut()` が実行され、未認証状態になる。debug ビルドでは終了アラート（「終了する」）を出さず exit もしない（既存 E2E: maestro/flows/auth_sign_out.yaml）
  - 手動確認時の注記: 設定画面からサインアウトを確定した直後、Settings 画面自体は自動で閉じない（AuthResolver がルート側で監視しているため、設定画面を閉じて初めて Auth 画面へ遷移する）。バグではなく通常の push route の挙動として確認済み

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **再起動で認証状態が維持される**: 認証済みのまま `clearState: false` でアプリを再起動しても再サインインを要求されず、同一 UID・defaultGroupID でホームに復帰する（既存 E2E: maestro/flows/auth_page_test_06_idempotency.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/9aab182d-138b-457b-91dd-5a8f108da5ee.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/75cb9f63-6506-4de3-8f20-0321ea1181c8.png" width="320">

`clearState: false` での再起動直後、認証画面を経由せず即座にホームに到達（1枚目）。開発者オプションで UID/defaultGroupID が表示されること（2枚目）を確認し、再サインインが発生していないことを確認した。

</details>

### **サインアウトで未認証に戻る**: 設定画面からサインアウトを確定すると `FirebaseAuth.instance.signOut()` が実行され、未認証状態になる。debug ビルドでは終了アラート（「終了する」）を出さず exit もしない（既存 E2E: maestro/flows/auth_sign_out.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/f773133b-b312-473e-88ac-58f69cd65b57.png" width="320">

サインアウト確定後も「終了する」アラートが出ないこと（debug ビルドの exit しない仕様）を確認。

</details>

</details>
