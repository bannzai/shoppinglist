#!/usr/bin/env bash
# Package を作成し、Product を attach する
# Usage:
#   create_package.sh --offering-key default --package-key '$rc_monthly' --product-id shoppinglist_480yen_1month

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

OFFERING_KEY=""
PACKAGE_KEY=""
PRODUCT_ID=""
DISPLAY_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --offering-key) OFFERING_KEY="$2"; shift 2 ;;
    --package-key) PACKAGE_KEY="$2"; shift 2 ;;
    --product-id) PRODUCT_ID="$2"; shift 2 ;;
    --display-name) DISPLAY_NAME="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${OFFERING_KEY:?--offering-key is required (e.g., default)}"
: "${PACKAGE_KEY:?--package-key is required (e.g., \$rc_monthly)}"
: "${PRODUCT_ID:?--product-id is required (matches naming convention)}"

validate_product_id "$PRODUCT_ID"

# Package key の標準値チェック（warning のみ、強制はしない）
if [[ ! "$PACKAGE_KEY" =~ ^\$rc_(weekly|monthly|two_month|three_month|six_month|annual|lifetime|custom)$ ]]; then
  printf 'Warning: Package key "%s" is not a standard $rc_* value. SDK will treat it as PackageType.custom.\n' "$PACKAGE_KEY" >&2
fi

display_name="${DISPLAY_NAME:-$PACKAGE_KEY}"

# Step 1: Offering ID を lookup_key から取得
printf 'Looking up offering: %s\n' "$OFFERING_KEY"
offerings_response=$(rc_api_v2 GET "/projects/{project_id}/offerings")
offering_id=$(printf '%s' "$offerings_response" | jq -r --arg lk "$OFFERING_KEY" '.items[] | select(.lookup_key == $lk) | .id' | head -1)

if [[ -z "$offering_id" ]]; then
  printf 'Offering with lookup_key="%s" not found.\n' "$OFFERING_KEY" >&2
  exit 1
fi

# Step 2: store_identifier から iOS/Android/Test Store の全 prodXXX を取得
# SDK は API Key (どのストア) に応じて Package の attach 済み product から適切なものを選ぶ
printf 'Looking up products: %s\n' "$PRODUCT_ID"
# shellcheck disable=SC2207
rc_product_ids=($(resolve_rc_product_ids_by_sid "$PRODUCT_ID"))

if [[ ${#rc_product_ids[@]} -eq 0 ]]; then
  printf 'No products with store_identifier="%s" found in RevenueCat.\n' "$PRODUCT_ID" >&2
  exit 1
fi
printf '  → resolved %d product(s): %s\n' "${#rc_product_ids[@]}" "${rc_product_ids[*]}"

# Step 3: Package を作成
pkg_body=$(jq -n --arg lk "$PACKAGE_KEY" --arg dn "$display_name" \
  '{lookup_key: $lk, display_name: $dn, position: 1}')

printf 'Creating package: %s in offering %s\n' "$PACKAGE_KEY" "$OFFERING_KEY"
pkg_response=$(rc_api_v2 POST "/projects/{project_id}/offerings/${offering_id}/packages" "$pkg_body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  printf '[DRY RUN] Would attach product %s\n' "$PRODUCT_ID" >&2
  exit 0
fi

package_id=$(printf '%s' "$pkg_response" | jq -r '.id // empty')

# 409 なら既存 package を再利用
if [[ -z "$package_id" ]] && printf '%s' "$pkg_response" | jq -e '.type == "resource_already_exists" or .code == 7263' >/dev/null 2>&1; then
  printf '  → already exists, looking up existing id...\n'
  list_response=$(rc_api_v2 GET "/projects/{project_id}/offerings/${offering_id}/packages?limit=50")
  package_id=$(printf '%s' "$list_response" | jq -r --arg lk "$PACKAGE_KEY" \
    '.items[] | select(.lookup_key == $lk) | .id' | head -1)
fi

if [[ -z "$package_id" ]]; then
  printf 'Failed to create package. Response: %s\n' "$pkg_response" >&2
  exit 1
fi
printf '  → ready: id=%s\n' "$package_id"

# Step 4: 既存 attach を GET で取得し、未 attach の product だけ POST で追加 (冪等化)
# RC v2: POST /projects/{pid}/packages/{pkid}/actions/attach_products
# body: {products: [{product_id, eligibility_criteria}]}
attached_response=$(rc_api_v2 GET "/projects/{project_id}/packages/${package_id}/products")
already_attached=$(printf '%s' "$attached_response" | jq -r '.items[]?.product.id')

to_attach=()
for pid in "${rc_product_ids[@]}"; do
  if ! printf '%s\n' "$already_attached" | grep -qxF "$pid"; then
    to_attach+=("$pid")
  fi
done

if [[ ${#to_attach[@]} -eq 0 ]]; then
  printf '  → already attached (%d product(s)), skipping\n' "${#rc_product_ids[@]}"
  exit 0
fi

products_json=$(printf '%s\n' "${to_attach[@]}" | jq -R '{product_id: ., eligibility_criteria: "all"}' | jq -s .)
attach_body=$(jq -n --argjson products "$products_json" '{products: $products}')

printf 'Attaching %d new product(s) to package %s (already had %d)\n' \
  "${#to_attach[@]}" "$PACKAGE_KEY" "$((${#rc_product_ids[@]} - ${#to_attach[@]}))"
printf '  adding: %s\n' "${to_attach[*]}"
attach_response=$(rc_api_v2 POST \
  "/projects/{project_id}/packages/${package_id}/actions/attach_products" \
  "$attach_body")

if printf '%s' "$attach_response" | jq -e '.id' >/dev/null 2>&1; then
  printf '  → attached\n'
elif [[ -z "$attach_response" ]]; then
  printf '  → attached (empty body)\n'
else
  printf 'Attach response: %s\n' "$attach_response"
fi
