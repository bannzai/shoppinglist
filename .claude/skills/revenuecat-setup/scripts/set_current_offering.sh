#!/usr/bin/env bash
# Current Offering を設定する（lookup_key 指定）
# Usage: set_current_offering.sh --lookup-key default

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

LOOKUP_KEY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lookup-key) LOOKUP_KEY="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${LOOKUP_KEY:?--lookup-key is required (e.g., default)}"

# Offering ID を lookup_key から解決
offerings_response=$(rc_api_v2 GET "/projects/{project_id}/offerings")
offering_id=$(printf '%s' "$offerings_response" | jq -r --arg lk "$LOOKUP_KEY" '.items[] | select(.lookup_key == $lk) | .id' | head -1)

if [[ -z "$offering_id" ]]; then
  printf 'Offering with lookup_key="%s" not found.\n' "$LOOKUP_KEY" >&2
  exit 1
fi

printf 'Setting current offering: lookup_key=%s id=%s\n' "$LOOKUP_KEY" "$offering_id"
response=$(rc_api_v2 POST "/projects/{project_id}/offerings/${offering_id}/actions/set_current" "")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

if printf '%s' "$response" | jq -e '.id' >/dev/null 2>&1; then
  printf '  → set as current\n'
else
  printf 'Response: %s\n' "$response"
fi
