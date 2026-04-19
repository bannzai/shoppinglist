#!/usr/bin/env bash
# Subscription を作成する
# Usage:
#   create_subscription.sh \
#     --package-name com.foo.bar \
#     --product-id shoppinglist_480yen_1month \
#     --display-name-ja "プレミアム（月額）" \
#     --display-name-en "Premium Monthly" \
#     [--description-ja "..."] [--description-en "..."]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq
require_python_jwt

PACKAGE_NAME=""
PRODUCT_ID=""
DISPLAY_NAME_JA=""
DISPLAY_NAME_EN=""
DESCRIPTION_JA=""
DESCRIPTION_EN=""
REGIONS_VERSION="2022/02"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package-name) PACKAGE_NAME="$2"; shift 2 ;;
    --product-id) PRODUCT_ID="$2"; shift 2 ;;
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
: "${DISPLAY_NAME_JA:?--display-name-ja is required}"
: "${DISPLAY_NAME_EN:?--display-name-en is required}"

validate_product_id "$PRODUCT_ID"

# listings 配列を作る
listings=$(jq -n \
  --arg ja "$DISPLAY_NAME_JA" \
  --arg en "$DISPLAY_NAME_EN" \
  --arg dja "$DESCRIPTION_JA" \
  --arg den "$DESCRIPTION_EN" \
  '[
    {languageCode: "ja", title: $ja, description: $dja},
    {languageCode: "en-US", title: $en, description: $den}
  ]')

body=$(jq -n --argjson listings "$listings" '{listings: $listings}')

ACCESS_TOKEN=$(get_access_token)
export ACCESS_TOKEN

encoded_pid=$(printf '%s' "$PRODUCT_ID" | jq -sRr @uri)
printf 'Creating subscription: %s\n' "$PRODUCT_ID"
response=$(play_api POST "/applications/${PACKAGE_NAME}/subscriptions?productId=${encoded_pid}&regionsVersion.version=${REGIONS_VERSION}" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

if printf '%s' "$response" | jq -e '.productId' >/dev/null 2>&1; then
  printf '  → created: %s\n' "$PRODUCT_ID"
else
  printf 'Failed. Response: %s\n' "$response" >&2
  exit 1
fi
