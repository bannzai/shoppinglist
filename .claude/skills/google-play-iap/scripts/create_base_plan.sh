#!/usr/bin/env bash
# Base Plan を作成する（DRAFT 状態）
# Usage:
#   create_base_plan.sh \
#     --package-name com.foo.bar \
#     --product-id shoppinglist_480yen_1month \
#     --base-plan-id monthly --price-jp 480

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

PACKAGE_NAME=""
PRODUCT_ID=""
BASE_PLAN_ID=""
PRICE_JP=""
REGIONS_VERSION="2022/02"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package-name) PACKAGE_NAME="$2"; shift 2 ;;
    --product-id) PRODUCT_ID="$2"; shift 2 ;;
    --base-plan-id) BASE_PLAN_ID="$2"; shift 2 ;;
    --price-jp) PRICE_JP="$2"; shift 2 ;;
    --regions-version) REGIONS_VERSION="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${PACKAGE_NAME:?--package-name is required}"
: "${PRODUCT_ID:?--product-id is required}"
: "${BASE_PLAN_ID:?--base-plan-id is required (e.g., monthly, six-month, yearly)}"
: "${PRICE_JP:?--price-jp is required (JPY integer, no decimals)}"

validate_product_id "$PRODUCT_ID"
product_type=$(extract_product_type "$PRODUCT_ID")
period=$(play_billing_period "$product_type")

# Subscription patch で basePlans に追加
# 既存 Subscription を取得してから basePlans を追加する
ACCESS_TOKEN=$(get_access_token)
export ACCESS_TOKEN

encoded_pid=$(printf '%s' "$PRODUCT_ID" | jq -sRr @uri)
printf 'Fetching subscription: %s\n' "$PRODUCT_ID"
existing=$(play_api GET "/applications/${PACKAGE_NAME}/subscriptions/${encoded_pid}")

# 既存 Subscription に新 Base Plan を追加
new_base_plan=$(jq -n \
  --arg bpid "$BASE_PLAN_ID" \
  --arg period "$period" \
  --arg price "${PRICE_JP}000000" \
  '{
    basePlanId: $bpid,
    state: "DRAFT",
    autoRenewingBasePlanType: {
      billingPeriodDuration: $period,
      gracePeriodDuration: "P3D",
      resubscribeState: "RESUBSCRIBE_STATE_ACTIVE",
      prorationMode: "SUBSCRIPTION_PRORATION_MODE_CHARGE_ON_NEXT_BILLING_DATE",
      legacyCompatible: false
    },
    regionalConfigs: [
      {regionCode: "JP", newSubscriberAvailability: true, price: {currencyCode: "JPY", units: ($price | tonumber / 1000000 | tostring), nanos: 0}}
    ]
  }')

# 既存 basePlans に追加して PATCH
patched=$(printf '%s' "$existing" | jq --argjson bp "$new_base_plan" '.basePlans += [$bp]')

printf 'Adding base plan: %s (period=%s, JPY %s)\n' "$BASE_PLAN_ID" "$period" "$PRICE_JP"
response=$(play_api PATCH "/applications/${PACKAGE_NAME}/subscriptions/${encoded_pid}?updateMask=basePlans&regionsVersion.version=${REGIONS_VERSION}" "$patched")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

if printf '%s' "$response" | jq -e '.productId' >/dev/null 2>&1; then
  printf '  → base plan added (DRAFT)\n'
  printf '  Note: Run activate_base_plan.sh to activate.\n'
else
  printf 'Failed. Response: %s\n' "$response" >&2
  exit 1
fi
