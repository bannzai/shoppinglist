---
feature: auth
verification: mobile-mcp, maestro
last_verified_commit: 8ee973c31d4b8e2d333a459d1bfe8173e03384f7
last_verified_at: 2026-08-19
---

# auth QA

認証画面（`lib/features/auth/page.dart`）はオンボーディング完了後の未認証ユーザーに表示される（`lib/features/resolver/auth.dart`）。匿名（ゲスト）ユーザーはビルドを問わず認証済みとして本体を利用でき（issue #548: ストア審査対応）、「サインインせずにはじめる」ボタンが release を含む全ビルドで表示される。アカウントは後から設定画面のアカウントセクションでリンクする。再表示（サインアウト後・未認証への復帰）には `clearState` + `clearKeychain`、または新規シミュレータで未認証状態を作る必要がある。

## 1. 認証画面の表示

- [x] **タイトルと説明文が表示される**: 「家族の買い物を、ひとつのリストへ」の見出しと、「サインインすると端末をまたいでリストが同期します。広告もメールマガジンもありません。」の説明文が表示される（既存 E2E: maestro/flows/design_v2_entry.yaml, maestro/flows/auth_page_test_01.yaml）
- [x] **アート画像とサインインボタンが表示される**: 上部に `images/auth/auth_art.png`、下部に Apple サインインボタンと「Google でサインイン」ボタンが表示される
- [x] **ゲスト開始ボタンが常時表示される**: 「サインインせずにはじめる」ボタンと「あとから設定画面でアカウントをリンクできます」の注記が release を含む全ビルドで表示される（issue #548 で「匿名サインイン（デバッグ用）」の kDebugMode ガードを撤廃。E2E: maestro/flows/design_v2_entry.yaml。widget test: test/features/auth/page_test.dart はボタンの存在確認のみで release モードは非検証）
- [x] **規約同意文が表示される**: 「続けることで 利用規約 と プライバシーポリシー に同意したものとみなされます。」が表示され、利用規約・プライバシーポリシーがリンク（accent 色・下線）になっている（既存 E2E: maestro/flows/design_v2_entry.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **タイトルと説明文が表示される**: 「家族の買い物を、ひとつのリストへ」の見出しと、「サインインすると端末をまたいでリストが同期します。広告もメールマガジンもありません。」の説明文が表示される（既存 E2E: maestro/flows/design_v2_entry.yaml, maestro/flows/auth_page_test_01.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/5c904ee9-36b3-4484-af42-fc346ea4fb6d.png" width="320">

gen-l10n 導入（UI 文字列の l10n 化）後も ja ロケールの見出し・説明文は従来どおり表示され、改行位置・行間の崩れはない。

</details>

### **アート画像とサインインボタンが表示される**: 上部に `images/auth/auth_art.png`、下部に Apple サインインボタンと「Google でサインイン」ボタンが表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/5c904ee9-36b3-4484-af42-fc346ea4fb6d.png" width="320">

</details>

### **ゲスト開始ボタンが常時表示される**: 「サインインせずにはじめる」ボタンと「あとから設定画面でアカウントをリンクできます」の注記が release を含む全ビルドで表示される（issue #548 で「匿名サインイン（デバッグ用）」の kDebugMode ガードを撤廃。E2E: maestro/flows/design_v2_entry.yaml。widget test: test/features/auth/page_test.dart はボタンの存在確認のみで release モードは非検証）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/5c904ee9-36b3-4484-af42-fc346ea4fb6d.png" width="320">

Google サインインボタンの下に「サインインせずにはじめる」ボタンと「あとから設定画面でアカウントをリンクできます」の注記が表示される。旧仕様（匿名サインインは debug ビルドのみ）のエビデンス（2026-07-14）は issue #548 で無効化済みで、本エビデンスが現仕様のもの。release ビルドでの表示の根拠はコード上 `GuestStartButton` に `kDebugMode` 等のビルド種別ガードが無いこと（lib/features/auth/page.dart）。widget test（test/features/auth/page_test.dart）はボタンの存在確認のみで、release モードでの表示は直接検証していない（ガードが再導入された場合はテストでは検出できないため、コードレビューで守る）。

</details>

### **規約同意文が表示される**: 「続けることで 利用規約 と プライバシーポリシー に同意したものとみなされます。」が表示され、利用規約・プライバシーポリシーがリンク（accent 色・下線）になっている（既存 E2E: maestro/flows/design_v2_entry.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/5c904ee9-36b3-4484-af42-fc346ea4fb6d.png" width="320">

l10n 化で同意文はテンプレート（`authAgreementNote`）+ リンクラベル（`settingsTermsOfService` / `settingsPrivacyPolicy`）の組み立てになったが、ja では従来どおり「続けることで 利用規約 と プライバシーポリシー に同意したものとみなされます。」と表示され、リンク 2 箇所が accent 色・下線で描画される。

</details>

</details>

---

## 2. サインイン操作

- [x] **ゲストで開始してホームへ到達する**: 「サインインせずにはじめる」をタップすると `FirebaseAuth.instance.signInAnonymously()` が実行され、以降のリゾルバ連鎖を経てホーム（買い物リスト）に到達する（issue #548 でボタン名を変更。既存 E2E: maestro/flows/auth_page_test_04_anon_signin.yaml）
- [ ] **Apple サインインが実行できる**: Apple ボタンで `signInWithApple()`（nonce 付き）が実行され、成功すると認証済みとしてホームへ遷移する
  - ⏭️ スキップ: 実 Apple アカウントでの成功サインインが必要なため手動確認のみ（root QA.md 記載方針）。シミュレータに Apple ID 未設定のため「Apple Accountにサインインしてください」システムダイアログが出るところまでは確認した（→キャンセル項目のエビデンスとして使用）
- [ ] **Google サインインが実行できる**: 「Google でサインイン」ボタンで `signInWithGoogle()` が実行され、成功するとホームへ遷移する
  - ⏭️ スキップ: 実 Google アカウントでの成功サインインが必要なため手動確認のみ（root QA.md 記載方針）。2026-07-14 の失敗記録（PlatformException）は PR https://github.com/bannzai/shoppinglist/pull/505 で Info.plist の GIDClientID / URL Scheme を xcconfig 経由で dev/prod に注入する形に修正済み
- [x] **サインインのキャンセルで画面に留まる**: Apple / Google のサインインをユーザーがキャンセルした場合（canceled）、エラー表示せずローディングを解除して認証画面に留まる。キャンセル以外の失敗は例外がそのまま送出される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ゲストで開始してホームへ到達する**: 「サインインせずにはじめる」をタップすると `FirebaseAuth.instance.signInAnonymously()` が実行され、以降のリゾルバ連鎖を経てホーム（買い物リスト）に到達する（issue #548 でボタン名を変更。既存 E2E: maestro/flows/auth_page_test_04_anon_signin.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/a68c9b07-d2f9-451e-8895-343a71db7421.png" width="320">

2026-08-19 の再検証は未実施。未認証状態を作り直すため `maestro/flows/auth_page_test_01.yaml`（`clearState: true` + `clearKeychain: true`）を実行したところ、以降アプリが LaunchLoading（白画面）のまま起動を完了しなくなり、ゲスト開始からホーム到達までを流せなかった（詳細は root QA.md の実行ナレッジ「clearState + clearKeychain 後に起動が完了しなくなる」を参照）。同セッションで AuthPage 上のボタン表示・文言（issue #548 の現仕様）は確認済み。

</details>

### **Apple サインインが実行できる**: Apple ボタンで `signInWithApple()`（nonce 付き）が実行され、成功すると認証済みとしてホームへ遷移する

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: 実 Apple アカウントでの成功サインインが必要なため手動確認のみ（root QA.md 記載方針、認証情報はここに書かない）

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/ae84d87f-261b-4701-b1d4-6729f95ddcc8.png" width="320">

シミュレータに Apple ID 未設定のため、Apple ボタンのタップで「Apple Account にサインインしてください」システムダイアログまで到達することは確認した（成功サインインは未検証）。

</details>

### **Google サインインが実行できる**: 「Google でサインイン」ボタンで `signInWithGoogle()` が実行され、成功するとホームへ遷移する

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: 実 Google アカウントでの成功サインインが必要なため手動確認のみ（root QA.md 記載方針）。2026-07-14 の失敗記録（PlatformException）は PR https://github.com/bannzai/shoppinglist/pull/505 で Info.plist の GIDClientID / URL Scheme を xcconfig 経由で dev/prod に注入する形に修正済み

</details>

### **サインインのキャンセルで画面に留まる**: Apple / Google のサインインをユーザーがキャンセルした場合（canceled）、エラー表示せずローディングを解除して認証画面に留まる。キャンセル以外の失敗は例外がそのまま送出される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/66219b37-25a1-4704-8568-b8678e99eeb4.png" width="320">

Apple: シミュレータに Apple ID 未設定のため「Apple Account にサインインしてください」ダイアログが出た状態で「閉じる」をタップ → エラー表示もローディングの残留もなく Auth 画面に復帰することを確認（`SignInWithAppleAuthorizationException.code == canceled` の分岐でエラー表示なくローディング解除して return する経路と一致、`lib/components/auth/apple.dart`）。`flutter run` のログにも例外は出力されなかった。
Google: 実 Google アカウントが必要なため、キャンセル経路（`GoogleSignInExceptionCode.canceled`）は未検証。

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

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/2cc8552c-8586-4451-9a6d-b7e1e86474eb.png" width="320">

同意文中の「利用規約」タップで Safari が起動し `bannzai.github.io` の「買い物リスト利用規約」が表示される。mobile-mcp でタップする場合、リンク span はアクセシビリティツリーに独立した要素として出ないため座標指定になる。同意文 1 行目の文字の中心（iPhone 16 相当・402x874pt で y=790 付近）を狙う必要があり、数 pt 上（y=784）だと無反応になる。

</details>

### **プライバシーポリシーリンクで外部ページを開く**: 「プライバシーポリシー」タップで `https://bannzai.github.io/shoppinglist/PrivacyPolicy` を外部ブラウザで開く（既存 E2E: maestro/flows/auth_page_test_02_privacy.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-08-19**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260819/7ea1ee04-876a-4250-81d9-ae44d30a3b41.png" width="320">

</details>

</details>

---

## 4. サインイン処理中の表示

- [ ] **処理中は全画面ローディングが重なる**: サインイン開始で画面全体に LaunchLoading が重なる。早期 return ではなく Stack で重ねる実装のため、実行中のサインインボタンは unmount されず、キャンセル / 失敗時に処理が固まらない
  - ⏭️ スキップ: overlay の表示時間が 1 秒未満で、mobile-mcp のタップ→スクショ往復レイテンシではスクショに収められない。2026-07-14 にコードレビューと状態遷移（true→false の往復）で間接確認済みだが、画像エビデンスが無いためチェックは付けない。撮影するなら Firebase Emulator 接続でレイテンシを増やすか、タップと `xcrun simctl io <UDID> screenshot` の連写を同一メッセージで並列発行する（root QA.md の実行ナレッジ参照）

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

---

## 6. iPhone Duo（外側・内側ディスプレイ）

- [x] **外側・内側ディスプレイでボタンと同意文が収まる**: iPhone Duo の外側（466×678pt）と内側（950×678pt）で、画像・見出し・サインインボタン 3 つ・注記・同意文が画面内に収まり、下端があふれない。高さが足りない時は画像だけが縮む（issue #640。widget test: test/features/auth/page_test.dart「高さの足りない画面でも AuthPage が overflow せずボタンが収まる」）
  - 自動化: manual（姿勢の切り替えは root QA.md の実行ナレッジ「iPhone Duo（折りたたみ）の外側・内側ディスプレイの確認」。収まることは widget test でも固定）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **外側・内側ディスプレイでボタンと同意文が収まる**: iPhone Duo の外側（466×678pt）と内側（950×678pt）で、画像・見出し・サインインボタン 3 つ・注記・同意文が画面内に収まり、下端があふれない。高さが足りない時は画像だけが縮む（issue #640。widget test: test/features/auth/page_test.dart「高さの足りない画面でも AuthPage が overflow せずボタンが収まる」）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-10-11**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/2026/10/10/ba7d58c6-7cf9-4282-9d2e-f8e559a42db3-duo-auth-outer-after.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/2026/10/10/10ea4829-0a89-4718-b8bc-dc78a305a28c-duo-auth-inner-after.png" width="320">

修正前は外側で 45pt、内側で 13pt の BOTTOM OVERFLOW（debug の黄黒の帯）が出て、ゲスト開始ボタンと同意文が切れていた（修正前の画像は PR https://github.com/bannzai/shoppinglist/pull/652 ）。修正後は外側で画像が 195pt に縮み、同意文まで収まる。iPhone 17 Pro（iOS 27.0）では画像 240pt のまま各要素の位置が修正前と同じ。

</details>

</details>
