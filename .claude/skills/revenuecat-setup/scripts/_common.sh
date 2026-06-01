#!/usr/bin/env bash
# revenuecat-setup 共通ライブラリ
# 各スクリプトは `source "$(dirname "$0")/_common.sh"` で読み込む

set -euo pipefail

# 必須環境変数チェック
: "${REVENUECAT_V2_SECRET_KEY:?REVENUECAT_V2_SECRET_KEY is required (sk_xxx)}"
: "${REVENUECAT_PROJECT_ID:?REVENUECAT_PROJECT_ID is required (proj_xxx)}"

readonly RC_API_BASE="https://api.revenuecat.com/v2"
readonly RC_API_V1_BASE="https://api.revenuecat.com/v1"

# 命名規則: {project}_{price}yen_{type}
readonly RC_PRODUCT_ID_REGEX='^[a-z][a-z0-9]*_[0-9]+yen_(1month|6month|1year|consumable|lifetime)$'

# Product ID の命名規則をバリデート。違反があれば exit 1。
# Usage: validate_product_id "shoppinglist_480yen_1month"
validate_product_id() {
  local product_id="$1"
  if ! [[ "$product_id" =~ $RC_PRODUCT_ID_REGEX ]]; then
    printf 'Error: Product ID "%s" does not match naming convention.\n' "$product_id" >&2
    printf '       Expected: {project}_{price}yen_{type} (type: 1month|6month|1year|consumable|lifetime)\n' >&2
    printf '       Examples: shoppinglist_480yen_1month, focus_10000yen_lifetime\n' >&2
    exit 1
  fi
}

# Product ID から type 部分を取り出す
# Usage: type=$(extract_product_type "shoppinglist_480yen_1month")  # → 1month
extract_product_type() {
  local product_id="$1"
  printf '%s' "$product_id" | sed -E 's/.*_([0-9]+yen)_(.+)$/\2/'
}

# Product ID から price 部分（数値）を取り出す
# Usage: price=$(extract_product_price "shoppinglist_480yen_1month")  # → 480
extract_product_price() {
  local product_id="$1"
  printf '%s' "$product_id" | sed -E 's/.*_([0-9]+)yen_.+$/\1/'
}

# v2 API を呼ぶ。dry-run なら curl コマンドを表示するだけ。
# Usage: rc_api_v2 GET /projects/{pid}/apps
#        rc_api_v2 POST /projects/{pid}/apps '{"type":"app_store","name":"foo"}'
rc_api_v2() {
  local method="$1"
  local path="$2"
  local body="${3:-}"
  local url="${RC_API_BASE}${path//\{project_id\}/$REVENUECAT_PROJECT_ID}"

  local curl_args=(
    -sS
    -X "$method"
    -H "Authorization: Bearer ${REVENUECAT_V2_SECRET_KEY}"
    -H "Content-Type: application/json"
    -H "Accept: application/json"
  )
  if [[ -n "$body" ]]; then
    curl_args+=(-d "$body")
  fi
  curl_args+=("$url")

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    printf '[DRY RUN] curl' >&2
    printf ' %q' "${curl_args[@]}" >&2
    printf '\n' >&2
    return 0
  fi

  curl "${curl_args[@]}"
}

# v1 API を呼ぶ
rc_api_v1() {
  local method="$1"
  local path="$2"
  local body="${3:-}"
  local url="${RC_API_V1_BASE}${path}"

  local curl_args=(
    -sS
    -X "$method"
    -H "Authorization: Bearer ${REVENUECAT_V2_SECRET_KEY}"
    -H "Content-Type: application/json"
    -H "Accept: application/json"
  )
  if [[ -n "$body" ]]; then
    curl_args+=(-d "$body")
  fi
  curl_args+=("$url")

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    printf '[DRY RUN] curl' >&2
    printf ' %q' "${curl_args[@]}" >&2
    printf '\n' >&2
    return 0
  fi

  curl "${curl_args[@]}"
}

# 共通: jq があるか確認
require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    printf 'Error: jq is required. Install with `brew install jq`.\n' >&2
    exit 1
  fi
}

# store_identifier から RC 内部 Product ID (prodXXX) を解決する。
# iOS/Android 両ストアに同 logical product があれば両方の ID を改行区切りで返す。
# Play subscription の `{sid}:{basePlanId}` 形式に対応するため prefix 一致でもマッチさせる。
resolve_rc_product_ids_by_sid() {
  local sid="$1"
  local products_response
  products_response=$(rc_api_v2 GET "/projects/{project_id}/products?limit=50")
  printf '%s' "$products_response" | jq -r --arg sid "$sid" \
    '.items[] | select(.store_identifier == $sid or (.store_identifier | startswith($sid + ":"))) | .id'
}

resolve_rc_product_id_by_sid() {
  resolve_rc_product_ids_by_sid "$1" | head -1
}
