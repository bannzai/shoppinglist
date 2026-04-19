#!/usr/bin/env bash
# Offering を作成する
# Usage: create_offering.sh --lookup-key default --display-name "Default Offering"

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

LOOKUP_KEY=""
DISPLAY_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lookup-key) LOOKUP_KEY="$2"; shift 2 ;;
    --display-name) DISPLAY_NAME="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${LOOKUP_KEY:?--lookup-key is required (e.g., default, discounted)}"
: "${DISPLAY_NAME:?--display-name is required}"

body=$(jq -n --arg lk "$LOOKUP_KEY" --arg dn "$DISPLAY_NAME" \
  '{lookup_key: $lk, display_name: $dn}')

printf 'Creating offering: %s\n' "$LOOKUP_KEY"
response=$(rc_api_v2 POST "/projects/{project_id}/offerings" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

offering_id=$(printf '%s' "$response" | jq -r '.id // empty')
if [[ -z "$offering_id" ]]; then
  printf 'Failed to create offering. Response: %s\n' "$response" >&2
  exit 1
fi
printf '  → created: id=%s lookup_key=%s\n' "$offering_id" "$LOOKUP_KEY"
