# IAP 自動化 Skill 群 設計プラン (グローバル Skill 想定)

## Context

`#215` (App Store Connect 商品登録)、`#216` (Google Play 商品登録)、`#217` (RevenueCat 設定) の手作業を Claude Code Skill 化する。複数アプリで再利用するため**グローバル Skill (`~/.claude/skills/`) として設計する**。

調査結果（3 API の自動化可能範囲）と、ユーザーフィードバックを反映した最終設計を以下にまとめる。

---

## 全体方針（ユーザー指示反映）

| 項目 | 方針 |
|---|---|
| 配置先 | `~/.claude/skills/` (グローバル) |
| 認証情報 | **全て環境変数 `*_BASE64` で管理**。明示的な setup フェーズなし。各スクリプト先頭で base64 デコードして使用 |
| 資産（paywall png 等） | Skill 内 `templates/` に同梱。共通 paywall テンプレ画像を使い回し |
| FAQ / 手動操作ガイド | Skill 内 `references/` にまとめ、ユーザーが「これ手動？」と聞いたら答えられるように |
| ドキュメント参照 | 公式・非公式 URL を `references/links.md` に集約 |
| リファレンス URL | 各 Skill 内で参照可能に |
| **Product ID 命名規則** | **`{project}_{price}yen_{type}` で統一** (詳細は次セクション) |

---

## Product ID 命名規則（全 Skill 共通の強制ルール）

### フォーマット
```
{project}_{price}yen_{type}
```

| 部位 | 説明 | 値例 |
|---|---|---|
| `{project}` | プロジェクト識別子 (snake_case) | `shoppinglist`, `focus`, `mealplan` |
| `{price}yen` | 円表記の価格（数値+`yen`） | `100yen`, `480yen`, `1000yen`, `4800yen`, `10000yen` |
| `{type}` | 商品タイプ。Subscription は期間も含める | `1month` / `6month` / `1year` / `consumable` / `lifetime` |

### 例（買い物リストの場合）
```
shoppinglist_480yen_1month
shoppinglist_2580yen_6month
shoppinglist_4800yen_1year
```

### 例（Focus アプリの場合、ユーザー実績）
```
focus_10000yen_lifetime
focus_4800yen_1year
focus_1000yen_1month
focus_100yen_consumable
```

### 各 API への mapping

| `type` | App Store Connect | Google Play | RevenueCat Package |
|---|---|---|---|
| `1month` | Subscription, `subscriptionPeriod: ONE_MONTH` | Subscription + Base Plan `P1M` | `$rc_monthly` |
| `6month` | Subscription, `subscriptionPeriod: SIX_MONTHS` | Subscription + Base Plan `P6M` | `$rc_six_month` |
| `1year` | Subscription, `subscriptionPeriod: ONE_YEAR` | Subscription + Base Plan `P1Y` | `$rc_annual` |
| `consumable` | IAP V2, `inAppPurchaseType: CONSUMABLE` | inappproducts (managed product) | (entitlement なし、都度 grant) |
| `lifetime` (= non-consumable) | IAP V2, `inAppPurchaseType: NON_CONSUMABLE` | inappproducts (managed product) | `$rc_lifetime` |

### Skill 側の責務
1. **入力時に命名規則をバリデート**: 入力 ID が正規表現 `^[a-z][a-z0-9]*_\d+yen_(1month|6month|1year|consumable|lifetime)$` にマッチしなければ Skill が拒否
2. **type から各ストア API パラメータを自動導出**: ユーザーは `type` だけ指定すれば良い、`subscriptionPeriod` や `P1M` への変換は Skill が行う
3. **`iap-orchestrator` の config では `project` と `price` と `type` を別フィールドで持ち、Product ID は自動生成**:

```json
{
  "project": "shoppinglist",
  "products": [
    { "price_jp": 480,  "type": "1month",   "display_name_ja": "プレミアム（月額）", ... },
    { "price_jp": 2580, "type": "6month",   "display_name_ja": "プレミアム（6ヶ月）", ... },
    { "price_jp": 4800, "type": "1year",    "display_name_ja": "プレミアム（年額）", ... }
  ]
}
```

→ Skill が `shoppinglist_480yen_1month` 等を機械的に生成する。

### 補足
- `price_jp` は **JPY 整数値**。他通貨は ASC/Play の自動換算 or 個別指定（`price_us` などのフィールドを optional 追加可能）
- `consumable` には期間がないため Subscription にできない、Skill 側で型チェック
- `lifetime` は Google Play では **non-consumable in-app product** として作成（`inappproducts`、subscription ではない）

---

## Skill 構成（全 4 つ）

| Skill | 役割 | 対象 API |
|---|---|---|
| `app-store-connect-iap` | iOS の IAP / Subscription 作成 | App Store Connect API (JWT, ES256) |
| `google-play-iap` | Android の IAP / Subscription 作成 | Google Play Developer API (Service Account) |
| `revenuecat-setup` | RC の App / Entitlement / Offering / Package セットアップ | RevenueCat REST API v2 (`sk_` Secret) |
| **`iap-orchestrator`** | 上記 3 Skill を順次起動する オーケストレータ | (Skill を内部で呼ぶ) |

---

## 環境変数設計（全 Skill 共通）

各スクリプトの先頭で `base64 -d` してから使う。`.zshrc` などで export しておく前提。

| 変数名 | 用途 | 元データ |
|---|---|---|
| `APP_STORE_CONNECT_KEY_BASE64` | ASC API JWT 署名鍵 | `.p8` ファイル |
| `APP_STORE_CONNECT_KEY_ID` | ASC API Key の ID | (10 文字、base64 不要) |
| `APP_STORE_CONNECT_ISSUER_ID` | ASC API の Issuer ID | (UUID、base64 不要) |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64` | Play Developer API 認証 | service-account.json |
| `REVENUECAT_V2_SECRET_KEY` | RC v2 API（`sk_` プレフィックス） | (そのまま、base64 不要) |
| `REVENUECAT_PROJECT_ID` | 操作対象 RC プロジェクト | (そのまま、base64 不要) |

→ `*_BASE64` の suffix が付くものだけ base64 デコード対象。それ以外はそのまま使う。

例（各スクリプト先頭の共通処理）:

```bash
#!/usr/bin/env bash
set -euo pipefail

: "${APP_STORE_CONNECT_KEY_BASE64:?env required}"
: "${APP_STORE_CONNECT_KEY_ID:?env required}"
: "${APP_STORE_CONNECT_ISSUER_ID:?env required}"

ASC_KEY_PATH=$(mktemp -t asc_key.p8)
trap "rm -f $ASC_KEY_PATH" EXIT
echo "$APP_STORE_CONNECT_KEY_BASE64" | base64 -d > "$ASC_KEY_PATH"
# 以降 $ASC_KEY_PATH を使って JWT 生成
```

---

## Skill 1: `app-store-connect-iap`

### ディレクトリ構成
```
~/.claude/skills/app-store-connect-iap/
├── SKILL.md
├── references/
│   ├── links.md          # 公式/非公式 URL 集
│   ├── manual-steps.md   # 手動が必要なタイミングと内容（FAQ）
│   └── jwt-spec.md       # JWT 生成仕様（ES256, 20 分有効）
├── templates/
│   └── paywall.png       # 審査用テンプレ画像（使い回し）
└── scripts/
    ├── _common.sh        # 環境変数チェック + JWT 生成 + curl wrapper
    ├── create_subscription_group.sh
    ├── create_subscription.sh
    ├── set_localization.sh
    ├── set_prices.sh
    ├── upload_review_screenshot.sh   # templates/paywall.png をアップロード
    └── submit_subscription.sh        # 2回目以降のみ
```

### 自動化範囲
- Subscription Group 作成 (`POST /v1/subscriptionGroups`)
- Auto-Renewable Subscription 作成 (`POST /v1/subscriptions`、`subscriptionPeriod`: `ONE_MONTH` / `SIX_MONTHS` / `ONE_YEAR`)
- Localization (ja / en-US) 登録
- Price 設定（per-territory、`POST /v1/subscriptionPrices` をループ）
- Review Screenshot アップロード（4 段階: 予約 → PUT → commit → polling）
- 2 回目以降の `POST /v1/subscriptionSubmissions` 提出

### 手動チェックポイント（`references/manual-steps.md` に明記）
- **初回 Subscription はアプリバイナリと一緒に App Store Connect Web で提出が必須**（Apple 公式: "The first in-app purchase must be submitted with an app binary submission"）
- Sandbox Tester の作成・削除（API 不可、Web UI のみ）
- Sandbox 反映に最大 1 時間遅延

### Paywall テンプレ画像
- `templates/paywall.png` に汎用的な「Premium Plan」UI のスクリーンショットを 1 枚配置
- 審査用に必要な「機能リスト + 価格 + Subscribe ボタン」が映っているもの
- 毎回これを使い回す（ユーザーの運用上問題ない実績あり）

---

## Skill 2: `google-play-iap`

### ディレクトリ構成
```
~/.claude/skills/google-play-iap/
├── SKILL.md
├── references/
│   ├── links.md
│   ├── manual-steps.md
│   └── edits-workflow.md  # Edits の楽観ロック仕様
└── scripts/
    ├── _common.sh         # SA JSON base64 デコード + auth
    ├── create_subscription.sh
    ├── create_base_plan.sh
    ├── activate_base_plan.sh
    ├── set_localization.sh
    ├── upload_aab.sh
    ├── promote_track.sh
    └── cleanup_edits.sh
```

### 自動化範囲
- Subscription 作成 (`monetization.subscriptions.create`)
- Base Plan 作成 + Activate (`P1M`, `P6M`, `P1Y`)
- Subscription Localization
- Price (`RegionalBasePlanConfig`)
- AAB アップロード (`edits.bundles.upload`)
- Track 切り替え (`edits.tracks.update`)
- Release notes 登録
- Dangling edits cleanup

### 手動チェックポイント
- **アプリ (package name) の Play Console 初回作成** (`applications` リソースに `create` メソッドなし)
- Service Account の Play Console 初回招待（Permissions API は招待後の権限変更のみ）
- RTDN の Topic 名登録（Cloud Pub/Sub 側は API 化可能だが Play Console 側 UI 必須）
- 個別 email の License Tester（`googleGroups[]` のみ受付）
- Data Safety フォーム
- **2026 から Closed testing で 12 名以上が 14 日間アクティブ要件**（ポリシー、API では解決不可）

---

## Skill 3: `revenuecat-setup`

### ディレクトリ構成
```
~/.claude/skills/revenuecat-setup/
├── SKILL.md
├── references/
│   ├── links.md
│   ├── manual-steps.md
│   └── lookup-key-conventions.md  # SDK 標準 lookup_key (`$rc_monthly` など)
└── scripts/
    ├── _common.sh
    ├── create_app.sh
    ├── create_products.sh        # ストア Skill の出力 JSON を入力
    ├── create_entitlement.sh
    ├── attach_products_to_entitlement.sh
    ├── create_offering.sh
    ├── create_package.sh
    ├── set_current_offering.sh
    └── grant_promotional.sh      # v2 grant_entitlement を使用
```

### 自動化範囲（**v2 API 1 本で統一**）
- App 作成 (`POST /v2/projects/{project_id}/apps`)
- Product 作成 (`POST /v2/projects/{project_id}/products`、ストア Skill の出力リストを入力に N 回 POST)
- Entitlement 作成 (`lookup_key: 'Premium'` を強制)
- Entitlement に Product を attach
- Offering 作成 (`lookup_key: 'default'` / `'discounted'`)
- Package 作成 (`lookup_key: '$rc_monthly'` / `'$rc_six_month'` / `'$rc_weekly'` を強制)
- Current Offering 設定
- **Promotional Entitlement 付与** (`POST /v2/projects/{project_id}/customers/{customer_id}/actions/grant_entitlement`)

### v1 API Key について（質問 3 への回答）
- **新規 Skill では v1 不要**。v2 の `grant_entitlement` で Promotional 付与可能（`customer_information:customers:read_write` スコープ、480 req/min）
- 既存 Functions の `grantPromotionalPremium` は v1 を使い続けて OK（Premium Entitlement を `lookup_key='Premium'` で正しく作れば 404 は解消する）
- 将来 Functions 側も v2 に統一したくなったら別タスクで対応

### 「Product 自動 import」について（質問 5 への回答）
- RC Dashboard の `+ New → Import Products` ボタン（接続済みストアから自動取得）は **REST API に同等エンドポイントが存在しない**
- Skill では「ストア Skill の出力 Product ID リスト（JSON）を入力にして、`POST /v2/projects/.../products` を N 回呼ぶ」で代替
- 結果は同じ。ユーザー視点では `iap-orchestrator` が橋渡しするので意識不要

### 手動チェックポイント
- **Project 自体の作成**（v2 にも作成 API なし、Dashboard 必須、最初の 1 回のみ）
- **Google Play Service Account JSON のアップロード**（`play_store` App は `package_name` のみ受け付け、JSON は別途 Dashboard アップロード）

### 既存コードとの整合性（強制バリデーション項目）

`lib/utils/purchase/purchase.dart` の以下定数と一致させる:

| 定数 | 値 | Skill 入力での扱い |
|---|---|---|
| `premiumEntitlementIdentifier` | `'Premium'` | Entitlement `lookup_key` のデフォルト値、変更時は警告 |
| `OfferingType` | `'default'` / `'discounted'` | Offering `lookup_key` のデフォルト値 |
| `PackageType` | SDK 標準 | Package `lookup_key` は `$rc_*` 標準値必須 |

---

## Skill 4: `iap-orchestrator` ← 新規追加（フィードバック 8）

### 想定ユースケース
> 「このアプリは com.example.foo というバンドルで、月額 480 円・半年 2580 円・年額 4800 円のプレミアムプランを iOS と Android で提供したい。プレミアム機能は X / Y / Z の 3 つ。3 ストア + RC を全部セットアップしてほしい」

### ディレクトリ構成
```
~/.claude/skills/iap-orchestrator/
├── SKILL.md
├── references/
│   ├── links.md
│   ├── workflow.md             # 全体フロー図
│   └── manual-checkpoints.md   # 全手動操作タイミングまとめ
└── scripts/
    ├── orchestrate.sh          # 全 Skill を順次呼ぶ
    └── config_template.json    # アプリごとの設定テンプレ
```

### config 設計
入力 JSON 1 ファイルで Skill 群に必要な情報を集約。**Product ID は `project` + `price_jp` + `type` から自動生成**するためユーザーは個別 ID を書かない:

```json
{
  "project": "shoppinglist",
  "app": {
    "bundle_id": "com.bannzai.shoppinglist",
    "package_name": "com.bannzai.shoppinglist",
    "display_name": { "ja": "買い物リスト", "en-US": "Shopping List" }
  },
  "products": [
    {
      "price_jp": 480,
      "type": "1month",
      "display_name": { "ja": "プレミアム（月額）", "en-US": "Premium Monthly" },
      "description": { "ja": "...", "en-US": "..." }
    },
    {
      "price_jp": 2580,
      "type": "6month",
      "display_name": { "ja": "プレミアム（6ヶ月）", "en-US": "Premium 6 Month" }
    },
    {
      "price_jp": 4800,
      "type": "1year",
      "display_name": { "ja": "プレミアム（年額）", "en-US": "Premium Yearly" }
    }
  ],
  "revenuecat": {
    "project_id": "proj_xxx",
    "entitlement_lookup_key": "Premium",
    "offerings": [
      { "lookup_key": "default", "packages": ["$rc_monthly", "$rc_six_month", "$rc_annual"] }
    ]
  }
}
```

→ Skill が以下を自動生成:
- Product ID (ASC / Play / RC 共通): `shoppinglist_480yen_1month`, `shoppinglist_2580yen_6month`, `shoppinglist_4800yen_1year`
- ASC `subscriptionPeriod`: `ONE_MONTH` / `SIX_MONTHS` / `ONE_YEAR`
- Play Base Plan billing period: `P1M` / `P6M` / `P1Y`
- RC Package `lookup_key`: `$rc_monthly` / `$rc_six_month` / `$rc_annual`

### オーケストレーションフロー
```
[Phase 1] iOS / Android 並列実行
  ├─ Skill 1: app-store-connect-iap (3 subscription 作成)
  └─ Skill 2: google-play-iap (3 subscription + base plan 作成 + activate)

[Phase 2] 手動チェックポイント (orchestrator が指示を出す)
  ├─ ASC: 「初回提出はバイナリと一緒に Web から行ってください」
  ├─ Play: 「Service Account JSON を Play Console に招待してください」
  └─ RC: 「Project と Service Account JSON を Dashboard で設定してください」

[Phase 3] RevenueCat セットアップ
  └─ Skill 3: revenuecat-setup (App + Product + Entitlement + Offering + Package)

[Phase 4] 動作確認
  └─ Promotional 付与でプレミアム動作確認
```

### Skill UX 例
```
/iap-orchestrator init           # config テンプレを生成
/iap-orchestrator validate config.json
/iap-orchestrator run config.json
/iap-orchestrator status         # 各 Skill の進捗
/iap-orchestrator manual-checkpoints  # 手動操作の一覧表示
```

### 手動チェックポイントの統合表示
全 Skill の手動操作を 1 ヶ所に集約。ユーザーが「いまどこで何を手動でやらないといけない？」と聞いたら、orchestrator がフェーズに応じて答える。

---

## 各 Skill 共通の設計原則

1. **スクリプトファースト**: SKILL.md に直接処理を書かず、`scripts/` 配下のシェル/Python に委譲（bannzai-skill-creator 準拠）
2. **冪等性**: 全操作 upsert パターン（`lookup_key` / `productId` で GET → 無ければ POST、あれば skip/PATCH）
3. **環境変数チェック**: 各スクリプト冒頭で `: "${VAR:?required}"` で必須変数を明示
4. **手動チェックポイント明示**: スクリプト中で `printf "次のステップ: ダッシュボードで XX してください\n"` を出力
5. **エラーリトライ**: 429 は exponential backoff、409 は upsert で吸収、5xx は最大 3 回リトライ
6. **既存コード規約準拠**: `lookup_key` バリデーションを Skill が拒否するレベルで強制
7. **動作確認セクション必須**: SKILL.md に「これで動いていることを確認するには」(dry-run / list-only モード)
8. **manual-steps.md (FAQ)**: ユーザーが「ここ手動？」と聞いたら答えられるよう Q&A 形式で配置

---

## 実装順序（見積もり時間 = ユーザーフィードバック 7 に従い短縮）

```
Phase A: revenuecat-setup (Skill 3)         ← 4 時間
  理由: 単独で価値が出る (404 解消、開発者オプションが動くようになる)
  必要環境変数: REVENUECAT_V2_SECRET_KEY, REVENUECAT_PROJECT_ID

Phase B: app-store-connect-iap (Skill 1)    ← 6 時間
  理由: iOS 先行リリースができる
  注意: 初回 Subscription はバイナリ提出と同時 (UI 必須) → Skill ではメタデータ作成までで終わり、提出は人間に依頼
  必要環境変数: APP_STORE_CONNECT_KEY_BASE64, APP_STORE_CONNECT_KEY_ID, APP_STORE_CONNECT_ISSUER_ID

Phase C: google-play-iap (Skill 2)          ← 6 時間
  理由: Android リリースに必要
  注意: アプリ初期作成 + Service Account 招待は UI、本体作成後から自動化
  必要環境変数: GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64

Phase D: iap-orchestrator (Skill 4)         ← 3 時間
  理由: A/B/C を統合して新規アプリ立ち上げを 1 コマンドに
  config JSON 設計とフェーズ管理、手動チェックポイント統合
```

合計 19 時間 ≈ 2.5 日（Claude が書く速度なら）。

---

## 関連 issue の更新（後続作業）

調査結果反映で以下の issue を更新:

- **#215** (App Store Connect 商品登録): 「初回はバイナリ提出と同時の UI 操作必須」追記、Skill 化対象範囲をメタデータ作成までに限定
- **#216** (Google Play Console 商品登録): 「アプリ作成 / Service Account 招待 / RTDN Topic 登録 / Closed testing 14 日要件」を手動チェックポイントとして追記
- **#217** (RevenueCat ダッシュボード設定): 404 真因 (`lookup_key` vs `entl_xxx` の取り違え) を追記、Project 作成と Service Account JSON アップロードのみ手動と明確化、v2 grant_entitlement で完結する旨追記

---

## 参考資料

### App Store Connect API
- [App Store Connect API トップ](https://developer.apple.com/documentation/appstoreconnectapi)
- [JWT トークン生成](https://developer.apple.com/documentation/appstoreconnectapi/generating-tokens-for-api-requests)
- [Subscriptions リソース](https://developer.apple.com/documentation/appstoreconnectapi/subscriptions)
- [Auto-Renewable Subscription 管理手順](https://developer.apple.com/documentation/appstoreconnectapi/managing-auto-renewable-subscriptions)
- [Subscription 提出手順](https://developer.apple.com/documentation/appstoreconnectapi/submitting-subscriptions-and-subscription-groups-for-app-review)
- [Subscription Price Points & Prices](https://developer.apple.com/documentation/appstoreconnectapi/subscription-price-points-and-subscription-prices)
- [Sandbox Testers (v2)](https://developer.apple.com/documentation/appstoreconnectapi/sandbox-testers)
- [レート制限](https://developer.apple.com/documentation/appstoreconnectapi/identifying-rate-limits)

### Google Play Developer API
- [Google Play Developer API トップ](https://developers.google.com/android-publisher)
- [Getting Started (認証)](https://developers.google.com/android-publisher/getting_started)
- [monetization.subscriptions](https://developers.google.com/android-publisher/api-ref/rest/v3/monetization.subscriptions)
- [monetization.subscriptions.basePlans/activate](https://developers.google.com/android-publisher/api-ref/rest/v3/monetization.subscriptions.basePlans/activate)
- [edits リソース](https://developers.google.com/android-publisher/api-ref/rest/v3/edits)
- [edits.bundles (AAB)](https://developers.google.com/android-publisher/api-ref/rest/v3/edits.bundles)
- [edits.tracks](https://developers.google.com/android-publisher/api-ref/rest/v3/edits.tracks)
- [Quotas (レート制限)](https://developers.google.com/android-publisher/quotas)
- [Closed Testing 14 日要件 (2026)](https://12testers14days.pro/blog/google-play-policy-changes-2026/)

### RevenueCat REST API
- [REST API v1 ドキュメント](https://www.revenuecat.com/docs/api-v1)
- [REST API v2 (Developer API) ドキュメント](https://www.revenuecat.com/docs/api-v2)
- [API Keys & Authentication](https://www.revenuecat.com/docs/projects/authentication)
- [Promotional Entitlements](https://www.revenuecat.com/docs/promotionals)
- [Connect Apps & Web Providers](https://www.revenuecat.com/docs/projects/connect-a-store)
- [REST API v2 App Management 追加 (2023/10)](https://revenuecat.releasenotes.io/release/n27PU-new-rest-api-v2-functionality-app-management-overview-metrics)
- [Community: 404 の原因](https://community.revenuecat.com/general-questions-7/rest-api-grant-promotional-retruns-error-with-not-found-4449)
- [Community: Project 作成 API は無い](https://community.revenuecat.com/general-questions-7/create-projects-apps-etc-via-api-1870)
- [RevenueCat MCP Server (公式 MCP との比較検討用)](https://www.revenuecat.com/docs/tools/mcp/setup)

→ これらは各 Skill の `references/links.md` にコピーして配置。

---

## 検証方法（各 Skill 完成後）

| Skill | 検証コマンド |
|---|---|
| `revenuecat-setup` | `~/.claude/skills/revenuecat-setup/scripts/create_entitlement.sh --dry-run` で API call 内容を確認、本実行で開発者オプションのプレミアム付与が成功すること |
| `app-store-connect-iap` | `~/.claude/skills/app-store-connect-iap/scripts/create_subscription.sh --dry-run` 後、ASC Web で作成されたことを目視確認 |
| `google-play-iap` | `~/.claude/skills/google-play-iap/scripts/create_subscription.sh --dry-run` 後、Play Console で確認 |
| `iap-orchestrator` | `~/.claude/skills/iap-orchestrator/scripts/orchestrate.sh --validate config.json` で fail せず、本実行で全フェーズ完了 |

---

## チェックリスト

### 実装内容
- [x] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している（`_common.sh` の base64 デコード例、config JSON テンプレ、ディレクトリ構成等）
- [x] 既存コードのパターン・構成を確認し、同じパターンで実装している（`purchase.dart` の `lookup_key` 整合性、bannzai-skill-creator 準拠）

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
