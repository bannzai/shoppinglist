#!/usr/bin/env bash
# Subscription Localization を作成する
# Usage:
#   set_localization.sh --subscription-id SUB_ID --locale ja --name "プレミアム" --description "..."

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq
require_python_jwt

SUB_ID=""
LOCALE=""
NAME=""
DESCRIPTION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --subscription-id) SUB_ID="$2"; shift 2 ;;
    --locale) LOCALE="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${SUB_ID:?--subscription-id is required}"
: "${LOCALE:?--locale is required (e.g., ja, en-US)}"
: "${NAME:?--name is required}"
: "${DESCRIPTION:?--description is required}"

body=$(jq -n \
  --arg locale "$LOCALE" \
  --arg name "$NAME" \
  --arg desc "$DESCRIPTION" \
  --arg sid "$SUB_ID" \
  '{
    data: {
      type: "subscriptionLocalizations",
      attributes: { locale: $locale, name: $name, description: $desc },
      relationships: { subscription: { data: { type: "subscriptions", id: $sid } } }
    }
  }')

JWT_TOKEN=$(generate_jwt)
export JWT_TOKEN

printf 'Setting localization: subscription=%s locale=%s\n' "$SUB_ID" "$LOCALE"
response=$(asc_api POST "/v1/subscriptionLocalizations" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

loc_id=$(printf '%s' "$response" | jq -r '.data.id // empty')
if [[ -z "$loc_id" ]]; then
  printf 'Failed. Response: %s\n' "$response" >&2
  exit 1
fi
printf '  → created: id=%s\n' "$loc_id"
