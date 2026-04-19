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
