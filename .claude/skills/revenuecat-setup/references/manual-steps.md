# RevenueCat 手動操作が必要なタイミング

## 1. Project の作成（最初の 1 回のみ）

**いつ**: 新しいアプリを RevenueCat に登録するとき。

**なぜ手動**: REST API v1/v2 のいずれにも Project 作成エンドポイントが存在しない。RevenueCat スタッフが 2025 年 3 月時点で「まだ無い」と回答（[Community](https://community.revenuecat.com/general-questions-7/create-projects-apps-etc-via-api-1870)）。

**手順**:
1. https://app.revenuecat.com にログイン
2. 左サイドバー上部の Project ドロップダウン → **+ Create new project**
3. プロジェクト名（任意）と通貨を入力
4. 作成後、URL に表示される `proj_xxxxx` を控える → `REVENUECAT_PROJECT_ID` として export

## 2. v2 Secret Key の発行

**いつ**: Skill 初回利用時。

**手順**:
1. Project Settings → **API Keys** タブ
2. **+ New** → **V2 Secret API Key** を選択
3. 必要なスコープを ON:
   - `project_configuration:apps:read_write`
   - `project_configuration:products:read_write`
   - `project_configuration:entitlements:read_write`
   - `project_configuration:offerings:read_write`
   - `project_configuration:packages:read_write`
   - `customer_information:customers:read_write` (grant_entitlement 用)
4. 生成された `sk_xxx` キーを `REVENUECAT_V2_SECRET_KEY` として export
5. **このキーは一度しか表示されない**。`.zshrc` 等に保存する

## 3. App Store Connect 連携用キーのアップロード（推奨は Dashboard）

**いつ**: `app_store` 型の App を作成して購入を扱いたいとき。

**API でも可能**: App 作成エンドポイントが `subscription_private_key`, `subscription_key_id`, `subscription_key_issuer`, `app_store_connect_api_key`, etc. のフィールドを受け付ける。**ただし運用上は Dashboard の方が安全**（鍵漏洩リスク低減）。

**Dashboard 手順**:
1. App 作成後（Skill が作る）→ Dashboard で対象 App を開く
2. Apple Specific → **App Store Connect API Key** で `.p8` をアップロード
3. または **In-App Purchase Key**（Subscription Status 用、別 Key）も同様にアップロード

## 4. Google Play Service Account JSON のアップロード（必須・Dashboard のみ）

**いつ**: `play_store` 型の App を作成したとき。

**なぜ手動**: REST API の `play_store` App 作成は `package_name` のみ受け付け、Service Account JSON を渡すフィールドが無い（[Connect a store](https://www.revenuecat.com/docs/projects/connect-a-store)）。

**手順**:
1. Google Cloud Console で Service Account を作成し、Play Console に招待（→ `google-play-iap` skill 参照）
2. Service Account JSON をダウンロード
3. RC Dashboard で対象 App を開く → Google Play Specific → **Service Account Credentials** で JSON をアップロード
4. アップロード後 24h ほど経過しないと Subscription Status が同期されないことがある（Google Play 側のキャッシュ）

## 5. Product の自動 import（Dashboard のみ・代替手段あり）

**いつ**: ストア (ASC/Play) で作成した Product を一括で RC に取り込みたいとき。

**Dashboard では可能**:
1. RC Dashboard → Products → **+ New → Import Products**
2. 接続済みストアから自動取得 → チェックして Import

**API には同等エンドポイントが無い**ので、Skill は `create_products.sh` で Product ID を 1 つずつ POST する設計。結果は同じ。

## 6. Webhook / Integration の細部設定

**いつ**: Slack / Stripe / Mixpanel 等への通知を設定したいとき。

**API も v2 にあるが**: ダッシュボード UI の方が整っているため、初回設定は Dashboard 推奨。

## 7. OAuth Client の登録

**いつ**: Skill を他人にも配布したい / マルチプロジェクト対応にしたいとき。

**手順**:
- RevenueCat サポートにメール申請（`support@revenuecat.com`）
- アプリ名・ホームページ URL・コールバック URL・public/confidential を伝える
- 自動セルフサービス登録は無い（リードタイムあり）

→ 個人用 Skill では Secret Key で十分なので、本 Skill では未対応。

## 8. Test Store の作成と API Key 発行（開発時のみ）

**いつ**: 実 ASC/Play に商品登録せずに開発ビルドで IAP フローをテストしたいとき。

**なぜ手動**: REST API v2 の `POST /projects/{pid}/apps` の `type` enum は `app_store, mac_app_store, play_store, amazon, stripe, rc_billing, roku, paddle` の 8 種のみで `test_store` が含まれない。Test Store は Dashboard 専用リソース。
- 確認ソース: [API v2 reference](https://www.revenuecat.com/docs/api-v2)、[OpenAPI YAML](https://www.revenuecat.com/docs/redocusaurus/plugin-redoc-0.yaml)（`test_store` 文字列ゼロ件）、[Test Store docs](https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store)（"create one on the **Apps and providers** tab"）

**手順**:
1. https://app.revenuecat.com/projects/${REVENUECAT_PROJECT_ID}/apps にアクセス
2. "Apps and providers" ページの **"Test configuration"** セクションから新規作成
3. 発行される Test Store Public API Key を `REVENUECAT_TEST_STORE_API_KEY` として export
4. Dashboard URL から Test Store App の内部 ID (`appXXX`) を控え、`REVENUECAT_TEST_STORE_APP_ID` として export（`inspect_test_store.sh` で API 経由発見できる場合は不要）
5. config の `revenuecat.test_store.enabled` を `true` にして `orchestrate.sh --phase 3` を実行
6. Products は自動登録される（Entitlement / Offering / Package は本番 App と共有）

**先行調査**: API での Test Store App の見え方 (`type` 値) が公式非明記のため、`inspect_test_store.sh` を実行してから `lookup_test_store_app.sh` の candidate 配列を確定すること。

**SDK 側の注意**: Test Store API Key で Release build を起動すると SDK が警告を出す（本番不可）。Flutter 側での API Key 切替は別 Issue で対応予定。

**参考**:
- https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store
- https://www.revenuecat.com/blog/engineering/testing-test-store/

## 9. Test Store Product の Base price 設定（必須・Dashboard のみ）

**いつ**: `create_products.sh --app-type test_store` で Test Store product を作成した直後。

**なぜ手動**: REST API v2 の以下のいずれの endpoint にも `price` / `currency` フィールドが存在しない（OpenAPI YAML 全文確認済み）:
- `POST /v2/projects/{pid}/products` (create-product) — request body は `store_identifier` / `app_id` / `type` / `display_name` / `subscription` / `title` のみ
- `POST /v2/projects/{pid}/products/{prod_id}` (update-product) — `display_name` のみ更新可
- `POST /v2/projects/{pid}/products/{prod_id}/create_in_store` — App Store 向け push 専用、Test Store 用途では使用不可

つまり Base price は Dashboard でしか設定できない。

**症状（未設定時）**: SDK が CONFIGURATION_ERROR(23) を返し Paywall が表示できない。
- `GET /v1/.../offerings` は package 一覧を返す（`platform_product_identifier` 入り、正常）
- `GET /rcbilling/v1/subscribers/{uid}/products?id=shoppinglist_500yen_1month&...` は `{"product_details":[]}` を返す（**price 未設定の product は除外される**）
- iOS SDK は `OfferingsManager.Error error 1` を発生 → Flutter 側に `PlatformException(code:23, CONFIGURATION_ERROR)` として透過
- shoppinglist Issue #237 で再現と root cause 特定済み

**手順**:
1. https://app.revenuecat.com/projects/${REVENUECAT_PROJECT_ID}/products にアクセス
2. 対象 Test Store product (例: `shoppinglist_500yen_1month`) をクリック
3. **Base price** セクションの **+ Add currency** で通貨と金額を追加
   - 日本円なら `JPY` / `500` 等、product_id 末尾の `_500yen_` から自然に読み取れる値を入れる
4. 全 Test Store product に対して繰り返す
5. 設定後、curl で確認:
   ```bash
   curl -H "Authorization: Bearer ${REVENUECAT_TEST_STORE_API_KEY}" \
     "https://api.revenuecat.com/rcbilling/v1/subscribers/dummy/products?id=shoppinglist_500yen_1month"
   # → product_details が非空配列で返れば OK
   # → product_details: [] のままなら設定が反映されていない（数秒〜1分待って再試行）
   ```

**参考**:
- OpenAPI YAML (`POST /products` schema 確認用): https://www.revenuecat.com/docs/redocusaurus/plugin-redoc-0.yaml
- Test Store overview: https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store
- shoppinglist Issue #237: 本症状の Maestro E2E 経由再現と log stream 解析
