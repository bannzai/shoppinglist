---
feature: _root
verification: mobile-mcp
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# QA 全体ガイド

## 対象環境

- Firebase project: **dev**（`shoppinglist-dev-b2787`。`firebase/.firebaserc` 参照）。prod（`shoppinglist-prod-857bb`）には QA で書き込みを行わない
- ビルド種別: **Debug ビルド**で実施する。`kDebugMode` 限定の匿名サインインボタン（`lib/features/auth/page.dart`）と開発者オプション（`lib/features/developer_options/`）は Debug ビルドでのみ有効
- iOS: bundle id `com.bannzai.shoppinglist.dev`。`ios/Firebase/GoogleService-Info.plist` は Debug/Release 共通で dev project 固定
- Android: debug buildType に `applicationIdSuffix = ".dev"` が設定されており（`android/app/build.gradle`）、`android/app/src/debug/google-services.json`（dev 用）が採用される。release/profile は prod
- 前提: Firebase Functions（GenKit）が dev project に事前デプロイ済みであること。未デプロイの場合、プレミアム付与・カテゴリロケーション順序設定など Functions 経由のデバッグ機能が失敗する

## 起動方法

1. iOS シミュレータ起動: `/sim-manager` skill（`sim-boot`）でプロジェクト固有シミュレータを起動する
2. アプリ起動:
   ```bash
   flutter run \
     --dart-define=SHOPPINGLIST_DEVELOPER_TOKEN=$SHOPPINGLIST_DEVELOPER_TOKEN \
     --dart-define=REVENUECAT_TEST_STORE_API_KEY=$REVENUECAT_TEST_STORE_API_KEY
   ```
   - VS Code から起動する場合は `.vscode/launch.json` の `"shoppinglist(dev)"` configuration を使う（同じ `--dart-define` が設定済み）
   - `REVENUECAT_TEST_STORE_API_KEY` が未設定だとアプリ起動直後に `initializePurchase()` の assert で落ちる（`maestro/README.md` 参照）。RevenueCat Dashboard（Test Store）から取得し、事前に環境変数として設定しておく
   - `SHOPPINGLIST_DEVELOPER_TOKEN` は開発者識別用トークン（`lib/entity/app_user.dart` 参照）。Secret Manager の値と一致確認が必要な機能を検証する場合のみ設定する。値は Secret Manager を参照し、直書きしない
3. Maestro E2E で起動する場合は `/maestro-flutter` skill を使う（`-e APP_ID=com.bannzai.shoppinglist.dev` の指定必須。詳細は `maestro/README.md`）

## ログイン方法

- **匿名サインイン（推奨）**: AuthPage の `kDebugMode` 限定ボタン「匿名サインイン（デバッグ用）」をタップすると `FirebaseAuth.instance.signInAnonymously()` が実行される（`lib/features/auth/page.dart`）。テストアカウントの発行・パスワード管理は不要
- Maestro での自動化は共通サブフロー `maestro/flows/shared/anonymous_sign_in.yaml` を `runFlow` で呼び出す
- Apple/Google サインインボタンも画面に表示されるが、実アカウントを使い分けずに済む匿名サインインを QA の標準ログイン手段とする

## 動作確認手段

- iOS シミュレータ管理: `/sim-manager`（`sim-boot` でプロジェクト・worktree 固有シミュレータを起動。他の動作確認 skill の前提）
- インタラクティブな UI 検証（アクセシビリティツリー探索・タップ・スワイプ・スクリーンショット）: `/verify-ui-mobile-mcp`
- E2E フロー実行: `/maestro-flutter`（`maestro/flows/` 配下。共通サブフローは `maestro/flows/shared/`。`-e APP_ID` の指定必須。詳細は `maestro/README.md`）
- QA.md 群の差分駆動での実行・記録: `/run-qa`（`last_verified_commit` と HEAD の差分から再テスト対象を判定し、スクリーンショットを `gh-r2-image` でアップロードして QA.md に記録する）

## 横断確認項目

## 1. 起動・認証

- [x] **アプリ起動**: dev Firebase project に接続した状態でアプリが起動し、認証状態に応じて AuthPage / Home が正しく分岐する
- [x] **匿名サインイン**: AuthPage の匿名サインインボタンからサインインでき、`AppResolvers`（`lib/features/resolver/`）経由で AppUser ドキュメントが作成されて Home に遷移する
- [x] **サインアウト**: 設定画面からサインアウトでき、AuthPage に戻る

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **アプリ起動**: dev Firebase project に接続した状態でアプリが起動し、認証状態に応じて AuthPage / Home が正しく分岐する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/auth_page_test_04_anon_signin.yaml` 実行（`clearState: true` で未サインイン状態から起動 → AuthPage表示 → サインイン後Home表示まで確認）

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/c12b6008-68c0-4c3a-919a-fe112ca0e4c2.png" width="320">

</details>

### **匿名サインイン**: AuthPage の匿名サインインボタンからサインインでき、`AppResolvers`（`lib/features/resolver/`）経由で AppUser ドキュメントが作成されて Home に遷移する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

同上の `auth_page_test_04_anon_signin.yaml` 実行で「匿名サインイン（デバッグ用）」タップ→GroupJoinOrCreatePage→「自分のリストを作る」→Home（タップで入力開始）まで到達

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/c12b6008-68c0-4c3a-919a-fe112ca0e4c2.png" width="320">

</details>

### **サインアウト**: 設定画面からサインアウトでき、AuthPage に戻る

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/auth_sign_out.yaml` でサインアウト確定 → `FirebaseAuth.instance.signOut()` 実行を確認（デバッグビルドでは `kDebugMode` ガードにより終了アラート・自動再起動なしで即座にreturnする設計のため、実行直後の画面は設定画面のまま）。その後アプリを再起動（`launchApp: clearState:false`）すると AuthPage が表示され、セッションが正しくクリアされていることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/f7e2ebcd-f6cc-40d7-8b28-29de148aff7e.png" width="320">

</details>

</details>

---

## 2. データ同期

- [x] **リアルタイム同期**: 開発者オプションの「デバッグユーザーとしてアイテム追加」実行後、Firestore の変更がリアルタイムでリスト画面に反映される
- [x] **グループ招待・参加**: グループ作成 → 招待コード発行 → 別ユーザー（デバッグユーザー）参加ができる

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **リアルタイム同期**: 開発者オプションの「デバッグユーザーとしてアイテム追加」実行後、Firestore の変更がリアルタイムでリスト画面に反映される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/virtual_pairing/01〜05` を実行。デバッグユーザーをグループに追加した状態で「デバッグユーザーとしてアイテム追加」を実行後、アプリを再起動すると `debug_item_test` が Home のリストにリアルタイム同期で表示されることを確認した（06_cleanup でデバッグデータは削除済み）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/acf8c2f5-8013-4fec-8fa9-d2bbd90e96fa.png" width="320">

</details>

### **グループ招待・参加**: グループ作成 → 招待コード発行 → 別ユーザー（デバッグユーザー）参加ができる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

CLAUDE.md の方針に基づき、実招待コードフロー（別途 `lib/features/group_invitation/QA.md` で検証）の代わりに開発者オプションの「デバッグユーザー作成」→「グループにデバッグユーザーを追加」（`maestro/flows/virtual_pairing/02, 03`）で検証。グループ管理画面で「メンバー 2人」となり、デバッグユーザーがグループに参加できていることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/8eebcc5c-01cd-4400-a84c-0b19655440c8.png" width="320">

</details>

</details>

---

## 3. 課金ゲート

- [x] **非プレミアム制限**: 非プレミアム状態でリスト数上限・カテゴリロケーション順・AI画像/URL認識回数などの制限が正しく機能する
- [x] **プレミアム解放**: 開発者オプションの「プレミアム付与（1日）」実行後、上記制限が解除される（実課金は行わない）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **非プレミアム制限**: 非プレミアム状態でリスト数上限・カテゴリロケーション順・AI画像/URL認識回数などの制限が正しく機能する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/shopping_list_limit_non_premium.yaml` 実行。非プレミアム状態で1グループ20個目までリストを作成でき、21個目で上限 SnackBar（「無料プランでは1グループあたり20個までリストを作成できます」+「アップグレード」CTA）が表示されることを確認した（他の制限項目=カテゴリロケーション順・AI認識回数は各機能別 QA.md で検証）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/568cdf11-8506-4171-ba3d-a497da40cc4c.png" width="320">

</details>

### **プレミアム解放**: 開発者オプションの「プレミアム付与（1日）」実行後、上記制限が解除される（実課金は行わない）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/zz_adhoc_premium_grant_evidence.yaml`（`shared/grant_premium_via_debug.yaml` を利用）を実行。付与前は設定のプレミアムカードが「プレミアムにアップグレード / 5 色テーマ・画像/URL読み取り回数アップなど」＋「はじめる」ボタンの非会員表示（下記1枚目）。開発者オプション →「プレミアム付与（1日）」（`functions.grantPromotionalPremium(duration: 'daily')`）で「プレミアム付与 完了」となり、付与後は同カードが「プレミアム会員 / すべての機能が利用できます」の会員表示に変わり、テーマカラー等のゲート済み機能が解放されることを確認した（下記2枚目。`customerInfoProvider.isPremium` が true になり全制限が解除される。実課金は行っていない）。

付与前（非会員）:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/1f27498d-f06d-4c91-9517-b4934fdc740f.png" width="320">

付与後（プレミアム会員）:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/2de6eb4f-8a27-40f4-979b-a35973fd9cd3.png" width="320">

</details>

</details>

---

## 4. 強制アップデート

- [ ] **強制アップデートダイアログ**: 強制アップデート対象と判定された場合、`ForceUpdateResolver`（`lib/features/resolver/force_update.dart`）がダイアログを表示しストアへ誘導する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **強制アップデートダイアログ**: 強制アップデート対象と判定された場合、`ForceUpdateResolver`（`lib/features/resolver/force_update.dart`）がダイアログを表示しストアへ誘導する

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 実機トリガーには Firebase Remote Config の `minimumAppVersion`（`lib/entity/remote_config_parameter.dart` のデフォルト値 `1.0.0`。現在のアプリバージョンと同一）を dev project 上で現在のアプリバージョンより高い値に変更する必要がある。dev project の Remote Config は共有インフラであり、このバッチ実行では `_root` の後に `shopping_list` / `home` / `auth` など多数の feature QA が同一 dev 環境に対して連続実行される予定のため、ここで変更すると後続の全 QA が強制アップデート画面でブロックされる。ロジックは静的検証で確認済み: `lib/provider/force_update.dart` の `CheckForceUpdate.call()` が `Version.fromPackage()` と `config.minimumAppVersion` を比較し、`lib/features/resolver/force_update.dart` の `ForceUpdateResolver` が該当時に `showOKDialog` でストア誘導する。実機での動作確認は、他の QA バッチ実行と競合しないタイミングで別途 Remote Config を変更して単独実行することを推奨する。

</details>

</details>

---

## 機能別 QA.md

高頻度・重要機能を先頭に記載する。

- [lib/features/shopping_list/QA.md](lib/features/shopping_list/QA.md)
- [lib/features/home/QA.md](lib/features/home/QA.md)
- [lib/features/auth/QA.md](lib/features/auth/QA.md)
- [lib/features/paywall/QA.md](lib/features/paywall/QA.md)
- [lib/features/group_list/QA.md](lib/features/group_list/QA.md)
- [lib/features/group_create/QA.md](lib/features/group_create/QA.md)
- [lib/features/group_join_or_create/QA.md](lib/features/group_join_or_create/QA.md)
- [lib/features/group_invitation/QA.md](lib/features/group_invitation/QA.md)
- [lib/features/group_setting/QA.md](lib/features/group_setting/QA.md)
- [lib/features/group_category/QA.md](lib/features/group_category/QA.md)
- [lib/features/group_category_edit/QA.md](lib/features/group_category_edit/QA.md)
- [lib/features/onboarding/QA.md](lib/features/onboarding/QA.md)
- [lib/features/shopping_list_setting/QA.md](lib/features/shopping_list_setting/QA.md)
- [lib/features/shopping_location/QA.md](lib/features/shopping_location/QA.md)
- [lib/features/location_reminder/QA.md](lib/features/location_reminder/QA.md)
- [lib/features/receipt/QA.md](lib/features/receipt/QA.md)
- [lib/features/home_widget/QA.md](lib/features/home_widget/QA.md)
- [lib/features/settings/QA.md](lib/features/settings/QA.md)
- [lib/features/inquiry/QA.md](lib/features/inquiry/QA.md)

## QA 対象外

- **`lib/features/previews/`**: Widgetbook 的なプレビュー基盤（`main_preview.dart` / `preview_app.dart` / `previews_page.dart` / `mock/`）。本番アプリとは別エントリポイントの画面確認用アプリで、ユーザー向け機能を持たないため QA 対象外
- **`lib/features/resolver/`**: 起動時の認証・DB 初期化・強制アップデート判定などを行う基盤（`auth.dart` / `database.dart` / `current_group_resolver.dart` / `force_update.dart` 等）。単体の画面を持たず、他の全機能の QA を実行する過程で間接的に検証される。強制アップデートのみ「横断確認項目」で明示的に確認する
- **`lib/features/developer_options/`**: デバッグビルド専用の開発者向け機能（シェイクジェスチャーで表示）。それ自体は QA 対象としないが、QA 実行時には「プレミアム付与」「デバッグユーザー作成」などをデバッグ支援ツールとして利用する（実課金・複数実機を使わずに検証するため）
