# 0008. RC Promotions API経由でのプレミアム付与（テスト用）

## Status
Accepted

## Context
PR #177のプレミアム機能11件の動作確認において、非プレミアムユーザーのゲーティング確認だけでなく、プレミアムユーザー時のUI動作確認も必要になった。しかしiOS SimulatorではApp Store課金フローが動作しないため、プレミアム状態をテスト環境で再現する手段が必要。

検討した方法:
1. **Firebase CLI で Custom Claims を直接設定**: クライアント側のみバイパスでき、RevenueCat側の状態は変わらない
2. **開発者オプションにRiverpod overrideトグル追加**: クライアント側のみで、Firebase Functions側のプレミアム判定はバイパスできない
3. **GenKit Function + RevenueCat Promotions API**: サーバー側でRC Promo APIを呼び出しEntitlementを付与し、同時にCustom Claimsも設定する

## Decision
方法3を採用。`grantPromotionalPremium` GenKit Functionを追加し、開発者オプションから呼び出す。

理由:
- RevenueCat側のEntitlement状態とFirebase Custom Claimsの両方を整合性を保って設定できる
- Firebase Functions側のプレミアム判定（`context.auth.token.isPremium`）も正しく動作する
- 既存のGenKit Functionパターン（`ai.defineFlow` + `onCallGenkit`）に準拠

## Consequences
- `REVENUECAT_SECRET_API_KEY` をFirebase Functions環境変数に設定する必要がある
- 本番環境でも呼び出し可能なため、将来的にアクセス制御（特定UIDのみ許可等）の追加を検討する
