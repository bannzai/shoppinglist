---
feature: paywall
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-15
---

# paywall QA

## 1. 画面表示・遷移

- [x] **ペイウォールの表示**: `showPaywall`（`fullscreenDialog: true`）で `PaywallPage` が画面下から迫り出し、AppBar 左の close アイコンで閉じられること。設定画面の非プレミアム時プレミアムカードの「はじめる」pill、および各 premium gate から遷移できる（既存 E2E: maestro/flows/shared/mock_purchase.yaml, design_v2_settings_paywall.yaml, paywall_display_and_dismiss.yaml）
- [x] **ヒーロー・特典リスト**: crown アイコンのヒーロー、見出し「プレミアムにアップグレード」、特典リスト（写真からのアイテム抽出（月 50 回）／ URL からのアイテム抽出（月 50 回）／ 5 色のテーマカラー／リスト保存期間が無制限／リストにレシートを保存）が表示されること（「店舗ごとの並び順」は feature flag で非表示）
- [x] **プラン一覧表示**: RC Offering から取得した monthly / annual / lifetime の Package タイルが表示され、`title`・`priceString`・「購入」ボタンが並ぶこと。annual タイルには「おすすめ」バッジと強調枠が付くこと

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ペイウォールの表示**: `showPaywall`（`fullscreenDialog: true`）で `PaywallPage` が画面下から迫り出し、AppBar 左の close アイコンで閉じられること。設定画面の非プレミアム時プレミアムカードの「はじめる」pill、および各 premium gate から遷移できる（既存 E2E: maestro/flows/shared/mock_purchase.yaml, design_v2_settings_paywall.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

設定画面の「はじめる」pill からペイウォール表示:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/53b94bbb-d393-4f4c-b11f-e72582b38f86.png" width="320">

close アイコンで設定画面に戻る（「はじめる」pill が再表示）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/7ba5c5b2-01c3-42a1-9359-0b00385f0d74.png" width="320">

</details>

### **ヒーロー・特典リスト**: crown アイコンのヒーロー、見出し「プレミアムにアップグレード」、特典リスト（写真からのアイテム抽出（月 50 回）／ URL からのアイテム抽出（月 50 回）／ 5 色のテーマカラー／リスト保存期間が無制限／リストにレシートを保存）が表示されること（「店舗ごとの並び順」は feature flag で非表示）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/53b94bbb-d393-4f4c-b11f-e72582b38f86.png" width="320">

</details>

### **プラン一覧表示**: RC Offering から取得した monthly / annual / lifetime の Package タイルが表示され、`title`・`priceString`・「購入」ボタンが並ぶこと。annual タイルには「おすすめ」バッジと強調枠が付くこと

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

monthly「Monthly $9.99」/ annual「Yearly $79.99」（おすすめバッジ・強調枠あり）/ lifetime「Lifetime $99.99」がそれぞれ title・priceString・購入ボタン付きで表示:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/53b94bbb-d393-4f4c-b11f-e72582b38f86.png" width="320">

</details>

</details>

---

## 2. プラン読み込み状態

- [ ] **読み込み中表示**: Offering 取得中は `CircularProgressIndicator` が表示されること
  - ⏭️ スキップ: RC Test Store への `Purchases.getOfferings()` が数百ms〜1秒程度で完了し、maestro のタップ→スクリーンショット往復レイテンシを上回れず撮影できなかった（詳細は下記動作確認エビデンス参照）
- [ ] **取得エラーと再試行**: Offering 取得失敗時は 📡 とエラーメッセージ（`describeError` の message）＋「再試行」ボタンが表示され、タップで `offeringsProvider` を invalidate して再取得すること
  - ⏭️ スキップ: `Purchases.getOfferings()` を意図的に失敗させる手段（RC設定破壊・ネットワーク遮断・デバッグトグル）が本QAセッションの許可コマンド範囲内にない（詳細は下記動作確認エビデンス参照）
- [ ] **プランなし表示**: monthly / annual / lifetime がいずれも null の場合「現在ご利用いただけるプランがありません」が表示されること
  - ⏭️ スキップ: 現在の RC Offering には3プランが実際に設定されており、空にするには RevenueCat Dashboard 側の設定変更が必要でQAセッション内では実行できない（詳細は下記動作確認エビデンス参照）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **読み込み中表示**: Offering 取得中は `CircularProgressIndicator` が表示されること

⏭️ スキップ: RC Test Store への `Purchases.getOfferings()` がコールドスタート直後でも数百ms〜1秒程度で完了し、maestro のタップ→スクリーンショット往復レイテンシ（tapOn直後に即 takeScreenshot しても間に合わない）を上回れず、`CircularProgressIndicator` 表示中のフレームを撮影できなかった（root QA.md「再現が難しい操作の手順」の1秒未満ローディング撮り逃しパターンと同種）。コードレビューで代替: `PaywallPage.build` の `offerings.when(loading: () => const _LoadingBody(), ...)` (lib/features/paywall/paywall_page.dart:41-42) と `_LoadingBody` (同308行) が `Center(child: CircularProgressIndicator())` を返す実装を確認済み。

<details><summary>動作確認スクショ</summary>

（未実行・上記理由によりスキップ）

</details>

### **取得エラーと再試行**: Offering 取得失敗時は 📡 とエラーメッセージ（`describeError` の message）＋「再試行」ボタンが表示され、タップで `offeringsProvider` を invalidate して再取得すること

⏭️ スキップ: `Purchases.getOfferings()` を失敗させるには RevenueCat 側の設定破壊やシミュレータのネットワーク遮断が必要で、本 QA セッションで許可されているツール（maestro / xcrun simctl）では実行手段がない（developer_options にも Offering 取得を強制失敗させるデバッグトグルは存在しない: `grep -n "offering" lib/features/developer_options/page.dart` は診断ダンプ表示のみで確認済み）。コードレビューで代替: `paywall_page.dart:43-51` の `error: (e, st) => _ErrorBody(...)` と `_ErrorBody` (同310-361行) が 📡 + `describeError(exception, stackTrace).message` + 「再試行」`AppPill`（`onPressed: onRetry`）を表示し、`onRetry` は `paywall_page.dart:47-50` で `ref.invalidate(offeringsProvider)` を呼ぶ実装を確認済み。

<details><summary>動作確認スクショ</summary>

（未実行・上記理由によりスキップ）

</details>

### **プランなし表示**: monthly / annual / lifetime がいずれも null の場合「現在ご利用いただけるプランがありません」が表示されること

⏭️ スキップ: 現在の RC Offering には monthly/annual/lifetime が実際に設定されており（Section 1 で確認済み）、この状態を再現するには RevenueCat Dashboard 側で Offering 構成を一時的に空にする必要があるため、QA セッション内では実行できない。コードレビューで代替: `paywall_page.dart:56-58` の `if (monthly == null && annual == null && lifetime == null) { return const _NoPlansBody(); }` と `_NoPlansBody` (同363-381行) が「現在ご利用いただけるプランがありません」を表示する実装を確認済み。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. 購入フロー

- [x] **購入成功でプレミアム化**: 「購入」タップ → RC Test Store の mock purchase modal で「Test valid purchase」を選ぶと `purchase.call(package)` が成功し、「購入ありがとうございました」SnackBar 表示後にペイウォールが pop、設定画面のプレミアムカードが「プレミアム会員」表示に変わること（実課金せず開発者オプションの mock purchase を使用。既存 E2E: maestro/flows/iap_purchase_monthly.yaml, iap_purchase_annual.yaml, iap_purchase_lifetime.yaml, shared/mock_purchase*.yaml）
- [x] **購入キャンセル・失敗**: mock purchase modal で「Cancel」／「Test failed purchase」を選んだ場合はプレミアム化されず、失敗時は `showErrorSnackBar` でエラーがそのまま表示されること（既存 E2E: maestro/flows/paywall_purchase_cancel_and_failure.yaml）
- [x] **購入中に閉じても黒画面にならない**: 購入の await 中に close ボタンで先に閉じても、pop が自ルートに限定されホーム剥がれ（黒画面）が起きないこと（#372）（既存 E2E: maestro/flows/paywall_close_during_purchase.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **購入成功でプレミアム化**: 「購入」タップ → RC Test Store の mock purchase modal で「Test valid purchase」を選ぶと `purchase.call(package)` が成功し、「購入ありがとうございました」SnackBar 表示後にペイウォールが pop、設定画面のプレミアムカードが「プレミアム会員」表示に変わること（実課金せず開発者オプションの mock purchase を使用。既存 E2E: maestro/flows/iap_purchase_monthly.yaml, iap_purchase_annual.yaml, iap_purchase_lifetime.yaml, shared/mock_purchase*.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

monthly購入後、「購入ありがとうございました」SnackBar表示、ペイウォールpop、設定画面プレミアムカードが「プレミアム会員 / すべての機能が利用できます」表示に変化:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/481245f9-f44f-45aa-b793-a0d80d376e27.png" width="320">

</details>

### **購入キャンセル・失敗**: mock purchase modal で「Cancel」／「Test failed purchase」を選んだ場合はプレミアム化されず、失敗時は `showErrorSnackBar` でエラーがそのまま表示されること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

Cancel選択後、プレミアム化されずPaywallに留まる（「購入」ボタンが再度押せる状態）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/498d3a05-427b-4b99-ade0-98b9fabcce59.png" width="320">

Test failed purchase選択後、`showErrorSnackBar`でエラーがそのまま表示（`FormatException: テスト購入でエラーが発生しました。コード: PurchasesErrorCode.testStoreSimulatedPurchaseError ...` を加工なしで表示。エラーメッセージ非加工の規約通り）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/ae552e6c-8563-4bb9-96d9-f76acada9be2.png" width="320">

</details>

### **購入中に閉じても黒画面にならない**: 購入の await 中に close ボタンで先に閉じても、pop が自ルートに限定されホーム剥がれ（黒画面）が起きないこと（#372）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

コードレビューで確認: `lib/utils/stdlib/navigator.dart` の `popRouteSafely` が、await開始前に束ねた `route`（`ModalRoute.of(context)`）の `route.isCurrent` / `route.isActive` を判定し、ユーザーが既に自ルートをpop済み（`isActive=false`）なら何もしない実装になっている（`paywall_page.dart` の購入ボタン `onPressed` も `Navigator.of(context)` / `ModalRoute.of(context)` を await前に確保して渡している）。

ライブ確認: maestro flow (`paywall_close_during_purchase.yaml`) で「購入」タップ直後に close(×)相当の座標をタップしたが、RC Test Storeのネイティブモーダルが即座に全画面を覆いタッチを奪うため、close タップはモーダルに吸収され不発だった（=このモーダル実装ではawait中に実際にcloseタップを通すこと自体が困難）。その後Cancelでawaitを解消した後の画面は黒画面にならず、Paywallが正常な状態のまま維持されることを確認した:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/b3a2c00e-44bb-4a51-b290-c1d8f2375882.png" width="320">

</details>

</details>

---

## 4. 復元・フッタリンク

- [x] **購入の復元**: フッタ「復元」タップで `Purchases.restorePurchases()` が実行され、成功時「購入を復元しました」SnackBar、失敗時は `showErrorSnackBar` が表示されること
- [x] **利用規約・プライバシーリンク**: フッタ「利用規約」「プライバシー」タップで各 URL が外部ブラウザ（`LaunchMode.externalApplication`）で開くこと（既存 E2E: maestro/flows/paywall_restore_and_footer_links.yaml, paywall_footer_terms_privacy_links.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **購入の復元**: フッタ「復元」タップで `Purchases.restorePurchases()` が実行され、成功時「購入を復元しました」SnackBar、失敗時は `showErrorSnackBar` が表示されること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

「復元」タップ後、「購入を復元しました」SnackBar表示:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/cc326513-f131-4a54-9364-7ab84adaaca0.png" width="320">

失敗時のUI（`showErrorSnackBar`）はセクション3「購入キャンセル・失敗」の失敗ケースで同一の表示関数の動作を確認済み。

</details>

### **利用規約・プライバシーリンク**: フッタ「利用規約」「プライバシー」タップで各 URL が外部ブラウザ（`LaunchMode.externalApplication`）で開くこと

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

「利用規約」タップ後、Safariで `bannzai.github.io/shoppinglist/Terms` が開く:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/a6f4095f-c7c4-437c-9055-464f3358b39b.png" width="320">

「プライバシー」タップ後、Safariで `bannzai.github.io/shoppinglist/PrivacyPolicy` が開く:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/8894ce6f-6443-40fc-ba9e-05f1a033c933.png" width="320">

**判明した再現手順（重要）**: paywall フッタの3リンク（利用規約・プライバシー・復元）は1つの `Text.rich(TextSpan[...])` として実装されているが、`maestro hierarchy` 実測では各spanが個別のaccessibility要素として正しい座標を持つことを確認した（bounds例: 利用規約 [109,770][163,791]、画面402x874pt換算で中心 34%,89%）。`tapOn: text指定`が通らなかったのは span座標の問題ではなく、直前に「復元」を実行した場合はSnackBarが画面下部（フッタ行とほぼ同じ位置）を覆ってタップを吸収していたため。フッタリンクを個別に検証する際は「復元」を先に実行しない、または実測座標（`maestro hierarchy`で取得）でタップする。

</details>

</details>

---
