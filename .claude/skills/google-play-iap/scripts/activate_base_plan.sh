#!/usr/bin/env bash
# Base Plan を ACTIVE に切り替える
# Usage: activate_base_plan.sh --package-name com.foo.bar --product-id shoppinglist_480yen_1month --base-plan-id monthly

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq
require_python_jwt

PACKAGE_NAME=""
PRODUCT_ID=""
BASE_PLAN_ID=""
LATENCY_TOLERANCE="PRODUCT_UPDATE_LATENCY_TOLERANCE_LATENCY_SENSITIVE"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package-name) PACKAGE_NAME="$2"; shift 2 ;;
    --product-id) PRODUCT_ID="$2"; shift 2 ;;
    --base-plan-id) BASE_PLAN_ID="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${PACKAGE_NAME:?--package-name is required}"
: "${PRODUCT_ID:?--product-id is required}"
: "${BASE_PLAN_ID:?--base-plan-id is required}"

validate_product_id "$PRODUCT_ID"

body=$(jq -n --arg lt "$LATENCY_TOLERANCE" '{latencyTolerance: $lt}')

ACCESS_TOKEN=$(get_access_token)
export ACCESS_TOKEN

encoded_pid=$(printf '%s' "$PRODUCT_ID" | jq -sRr @uri)
encoded_bpid=$(printf '%s' "$BASE_PLAN_ID" | jq -sRr @uri)

printf 'Activating base plan: %s/%s\n' "$PRODUCT_ID" "$BASE_PLAN_ID"
response=$(play_api POST "/applications/${PACKAGE_NAME}/subscriptions/${encoded_pid}/basePlans/${encoded_bpid}:activate" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

if printf '%s' "$response" | jq -e '.basePlans[]? | select(.basePlanId == "'"$BASE_PLAN_ID"'") | .state == "ACTIVE"' >/dev/null 2>&1; then
  printf '  → activated\n'
else
  printf 'Response: %s\n' "$response"
fi
