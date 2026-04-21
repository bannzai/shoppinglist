#!/usr/bin/env bash
# Dashboard で作成済みの Test Store App の id を取得する
# API v2 の POST /projects/{pid}/apps の type enum には test_store が存在しないため作成は不可
# 出典: https://www.revenuecat.com/docs/api-v2 / OpenAPI YAML で確認済み
# Usage:
#   lookup_test_store_app.sh
#   lookup_test_store_app.sh --dry-run

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

# 1) Env fallback 優先 (Dashboard URL から手動取得した app_id を注入可能)
if [[ -n "${REVENUECAT_TEST_STORE_APP_ID:-}" ]]; then
  printf 'Reusing Test Store app_id from env: %s\n' "$REVENUECAT_TEST_STORE_APP_ID" >&2
  printf 'Test Store app_id: %s\n' "$REVENUECAT_TEST_STORE_APP_ID"
  exit 0
fi

# 2) API v2 で自動発見を試す
if [[ "$DRY_RUN" -eq 1 ]]; then
  rc_api_v2 GET "/projects/{project_id}/apps?limit=50" >/dev/null
  printf '[DRY RUN] Would filter apps by type matching test store\n' >&2
  exit 0
fi

apps_response=$(rc_api_v2 GET "/projects/{project_id}/apps?limit=50")

# inspect_test_store.sh で判明した type 値を先頭に置く
# 実機確認で確定後に配列を絞ること
for candidate_type in test_store test; do
  test_store_id=$(printf '%s' "$apps_response" | jq -r --arg t "$candidate_type" \
    '.items[] | select(.type == $t) | .id' | head -1)
  if [[ -n "$test_store_id" ]]; then
    printf 'Found Test Store app (type=%s): %s\n' "$candidate_type" "$test_store_id" >&2
    printf 'Test Store app_id: %s\n' "$test_store_id"
    exit 0
  fi
done

cat >&2 <<EOF

================================================================
[Manual Step] Test Store App が REST API から発見できませんでした。

1. Dashboard で Test Store を作成:
   https://app.revenuecat.com/projects/${REVENUECAT_PROJECT_ID}/apps
   → "Apps and providers" → "Test configuration" で新規作成
2. 発行された Test Store API Key を REVENUECAT_TEST_STORE_API_KEY に export
3. Dashboard URL に表示される appXXX 形式の ID を REVENUECAT_TEST_STORE_APP_ID に export
4. 本スクリプトを再実行

参考: https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store
================================================================
EOF
exit 1
