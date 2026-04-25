#!/usr/bin/env bash
# RevenueCat に Product を作成する（複数同時）
# 命名規則 {project}_{price}yen_{type} を強制バリデート
# Usage:
#   create_products.sh --app-id app_xxx --app-type app_store --product-ids id1,id2,id3
#   create_products.sh --app-id app_xxx --app-type play_store --product-ids id1 --display-name "Premium"

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

APP_ID=""
APP_TYPE=""
PRODUCT_IDS=""
DISPLAY_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-id) APP_ID="$2"; shift 2 ;;
    --app-type) APP_TYPE="$2"; shift 2 ;;
    --product-ids) PRODUCT_IDS="$2"; shift 2 ;;
    --display-name) DISPLAY_NAME="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${APP_ID:?--app-id is required}"
: "${APP_TYPE:?--app-type is required (app_store|play_store|mac_app_store|amazon|test_store)}"
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

  # Play Store subscription のみ {sid}:{basePlanId} 形式
  # https://www.revenuecat.com/docs/getting-started/entitlements/android-products
  store_identifier="$product_id"
  if [[ "$APP_TYPE" == "play_store" && "$rc_type" == "subscription" ]]; then
    store_identifier="${product_id}:${product_type}"
  fi

  # Test Store は実ストア連携がないため title と subscription.duration (subscription 型のみ) が必須。
  # Duration enum: P1W / P1M / P2M / P3M / P6M / P1Y
  # https://www.revenuecat.com/docs/redocusaurus/plugin-redoc-0.yaml
  duration=""
  if [[ "$APP_TYPE" == "test_store" && "$rc_type" == "subscription" ]]; then
    case "$product_type" in
      1month) duration="P1M" ;;
      6month) duration="P6M" ;;
      1year)  duration="P1Y" ;;
      *) printf 'Unknown subscription duration for product_type: %s\n' "$product_type" >&2; exit 1 ;;
    esac
  fi

  body=$(jq -n \
    --arg sid "$store_identifier" \
    --arg type "$rc_type" \
    --arg aid "$APP_ID" \
    --arg dn "$display_name" \
    --arg apt "$APP_TYPE" \
    --arg dur "$duration" \
    '{store_identifier: $sid, type: $type, app_id: $aid, display_name: $dn}
     + (if $apt == "test_store" then {title: $dn} else {} end)
     + (if $apt == "test_store" and $dur != "" then {subscription: {duration: $dur}} else {} end)')

  printf 'Creating product: %s (store_identifier=%s type=%s)\n' "$product_id" "$store_identifier" "$rc_type"
  response=$(rc_api_v2 POST "/projects/{project_id}/products" "$body")

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    continue
  fi

  rc_product_id=$(printf '%s' "$response" | jq -r '.id // empty')
  if [[ -z "$rc_product_id" ]]; then
    if printf '%s' "$response" | jq -e '.type == "resource_already_exists" or .code == 7263' >/dev/null 2>&1; then
      printf '  → already exists, skipping\n'
      continue
    fi
    printf 'Failed to create product %s. Response: %s\n' "$product_id" "$response" >&2
    exit 1
  fi
  printf '  → created: id=%s\n' "$rc_product_id"
done
