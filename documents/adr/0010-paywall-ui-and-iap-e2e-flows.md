# 0010. ペイウォール UI 新設と IAP E2E フロー雛形整備

## Status
Accepted

## Context

PR #233（Issue #229）で RevenueCat Test Store API Key の `kDebugMode` 切替基盤が merged 済。しかし、Issue #235「IAP を含む Maestro E2E フローを iOS / Android で整備する」を進めるにあたり、事前調査で以下の前提と異なる事実が判明した。

1. **ペイウォール UI が `lib/` に未実装**: `Purchases.purchase(PurchaseParams.package(...))` を呼ぶ UI が `lib/` 配下に一切存在しない（`purchaseProvider` を `ref.read` している箇所ゼロ）。ユーザーは現状アプリから課金を開始できず、E2E が踏むべき導線が無い。
2. **`lib/utils/purchase/purchase.dart` の Package Provider は `weekly / monthly / sixMonth / monthlyPremium` のみ**で、`annualPackage` / `lifetimePackage` が未定義。Test Store Offering に 3 Package (`$rc_monthly` / `$rc_annual` / `$rc_lifetime`) が attach 済みでもアプリ側が拾えない。
3. **購入後の専用表示が無い**: 「プレミアム会員」のような文言が UI に未実装。E2E の assert 対象は "ロックアイコン消失" や "『プレミアム: 無制限』表示" 等の既存 UI 変化しか無かった。
4. **`maestro/flows/premium_category_location_order.yaml` はファイル名に反し実態は非プレミアム検証**で、Issue 本文の「premium 版あり」は誤り。

E2E の前段として、まず「課金導線が存在するアプリ」「購入後の状態を assert できるマーカー」「3 Package を提示する画面」「Maestro 用の `Key` または安定した accessibility ターゲット」が必要となった。

## Decision

### Flutter

1. **`lib/utils/purchase/purchase.dart` に `annualPackage` / `lifetimePackage` Provider を追加**
   - 既存 `monthlyPackage` / `sixMonthPackage` と同じ `@Riverpod()` パターン
   - 現在 Offering の `availablePackages` から `PackageType.annual` / `PackageType.lifetime` を `firstWhereOrNull` で抽出

2. **`lib/features/paywall/` を新規作成**
   - `paywall_page.dart`: `PaywallPage`（`ConsumerWidget`） + `_PaywallPackageTile`
     - `offeringsProvider` を `when` で監視し、loading 中は `CircularProgressIndicator`、error 時は例外メッセージそのまま表示、data 時に 3 Package の Card を表示
     - 各購入ボタンに `Key('paywall_subscribe_${packageType.name}')` を付与（テスト識別子。なお iOS accessibility identifier には伝搬しないため、Maestro tap は表示順 index で行う）
     - 購入は `ref.read(purchaseProvider).call(package)` に委譲し、成功で「購入ありがとうございました」SnackBar → 画面 pop、例外で `e.toString()` をそのまま SnackBar 表示
   - `paywall.dart`: `Future<void> showPaywall({required BuildContext context})` で `MaterialPageRoute(fullscreenDialog: true)` を push

3. **Settings に「プレミアム会員」ListTile（`_PremiumMembershipTile`）を追加**
   - `customerInfoProvider.isPremium` を watch して subtitle を「有効」/「未加入」で出し分け
   - 未加入時のみ `onTap` で `showPaywall(context)` を呼ぶ
   - E2E の assert 対象として機能（購入後に subtitle が「有効」になる）

4. **各 premium gate の SnackBar に `SnackBarAction('アップグレード')` を追加**
   - 対象: テーマカラー設定 / 位置情報リマインダー（Switch / 地図側）/ リストエクスポート / グループ作成上限 / アイテム写真添付 / 買い物場所順カテゴリ並び替え（Dropdown / Reorder）/ AI 画像認識 / AI URL 認識 / リスト作成上限（Exception catch 経由 3 箇所）
   - 既存メッセージは保持し、`SnackBarAction` のタップで `showPaywall(context)` に遷移
   - AI 認識系は premium ユーザーには「アップグレード」action を出さない（`isPremium ? null : SnackBarAction(...)`）

### Maestro

5. **共通購入サブフローはパッケージ別に 3 ファイル化**
   - `shared/mock_purchase.yaml`（monthly 専用）/ `shared/mock_purchase_annual.yaml` / `shared/mock_purchase_lifetime.yaml`
   - 当初は `runFlow + env: PACKAGE_TYPE` で 1 ファイル化を試みたが、Maestro が `idRegex` / `index` のリテラル展開には `${VAR}` 構文を適用しないため不発。Package 別ファイル分割で確実に動かす

6. **設定画面の「プレミアム会員」ListTile アクセスは `scrollUntilVisible` ではなく `swipe` 2 回 + 部分一致 regex tapOn**
   - Flutter の `ListTile` は `title` + `subtitle` が 1 つのセマンティクス要素にマージされ、`scrollUntilVisible` の text 単独マッチが iOS で不安定
   - `swipe { start: "50%,80%", end: "50%,20%" }` を 2 回打って ListTile を可視範囲に入れ、`tapOn { text: ".*プレミアム会員.*" }` で部分一致 tap

7. **PaywallPage 上の購入ボタンは `text: "購入"` + 表示順 `index`（0 / 1 / 2）で tap**
   - Flutter `Key('paywall_subscribe_xxx')` は iOS accessibility identifier に伝搬しないため、`id` 指定で `Element not found` になる
   - 表示順は monthly → annual → lifetime 固定（PaywallPage 実装と一致）

8. **新規 14 本の Maestro フロー**を作成
   - `iap_purchase_{monthly,annual,lifetime}.yaml`: 購入後に「プレミアム会員: 有効」を assert
   - `premium_{theme_color_setting, export_shopping_list, group_creation, item_photo_attachment, location_reminder, shopping_list_display_period, shopping_list_limit, shopping_list_limit_duplicate, ai_image_recognition, ai_url_recognition}.yaml`: 各機能で `assertNotVisible` で non_premium SnackBar が出ないこと + premium 表示の assertVisible
   - 全フロー `inputText` は ASCII 化（Android Unicode 入力エラー回避）
   - `maestro/README.md` に iOS / Android 実行手順 + Test Store Key 取得手順 + トラブルシュート

### 採用しなかった選択肢

- **Maestro `runFlow + env` で 1 ファイル化**: `idRegex` / `text` の `${VAR}` 展開は機能するが、`tapOn { id: "paywall_subscribe_${PACKAGE_TYPE}" }` のような `idRegex` リテラル展開は Maestro 1.x で動作せず断念。プラットフォーム別調整が必要になった場合の保守性も考えてパッケージ別ファイル化の方が扱いやすい。
- **Flutter `Semantics(identifier: ...)` で iOS accessibility id を出す**: 後続でこの選択肢に切り替える余地はあるが、現状は `text + index` の組合せで十分動作する想定。Issue #235 のスコープ外として後続に回す。
- **Test Store の事前データ投入を E2E に組み込む**: AI 画像 / URL 認識上限テストは `aiUsage/{yyyy-MM}` の事前投入が必要だが、E2E から Firestore を直接叩くのは別 Issue 化。`optional: true` で保護して走らせ、未到達でも fail しない設計とした。

## Consequences

### Positive
- ユーザーがアプリから課金を開始できる（PaywallPage 経由）
- 各 premium gate が「ペイウォールへの導線つき SnackBar」になり、ロックされた機能から購入動線へ繋がる UX が成立
- Issue #235 で要求されている iOS / Android 両プラットフォーム向けの Maestro E2E フロー雛形（14 本）が揃う
- `customerInfoProvider.isPremium` を Settings の ListTile で可視化することで、E2E から購入後状態を素直に assert できる

### Negative / Trade-off
- **PaywallPage はミニマル UI**（タイトル + 説明 + Card 3 枚）で、コンバージョン最適化されたデザインではない。`paywall-design` skill の活用や A/B テストは後続 Issue で対応
- ~~**iOS Maestro 実行は CONFIGURATION_ERROR で未完了**~~: 当初は `launchApp.clearState=true + clearKeychain=true` 起動 × Test Store mode の race を疑っていたが、Issue #237（https://github.com/bannzai/shoppinglist/issues/237）の調査で **真の root cause は RC Dashboard の Test Store product に Base price (currency) が未設定** だったと判明した。`/rcbilling/v1/.../products?id=...` が `{"product_details":[]}` を返し、SDK が `OfferingsManager.Error error 1` を発生させていた。Dashboard で Base price を設定すれば解消する（API 経由設定は不可、Dashboard 専用操作）
- **Flutter `Key('paywall_subscribe_xxx')` は実質飾り**: iOS で accessibility identifier に伝搬しないため、Maestro テストからは `text + index` で間接 tap する。将来 `Semantics` に切り替える場合は本 ADR を更新する

### Follow-up
- ~~iOS / Android での Maestro E2E 実行（Phase I / J）は Test Store × clearState の挙動が解明された後に再開~~ → Issue #237 で root cause（Test Store Base price）解消、`iap_purchase_*.yaml` 3 本 + `category_location_order_non_premium.yaml` + `premium_ai_image_recognition.yaml` + `premium_ai_url_recognition.yaml` の 6/15 が iPhone 16 Plus / iOS 18.5 で PASS 確認済み
- ~~mock purchase modal の `tapOn` 対象（暫定 `"Subscribe"`）は実機調査で確定し、必要なら iOS / Android で platform 別サブフローに分離~~ → Issue #237 検証時に実 modal を確認し `Test valid purchase` に確定。`shared/mock_purchase{,_annual,_lifetime}.yaml` を更新済み
- **premium_*.yaml × 11 の方針転換**: Issue #237 検証で残り 9 本が flow-design 問題で fail（mock_purchase 後の Settings 画面 scroll 引き継ぎ等）。Maestro での課金 modal 自動操作自体が long-term で脆いため、**RC Promotional Entitlement の grant + デバッグ画面ボタン経由** に切り替える。詳細は Issue #239（https://github.com/bannzai/shoppinglist/issues/239）で対応
- IAP 3 flow（`iap_purchase_{monthly,annual,lifetime}.yaml`）は実購入フロー検証専用として `mock_purchase` 経路を残す
- `maestro/flows/premium_category_location_order.yaml` の名前と実態の不整合は本 PR で同時対応: 既存ファイルを `category_location_order_non_premium.yaml` にリネームし、新規 `premium_category_location_order.yaml`（実 premium 版、SnackBar 非表示の弱 assert）を追加
- ペイウォール UI のデザイン拡充（コンバージョン視点）は paywall-design skill ベースで別 Issue
