# App Store Connect API 参考リンク集

## 公式

### 全体
- [App Store Connect API トップ](https://developer.apple.com/documentation/appstoreconnectapi)
- [API 公式概要](https://developer.apple.com/app-store-connect/api/)
- [API キー作成](https://developer.apple.com/documentation/appstoreconnectapi/creating-api-keys-for-app-store-connect-api)
- [JWT トークン生成](https://developer.apple.com/documentation/appstoreconnectapi/generating-tokens-for-api-requests)
- [レート制限](https://developer.apple.com/documentation/appstoreconnectapi/identifying-rate-limits)
- [アセット (画像) アップロード](https://developer.apple.com/documentation/appstoreconnectapi/uploading-assets-to-app-store-connect)

### Subscription
- [Subscriptions リソース](https://developer.apple.com/documentation/appstoreconnectapi/subscriptions)
- [Subscription Groups](https://developer.apple.com/documentation/appstoreconnectapi/subscription-groups)
- [Auto-Renewable Subscription Group 作成手順](https://developer.apple.com/documentation/appstoreconnectapi/creating-auto-renewable-subscription-groups)
- [Auto-Renewable Subscription 管理手順](https://developer.apple.com/documentation/appstoreconnectapi/managing-auto-renewable-subscriptions)
- [Subscription 提出手順](https://developer.apple.com/documentation/appstoreconnectapi/submitting-subscriptions-and-subscription-groups-for-app-review)
- [POST /v1/subscriptions](https://developer.apple.com/documentation/appstoreconnectapi/post-v1-subscriptions)
- [SubscriptionCreateRequest (`subscriptionPeriod` 列挙)](https://developer.apple.com/documentation/appstoreconnectapi/subscriptioncreaterequest/data-data.dictionary/attributes-data.dictionary)
- [Subscription Review Screenshot](https://developer.apple.com/documentation/appstoreconnectapi/subscription-app-store-review-screenshots)
- [Subscription Price Points & Prices](https://developer.apple.com/documentation/appstoreconnectapi/subscription-price-points-and-subscription-prices)

### IAP V2 (参考)
- [IAPv2 概要](https://developer.apple.com/documentation/appstoreconnectapi/inappurchases-v2)
- [IAP 管理手順](https://developer.apple.com/documentation/appstoreconnectapi/managing-in-app-purchases)
- [IAP 提出](https://developer.apple.com/documentation/appstoreconnectapi/in-app-purchase-submissions)

### Sandbox
- [Sandbox Testers (v2)](https://developer.apple.com/documentation/appstoreconnectapi/sandbox-testers)
- [Sandbox Apple Account 作成 (UI 手順)](https://developer.apple.com/help/app-store-connect/test-in-app-purchases/create-sandbox-apple-ids)

## サードパーティ
- [RevenueCat: ASC API Key 設定](https://www.revenuecat.com/docs/service-credentials/itunesconnect-app-specific-shared-secret/app-store-connect-api-key-configuration)
- [Apple Developer Forums: per-minute 429 事例](https://developer.apple.com/forums/thread/731014)

## 重要な制約事項
- **初回 Subscription はバイナリ提出と同時の Web 操作必須**: "The first in-app purchase must be submitted with an app binary submission through appstoreconnect.apple.com."
- API Key は発行時の `.p8` を **1 回しかダウンロードできない**
- JWT は **20 分以内**（一部 GET 専用は 6 ヶ月可）
- レート制限: **3500 req/hour/key**、Forums では分間 300〜350 で 429 観測の事例あり
