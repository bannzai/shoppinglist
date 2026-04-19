#!/usr/bin/env bash
# Subscription の価格を territory ごとに設定する
# Usage:
#   set_prices.sh --subscription-id SUB_ID --price-jp 480 --territories US,JP,GB
#   set_prices.sh --subscription-id SUB_ID --price-jp 480 --all-territories

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq
require_python_jwt

SUB_ID=""
PRICE_JP=""
TERRITORIES=""
ALL_TERRITORIES=0
START_DATE="$(date -u +%Y-%m-%d)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --subscription-id) SUB_ID="$2"; shift 2 ;;
    --price-jp) PRICE_JP="$2"; shift 2 ;;
    --territories) TERRITORIES="$2"; shift 2 ;;
    --all-territories) ALL_TERRITORIES=1; shift ;;
    --start-date) START_DATE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${SUB_ID:?--subscription-id is required}"
: "${PRICE_JP:?--price-jp is required (JPY integer)}"

if [[ -z "$TERRITORIES" && $ALL_TERRITORIES -ne 1 ]]; then
  printf 'Either --territories or --all-territories is required\n' >&2
  exit 1
fi

JWT_TOKEN=$(generate_jwt)
export JWT_TOKEN

# Step 1: JPY の価格に対応する subscriptionPricePoint を取得
printf 'Looking up price point for JPY %s\n' "$PRICE_JP"
pp_response=$(asc_api GET "/v1/subscriptions/${SUB_ID}/pricePoints?filter%5Bterritory%5D=JPN&include=territory&limit=200")

# 完全一致する customerPrice (例: "480") を探す
jp_price_point_id=$(printf '%s' "$pp_response" | jq -r --arg p "$PRICE_JP" '.data[] | select(.attributes.customerPrice == $p or .attributes.customerPrice == ($p + ".00")) | .id' | head -1)

if [[ -z "$jp_price_point_id" ]]; then
  printf 'No price point found for JPY %s. Available prices:\n' "$PRICE_JP" >&2
  printf '%s' "$pp_response" | jq -r '.data[].attributes.customerPrice' | head -20 >&2
  exit 1
fi
printf '  → JP price point: %s\n' "$jp_price_point_id"

# Step 2: territories のリストを構築
if [[ $ALL_TERRITORIES -eq 1 ]]; then
  printf 'Fetching all territories...\n'
  territory_response=$(asc_api GET "/v1/territories?limit=200")
  territory_list=$(printf '%s' "$territory_response" | jq -r '.data[].id' | tr '\n' ',' | sed 's/,$//')
else
  territory_list="$TERRITORIES"
fi

IFS=',' read -ra TS <<< "$territory_list"

# Step 3: 各 territory で equivalent price point を取得して設定
for territory in "${TS[@]}"; do
  printf 'Setting price for territory: %s\n' "$territory"

  if [[ "$territory" == "JPN" ]]; then
    target_pp_id="$jp_price_point_id"
  else
    eq_response=$(asc_api GET "/v1/subscriptionPricePoints/${jp_price_point_id}/equalizations?filter%5Bterritory%5D=${territory}")
    target_pp_id=$(printf '%s' "$eq_response" | jq -r '.data[0].id // empty')
    if [[ -z "$target_pp_id" ]]; then
      printf '  → no equivalent for %s, skipping\n' "$territory" >&2
      continue
    fi
  fi

  body=$(jq -n \
    --arg sd "$START_DATE" \
    --arg sid "$SUB_ID" \
    --arg pp "$target_pp_id" \
    '{
      data: {
        type: "subscriptionPrices",
        attributes: { startDate: $sd, preserveCurrentPrice: false },
        relationships: {
          subscription: { data: { type: "subscriptions", id: $sid } },
          subscriptionPricePoint: { data: { type: "subscriptionPricePoints", id: $pp } }
        }
      }
    }')

  asc_api POST "/v1/subscriptionPrices" "$body" >/dev/null

  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    printf '  → set\n'
    sleep 0.2  # スロットリング
  fi
done
