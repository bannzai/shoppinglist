---
feature: paywall
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# paywall QA

## 1. 画面表示・遷移

- [ ] **ペイウォールの表示**: `showPaywall`（`fullscreenDialog: true`）で `PaywallPage` が画面下から迫り出し、AppBar 左の close アイコンで閉じられること。設定画面の非プレミアム時プレミアムカードの「はじめる」pill、および各 premium gate から遷移できる（既存 E2E: maestro/flows/shared/mock_purchase.yaml, design_v2_settings_paywall.yaml）
- [ ] **ヒーロー・特典リスト**: crown アイコンのヒーロー、見出し「プレミアムにアップグレード」、特典リスト（写真からのアイテム抽出（月 50 回）／ URL からのアイテム抽出（月 50 回）／ 5 色のテーマカラー／リスト保存期間が無制限／リストにレシートを保存）が表示されること（「店舗ごとの並び順」は feature flag で非表示）
- [ ] **プラン一覧表示**: RC Offering から取得した monthly / annual / lifetime の Package タイルが表示され、`title`・`priceString`・「購入」ボタンが並ぶこと。annual タイルには「おすすめ」バッジと強調枠が付くこと

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ペイウォールの表示**: `showPaywall`（`fullscreenDialog: true`）で `PaywallPage` が画面下から迫り出し、AppBar 左の close アイコンで閉じられること。設定画面の非プレミアム時プレミアムカードの「はじめる」pill、および各 premium gate から遷移できる（既存 E2E: maestro/flows/shared/mock_purchase.yaml, design_v2_settings_paywall.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **ヒーロー・特典リスト**: crown アイコンのヒーロー、見出し「プレミアムにアップグレード」、特典リスト（写真からのアイテム抽出（月 50 回）／ URL からのアイテム抽出（月 50 回）／ 5 色のテーマカラー／リスト保存期間が無制限／リストにレシートを保存）が表示されること（「店舗ごとの並び順」は feature flag で非表示）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **プラン一覧表示**: RC Offering から取得した monthly / annual / lifetime の Package タイルが表示され、`title`・`priceString`・「購入」ボタンが並ぶこと。annual タイルには「おすすめ」バッジと強調枠が付くこと

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. プラン読み込み状態

- [ ] **読み込み中表示**: Offering 取得中は `CircularProgressIndicator` が表示されること
- [ ] **取得エラーと再試行**: Offering 取得失敗時は 📡 とエラーメッセージ（`describeError` の message）＋「再試行」ボタンが表示され、タップで `offeringsProvider` を invalidate して再取得すること
- [ ] **プランなし表示**: monthly / annual / lifetime がいずれも null の場合「現在ご利用いただけるプランがありません」が表示されること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **読み込み中表示**: Offering 取得中は `CircularProgressIndicator` が表示されること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **取得エラーと再試行**: Offering 取得失敗時は 📡 とエラーメッセージ（`describeError` の message）＋「再試行」ボタンが表示され、タップで `offeringsProvider` を invalidate して再取得すること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **プランなし表示**: monthly / annual / lifetime がいずれも null の場合「現在ご利用いただけるプランがありません」が表示されること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. 購入フロー

- [ ] **購入成功でプレミアム化**: 「購入」タップ → RC Test Store の mock purchase modal で「Test valid purchase」を選ぶと `purchase.call(package)` が成功し、「購入ありがとうございました」SnackBar 表示後にペイウォールが pop、設定画面のプレミアムカードが「プレミアム会員」表示に変わること（実課金せず開発者オプションの mock purchase を使用。既存 E2E: maestro/flows/iap_purchase_monthly.yaml, iap_purchase_annual.yaml, iap_purchase_lifetime.yaml, shared/mock_purchase*.yaml）
- [ ] **購入キャンセル・失敗**: mock purchase modal で「Cancel」／「Test failed purchase」を選んだ場合はプレミアム化されず、失敗時は `showErrorSnackBar` でエラーがそのまま表示されること
- [ ] **購入中に閉じても黒画面にならない**: 購入の await 中に close ボタンで先に閉じても、pop が自ルートに限定されホーム剥がれ（黒画面）が起きないこと（#372）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **購入成功でプレミアム化**: 「購入」タップ → RC Test Store の mock purchase modal で「Test valid purchase」を選ぶと `purchase.call(package)` が成功し、「購入ありがとうございました」SnackBar 表示後にペイウォールが pop、設定画面のプレミアムカードが「プレミアム会員」表示に変わること（実課金せず開発者オプションの mock purchase を使用。既存 E2E: maestro/flows/iap_purchase_monthly.yaml, iap_purchase_annual.yaml, iap_purchase_lifetime.yaml, shared/mock_purchase*.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **購入キャンセル・失敗**: mock purchase modal で「Cancel」／「Test failed purchase」を選んだ場合はプレミアム化されず、失敗時は `showErrorSnackBar` でエラーがそのまま表示されること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **購入中に閉じても黒画面にならない**: 購入の await 中に close ボタンで先に閉じても、pop が自ルートに限定されホーム剥がれ（黒画面）が起きないこと（#372）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. 復元・フッタリンク

- [ ] **購入の復元**: フッタ「復元」タップで `Purchases.restorePurchases()` が実行され、成功時「購入を復元しました」SnackBar、失敗時は `showErrorSnackBar` が表示されること
- [ ] **利用規約・プライバシーリンク**: フッタ「利用規約」「プライバシー」タップで各 URL が外部ブラウザ（`LaunchMode.externalApplication`）で開くこと

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **購入の復元**: フッタ「復元」タップで `Purchases.restorePurchases()` が実行され、成功時「購入を復元しました」SnackBar、失敗時は `showErrorSnackBar` が表示されること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **利用規約・プライバシーリンク**: フッタ「利用規約」「プライバシー」タップで各 URL が外部ブラウザ（`LaunchMode.externalApplication`）で開くこと

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---
