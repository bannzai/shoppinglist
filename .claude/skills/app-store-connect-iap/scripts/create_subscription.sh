#!/usr/bin/env bash
# Auto-Renewable Subscription を作成する
# Usage:
#   create_subscription.sh --group-id GROUP_ID --product-id shoppinglist_480yen_1month --reference-name "Premium Monthly"

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq
require_python_jwt

GROUP_ID=""
PRODUCT_ID=""
REFERENCE_NAME=""
FAMILY_SHARABLE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --group-id) GROUP_ID="$2"; shift 2 ;;
    --product-id) PRODUCT_ID="$2"; shift 2 ;;
    --reference-name) REFERENCE_NAME="$2"; shift 2 ;;
    --family-sharable) FAMILY_SHARABLE="true"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${GROUP_ID:?--group-id is required}"
: "${PRODUCT_ID:?--product-id is required}"
: "${REFERENCE_NAME:?--reference-name is required}"

validate_product_id "$PRODUCT_ID"
product_type=$(extract_product_type "$PRODUCT_ID")
period=$(asc_subscription_period "$product_type")

body=$(jq -n \
  --arg ref "$REFERENCE_NAME" \
  --arg pid "$PRODUCT_ID" \
  --arg period "$period" \
  --arg gid "$GROUP_ID" \
  --argjson fs "$FAMILY_SHARABLE" \
  '{
    data: {
      type: "subscriptions",
      attributes: {
        name: $ref,
        productId: $pid,
        subscriptionPeriod: $period,
        familySharable: $fs
      },
      relationships: { group: { data: { type: "subscriptionGroups", id: $gid } } }
    }
  }')

JWT_TOKEN=$(generate_jwt)
export JWT_TOKEN

printf 'Creating subscription: %s (period=%s)\n' "$PRODUCT_ID" "$period"
response=$(asc_api POST "/v1/subscriptions" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

sub_id=$(printf '%s' "$response" | jq -r '.data.id // empty')
if [[ -z "$sub_id" ]]; then
  printf 'Failed. Response: %s\n' "$response" >&2
  exit 1
fi
printf '  → created: id=%s\n' "$sub_id"
