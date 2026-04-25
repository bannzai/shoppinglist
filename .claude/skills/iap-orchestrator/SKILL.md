---
name: iap-orchestrator
description: |
  新規アプリの IAP セットアップを 3 ストア横断で一括実行するオーケストレータスキル。
  config JSON 1 つで App Store Connect / Google Play / RevenueCat の Subscription / Product / Entitlement / Offering を作成する。
  app-store-connect-iap, google-play-iap, revenuecat-setup の 3 Skill を内部で順次起動する。
  Product ID 命名規則 `{project}_{price}yen_{type}` を強制し、type から各ストア API パラメータを自動導出する。
  使用例: "/iap-orchestrator init"  "/iap-orchestrator run config.json"
user_invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# iap-orchestrator スキル

新規アプリの「3 ストア + RC でプレミアムプラン提供」を 1 ファイル + 1 コマンドで完結させる。

## 想定ユースケース
> 「このアプリは com.example.foo というバンドルで、月額 480 円・半年 2580 円・年額 4800 円のプレミアムプランを iOS と Android で提供したい。3 ストア + RC を全部セットアップしてほしい」

## 依存スキル
- `app-store-connect-iap` (Skill 1)
- `google-play-iap` (Skill 2)
- `revenuecat-setup` (Skill 3)

これら 3 スキルを内部で `bash ~/.claude/skills/...` 経由で起動する。

## 環境変数
依存スキルが必要とする全環境変数を事前 export しておく:

| 変数名 | スキル |
|---|---|
| `ASC_KEY_P8_BASE64` | Skill 1 |
| `ASC_KEY_ID` | Skill 1 |
| `ASC_ISSUER_ID` | Skill 1 |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64` | Skill 2 |
| `REVENUECAT_V2_SECRET_KEY` | Skill 3 |
| `REVENUECAT_PROJECT_ID` | Skill 3 |

## 使い方

### 1. config テンプレ生成
```bash
bash ~/.claude/skills/iap-orchestrator/scripts/init.sh > my-app-iap-config.json
# テンプレを編集（project / app / products / revenuecat を入力）
```

### 2. config 検証
```bash
bash ~/.claude/skills/iap-orchestrator/scripts/validate.sh my-app-iap-config.json
```

### 3. 実行
```bash
bash ~/.claude/skills/iap-orchestrator/scripts/orchestrate.sh my-app-iap-config.json
```

### 4. 手動チェックポイント表示
```bash
bash ~/.claude/skills/iap-orchestrator/scripts/manual_checkpoints.sh
```

### dry-run
全スクリプトに `--dry-run` を渡すと API call せず curl コマンドだけ表示。

## オーケストレーションフロー

```
[Phase 0] config 検証
  ├─ JSON schema validation
  ├─ Product ID が命名規則にマッチするか
  └─ 環境変数チェック

[Phase 1] iOS / Android 並列実行
  ├─ Skill 1: app-store-connect-iap
  │   └─ Subscription Group → Subscription × N → Localization × 2N → Price → Review Screenshot
  └─ Skill 2: google-play-iap
      └─ Subscription × N → Base Plan × N → Activate × N

[Phase 2] 手動チェックポイント案内
  ├─ ASC: 「初回提出はバイナリと一緒に Web から行ってください」
  ├─ Play: 「Service Account JSON を Play Console に招待 / RTDN 設定」
  └─ RC: 「Project と Google Play Service Account JSON を Dashboard で設定」

[Phase 3] RevenueCat セットアップ
  └─ Skill 3: revenuecat-setup
      └─ App × 2 → Product × N → Entitlement → Offering → Package × N → Set Current
```

## config 仕様

`scripts/config_template.json` に最小例を配置。`init.sh` で出力する。

主要フィールド:
- `project`: snake_case のプロジェクト識別子（例: `shoppinglist`）
- `app.bundle_id`, `app.package_name`, `app.display_name`
- `products[]`: 各 Product の `price_jp` と `type`、display_name / description
  - Product ID は `{project}_{price_jp}yen_{type}` で**自動生成**（手動指定不要）
- `revenuecat.project_id`, `revenuecat.entitlement_lookup_key`, `revenuecat.offerings`

## 関連リンク
- 全体フロー: `references/workflow.md`
- 全手動チェックポイント統合: `references/manual-checkpoints.md`
- 命名規則: 各依存スキルの `references/naming-conventions.md` 参照
