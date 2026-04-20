#!/usr/bin/env bash
# inappproduct (one-time / lifetime) を upsert する。
# subscriptions と異なり Edits セッション不要で /inappproducts エンドポイントを直接叩く。
# Usage:
#   create_inapp_product.sh \
#     --package-name com.foo.bar \
#     --product-id shoppinglist_10000yen_lifetime \
#     --price-jp 10000 \
#     --display-name-ja "プレミアム（買い切り）" \
#     --display-name-en "Premium Lifetime" \
#     [--description-ja "..."] [--description-en "..."]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

PACKAGE_NAME=""
PRODUCT_ID=""
PRICE_JP=""
DISPLAY_NAME_JA=""
DISPLAY_NAME_EN=""
DESCRIPTION_JA=""
DESCRIPTION_EN=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package-name) PACKAGE_NAME="$2"; shift 2 ;;
    --product-id) PRODUCT_ID="$2"; shift 2 ;;
    --price-jp) PRICE_JP="$2"; shift 2 ;;
    --display-name-ja) DISPLAY_NAME_JA="$2"; shift 2 ;;
    --display-name-en) DISPLAY_NAME_EN="$2"; shift 2 ;;
    --description-ja) DESCRIPTION_JA="$2"; shift 2 ;;
    --description-en) DESCRIPTION_EN="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${PACKAGE_NAME:?--package-name is required}"
: "${PRODUCT_ID:?--product-id is required}"
: "${PRICE_JP:?--price-jp is required (JPY integer)}"
: "${DISPLAY_NAME_JA:?--display-name-ja is required}"
: "${DISPLAY_NAME_EN:?--display-name-en is required}"

validate_product_id "$PRODUCT_ID"

# JPY は小数点なし通貨
PRICE_MICROS="${PRICE_JP}000000"

body=$(jq -n \
  --arg package "$PACKAGE_NAME" \
  --arg sku "$PRODUCT_ID" \
  --arg priceMicros "$PRICE_MICROS" \
  --arg ja_title "$DISPLAY_NAME_JA" \
  --arg ja_desc "$DESCRIPTION_JA" \
  --arg en_title "$DISPLAY_NAME_EN" \
  --arg en_desc "$DESCRIPTION_EN" \
  '{
    packageName: $package,
    sku: $sku,
    status: "active",
    purchaseType: "managedUser",
    defaultPrice: {priceMicros: $priceMicros, currency: "JPY"},
    prices: {JP: {priceMicros: $priceMicros, currency: "JPY"}},
    defaultLanguage: "ja-JP",
    listings: {
      "ja-JP": {title: $ja_title, description: $ja_desc},
      "en-US": {title: $en_title, description: $en_desc}
    }
  }')

ACCESS_TOKEN=$(get_access_token)
export ACCESS_TOKEN

encoded_sku=$(printf '%s' "$PRODUCT_ID" | jq -sRr @uri)

# PUT は upsert 相当なので再実行安全。autoConvertMissingPrices=false で未指定国の価格自動変換を止める。
printf 'Upserting in-app product: %s (JPY %s)\n' "$PRODUCT_ID" "$PRICE_JP"
response=$(play_api PUT "/applications/${PACKAGE_NAME}/inappproducts/${encoded_sku}?autoConvertMissingPrices=false" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

if printf '%s' "$response" | jq -e '.sku' >/dev/null 2>&1; then
  printf '  → upserted: id=%s\n' "$PRODUCT_ID"
else
  printf 'Failed. Response: %s\n' "$response" >&2
  exit 1
fi
