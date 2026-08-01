# 0026. プレミアム判定を Custom Claims から RevenueCat Subscribers API に統一

## Status
Accepted

## Context
Issue #385 で「有料会員でも AI 機能が月5回まで」というエラーが報告された。調査の結果、サーバー側（Firebase Functions）のプレミアム判定が Firebase Auth Custom Claims（`premium` / `isPremium`）に依存している一方、**Custom Claims を設定するコードがどこにも存在しない**ことが判明した（`setCustomUserClaims` の呼び出しは皆無、RevenueCat の Firebase Extension も未導入）。そのため課金ユーザーでも `hasPremiumEntitlement` が常に false を返し、無料上限（AI 機能 月5回）が適用されていた。

さらに claim のキーが関数によって `premium`（AI 系3関数）と `isPremium`（uploadShoppingListItemImage / createGroup / createShoppingList）で不統一だった。

プレミアム状態の実体は RevenueCat（ストア課金・Promotional 付与の両方が反映される）にのみ存在し、クライアントは RevenueCat SDK の customerInfo で正しく判定できていた。

## Decision
サーバー側のプレミアム判定を共通ヘルパー `firebase/functions/src/functions/utils/premium.ts` に集約し、RevenueCat Subscribers API（`GET /v1/subscribers/{uid}`）への照会に統一する。Custom Claims への依存は廃止する。

- `entitlements.Premium` の `expires_date` が null（無期限）または未来であればプレミアムと判定する
- 判定に失敗した場合（API エラー・ネットワーク例外）は無料ユーザーとして扱う
- Secret は `grantPromotionalPremium` で既に使用していた `REVENUECAT_SECRET_API_KEY` を共用し、定義もこのヘルパーを SSOT とする

検討した代替案:
1. **購入時に Custom Claims を同期する（RevenueCat Webhook → Functions）**: Webhook の受け口・キー統一・同期タイミングの考慮が必要で変更が大きく見送り
2. **クライアントの申告値を信用する**: 改ざん可能なため不採用

ADR 0008 の「RC Promo API 呼び出しと同時に Custom Claims も設定する」という記述は、本決定により実質置き換えられる（Claims はもはや参照されない）。

## Consequences
- 有料会員に AI 機能のプレミアム上限（月50回）が正しく適用される。createGroup / createShoppingList / uploadShoppingListItemImage の同種バグも同時に解消
- プレミアム状態の SSOT が RevenueCat に一本化され、クライアント（customerInfo）とサーバー（Subscribers API）が同じソースを参照する
- プレミアム判定を行う Functions の呼び出しごとに RevenueCat API への HTTP 往復（数百 ms）が追加される。現状の呼び出し頻度では許容範囲だが、増加した場合はキャッシュの検討が必要
- プレミアム判定を行うすべての Functions に `REVENUECAT_SECRET_API_KEY` の secret バインドが必要になる
- クライアント側の `firestoreIsPremium`（Custom Claims 読み取り、home_widget_sync で使用）は依然 false を返し続ける問題が残っており、別途対応が必要
  - 追記: Issue #523（課金後もリスト作成上限の課金催促が出る）でこの残課題が顕在化したため、クライアント側のプレミアム判定も RevenueCat SDK の `customerInfoProvider` に統一し、`firestoreIsPremium` は削除した
