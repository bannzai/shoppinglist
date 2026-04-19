#!/usr/bin/env bash
# google-play-iap 共通ライブラリ

set -euo pipefail

: "${GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64:?GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64 is required (base64 of service-account.json)}"

readonly PLAY_API_BASE="https://androidpublisher.googleapis.com/androidpublisher/v3"
readonly PLAY_PRODUCT_ID_REGEX='^[a-z][a-z0-9]*_[0-9]+yen_(1month|6month|1year|consumable|lifetime)$'
readonly PLAY_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Access token を生成して echo
get_access_token() {
  python3 "${PLAY_SCRIPT_DIR}/_auth.py"
}

# 命名規則バリデーション
validate_product_id() {
  local product_id="$1"
  if ! [[ "$product_id" =~ $PLAY_PRODUCT_ID_REGEX ]]; then
    printf 'Error: Product ID "%s" does not match naming convention.\n' "$product_id" >&2
    printf '       Expected: {project}_{price}yen_{type} (type: 1month|6month|1year|consumable|lifetime)\n' >&2
    exit 1
  fi
}

# Product type → ISO 8601 billing period
# Usage: period=$(play_billing_period "1month")  # → P1M
play_billing_period() {
  case "$1" in
    1month) printf 'P1M' ;;
    6month) printf 'P6M' ;;
    1year)  printf 'P1Y' ;;
    *)      printf 'Error: type %s does not map to billingPeriodDuration\n' "$1" >&2; exit 1 ;;
  esac
}

# Product ID から type を抽出
extract_product_type() {
  printf '%s' "$1" | sed -E 's/.*_([0-9]+yen)_(.+)$/\2/'
}

# Play API call
# Usage: play_api GET "/applications/{packageName}/subscriptions"
#        play_api POST "/applications/{packageName}/subscriptions?productId=foo&regionsVersion.version=2022/02" '{...}'
play_api() {
  local method="$1"
  local path="$2"
  local body="${3:-}"
  local url="${PLAY_API_BASE}${path}"

  : "${ACCESS_TOKEN:?ACCESS_TOKEN must be set (call get_access_token first)}"

  local curl_args=(
    -sS
    -X "$method"
    -H "Authorization: Bearer ${ACCESS_TOKEN}"
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

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    printf 'Error: jq is required. Install with `brew install jq`.\n' >&2
    exit 1
  fi
}

require_python_jwt() {
  if ! command -v python3 >/dev/null 2>&1; then
    printf 'Error: python3 is required.\n' >&2
    exit 1
  fi
  if ! python3 -c "import jwt" 2>/dev/null; then
    printf 'Error: PyJWT is required. Install with: pip3 install pyjwt cryptography\n' >&2
    exit 1
  fi
}
