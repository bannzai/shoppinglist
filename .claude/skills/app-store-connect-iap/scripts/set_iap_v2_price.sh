#!/usr/bin/env bash
# IAP V2 の価格を設定する（簡易版: JPN/JPY のみ）
# 全 territory 対応は将来拡張。lifetime/consumable の最低限動作確認用。
# Usage: set_iap_v2_price.sh --iap-id IAP_ID --price-jp 10000

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

IAP_ID=""
PRICE_JP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --iap-id) IAP_ID="$2"; shift 2 ;;
    --price-jp) PRICE_JP="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${IAP_ID:?--iap-id is required}"
: "${PRICE_JP:?--price-jp is required (JPY integer, no decimals)}"

JWT_TOKEN=$(generate_jwt)
export JWT_TOKEN

# Step 1: JPN territory の IAP V2 価格ポイント候補を取得し、JPY 完全一致を選ぶ (links.next でページネーション)
printf 'Looking up IAP V2 price point for JPY %s\n' "$PRICE_JP"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  # DRY_RUN は curl 本体を走らせないため 1 ページだけ叩いて curl ログを出す
  asc_api GET "/v2/inAppPurchases/${IAP_ID}/pricePoints?filter%5Bterritory%5D=JPN&include=territory&limit=200" >/dev/null
  jp_price_point_id="DRY_RUN_PP_ID"
else
  jp_price_point_id=""
  first_page_sample=""
  next_path="/v2/inAppPurchases/${IAP_ID}/pricePoints?filter%5Bterritory%5D=JPN&include=territory&limit=200"

  while [[ -n "$next_path" ]]; do
    pp_response=$(asc_api GET "$next_path")

    matched=$(printf '%s' "$pp_response" | jq -r --arg p "$PRICE_JP" \
      '.data[] | select(.attributes.customerPrice == $p or .attributes.customerPrice == ($p + ".00")) | .id' 2>/dev/null | head -1)
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
    printf 'No IAP V2 price point found for JPY %s (searched all pages). First page sample:\n' "$PRICE_JP" >&2
    printf '%s\n' "$first_page_sample" >&2
    exit 1
  fi
fi
printf '  → JP price point: %s\n' "$jp_price_point_id"

# Step 2: inAppPurchasePriceSchedule を 1 リクエストで作成
# manualPrices に JPN 用 price を inline で含める方式（公式 IAP V2 パターン）
body=$(jq -n \
  --arg iid "$IAP_ID" \
  --arg pp "$jp_price_point_id" \
  '{
    data: {
      type: "inAppPurchasePriceSchedules",
      relationships: {
        inAppPurchase: { data: { type: "inAppPurchases", id: $iid } },
        manualPrices: { data: [{ type: "inAppPurchasePrices", id: "${price1}" }] },
        baseTerritory: { data: { type: "territories", id: "JPN" } }
      }
    },
    included: [
      {
        type: "inAppPurchasePrices",
        id: "${price1}",
        attributes: { startDate: null },
        relationships: {
          inAppPurchaseV2: { data: { type: "inAppPurchases", id: $iid } },
          inAppPurchasePricePoint: { data: { type: "inAppPurchasePricePoints", id: $pp } }
        }
      }
    ]
  }')

printf 'Setting IAP V2 price schedule (JPN only): JPY %s\n' "$PRICE_JP"
response=$(asc_api POST "/v1/inAppPurchasePriceSchedules" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

if printf '%s' "$response" | jq -e '.data.id' >/dev/null 2>&1; then
  printf '  → schedule created\n'
else
  printf 'Response: %s\n' "$response" >&2
  exit 1
fi
