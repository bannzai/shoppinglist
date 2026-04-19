# 0009. IAP 自動化 4 Skill 構成と設計判断

## Status
Accepted

## Context

`#215` (App Store Connect 商品登録)、`#216` (Google Play Console 商品登録)、`#217` (RevenueCat ダッシュボード設定) を Claude Code Skill 化する必要があった。新規アプリ立ち上げのたびに 3 ストア横断で同じ手順を繰り返すコストを下げ、`{project}_{price}yen_{type}` の命名規則を機械的に強制したい。

調査結果（`plans/immutable-coalescing-wren.md` 参照）から判明した制約:

- **App Store Connect API**: JWT (ES256, 20 分有効)。初回 Subscription はバイナリと同時提出が必須で API 完結不可。Sandbox Tester 作成も UI 必須。
- **Google Play Developer API**: Service Account 認証。アプリ初回作成 / SA 招待 / RTDN Topic 登録は UI 必須。
- **RevenueCat REST API**: v1 と v2 の 2 系統あり、v2 は App / Product / Entitlement / Offering / Package + grant_entitlement (Promotional 付与) を扱える。Project 作成と Google Play SA JSON アップロードは Dashboard 必須。

これらをまとめて自動化するため、設計判断を以下に記録する。

## Decision

### 1. RevenueCat は v2 API 1 本に統一する

選択肢:
- a. v1 のみ使用（既存 `firebase/functions/src/functions/grantPromotionalPremium/function.ts` と同じ）
- b. v1 + v2 併用
- c. **v2 主軸、v1 は触らない**（採用）

理由:
- v2 に App / Product / Entitlement / Offering / Package の CRUD が揃っている（v1 には無い）
- v2 にも `POST /v2/projects/{project_id}/customers/{customer_id}/actions/grant_entitlement` があり Promotional 付与可能
- Skill 用 Secret Key は 1 本で済み、運用がシンプル
- 既存 Functions は v1 のままで動作（破壊的変更なし）

### 2. 認証情報は環境変数 `*_BASE64` で扱い、setup フェーズを設けない

選択肢:
- a. 各 Skill 初回実行時に setup スクリプトでファイルパスを設定
- b. 既存 keychain / 1Password CLI から都度取得
- c. **環境変数 `*_BASE64` で base64 エンコード済みを export、各スクリプト先頭で `base64 -d`**（採用）

理由:
- バイナリファイル (`.p8`, `service-account.json`) を `.zshrc` で `BASE64` suffix の環境変数にしておけば、Skill 側で setup 不要
- Skill が認証情報を平文で扱うのはスクリプト実行時のみ（`mktemp` + `trap rm` でクリーンアップ）
- 複数プロジェクト共通の認証情報を 1 度の export で再利用できる
- 命名規則: suffix `_BASE64` がついている変数のみ base64 デコード対象（`APP_STORE_CONNECT_KEY_BASE64` / `GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64`）。それ以外（`REVENUECAT_V2_SECRET_KEY` 等）はそのまま使用

### 3. Product ID 命名規則 `{project}_{price}yen_{type}` を全 Skill で正規表現バリデート

選択肢:
- a. 自由命名（ユーザー判断）
- b. ベストプラクティス推奨のみ、強制せず
- c. **Skill が正規表現で命名規則違反を拒否（exit 1）**（採用）

正規表現: `^[a-z][a-z0-9]*_\d+yen_(1month|6month|1year|consumable|lifetime)$`

例: `shoppinglist_480yen_1month`, `focus_10000yen_lifetime`

理由:
- 複数アプリで同一ルールに統一することで RC との対応関係が崩れない
- `type` から ASC `subscriptionPeriod` (`ONE_MONTH`/`SIX_MONTHS`/`ONE_YEAR`)、Play `billingPeriodDuration` (`P1M`/`P6M`/`P1Y`)、RC Package `lookup_key` (`$rc_monthly`/`$rc_six_month`/`$rc_annual`) を機械的に導出可能
- `iap-orchestrator` の config では `project` + `price_jp` + `type` のみ指定し、Product ID は Skill が組み立てる（個別 ID 指定不要）
- 命名ミス（typo）の混入を防止

### 4. 4 Skill 責務分離 + オーケストレータの 4 Skill 構成

| Skill | 責務 |
|---|---|
| `app-store-connect-iap` | ASC API 単独操作（JWT 生成、Subscription Group/Subscription/Localization/Price/Review Screenshot/提出） |
| `google-play-iap` | Google Play API 単独操作（Subscription/Base Plan/Activate/AAB upload/Track promote） |
| `revenuecat-setup` | RC v2 API 単独操作（App/Product/Entitlement/Offering/Package/grant_promotional） |
| `iap-orchestrator` | config JSON 1 つで上記 3 Skill を順次起動 |

選択肢:
- a. 1 Skill に全機能統合
- b. ストア別 2 Skill (iOS / Android) + RC 1 Skill
- c. **3 ストア API + 1 オーケストレータ = 4 Skill**（採用）

理由:
- 個別 API を単独で叩きたいケース（特定 Subscription だけ追加など）にも対応可能
- 単独 Skill ごとに責務が明確で `bannzai-skill-creator` の「スクリプトファースト」原則に準拠
- オーケストレータ層は config JSON を入力に各 Skill を順次呼ぶだけのシンプルな構造
- グローバル化 (`~/.claude/skills/`) する際も Skill ごとに移植可能

### 5. 各 Skill のディレクトリ構成は SKILL.md + references/ + scripts/ + (templates/)

`bannzai-skill-creator` 準拠:
- `SKILL.md`: 概要、できる/できないこと、環境変数、使い方、動作確認
- `references/links.md`: 公式・非公式 URL 集
- `references/manual-steps.md`: 手動が必要な操作の FAQ
- `references/naming-conventions.md`: Product ID / lookup_key 命名規則
- `scripts/_common.sh`: 環境変数チェック + API call wrapper
- `scripts/_jwt.py` / `_auth.py`: トークン生成（必要なスキルのみ）
- `scripts/<operation>.sh`: 各操作スクリプト（dry-run 対応）
- `templates/paywall.png`: ASC 用テンプレ画像（`app-store-connect-iap` のみ）

## Consequences

### 良い点
- 新規アプリ立ち上げ時に config JSON 1 つ + `iap-orchestrator` 1 コマンドで 3 ストア + RC のメタデータが揃う
- 命名規則を機械的に強制することで「typo で RC との対応が崩れる」事故を防止
- v2 API 1 本に統一したので Skill 用認証情報は v2 Secret Key 1 本で済む
- 各 Skill が単独でも使えるので、特定操作のみ実行したい場合にも柔軟
- 既存 Functions は v1 のままで動作するため破壊的変更なし

### 悪い点 / トレードオフ
- 全自動化は不可能。各 API に手動チェックポイントが残る:
  - ASC: 初回 Subscription はバイナリ提出と同時の Web 操作必須 / Sandbox Tester 作成 UI 必須
  - Play: アプリ初期作成 / SA 招待 / RTDN Topic 登録 / Closed Testing 14 日要件
  - RC: Project 作成 / Google Play SA JSON アップロード
- ASC API は per-territory price ループが必須で、175 territory × 3 サブスク = 525 リクエスト/初期セットアップ。レート制限内だが約 2 分かかる
- ASC `templates/paywall.png` はユーザーが事前配置必須。配置されていないと `upload_review_screenshot.sh` が失敗
- Skill 群はプロジェクト固有 (`.claude/skills/`) に配置。グローバル化時はサンプル名（`com.example.myapp` 等）への汎用化が必要

### 影響範囲
- `.claude/skills/{app-store-connect-iap,google-play-iap,revenuecat-setup,iap-orchestrator}/` 配下にファイル追加
- 既存コードへの影響なし（Skill 追加のみ）
- 関連 issue: `#215`, `#216`, `#217`, `#218` (Paywall 実装)
