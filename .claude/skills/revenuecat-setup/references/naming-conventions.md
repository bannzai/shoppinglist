# RevenueCat 命名規則

## Product ID
全ストア共通の命名規則 `{project}_{price}yen_{type}` を使用。

正規表現: `^[a-z][a-z0-9]*_\d+yen_(1month|6month|1year|consumable|lifetime)$`

| 部位 | 説明 | 例 |
|---|---|---|
| `{project}` | snake_case のプロジェクト識別子 | `focus`, `shoppinglist`, `mealplan` |
| `{price}yen` | 円表記の価格 | `100yen`, `480yen`, `4800yen`, `10000yen` |
| `{type}` | 商品タイプ | `1month` / `6month` / `1year` / `consumable` / `lifetime` |

例:
- `shoppinglist_480yen_1month`
- `shoppinglist_2580yen_6month`
- `shoppinglist_4800yen_1year`
- `focus_10000yen_lifetime`
- `focus_100yen_consumable`

`create_products.sh` 等のスクリプトは入力 Product ID をこの正規表現でバリデートし、不一致なら拒否する。

## Entitlement lookup_key
- 既定: `'Premium'`（`shoppinglist` の `lib/utils/purchase/purchase.dart:16` の `premiumEntitlementIdentifier` と一致）
- 大文字始まり、英数字のみ
- 1 つの App に複数 Entitlement を持つことは可能だが、シンプルなアプリでは `Premium` 1 つで十分

## Offering lookup_key
- 既定: `'default'`（current Offering）
- 割引用: `'discounted'`（`OfferingType.discounted` に対応）

## Package lookup_key
SDK 標準値（`$` プレフィックスが付く）を使う。これにより `purchases_flutter` の `PackageType` enum と自動対応:

| Package lookup_key | PackageType (SDK) | Product ID type |
|---|---|---|
| `$rc_lifetime` | `lifetime` | `lifetime` |
| `$rc_annual` | `annual` | `1year` |
| `$rc_six_month` | `sixMonth` | `6month` |
| `$rc_three_month` | `threeMonth` | (未対応) |
| `$rc_two_month` | `twoMonth` | (未対応) |
| `$rc_monthly` | `monthly` | `1month` |
| `$rc_weekly` | `weekly` | (未対応) |

カスタム lookup_key を使うと SDK 側で `PackageType.custom` になり、`firstWhereOrNull((e) => e.packageType == PackageType.monthly)` がヒットしなくなるので注意。
