---
feature: paywall
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# paywall QA

## 1. 導線・画面表示

- [x] **設定画面の「はじめる」からPaywallPageに遷移する**: 非プレミアム時、設定画面上部のプレミアム会員カードの「はじめる」ボタンをタップすると、下からのモーダル（fullscreenDialog）でPaywallPageが表示される。maestro/flows/shared/mock_purchase.yaml で確認。
- [x] **プレミアムゲートのSnackBarからもPaywallPageに遷移する**: テーマカラー設定など非プレミアム時に表示されるSnackBarの「アップグレード」アクションをタップするとPaywallPageに遷移する。maestro/flows/theme_color_setting_non_premium.yaml で確認。
- [ ] **オファリング読み込み中はローディング表示になる**: PaywallPage表示直後、RevenueCat Offering取得が完了するまで中央にCircularProgressIndicatorが表示される。
- [x] **プラン一覧が表示される**: ヒーロー見出し「プレミアムにアップグレード」、特典リスト（写真からのアイテム抽出・URLからのアイテム抽出・5色のテーマカラー・リスト保存期間無制限・レシート保存の5項目。店舗ごとの並び順はfeature flag無効のため非表示）、monthly/annual（おすすめバッジ付き）/lifetimeの3プランが表示される。
- [x] **閉じるボタンでPaywallPageを閉じられる**: AppBar leadingの×アイコンをタップするとPaywallPageが閉じ、遷移元の画面に戻る。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **設定画面の「はじめる」からPaywallPageに遷移する**: 非プレミアム時、設定画面上部のプレミアム会員カードの「はじめる」ボタンをタップすると、下からのモーダル（fullscreenDialog）でPaywallPageが表示される。maestro/flows/shared/mock_purchase.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/iap_purchase_monthly.yaml`（内部で `shared/mock_purchase.yaml` を実行）にて、設定画面の「はじめる」タップ→PaywallPage表示→「購入」ボタン出現までを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/b6297b79-e27f-4189-918b-3c2dad89b4d1.png" width="320">

</details>

### **プレミアムゲートのSnackBarからもPaywallPageに遷移する**: テーマカラー設定など非プレミアム時に表示されるSnackBarの「アップグレード」アクションをタップするとPaywallPageに遷移する。maestro/flows/theme_color_setting_non_premium.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

非プレミアムユーザーで設定画面→テーマカラーをタップし、「テーマカラーの変更はプレミアム機能です」SnackBarの「アップグレード」ボタンを確認（下図）。mobile-mcpでタップし、PaywallPageに遷移することを確認した（遷移先は「プラン一覧が表示される」項目のスクショと同一）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/863dc84d-9f8a-4afa-8ec5-f8d7240cc2fe.png" width="320">

</details>

### **オファリング読み込み中はローディング表示になる**: PaywallPage表示直後、RevenueCat Offering取得が完了するまで中央にCircularProgressIndicatorが表示される。

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: RevenueCat Test Store（Debugビルド）は `getOfferings()` の応答が非常に高速で、mobile-mcpでのタップ→スクリーンショット撮影の往復では、アプリ再起動直後の初回表示でもローディング状態を捕捉できなかった。実装は `lib/features/paywall/paywall_page.dart` の `offerings.when(loading: () => const _LoadingBody(), ...)` でRiverpodの `AsyncValue.when` パターンを正しく使用していることをコードレビューで確認済み。

</details>

### **プラン一覧が表示される**: ヒーロー見出し「プレミアムにアップグレード」、特典リスト（写真からのアイテム抽出・URLからのアイテム抽出・5色のテーマカラー・リスト保存期間無制限・レシート保存の5項目。店舗ごとの並び順はfeature flag無効のため非表示）、monthly/annual（おすすめバッジ付き）/lifetimeの3プランが表示される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

ヒーロー見出し「プレミアムにアップグレード」、特典5項目（店舗ごとの並び順は非表示）、Monthly $9.99 / Yearly $79.99（おすすめバッジ）/ Lifetime $99.99 の3プランが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/adc55bc0-de18-4278-8bd4-ceeb54a96675.png" width="320">

</details>

### **閉じるボタンでPaywallPageを閉じられる**: AppBar leadingの×アイコンをタップするとPaywallPageが閉じ、遷移元の画面に戻る。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

PaywallPage表示中に左上の×アイコンをタップし、設定画面に戻ることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/c6ffbeb3-7bac-4c47-95cc-7c3cad46129d.png" width="320">

</details>

</details>

---

## 2. 購入（RevenueCat Test Store モック）

- [x] **monthlyプランを購入できる**: 先頭（monthly）の「購入」ボタンをタップし、RC Test Storeモーダルで「Test valid purchase」を選ぶと購入が成立し、「購入ありがとうございました」SnackBar表示後PaywallPageが閉じ、設定画面のプレミアム会員カードが加入済み表示に変わる。maestro/flows/iap_purchase_monthly.yaml で確認。
- [x] **annualプランを購入できる**: 2番目（おすすめバッジ付き）の「購入」ボタンから同様に購入完了できる。maestro/flows/iap_purchase_annual.yaml で確認。
- [x] **lifetimeプランを購入できる**: 3番目の「購入」ボタンから同様に購入完了できる。maestro/flows/iap_purchase_lifetime.yaml で確認。
- [ ] **本番Storeでの実課金はSimulatorでは検証不可**: Releaseビルドの本番Store決済は実アカウント・実カードを要するためSimulatorでは確認できない。Debugビルドの `REVENUECAT_TEST_STORE_API_KEY` によるTest Storeモック購入で代替する。
- [x] **購入キャンセル時はエラー表示なくPaywallPageに留まる**: Test Storeモーダルで「Cancel」を選ぶと、SnackBar等のエラー表示は出ずPaywallPageに留まる（`Purchase.call` がキャンセルを無視して `false` を返す実装）。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **monthlyプランを購入できる**: 先頭（monthly）の「購入」ボタンをタップし、RC Test Storeモーダルで「Test valid purchase」を選ぶと購入が成立し、「購入ありがとうございました」SnackBar表示後PaywallPageが閉じ、設定画面のプレミアム会員カードが加入済み表示に変わる。maestro/flows/iap_purchase_monthly.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro test -e APP_ID=com.bannzai.shoppinglist.dev maestro/flows/iap_purchase_monthly.yaml` 実行。Test Storeモーダルで「Test valid purchase」選択後、「購入ありがとうございました」SnackBar表示、設定画面のプレミアム会員カードが「プレミアム会員」表示に変わることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/3f655fd5-e8ea-42b3-a989-6fb15f11813e.png" width="320">

</details>

### **annualプランを購入できる**: 2番目（おすすめバッジ付き）の「購入」ボタンから同様に購入完了できる。maestro/flows/iap_purchase_annual.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro test -e APP_ID=com.bannzai.shoppinglist.dev maestro/flows/iap_purchase_annual.yaml` 実行。2番目（おすすめバッジ付き）の「購入」ボタンから購入完了し、プレミアム会員表示に変わることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/4f45ac64-0cdd-443b-8c27-98ae4492ab39.png" width="320">

</details>

### **lifetimeプランを購入できる**: 3番目の「購入」ボタンから同様に購入完了できる。maestro/flows/iap_purchase_lifetime.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro test -e APP_ID=com.bannzai.shoppinglist.dev maestro/flows/iap_purchase_lifetime.yaml` 実行。3番目の「購入」ボタンから購入完了し、プレミアム会員表示に変わることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/cb93e9bd-57e6-4f30-adc5-a750c1ede085.png" width="320">

</details>

### **本番Storeでの実課金はSimulatorでは検証不可**: Releaseビルドの本番Store決済は実アカウント・実カードを要するためSimulatorでは確認できない。Debugビルドの `REVENUECAT_TEST_STORE_API_KEY` によるTest Storeモック購入で代替する。

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: `lib/features/paywall/README.md` および `lib/utils/purchase/purchase.dart` をコードレビューし、Debugビルドは `REVENUECAT_TEST_STORE_API_KEY` によりRC Test Storeを使用し、Releaseビルドのみ本番Appleストアキーを使用する設計であることを確認した（PR #233）。本番Storeでの実課金はSimulatorの制約上そもそも実行不可能であり、上記monthly/annual/lifetimeの3項目でTest Storeモック購入により代替検証済み。

</details>

### **購入キャンセル時はエラー表示なくPaywallPageに留まる**: Test Storeモーダルで「Cancel」を選ぶと、SnackBar等のエラー表示は出ずPaywallPageに留まる（`Purchase.call` がキャンセルを無視して `false` を返す実装）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

monthlyプランの「購入」タップ→Test Storeモーダルで「Cancel」選択後、SnackBar等のエラー表示なくPaywallPageに留まることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/13482b70-e64c-4dd7-9703-238ba3666ed2.png" width="320">

</details>

</details>

---

## 3. エラー・その他導線

- [ ] **オファリング取得失敗時はエラー表示と再試行ボタンが出る**: オフライン状態などでOffering取得に失敗すると、エラーメッセージと「再試行」ボタンが表示され、タップで再取得が走る。
- [x] **購入失敗時は例外メッセージがSnackBarで表示される**: Test Storeモーダルの「Test failed purchase」を選ぶと、決済失敗の例外内容がSnackBarでそのまま表示される。
- [x] **フッターの「復元」で購入を復元できる**: 「復元」タップで `Purchases.restorePurchases()` が呼ばれ、成功すると「購入を復元しました」SnackBarが表示される。
- [ ] **フッターの利用規約・プライバシーリンクが開く**: 「利用規約」「プライバシー」タップでそれぞれ外部ブラウザが開く。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **オファリング取得失敗時はエラー表示と再試行ボタンが出る**: オフライン状態などでOffering取得に失敗すると、エラーメッセージと「再試行」ボタンが表示され、タップで再取得が走る。

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: iOS Simulatorはホストのネットワークスタックを直接共有しており、Settingsアプリの機内モードトグルはSimulatorには存在しない（実ラジオが無いため）。Simulator単体だけを狙ってオフライン化する手段（Network Link ConditionerはmacOSホスト全体に影響）が無く、dev環境で他のfeature QAセッションが並行実行中のため、ホスト全体やdev Firebase projectへの疎通に影響する変更は避けた。実装は `lib/utils/purchase/purchase.dart` の `offeringsProvider` が `Purchases.getOfferings()` の例外を再送出し、`lib/features/paywall/paywall_page.dart` の `offerings.when(error: (e, st) => _ErrorBody(...))` が例外メッセージと「再試行」ボタン（タップで `ref.invalidate(offeringsProvider)`）を表示する実装であることをコードレビューで確認した。

</details>

### **購入失敗時は例外メッセージがSnackBarで表示される**: Test Storeモーダルの「Test failed purchase」を選ぶと、決済失敗の例外内容がSnackBarでそのまま表示される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

monthlyプランの「購入」タップ→Test Storeモーダルで「Test failed purchase」選択後、`FormatException: テスト購入でエラーが発生しました...`（`PurchasesErrorCode.testStoreSimulatedPurchaseError` に対応する例外メッセージ）がSnackBarにそのまま表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/62769d4f-8742-4129-8108-3e7e9ec03f7c.png" width="320">

</details>

### **フッターの「復元」で購入を復元できる**: 「復元」タップで `Purchases.restorePurchases()` が呼ばれ、成功すると「購入を復元しました」SnackBarが表示される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

PaywallPageフッターの「復元」をタップし、「購入を復元しました」SnackBarが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/75da1923-17e6-49f5-9341-bb2875686118.png" width="320">

</details>

### **フッターの利用規約・プライバシーリンクが開く**: 「利用規約」「プライバシー」タップでそれぞれ外部ブラウザが開く。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

「プライバシー」タップは外部ブラウザ（Safari）が開き、プライバシーポリシーが正常に表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/b8c40dc3-0a57-4169-9770-fa623ea2acd2.png" width="320">

❌ 失敗: 「利用規約」タップは外部ブラウザ（Safari）が開くが `https://bannzai.github.io/shoppinglist/TermsOfService` が404を返し、規約本文が表示されない（設定画面の同じリンクと同一の既知不具合）。再現手順: PaywallPage表示 → フッターの「利用規約」をタップ → Safariで404ページが表示される。issue: https://github.com/bannzai/shoppinglist/issues/476 （既存issueにpaywallでの再現を追記済み: https://github.com/bannzai/shoppinglist/issues/476#issuecomment-4883982398 ）

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/7ab5e4bb-3c38-4d36-a744-0fea8d0bdf4a.png" width="320">

</details>

</details>
