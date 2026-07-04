---
feature: paywall
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# paywall QA

## 1. 導線・画面表示

- [ ] **設定画面の「はじめる」からPaywallPageに遷移する**: 非プレミアム時、設定画面上部のプレミアム会員カードの「はじめる」ボタンをタップすると、下からのモーダル（fullscreenDialog）でPaywallPageが表示される。maestro/flows/shared/mock_purchase.yaml で確認。
- [ ] **プレミアムゲートのSnackBarからもPaywallPageに遷移する**: テーマカラー設定など非プレミアム時に表示されるSnackBarの「アップグレード」アクションをタップするとPaywallPageに遷移する。maestro/flows/theme_color_setting_non_premium.yaml で確認。
- [ ] **オファリング読み込み中はローディング表示になる**: PaywallPage表示直後、RevenueCat Offering取得が完了するまで中央にCircularProgressIndicatorが表示される。
- [ ] **プラン一覧が表示される**: ヒーロー見出し「プレミアムにアップグレード」、特典リスト（写真からのアイテム抽出・URLからのアイテム抽出・5色のテーマカラー・リスト保存期間無制限・レシート保存の5項目。店舗ごとの並び順はfeature flag無効のため非表示）、monthly/annual（おすすめバッジ付き）/lifetimeの3プランが表示される。
- [ ] **閉じるボタンでPaywallPageを閉じられる**: AppBar leadingの×アイコンをタップするとPaywallPageが閉じ、遷移元の画面に戻る。

---

## 2. 購入（RevenueCat Test Store モック）

- [ ] **monthlyプランを購入できる**: 先頭（monthly）の「購入」ボタンをタップし、RC Test Storeモーダルで「Test valid purchase」を選ぶと購入が成立し、「購入ありがとうございました」SnackBar表示後PaywallPageが閉じ、設定画面のプレミアム会員カードが加入済み表示に変わる。maestro/flows/iap_purchase_monthly.yaml で確認。
- [ ] **annualプランを購入できる**: 2番目（おすすめバッジ付き）の「購入」ボタンから同様に購入完了できる。maestro/flows/iap_purchase_annual.yaml で確認。
- [ ] **lifetimeプランを購入できる**: 3番目の「購入」ボタンから同様に購入完了できる。maestro/flows/iap_purchase_lifetime.yaml で確認。
- [ ] **本番Storeでの実課金はSimulatorでは検証不可**: Releaseビルドの本番Store決済は実アカウント・実カードを要するためSimulatorでは確認できない。Debugビルドの `REVENUECAT_TEST_STORE_API_KEY` によるTest Storeモック購入で代替する。
- [ ] **購入キャンセル時はエラー表示なくPaywallPageに留まる**: Test Storeモーダルで「Cancel」を選ぶと、SnackBar等のエラー表示は出ずPaywallPageに留まる（`Purchase.call` がキャンセルを無視して `false` を返す実装）。

---

## 3. エラー・その他導線

- [ ] **オファリング取得失敗時はエラー表示と再試行ボタンが出る**: オフライン状態などでOffering取得に失敗すると、エラーメッセージと「再試行」ボタンが表示され、タップで再取得が走る。
- [ ] **購入失敗時は例外メッセージがSnackBarで表示される**: Test Storeモーダルの「Test failed purchase」を選ぶと、決済失敗の例外内容がSnackBarでそのまま表示される。
- [ ] **フッターの「復元」で購入を復元できる**: 「復元」タップで `Purchases.restorePurchases()` が呼ばれ、成功すると「購入を復元しました」SnackBarが表示される。
- [ ] **フッターの利用規約・プライバシーリンクが開く**: 「利用規約」「プライバシー」タップでそれぞれ外部ブラウザが開く。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **オファリング取得失敗時はエラー表示と再試行ボタンが出る**: オフライン状態などでOffering取得に失敗すると、エラーメッセージと「再試行」ボタンが表示され、タップで再取得が走る。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **購入失敗時は例外メッセージがSnackBarで表示される**: Test Storeモーダルの「Test failed purchase」を選ぶと、決済失敗の例外内容がSnackBarでそのまま表示される。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **フッターの「復元」で購入を復元できる**: 「復元」タップで `Purchases.restorePurchases()` が呼ばれ、成功すると「購入を復元しました」SnackBarが表示される。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **フッターの利用規約・プライバシーリンクが開く**: 「利用規約」「プライバシー」タップでそれぞれ外部ブラウザが開く。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
