---
name: google-play-iap
description: |
  Google Play Developer API (Service Account) を使い、Android アプリのプレミアムサブスクリプションの
  作成、Base Plan の有効化、Localization、AAB アップロード、Track 切り替えを自動化するスキル。
  アプリ自体の作成・Service Account 招待・RTDN は手動が必要（Play Console UI のみ対応）。
  Product ID 命名規則 `{project}_{price}yen_{type}` を強制する。
  使用例: "/google-play-iap create-subscription premium --base-plans monthly"
user_invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# google-play-iap スキル

Google Play Developer API v3 (`monetization.subscriptions.*`, `edits.*`) を使い、リリース準備を自動化する。

## できること
- **Subscription 作成** (`create_subscription.sh`)
- **Base Plan 作成 + Activate** (`create_base_plan.sh`, `activate_base_plan.sh`)
- **Subscription Localization** (`set_localization.sh`)
- **Edits ベースの AAB アップロード** (`upload_aab.sh`)
- **Track 切り替え** (`promote_track.sh`)
- **Edits cleanup** (`cleanup_edits.sh`): dangling edits を一括削除

## できないこと（手動が必要）
詳細は `references/manual-steps.md` 参照。
- **アプリ (package name) の Play Console 初回作成** (`applications` リソースに `create` メソッドなし)
- Service Account の Play Console 初回招待（Permissions API は招待後の権限変更のみ対応）
- RTDN の Topic 名登録（Cloud Pub/Sub 側は API 化可能だが Play Console 側 UI 必須）
- 個別 email の License Tester（`googleGroups[]` のみ受付）
- Data Safety フォーム
- **2026 から Closed testing で 12 名以上が 14 日間アクティブ要件**（API では解決不可）

## 環境変数
| 変数名 | 用途 |
|---|---|
| `GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64` | Service Account JSON（base64 エンコード） |

## Product ID 命名規則
全スクリプトで `{project}_{price}yen_{type}` を強制。詳細は `references/naming-conventions.md`。

## 使い方

```bash
# Subscription 作成
bash ~/.claude/skills/google-play-iap/scripts/create_subscription.sh \
  --package-name com.bannzai.shoppinglist \
  --product-id shoppinglist_480yen_1month \
  --display-name-ja "プレミアム（月額）" \
  --display-name-en "Premium Monthly"

# Base Plan 作成
bash ~/.claude/skills/google-play-iap/scripts/create_base_plan.sh \
  --package-name com.bannzai.shoppinglist \
  --product-id shoppinglist_480yen_1month \
  --base-plan-id monthly --price-jp 480

# Activate
bash ~/.claude/skills/google-play-iap/scripts/activate_base_plan.sh \
  --package-name com.bannzai.shoppinglist \
  --product-id shoppinglist_480yen_1month \
  --base-plan-id monthly

# AAB アップロード
bash ~/.claude/skills/google-play-iap/scripts/upload_aab.sh \
  --package-name com.bannzai.shoppinglist \
  --aab-path build/app/outputs/bundle/release/app-release.aab \
  --track internal --release-notes-ja "初回リリース" --release-notes-en "Initial release"

# Track 切り替え
bash ~/.claude/skills/google-play-iap/scripts/promote_track.sh \
  --package-name com.bannzai.shoppinglist \
  --version-code 12 --from internal --to closed
```

## 動作確認
1. Service Account JSON を base64 エンコードして `GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64` に export
2. Play Console でアプリ作成 + Service Account 招待 + 初回 AAB を internal track にアップロード（手動）
3. `create_subscription.sh` で Subscription 作成 → Play Console で確認

## 関連リンク
- 公式・非公式リファレンス: `references/links.md`
- 手動操作の詳細: `references/manual-steps.md`
- Edits ワークフロー: `references/edits-workflow.md`
