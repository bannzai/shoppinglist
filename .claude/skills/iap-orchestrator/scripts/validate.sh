#!/usr/bin/env bash
# config を検証する（JSON parse + Product ID 命名規則 + 必須フィールド）
# Usage: validate.sh config.json

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

CONFIG="${1:?Usage: validate.sh config.json}"

if [[ ! -f "$CONFIG" ]]; then
  printf 'Error: config not found: %s\n' "$CONFIG" >&2
  exit 1
fi

# JSON 構文チェック
jq empty "$CONFIG"

# 必須フィールドチェック
for key in project app.bundle_id app.package_name products revenuecat.entitlement_lookup_key; do
  if ! jq -e ".${key}" "$CONFIG" >/dev/null; then
    printf 'Missing required field: %s\n' "$key" >&2
    exit 1
  fi
done

# project が snake_case か
project=$(jq -r '.project' "$CONFIG")
if ! [[ "$project" =~ ^[a-z][a-z0-9_]*$ ]]; then
  printf 'project must be snake_case: %s\n' "$project" >&2
  exit 1
fi

# 各 Product を命名規則チェック
fail=0
while IFS= read -r product_id; do
  if ! [[ "$product_id" =~ $ORCH_PRODUCT_ID_REGEX ]]; then
    printf 'Generated product ID does not match naming convention: %s\n' "$product_id" >&2
    fail=1
  fi
done < <(list_product_ids "$CONFIG")

if [[ $fail -eq 1 ]]; then
  exit 1
fi

# 環境変数（warning のみ、validate では fail にしない）
for var in ASC_KEY_P8_BASE64 ASC_KEY_ID ASC_ISSUER_ID GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64 REVENUECAT_V2_SECRET_KEY REVENUECAT_PROJECT_ID; do
  if [[ -z "${!var:-}" ]]; then
    printf '[warning] env var %s is not set (will fail at orchestrate time)\n' "$var" >&2
  fi
done

# Test Store を有効化している場合、関連環境変数の存在を警告
if jq -e '.revenuecat.test_store.enabled == true' "$CONFIG" >/dev/null; then
  if [[ -z "${REVENUECAT_TEST_STORE_API_KEY:-}" ]]; then
    printf '[warning] revenuecat.test_store.enabled=true but REVENUECAT_TEST_STORE_API_KEY is not set.\n' >&2
  fi
fi

printf 'OK: config is valid.\n'
printf 'Generated product IDs:\n'
list_product_ids "$CONFIG" | sed 's/^/  - /'
