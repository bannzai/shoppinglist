#!/usr/bin/env bash
# Subscription を base plan 同梱で作成する
# Play Developer API v3 では subscription 作成時に basePlans に 1 つ以上含める必要がある
# (単独 listings のみの POST は "Subscription must contain at least one base plan" で弾かれる)
# Usage:
#   create_subscription.sh \
#     --package-name com.foo.bar \
#     --product-id shoppinglist_480yen_1month \
#     --base-plan-id 1month \
#     --price-jp 480 \
#     --display-name-ja "プレミアム（月額）" \
#     --display-name-en "Premium Monthly" \
#     [--description-ja "..."] [--description-en "..."]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

PACKAGE_NAME=""
PRODUCT_ID=""
BASE_PLAN_ID=""
PRICE_JP=""
DISPLAY_NAME_JA=""
DISPLAY_NAME_EN=""
DESCRIPTION_JA=""
DESCRIPTION_EN=""
REGIONS_VERSION="2022/02"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package-name) PACKAGE_NAME="$2"; shift 2 ;;
    --product-id) PRODUCT_ID="$2"; shift 2 ;;
    --base-plan-id) BASE_PLAN_ID="$2"; shift 2 ;;
    --price-jp) PRICE_JP="$2"; shift 2 ;;
    --display-name-ja) DISPLAY_NAME_JA="$2"; shift 2 ;;
    --display-name-en) DISPLAY_NAME_EN="$2"; shift 2 ;;
    --description-ja) DESCRIPTION_JA="$2"; shift 2 ;;
    --description-en) DESCRIPTION_EN="$2"; shift 2 ;;
    --regions-version) REGIONS_VERSION="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${PACKAGE_NAME:?--package-name is required}"
: "${PRODUCT_ID:?--product-id is required}"
: "${BASE_PLAN_ID:?--base-plan-id is required (1month/6month/1year)}"
: "${PRICE_JP:?--price-jp is required (JPY integer)}"
: "${DISPLAY_NAME_JA:?--display-name-ja is required}"
: "${DISPLAY_NAME_EN:?--display-name-en is required}"

validate_product_id "$PRODUCT_ID"

BILLING_PERIOD=$(play_billing_period "$BASE_PLAN_ID")

listings=$(jq -n \
  --arg ja "$DISPLAY_NAME_JA" \
  --arg en "$DISPLAY_NAME_EN" \
  --arg dja "$DESCRIPTION_JA" \
  --arg den "$DESCRIPTION_EN" \
  '[
    {languageCode: "ja-JP", title: $ja, description: $dja},
    {languageCode: "en-US", title: $en, description: $den}
  ]')

# google.type.Money: units は整数 JPY (500)、micros ではない
body=$(jq -n \
  --argjson listings "$listings" \
  --arg bpid "$BASE_PLAN_ID" \
  --arg period "$BILLING_PERIOD" \
  --arg priceUnits "$PRICE_JP" \
  '{
    listings: $listings,
    basePlans: [{
      basePlanId: $bpid,
      state: "DRAFT",
      autoRenewingBasePlanType: {
        billingPeriodDuration: $period,
        gracePeriodDuration: "P3D",
        resubscribeState: "RESUBSCRIBE_STATE_ACTIVE",
        prorationMode: "SUBSCRIPTION_PRORATION_MODE_CHARGE_ON_NEXT_BILLING_DATE",
        legacyCompatible: true
      },
      regionalConfigs: [{
        regionCode: "JP",
        price: {
          currencyCode: "JPY",
          units: $priceUnits,
          nanos: 0
        },
        newSubscriberAvailability: true
      }]
    }]
  }')

ACCESS_TOKEN=$(get_access_token)
export ACCESS_TOKEN

encoded_pid=$(printf '%s' "$PRODUCT_ID" | jq -sRr @uri)
printf 'Creating subscription with base plan: %s (%s JPY %s)\n' "$PRODUCT_ID" "$BASE_PLAN_ID" "$PRICE_JP"
response=$(play_api POST "/applications/${PACKAGE_NAME}/subscriptions?productId=${encoded_pid}&regionsVersion.version=${REGIONS_VERSION}" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

if printf '%s' "$response" | jq -e '.productId' >/dev/null 2>&1; then
  printf '  → created: %s with base plan %s\n' "$PRODUCT_ID" "$BASE_PLAN_ID"
else
  printf 'Failed. Response: %s\n' "$response" >&2
  exit 1
fi
