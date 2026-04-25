#!/usr/bin/env bash
# IAP V2 のローカライズを作成する
# Usage:
#   set_iap_v2_localization.sh --iap-id IAP_ID --locale ja --name "ライフタイム" --description "..."

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

IAP_ID=""
LOCALE=""
NAME=""
DESCRIPTION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --iap-id) IAP_ID="$2"; shift 2 ;;
    --locale) LOCALE="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${IAP_ID:?--iap-id is required}"
: "${LOCALE:?--locale is required (e.g., ja, en-US)}"
: "${NAME:?--name is required}"
: "${DESCRIPTION:?--description is required}"

body=$(jq -n \
  --arg locale "$LOCALE" \
  --arg name "$NAME" \
  --arg desc "$DESCRIPTION" \
  --arg iid "$IAP_ID" \
  '{
    data: {
      type: "inAppPurchaseLocalizations",
      attributes: { locale: $locale, name: $name, description: $desc },
      relationships: { inAppPurchaseV2: { data: { type: "inAppPurchases", id: $iid } } }
    }
  }')

JWT_TOKEN=$(generate_jwt)
export JWT_TOKEN

printf 'Setting IAP V2 localization: iap=%s locale=%s\n' "$IAP_ID" "$LOCALE"
response=$(asc_api POST "/v1/inAppPurchaseLocalizations" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

loc_id=$(printf '%s' "$response" | jq -r '.data.id // empty')
if [[ -z "$loc_id" ]]; then
  printf 'Failed. Response: %s\n' "$response" >&2
  exit 1
fi
printf '  → created: id=%s\n' "$loc_id"
