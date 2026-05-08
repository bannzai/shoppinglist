#!/usr/bin/env bash
# Subscription Group を作成する
# Usage: create_subscription_group.sh --app-id 1234567890 --reference-name Premium

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

APP_ID=""
REFERENCE_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-id) APP_ID="$2"; shift 2 ;;
    --reference-name) REFERENCE_NAME="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${APP_ID:?--app-id is required}"
: "${REFERENCE_NAME:?--reference-name is required}"

JWT_TOKEN=$(generate_jwt)
export JWT_TOKEN

body=$(jq -n --arg ref "$REFERENCE_NAME" --arg aid "$APP_ID" '{
  data: {
    type: "subscriptionGroups",
    attributes: { referenceName: $ref },
    relationships: { app: { data: { type: "apps", id: $aid } } }
  }
}')

printf 'Creating subscription group: %s\n' "$REFERENCE_NAME"
response=$(asc_api POST "/v1/subscriptionGroups" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

group_id=$(printf '%s' "$response" | jq -r '.data.id // empty')
if [[ -z "$group_id" ]]; then
  printf 'Failed. Response: %s\n' "$response" >&2
  exit 1
fi
printf '  → created: id=%s\n' "$group_id"
