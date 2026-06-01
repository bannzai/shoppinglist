#!/usr/bin/env bash
# Bundle ID から App Store Connect の App ID を解決する
# Usage: get_app_id.sh --bundle-id com.bannzai.shoppinglist

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

BUNDLE_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bundle-id) BUNDLE_ID="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${BUNDLE_ID:?--bundle-id is required}"

JWT_TOKEN=$(generate_jwt)
export JWT_TOKEN

response=$(asc_api GET "/v1/apps?filter%5BbundleId%5D=${BUNDLE_ID}")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

app_id=$(printf '%s' "$response" | jq -r '.data[0].id // empty')
if [[ -z "$app_id" ]]; then
  printf 'No app found for bundle ID: %s\n' "$BUNDLE_ID" >&2
  printf 'Response: %s\n' "$response" >&2
  exit 1
fi

printf '%s\n' "$app_id"
