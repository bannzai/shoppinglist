#!/usr/bin/env bash
# Subscription の価格を territory ごとに設定する
# Usage:
#   set_prices.sh --subscription-id SUB_ID --price-jp 480 --territories US,JP,GB
#   set_prices.sh --subscription-id SUB_ID --price-jp 480 --all-territories
#   set_prices.sh --subscription-id SUB_ID --price-jp 480 --territories JPN --start-date 2026-01-01

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

SUB_ID=""
PRICE_JP=""
TERRITORIES=""
ALL_TERRITORIES=0
# 初回価格は startDate なし (即時適用) でしか設定できず、ASC は当日以前の startDate を
# "a future date is expected, and must be on or after <明日>" で拒否する。
# そのためデフォルトは空 (= startDate を送らない)。予約価格変更のみ --start-date で翌日以降を指定する。
START_DATE=""

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

# Step 1: JPY の価格に対応する subscriptionPricePoint を取得 (links.next でページネーション)
printf 'Looking up price point for JPY %s\n' "$PRICE_JP"
jp_price_point_id=""
first_page_sample=""
next_path="/v1/subscriptions/${SUB_ID}/pricePoints?filter%5Bterritory%5D=JPN&include=territory&limit=200"

while [[ -n "$next_path" ]]; do
  pp_response=$(asc_api GET "$next_path")

  matched=$(printf '%s' "$pp_response" | jq -r --arg p "$PRICE_JP" '.data[] | select(.attributes.customerPrice == $p or .attributes.customerPrice == ($p + ".00")) | .id' 2>/dev/null | head -1)
  if [[ -n "$matched" ]]; then
    jp_price_point_id="$matched"
    break
  fi

  if [[ -z "$first_page_sample" ]]; then
    first_page_sample=$(printf '%s' "$pp_response" | jq -r '.data[].attributes.customerPrice' 2>/dev/null | head -20)
  fi

  next_url=$(printf '%s' "$pp_response" | jq -r '.links.next // empty' 2>/dev/null)
  if [[ -z "$next_url" ]]; then
    break
  fi
  next_path="${next_url#${ASC_API_BASE}}"
done

if [[ -z "$jp_price_point_id" ]]; then
  printf 'No price point found for JPY %s (searched all pages). First page sample:\n' "$PRICE_JP" >&2
  printf '%s\n' "$first_page_sample" >&2
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

  if [[ -n "$START_DATE" ]]; then
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
  else
    body=$(jq -n \
      --arg sid "$SUB_ID" \
      --arg pp "$target_pp_id" \
      '{
        data: {
          type: "subscriptionPrices",
          relationships: {
            subscription: { data: { type: "subscriptions", id: $sid } },
            subscriptionPricePoint: { data: { type: "subscriptionPricePoints", id: $pp } }
          }
        }
      }')
  fi

  response=$(asc_api POST "/v1/subscriptionPrices" "$body")

  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    if ! printf '%s' "$response" | jq -e '.data.id' >/dev/null 2>&1; then
      printf '  → failed: %s\n' "$response" >&2
      exit 1
    fi
    printf '  → set\n'
    sleep 0.2  # スロットリング
  fi
done
