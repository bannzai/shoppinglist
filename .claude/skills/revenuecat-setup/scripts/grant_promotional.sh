#!/usr/bin/env bash
# Promotional Entitlement を customer に付与する（v2 grant_entitlement）
# Usage:
#   grant_promotional.sh --customer-id <firebase_uid> --entitlement-key Premium --duration monthly
#   grant_promotional.sh --customer-id <firebase_uid> --entitlement-key Premium --end-time-ms 1735689600000

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

CUSTOMER_ID=""
ENTITLEMENT_KEY=""
DURATION=""
END_TIME_MS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --customer-id) CUSTOMER_ID="$2"; shift 2 ;;
    --entitlement-key) ENTITLEMENT_KEY="$2"; shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    --end-time-ms) END_TIME_MS="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${CUSTOMER_ID:?--customer-id is required (Firebase UID)}"
: "${ENTITLEMENT_KEY:?--entitlement-key is required (e.g., Premium)}"

if [[ -z "$DURATION" && -z "$END_TIME_MS" ]]; then
  printf 'Either --duration or --end-time-ms is required\n' >&2
  exit 1
fi

if [[ -n "$DURATION" && -n "$END_TIME_MS" ]]; then
  printf '--duration and --end-time-ms cannot both be specified\n' >&2
  exit 1
fi

# duration 値の検証
if [[ -n "$DURATION" ]]; then
  case "$DURATION" in
    daily|three_day|weekly|two_week|monthly|two_month|three_month|six_month|yearly|lifetime) ;;
    *)
      printf 'Invalid duration: %s\n' "$DURATION" >&2
      printf 'Valid: daily|three_day|weekly|two_week|monthly|two_month|three_month|six_month|yearly|lifetime\n' >&2
      exit 1
      ;;
  esac
fi

# Entitlement ID を lookup_key から解決
printf 'Looking up entitlement: %s\n' "$ENTITLEMENT_KEY"
entitlements_response=$(rc_api_v2 GET "/projects/{project_id}/entitlements")
entitlement_id=$(printf '%s' "$entitlements_response" | jq -r --arg lk "$ENTITLEMENT_KEY" '.items[] | select(.lookup_key == $lk) | .id' | head -1)

if [[ -z "$entitlement_id" ]]; then
  printf 'Entitlement with lookup_key="%s" not found.\n' "$ENTITLEMENT_KEY" >&2
  printf 'Hint: Make sure to create it first with create_entitlement.sh --lookup-key %s\n' "$ENTITLEMENT_KEY" >&2
  exit 1
fi

# リクエストボディ
if [[ -n "$DURATION" ]]; then
  body=$(jq -n --arg eid "$entitlement_id" --arg d "$DURATION" \
    '{entitlement_id: $eid, duration: $d}')
else
  body=$(jq -n --arg eid "$entitlement_id" --arg et "$END_TIME_MS" \
    '{entitlement_id: $eid, end_time_ms: ($et | tonumber)}')
fi

printf 'Granting entitlement %s to customer %s\n' "$ENTITLEMENT_KEY" "$CUSTOMER_ID"
response=$(rc_api_v2 POST "/projects/{project_id}/customers/${CUSTOMER_ID}/actions/grant_entitlement" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

if printf '%s' "$response" | jq -e '.entitlement_id // .id' >/dev/null 2>&1; then
  printf '  → granted\n'
else
  printf 'Response: %s\n' "$response"
  # 404 の場合はヒントを出す
  if printf '%s' "$response" | jq -e '.code == 404 or .status == 404' >/dev/null 2>&1; then
    printf '\nHint: 404 means customer (%s) is not registered in RevenueCat yet.\n' "$CUSTOMER_ID" >&2
    printf '      The customer is auto-created when the app calls Purchases.logIn(uid) for the first time.\n' >&2
  fi
  exit 1
fi
