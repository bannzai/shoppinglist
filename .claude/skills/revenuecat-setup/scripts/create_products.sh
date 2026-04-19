#!/usr/bin/env bash
# RevenueCat に Product を作成する（複数同時）
# 命名規則 {project}_{price}yen_{type} を強制バリデート
# Usage:
#   create_products.sh --app-id app_xxx --product-ids id1,id2,id3
#   create_products.sh --app-id app_xxx --product-ids id1 --display-name "Premium"

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

APP_ID=""
PRODUCT_IDS=""
DISPLAY_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-id) APP_ID="$2"; shift 2 ;;
    --product-ids) PRODUCT_IDS="$2"; shift 2 ;;
    --display-name) DISPLAY_NAME="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${APP_ID:?--app-id is required}"
: "${PRODUCT_IDS:?--product-ids is required (comma-separated)}"

IFS=',' read -ra IDS <<< "$PRODUCT_IDS"

for product_id in "${IDS[@]}"; do
  validate_product_id "$product_id"
  product_type=$(extract_product_type "$product_id")

  # type を RC の Product type に変換
  case "$product_type" in
    1month|6month|1year)
      rc_type="subscription"
      ;;
    consumable)
      rc_type="consumable"
      ;;
    lifetime)
      rc_type="non_consumable"
      ;;
    *)
      printf 'Unknown product type: %s\n' "$product_type" >&2
      exit 1
      ;;
  esac

  display_name="${DISPLAY_NAME:-$product_id}"

  body=$(jq -n \
    --arg sid "$product_id" \
    --arg type "$rc_type" \
    --arg aid "$APP_ID" \
    --arg dn "$display_name" \
    '{store_identifier: $sid, type: $type, app_id: $aid, display_name: $dn}')

  printf 'Creating product: %s (type=%s)\n' "$product_id" "$rc_type"
  response=$(rc_api_v2 POST "/projects/{project_id}/products" "$body")

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    continue
  fi

  rc_product_id=$(printf '%s' "$response" | jq -r '.id // empty')
  if [[ -z "$rc_product_id" ]]; then
    printf 'Failed to create product %s. Response: %s\n' "$product_id" "$response" >&2
    # 既に存在する場合はスキップ（idempotent）
    if printf '%s' "$response" | jq -e '.code == 7263' >/dev/null 2>&1; then
      printf '  → already exists, skipping\n'
      continue
    fi
    exit 1
  fi
  printf '  → created: id=%s\n' "$rc_product_id"
done
