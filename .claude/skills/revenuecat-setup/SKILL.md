---
name: revenuecat-setup
description: |
  RevenueCat REST API v2 を使い、App / Product / Entitlement / Offering / Package のセットアップと、
  開発用の Promotional Entitlement 付与を自動化するスキル。
  Project 自体の作成と Google Play Service Account JSON のアップロードのみ Dashboard 手動。
  Product ID 命名規則 `{project}_{price}yen_{type}` を強制する。
  使用例: "/revenuecat-setup create-app --type app_store --bundle-id com.foo.bar"
user_invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# revenuecat-setup スキル

RevenueCat の v2 REST API を使い、リリース準備に必要な以下を自動化する。

## できること
- **App 作成** (`create_app.sh`): App Store / Google Play 用の App を RC プロジェクトに登録
- **Product 作成** (`create_products.sh`): ストアで作成済みの Product を RC に登録（個別 POST で N 件）
- **Entitlement 作成 + Product attach** (`create_entitlement.sh`): `lookup_key` 強制
- **Offering 作成** (`create_offering.sh`): `default` / `discounted` 等
- **Package 作成 + Product attach** (`create_package.sh`): `$rc_monthly` / `$rc_six_month` / `$rc_annual` / `$rc_lifetime` / `$rc_weekly`
- **Current Offering 設定** (`set_current_offering.sh`)
- **Promotional Entitlement 付与** (`grant_promotional.sh`): v2 `grant_entitlement` を使用

## できないこと（手動が必要）
詳細は `references/manual-steps.md` を参照。
- **Project 自体の作成**: Dashboard で 1 回だけ作成 (https://app.revenuecat.com)
- **Google Play Service Account JSON のアップロード**: `play_store` 型の App を API で作っても、JSON は別途 Dashboard アップロード必要
- **App Store Connect の API Key (.p8) を Dashboard 経由でアップロードする方が楽**: API でも `subscription_private_key` フィールドに渡せるが、運用上は Dashboard 推奨
- **Test Store App の作成**: REST API v2 の `type` enum に `test_store` が含まれないため Dashboard 専用。開発時に実ストア登録なしで IAP フローをテストしたいときに Dashboard で作成 → `lookup_test_store_app.sh` で API 経由 ID 解決 → `create_products.sh --app-type test_store` で Products 登録

## 環境変数
スクリプト先頭で `: "${VAR:?required}"` でチェック。事前に `.zshrc` 等で export しておく。

| 変数名 | 用途 |
|---|---|
| `REVENUECAT_V2_SECRET_KEY` | v2 API Bearer 認証用（`sk_` プレフィックス） |
| `REVENUECAT_PROJECT_ID` | 操作対象 Project ID |

## Product ID 命名規則（強制）
全スクリプトの引数で Product ID は以下の正規表現にマッチする必要あり:
```
^[a-z][a-z0-9]*_\d+yen_(1month|6month|1year|consumable|lifetime)$
```

例: `shoppinglist_480yen_1month`, `focus_10000yen_lifetime`

詳細は `references/naming-conventions.md`。

## 使い方

### 単発操作
```bash
# App 作成
bash ~/.claude/skills/revenuecat-setup/scripts/create_app.sh \
  --type app_store --bundle-id com.bannzai.shoppinglist --name "買い物リスト (iOS)"

# Product 作成
bash ~/.claude/skills/revenuecat-setup/scripts/create_products.sh \
  --app-id app_xxx \
  --product-ids shoppinglist_480yen_1month,shoppinglist_2580yen_6month,shoppinglist_4800yen_1year

# Entitlement 作成 + Product attach
bash ~/.claude/skills/revenuecat-setup/scripts/create_entitlement.sh \
  --lookup-key Premium \
  --display-name "プレミアム" \
  --attach-products shoppinglist_480yen_1month,shoppinglist_2580yen_6month,shoppinglist_4800yen_1year

# Offering 作成
bash ~/.claude/skills/revenuecat-setup/scripts/create_offering.sh \
  --lookup-key default --display-name "Default Offering"

# Package 作成 + Product attach
bash ~/.claude/skills/revenuecat-setup/scripts/create_package.sh \
  --offering-key default --package-key '$rc_monthly' --product-id shoppinglist_480yen_1month

# Current Offering 設定
bash ~/.claude/skills/revenuecat-setup/scripts/set_current_offering.sh --lookup-key default

# Test Store (開発時のみ、Dashboard で作成済みが前提)
# 事前調査
bash ~/.claude/skills/revenuecat-setup/scripts/inspect_test_store.sh
# Test Store app_id の解決
bash ~/.claude/skills/revenuecat-setup/scripts/lookup_test_store_app.sh
# Test Store Products 登録
bash ~/.claude/skills/revenuecat-setup/scripts/create_products.sh \
  --app-id app_xxx --app-type test_store \
  --product-ids shoppinglist_480yen_1month,shoppinglist_2580yen_6month,shoppinglist_4800yen_1year

# Promotional 付与（テスト用、duration: daily/weekly/monthly/yearly/lifetime 等）
bash ~/.claude/skills/revenuecat-setup/scripts/grant_promotional.sh \
  --customer-id <firebase_uid> --entitlement-key Premium --duration monthly
```

### dry-run
全スクリプトに `--dry-run` を渡すと API call を実行せず curl コマンドを表示。

## 動作確認
1. Project を https://app.revenuecat.com で作成（手動、1 回のみ）
2. `REVENUECAT_V2_SECRET_KEY` と `REVENUECAT_PROJECT_ID` を export
3. `create_app.sh` で App 作成 → Dashboard で確認
4. `create_entitlement.sh` で `lookup_key=Premium` の Entitlement を作成
5. `grant_promotional.sh` で自分の Firebase UID にプレミアムを付与
6. アプリ側で `customerInfoProvider` の `isPremium=true` になることを確認

## 関連リンク
- 公式・非公式リファレンス: `references/links.md`
- 手動操作の詳細: `references/manual-steps.md`
- 命名規則の詳細: `references/naming-conventions.md`
