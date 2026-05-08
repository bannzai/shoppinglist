# Google Play Product ID 命名規則

全ストア共通の命名規則 `{project}_{price}yen_{type}` を使用。

正規表現: `^[a-z][a-z0-9]*_\d+yen_(1month|6month|1year|consumable|lifetime)$`

## Play への mapping

| `type` | リソース | billing period |
|---|---|---|
| `1month` | Subscription + Base Plan (auto-renewing) | `P1M` |
| `6month` | Subscription + Base Plan (auto-renewing) | `P6M` |
| `1year` | Subscription + Base Plan (auto-renewing) | `P1Y` |
| `consumable` | inappproducts (managed product) | (期間なし) |
| `lifetime` | inappproducts (managed product, non-consumable) | (期間なし) |

## 1 Subscription / 複数 Base Plan の構成
**推奨**: 1 つの Subscription `productId` に対して 3 つの Base Plan を作る:
- Subscription productId: `<project>_premium`（命名規則の例外として、grouping のため）
- Base Plan ID: `monthly` / `six-month` / `yearly`

ただし本スキルでは命名規則統一のため **1 product : 1 Base Plan**:
- `shoppinglist_480yen_1month` → Base Plan `monthly`
- `shoppinglist_2580yen_6month` → Base Plan `six-month`
- `shoppinglist_4800yen_1year` → Base Plan `yearly`

複数 Base Plan を 1 つの Subscription にまとめたい場合はオプション `--subscription-id` で別途指定可能。

## 注意
- Subscription productId は Play Console で **作成後変更不可**
- Product ID は **小文字/数字/アンダースコア/ドット 1-40 文字**
- Base Plan は **DRAFT 状態で作成される**ので明示的に `:activate` が必要
