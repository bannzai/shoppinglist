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

# 409 (resource_already_exists) なら既存 ID を GET で取得して再利用
if [[ -z "$entitlement_id" ]] && printf '%s' "$response" | jq -e '.type == "resource_already_exists" or .code == 7263' >/dev/null 2>&1; then
  printf '  → already exists, looking up existing id...\n'
  list_response=$(rc_api_v2 GET "/projects/{project_id}/entitlements?limit=50")
  entitlement_id=$(printf '%s' "$list_response" | jq -r --arg lk "$LOOKUP_KEY" \
    '.items[] | select(.lookup_key == $lk) | .id' | head -1)
fi

if [[ -z "$entitlement_id" ]]; then
  printf 'Failed to create entitlement. Response: %s\n' "$response" >&2
  exit 1
fi
printf '  → ready: id=%s lookup_key=%s\n' "$entitlement_id" "$LOOKUP_KEY"

if [[ -n "$ATTACH_PRODUCTS" ]]; then
  IFS=',' read -ra SIDS <<< "$ATTACH_PRODUCTS"

  # RC v2 の attach_products API は内部 Product ID (prodXXX) を要求する。
  # store_identifier から iOS/Android 両方の ID を引いて attach する。
  rc_ids=()
  for sid in "${SIDS[@]}"; do
    # shellcheck disable=SC2207
    ids_for_sid=($(resolve_rc_product_ids_by_sid "$sid"))
    if [[ ${#ids_for_sid[@]} -eq 0 ]]; then
      printf 'Warning: No RC product found for store_identifier="%s" (skipping)\n' "$sid" >&2
      continue
    fi
    rc_ids+=("${ids_for_sid[@]}")
  done

  if [[ ${#rc_ids[@]} -eq 0 ]]; then
    printf 'Error: No RC products resolved for attach. Create products first.\n' >&2
    exit 1
  fi

  product_id_list=$(printf '%s\n' "${rc_ids[@]}" | jq -R . | jq -s .)
  attach_body=$(jq -n --argjson pids "$product_id_list" '{product_ids: $pids}')

  printf '\nAttaching %d RC product IDs to entitlement %s\n' "${#rc_ids[@]}" "$LOOKUP_KEY"
  printf '  target ids: %s\n' "$(printf '%s ' "${rc_ids[@]}")"
  attach_response=$(rc_api_v2 POST "/projects/{project_id}/entitlements/${entitlement_id}/actions/attach_products" "$attach_body")

  if printf '%s' "$attach_response" | jq -e '.id' >/dev/null 2>&1; then
    printf '  → attached\n'
  elif [[ -z "$attach_response" ]]; then
    printf '  → attached (empty body)\n'
  else
    printf 'Attach response: %s\n' "$attach_response"
  fi
fi
