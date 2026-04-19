# RevenueCat REST API 参考リンク集

## 公式ドキュメント

### REST API
- [REST API v1](https://www.revenuecat.com/docs/api-v1) - レガシー、Subscriber 操作・Promotional 付与に使用
- [REST API v2 (Developer API)](https://www.revenuecat.com/docs/api-v2) - 推奨、リソース管理 + 顧客操作の後継
- [API Keys & Authentication](https://www.revenuecat.com/docs/projects/authentication) - キー種別、スコープ
- [OAuth 2.0 Overview](https://www.revenuecat.com/docs/projects/oauth-overview) - OAuth フロー（本 Skill では未使用）

### リソース管理
- [Projects Overview](https://www.revenuecat.com/docs/projects/overview) - Project は Dashboard でのみ作成可能
- [Connect Apps & Web Providers](https://www.revenuecat.com/docs/projects/connect-a-store) - App / Service Account JSON 連携
- [Entitlements](https://www.revenuecat.com/docs/getting-started/entitlements) - Entitlement の概念
- [Offerings](https://www.revenuecat.com/docs/offerings/overview) - Offering / Package の構造

### Promotional
- [Promotional Entitlements](https://www.revenuecat.com/docs/promotionals) - 付与の仕組み

### 統合
- [Firebase Functions integration](https://www.revenuecat.com/docs/integrations/firebase-integration)
- [RevenueCat MCP Server](https://www.revenuecat.com/docs/tools/mcp/setup) - 公式 MCP（Skill の代替検討）

## エンドポイント別仕様

### v1
- [POST /v1/subscribers/{app_user_id}/entitlements/{entitlement_identifier}/promotional](https://www.revenuecat.com/docs/api-v1) - Promotional 付与（`entitlement_identifier` には `lookup_key` を渡す）

### v2
- `POST /v2/projects/{project_id}/apps` - App 作成
- `POST /v2/projects/{project_id}/products` - Product 作成
- `POST /v2/projects/{project_id}/entitlements` - Entitlement 作成
- `POST /v2/projects/{project_id}/offerings` - Offering 作成
- `POST /v2/projects/{project_id}/offerings/{offering_id}/packages` - Package 作成
- `POST /v2/projects/{project_id}/customers/{customer_id}/actions/grant_entitlement` - Promotional 付与（v2 版）

## コミュニティ・トラブルシューティング
- [Promotional 404 の真因 (lookup_key vs entl_xxx)](https://community.revenuecat.com/general-questions-7/rest-api-grant-promotional-retruns-error-with-not-found-4449)
- [Project 作成 API は無い (2025/3 時点)](https://community.revenuecat.com/general-questions-7/create-projects-apps-etc-via-api-1870)
- [REST API v2 App Management 追加 (2023/10)](https://revenuecat.releasenotes.io/release/n27PU-new-rest-api-v2-functionality-app-management-overview-metrics)

## レート制限
| ドメイン | 制限 |
|---|---|
| Customer Information | 480 req/min |
| Project Configuration | 60 req/min |
| Charts & Metrics | 5–15 req/min |
