# iap-orchestrator 全体フロー

## 概要
3 ストア横断 IAP セットアップを config 1 ファイル + 1 コマンドで完結させる。

## フロー図

```
[USER]
  ↓ 1. config テンプレ生成
  init.sh → config.json

[USER]
  ↓ 2. config 編集（project, products, revenuecat 等を記入）

[USER]
  ↓ 3. 実行
  orchestrate.sh config.json

[ORCHESTRATOR]
  Phase 0: 検証
    ├─ JSON parse
    ├─ Product ID 命名規則チェック
    └─ 環境変数存在チェック

  Phase 1: ストア並列実行
    ├─ Skill 1 (ASC):
    │   ├─ get_app_id (bundle_id → app_id 解決)
    │   ├─ create_subscription_group
    │   ├─ for each product:
    │   │   ├─ create_subscription
    │   │   ├─ set_localization (ja)
    │   │   ├─ set_localization (en-US)
    │   │   ├─ set_prices
    │   │   └─ upload_review_screenshot
    │   └─ (初回バイナリ提出は手動)
    └─ Skill 2 (Play):
        └─ for each product:
            ├─ create_subscription
            ├─ create_base_plan
            └─ activate_base_plan

  Phase 2: 手動チェックポイント表示
    └─ manual_checkpoints.sh の出力を表示してユーザーに確認待ち

  Phase 3: RevenueCat セットアップ
    └─ Skill 3 (RC):
        ├─ create_app (app_store)
        ├─ create_app (play_store)  ※ Service Account JSON は別途 Dashboard 手動
        ├─ create_products (ASC + Play 両方の Product を import)
        ├─ create_entitlement (lookup_key: Premium)
        ├─ create_offering (lookup_key: default)
        ├─ for each product → create_package + attach_product
        └─ set_current_offering
```

## 手動チェックポイントが入るタイミング

- **Phase 0 → Phase 1 の前**: ASC / Play のアプリ作成 / 招待 / 初回 AAB アップロードは事前に必要
- **Phase 2**: ASC 初回バイナリ提出 / Play RTDN 設定 / RC Project 作成 / RC Service Account JSON アップロード
- これらの手動操作は orchestrator が `printf` で促す
