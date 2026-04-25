---
name: app-store-connect-iap
description: |
  App Store Connect API (JWT, ES256) を使い、iOS アプリのプレミアムサブスクリプション
  (Auto-Renewable Subscription) のメタデータ作成を自動化するスキル。
  Subscription Group / Subscription / Localization / Price / Review Screenshot / 提出 を扱う。
  **初回 Subscription はバイナリと同時提出が必須** で、Skill ではメタデータ作成までで終わる。
  Product ID 命名規則 `{project}_{price}yen_{type}` を強制する。
  使用例: "/app-store-connect-iap create-subscription premium-monthly --period ONE_MONTH"
user_invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# app-store-connect-iap スキル

App Store Connect API を使い、リリース準備に必要な以下を自動化する。

## できること
- **Subscription Group 作成** (`create_subscription_group.sh`)
- **Subscription 作成** (`create_subscription.sh`): `subscriptionPeriod` を `1month` / `6month` / `1year` から自動マップ
- **Localization** (`set_localization.sh`): ja / en-US の Display Name / Description
- **Price 設定** (`set_prices.sh`): per-territory ループ実装
- **Review Screenshot アップロード** (`upload_review_screenshot.sh`): `templates/paywall.png` のテンプレ画像を使い回し
- **2 回目以降の提出** (`submit_subscription.sh`)
- **App ID 取得** (`get_app_id.sh`): bundle ID から App Store Connect 内の `app id` を解決

## できないこと（手動が必要）
詳細は `references/manual-steps.md` 参照。
- **初回 Subscription はアプリバイナリと一緒に App Store Connect Web で提出が必須**（Apple 公式: "The first in-app purchase must be submitted with an app binary submission"）
- Sandbox Tester の作成・削除（API 不可、Web UI のみ）
- Sandbox 反映に最大 1 時間遅延

## 環境変数
| 変数名 | 用途 |
|---|---|
| `ASC_KEY_P8_BASE64` | `.p8` 秘密鍵（base64 エンコード） |
| `ASC_KEY_ID` | API Key の ID（10 文字） |
| `ASC_ISSUER_ID` | API の Issuer ID（UUID） |

## Product ID 命名規則
全スクリプトで `{project}_{price}yen_{type}` を強制。詳細は `references/naming-conventions.md`。

## Paywall テンプレ画像
`templates/paywall.png` に Apple 審査用の汎用 Paywall スクショを配置。
このファイルが無い場合、`upload_review_screenshot.sh` は失敗する。**初回利用時は適切な png を `templates/paywall.png` に配置**。

## 使い方

```bash
# App ID 取得（後続で使う app_id を bundle_id から解決）
bash ~/.claude/skills/app-store-connect-iap/scripts/get_app_id.sh --bundle-id com.bannzai.shoppinglist

# Subscription Group 作成
bash ~/.claude/skills/app-store-connect-iap/scripts/create_subscription_group.sh \
  --app-id 1234567890 --reference-name Premium

# Subscription 作成（命名規則を強制バリデート）
bash ~/.claude/skills/app-store-connect-iap/scripts/create_subscription.sh \
  --group-id <group_id> \
  --product-id shoppinglist_480yen_1month \
  --reference-name "Premium Monthly"

# Localization 設定
bash ~/.claude/skills/app-store-connect-iap/scripts/set_localization.sh \
  --subscription-id <sub_id> \
  --locale ja --name "プレミアム（月額）" --description "..."

# Price 設定
bash ~/.claude/skills/app-store-connect-iap/scripts/set_prices.sh \
  --subscription-id <sub_id> --price-jp 480 --territories US,JP,GB

# Review Screenshot アップロード
bash ~/.claude/skills/app-store-connect-iap/scripts/upload_review_screenshot.sh \
  --subscription-id <sub_id>

# 2回目以降の提出
bash ~/.claude/skills/app-store-connect-iap/scripts/submit_subscription.sh \
  --subscription-id <sub_id>
```

すべてのスクリプトに `--dry-run` オプションあり。

## 動作確認
1. ASC の API Key (.p8) を発行 → base64 エンコードして export
2. `get_app_id.sh` で bundle ID 解決
3. `create_subscription_group.sh` でグループ作成 → ASC Web で表示確認
4. `create_subscription.sh` で Subscription 作成 → ASC Web で表示確認
5. （初回リリースの場合）バイナリと一緒に Web 経由で提出

## 関連リンク
- 公式・非公式リファレンス: `references/links.md`
- 手動操作の詳細: `references/manual-steps.md`
- JWT 仕様: `references/jwt-spec.md`
