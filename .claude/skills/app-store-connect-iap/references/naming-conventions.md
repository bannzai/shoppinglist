# App Store Connect Product ID 命名規則

全ストア共通の命名規則 `{project}_{price}yen_{type}` を使用。

正規表現: `^[a-z][a-z0-9]*_\d+yen_(1month|6month|1year|consumable|lifetime)$`

## ASC への mapping

| `type` | `subscriptionPeriod` (Auto-Renewable) | IAP V2 `inAppPurchaseType` |
|---|---|---|
| `1month` | `ONE_MONTH` | - |
| `6month` | `SIX_MONTHS` | - |
| `1year` | `ONE_YEAR` | - |
| `consumable` | - | `CONSUMABLE` |
| `lifetime` | - | `NON_CONSUMABLE` |

例:
- `shoppinglist_480yen_1month` → Subscription, ONE_MONTH
- `focus_10000yen_lifetime` → IAP V2, NON_CONSUMABLE
- `focus_100yen_consumable` → IAP V2, CONSUMABLE

## 注意
- Product ID は **一度作成すると削除不可**。命名ミスに注意
- スクリプトは正規表現で強制バリデートし、不一致なら exit 1
