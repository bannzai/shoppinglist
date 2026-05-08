#!/usr/bin/env bash
# IAP V2 (NON_CONSUMABLE / CONSUMABLE) を作成する
# Usage:
#   create_iap_v2.sh --app-id 1234567890 --product-id shoppinglist_10000yen_lifetime --reference-name "Lifetime"
#   create_iap_v2.sh --app-id 1234567890 --product-id shoppinglist_100yen_consumable --reference-name "Tip"

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

APP_ID=""
PRODUCT_ID=""
REFERENCE_NAME=""
FAMILY_SHARABLE="false"
REVIEW_NOTE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-id) APP_ID="$2"; shift 2 ;;
    --product-id) PRODUCT_ID="$2"; shift 2 ;;
    --reference-name) REFERENCE_NAME="$2"; shift 2 ;;
    --family-sharable) FAMILY_SHARABLE="true"; shift ;;
    --review-note) REVIEW_NOTE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${APP_ID:?--app-id is required}"
: "${PRODUCT_ID:?--product-id is required}"
: "${REFERENCE_NAME:?--reference-name is required}"

validate_product_id "$PRODUCT_ID"
product_type=$(extract_product_type "$PRODUCT_ID")
iap_type=$(asc_iap_v2_type "$product_type")

body=$(jq -n \
  --arg ref "$REFERENCE_NAME" \
  --arg pid "$PRODUCT_ID" \
  --arg iap_type "$iap_type" \
  --arg note "$REVIEW_NOTE" \
  --arg aid "$APP_ID" \
  --argjson fs "$FAMILY_SHARABLE" \
  '{
    data: {
      type: "inAppPurchases",
      attributes: ({
        name: $ref,
        productId: $pid,
        inAppPurchaseType: $iap_type,
        familySharable: $fs
      } + (if $note == "" then {} else {reviewNote: $note} end)),
      relationships: { app: { data: { type: "apps", id: $aid } } }
    }
  }')

JWT_TOKEN=$(generate_jwt)
export JWT_TOKEN

printf 'Creating IAP V2: %s (type=%s)\n' "$PRODUCT_ID" "$iap_type"
response=$(asc_api POST "/v2/inAppPurchases" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

iap_id=$(printf '%s' "$response" | jq -r '.data.id // empty')
if [[ -z "$iap_id" ]]; then
  printf 'Failed. Response: %s\n' "$response" >&2
  exit 1
fi
printf '  → created: id=%s\n' "$iap_id"
