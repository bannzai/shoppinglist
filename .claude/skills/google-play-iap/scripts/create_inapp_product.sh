#!/usr/bin/env bash
# One-time product (lifetime / consumable) を新 API で upsert する。
# 旧 /inappproducts エンドポイントは "Please migrate to the new publishing API" で非推奨。
# 新エンドポイント: PATCH /applications/{pkg}/onetimeproducts/{productId}
#
# 前提: AndroidManifest.xml に `com.android.vending.BILLING` permission を宣言した AAB を
#       Play Console の Internal testing track に 1 回アップロード済みであること。
#       未対応だと "Can't create product. To fix, request billing permission." で失敗する。
#       詳細: google-play-iap/references/manual-steps.md の §1-a 参照。
#
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

body=$(jq -n \
  --arg package "$PACKAGE_NAME" \
  --arg pid "$PRODUCT_ID" \
  --arg ja_title "$DISPLAY_NAME_JA" \
  --arg ja_desc "$DESCRIPTION_JA" \
  --arg en_title "$DISPLAY_NAME_EN" \
  --arg en_desc "$DESCRIPTION_EN" \
  --arg priceUnits "$PRICE_JP" \
  '{
    packageName: $package,
    productId: $pid,
    listings: [
      {languageCode: "ja", title: $ja_title, description: $ja_desc},
      {languageCode: "en-US", title: $en_title, description: $en_desc}
    ],
    purchaseOptions: [
      {
        purchaseOptionId: "default",
        state: "ACTIVE",
        buyOption: {legacyCompatible: true},
        regionalPricingAndAvailabilityConfigs: [
          {
            regionCode: "JP",
            price: {currencyCode: "JPY", units: $priceUnits, nanos: 0},
            availability: "AVAILABLE"
          }
        ]
      }
    ]
  }')

ACCESS_TOKEN=$(get_access_token)
export ACCESS_TOKEN

encoded_pid=$(printf '%s' "$PRODUCT_ID" | jq -sRr @uri)

printf 'Upserting one-time product (new API): %s (JPY %s)\n' "$PRODUCT_ID" "$PRICE_JP"
response=$(play_api PATCH "/applications/${PACKAGE_NAME}/onetimeproducts/${encoded_pid}?regionsVersion.version=2022/02&updateMask=listings,purchaseOptions&allowMissing=true" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

if printf '%s' "$response" | jq -e '.productId' >/dev/null 2>&1; then
  printf '  → upserted: id=%s\n' "$PRODUCT_ID"
else
  printf 'Failed. Response: %s\n' "$response" >&2
  exit 1
fi
