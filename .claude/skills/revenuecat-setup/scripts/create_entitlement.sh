#!/usr/bin/env bash
# Entitlement を作成し、必要なら Product を attach する
# Usage:
#   create_entitlement.sh --lookup-key Premium --display-name "プレミアム"
#   create_entitlement.sh --lookup-key Premium --display-name "プレミアム" --attach-products id1,id2,id3

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

LOOKUP_KEY=""
DISPLAY_NAME=""
ATTACH_PRODUCTS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lookup-key) LOOKUP_KEY="$2"; shift 2 ;;
    --display-name) DISPLAY_NAME="$2"; shift 2 ;;
    --attach-products) ATTACH_PRODUCTS="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${LOOKUP_KEY:?--lookup-key is required (e.g., Premium)}"
: "${DISPLAY_NAME:?--display-name is required}"

body=$(jq -n --arg lk "$LOOKUP_KEY" --arg dn "$DISPLAY_NAME" \
  '{lookup_key: $lk, display_name: $dn}')

printf 'Creating entitlement: %s\n' "$LOOKUP_KEY"
response=$(rc_api_v2 POST "/projects/{project_id}/entitlements" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  if [[ -n "$ATTACH_PRODUCTS" ]]; then
    printf '\n[DRY RUN] Would attach products: %s\n' "$ATTACH_PRODUCTS" >&2
  fi
  exit 0
fi

entitlement_id=$(printf '%s' "$response" | jq -r '.id // empty')
if [[ -z "$entitlement_id" ]]; then
  printf 'Failed to create entitlement. Response: %s\n' "$response" >&2
  exit 1
fi
printf '  → created: id=%s lookup_key=%s\n' "$entitlement_id" "$LOOKUP_KEY"

if [[ -n "$ATTACH_PRODUCTS" ]]; then
  IFS=',' read -ra PIDS <<< "$ATTACH_PRODUCTS"
  product_id_list=$(printf '%s\n' "${PIDS[@]}" | jq -R . | jq -s .)

  attach_body=$(jq -n --argjson pids "$product_id_list" '{product_ids: $pids}')

  printf '\nAttaching %d products to entitlement %s\n' "${#PIDS[@]}" "$LOOKUP_KEY"
  attach_response=$(rc_api_v2 POST "/projects/{project_id}/entitlements/${entitlement_id}/actions/attach_products" "$attach_body")

  if printf '%s' "$attach_response" | jq -e '.id' >/dev/null 2>&1; then
    printf '  → attached\n'
  else
    printf 'Attach response: %s\n' "$attach_response"
  fi
fi
