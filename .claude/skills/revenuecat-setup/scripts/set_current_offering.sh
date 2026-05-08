#!/usr/bin/env bash
# Current Offering は RC API v2 に対応エンドポイントが無いため Dashboard 手動が必要
# https://www.revenuecat.com/docs/offerings/overview
# Usage: set_current_offering.sh --lookup-key default

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

LOOKUP_KEY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lookup-key) LOOKUP_KEY="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${LOOKUP_KEY:?--lookup-key is required (e.g., default)}"

offerings_response=$(rc_api_v2 GET "/projects/{project_id}/offerings")
offering_id=$(printf '%s' "$offerings_response" | jq -r --arg lk "$LOOKUP_KEY" \
  '.items[] | select(.lookup_key == $lk) | .id' | head -1)

if [[ -z "$offering_id" ]]; then
  printf 'Offering with lookup_key="%s" not found.\n' "$LOOKUP_KEY" >&2
  exit 1
fi

cat >&2 <<EOF

================================================================
[Manual Step] Current Offering は RC Dashboard で設定してください
(RC API v2 にエンドポイントが存在しないため自動化不可)

1. https://app.revenuecat.com/projects/${REVENUECAT_PROJECT_ID}/offerings/${offering_id}
2. "Make Current" を押下
3. lookup_key=${LOOKUP_KEY} に "current" バッジが付けば完了

出典: https://www.revenuecat.com/docs/offerings/overview
================================================================

EOF

exit 0
