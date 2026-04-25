#!/usr/bin/env bash
# Test Store App の REST API 可視性を確認する先行調査スクリプト
# Dashboard で Test Store を作成済みであることが前提
# 得られた type 値を lookup_test_store_app.sh の candidate 配列に反映する
# Usage: bash inspect_test_store.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

printf '=== GET /projects/{pid}/apps (all apps including Test Store candidates) ===\n'
apps_response=$(rc_api_v2 GET "/projects/{project_id}/apps?limit=50")
printf '%s\n' "$apps_response" | jq '.items[] | {id, type, name}'

printf '\n=== Filter by type matching "test" (case-insensitive) ===\n'
printf '%s\n' "$apps_response" | jq '.items[] | select(.type | test("test"; "i")) | {id, type, name}'

printf '\n=== GET /projects/{pid}/products (inspect app_id linkage) ===\n'
products_response=$(rc_api_v2 GET "/projects/{project_id}/products?limit=50")
printf '%s\n' "$products_response" | jq '.items[] | {id, store_identifier, app_id, type}'

printf '\n=== Hint ===\n'
printf -- '- Test Store app が type=??? で返る場合、その type 値を lookup_test_store_app.sh の candidate 配列に追加\n'
printf -- '- 返らない場合は env 経由 (REVENUECAT_TEST_STORE_APP_ID) で ID を手動注入する fallback を使う\n'
