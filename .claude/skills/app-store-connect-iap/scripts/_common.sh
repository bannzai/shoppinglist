#!/usr/bin/env bash
# app-store-connect-iap 共通ライブラリ

set -euo pipefail

: "${ASC_KEY_P8_BASE64:?ASC_KEY_P8_BASE64 is required (base64 of .p8)}"
: "${ASC_KEY_ID:?ASC_KEY_ID is required}"
: "${ASC_ISSUER_ID:?ASC_ISSUER_ID is required}"

readonly ASC_API_BASE="https://api.appstoreconnect.apple.com"
readonly ASC_PRODUCT_ID_REGEX='^[a-z][a-z0-9]*_[0-9]+yen_(1month|6month|1year|consumable|lifetime)$'
readonly ASC_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ASC_VENV_DIR="${ASC_SCRIPT_DIR}/../.venv"
readonly ASC_VENV_PYTHON="${ASC_VENV_DIR}/bin/python"
# PyJWT 3.x 系で jwt.encode の戻り値型が str ↔ bytes で変わった前例があるためピン留め
readonly ASC_VENV_PACKAGES=("pyjwt==2.9.0" "cryptography==43.0.1")

# Skill ローカル venv を冪等にセットアップ。既に存在すれば何もしない。
ensure_venv() {
  if [[ -x "${ASC_VENV_PYTHON}" ]]; then
    return 0
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    printf 'Error: python3 is required to bootstrap venv.\n' >&2
    exit 1
  fi
  printf 'Creating venv: %s\n' "${ASC_VENV_DIR}" >&2
  python3 -m venv "${ASC_VENV_DIR}"
  printf 'Installing packages: %s\n' "${ASC_VENV_PACKAGES[*]}" >&2
  "${ASC_VENV_PYTHON}" -m pip install --quiet --upgrade pip
  "${ASC_VENV_PYTHON}" -m pip install --quiet "${ASC_VENV_PACKAGES[@]}"
}

# JWT を生成して echo。Skill 内では JWT_TOKEN 変数にキャッシュして使う。
generate_jwt() {
  ensure_venv
  "${ASC_VENV_PYTHON}" "${ASC_SCRIPT_DIR}/_jwt.py"
}

# Product ID 命名規則をバリデート
validate_product_id() {
  local product_id="$1"
  if ! [[ "$product_id" =~ $ASC_PRODUCT_ID_REGEX ]]; then
    printf 'Error: Product ID "%s" does not match naming convention.\n' "$product_id" >&2
    printf '       Expected: {project}_{price}yen_{type} (type: 1month|6month|1year|consumable|lifetime)\n' >&2
    exit 1
  fi
}

# Product ID type → ASC subscriptionPeriod
# Usage: type=$(asc_subscription_period "1month")  # → ONE_MONTH
asc_subscription_period() {
  case "$1" in
    1month) printf 'ONE_MONTH' ;;
    6month) printf 'SIX_MONTHS' ;;
    1year)  printf 'ONE_YEAR'  ;;
    *)      printf 'Error: type %s does not map to subscriptionPeriod\n' "$1" >&2; exit 1 ;;
  esac
}

# Product ID type → ASC inAppPurchaseType (IAP V2)
# Usage: type=$(asc_iap_v2_type "lifetime")  # → NON_CONSUMABLE
asc_iap_v2_type() {
  case "$1" in
    lifetime)   printf 'NON_CONSUMABLE' ;;
    consumable) printf 'CONSUMABLE' ;;
    *)          printf 'Error: type %s does not map to inAppPurchaseType (IAP V2)\n' "$1" >&2; exit 1 ;;
  esac
}

# Product type が Subscription かどうか
# Usage: if is_subscription_type "1month"; then ...
is_subscription_type() {
  case "$1" in
    1month|6month|1year) return 0 ;;
    *)                   return 1 ;;
  esac
}

# Product type が IAP V2 (lifetime/consumable) かどうか
is_iap_v2_type() {
  case "$1" in
    lifetime|consumable) return 0 ;;
    *)                   return 1 ;;
  esac
}

# Product ID から type を抽出
extract_product_type() {
  printf '%s' "$1" | sed -E 's/.*_([0-9]+yen)_(.+)$/\2/'
}

# ASC API call。$JWT_TOKEN を必須とする。
# Usage: asc_api GET "/v1/apps?filter[bundleId]=com.foo.bar"
#        asc_api POST "/v1/subscriptions" '{"data":{...}}'
asc_api() {
  local method="$1"
  local path="$2"
  local body="${3:-}"
  local url="${ASC_API_BASE}${path}"

  : "${JWT_TOKEN:?JWT_TOKEN must be set (call generate_jwt first)}"

  local curl_args=(
    -sS
    -X "$method"
    -H "Authorization: Bearer ${JWT_TOKEN}"
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

# jq 必須
require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    printf 'Error: jq is required. Install with `brew install jq`.\n' >&2
    exit 1
  fi
}
