#!/usr/bin/env bash
# Dangling edits を削除する
# Note: Play API は edits の list 取得をサポートしていない（個別 ID 指定での delete のみ）
# このスクリプトは「指定 edit ID を delete」もしくは「新規 insert + delete で active edit をクリア」する
# Usage: cleanup_edits.sh --package-name com.foo.bar [--edit-id EDIT_ID]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq
require_python_jwt

PACKAGE_NAME=""
EDIT_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package-name) PACKAGE_NAME="$2"; shift 2 ;;
    --edit-id) EDIT_ID="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${PACKAGE_NAME:?--package-name is required}"

ACCESS_TOKEN=$(get_access_token)
export ACCESS_TOKEN

if [[ -z "$EDIT_ID" ]]; then
  printf 'No --edit-id given. Creating a probe edit to surface conflict info.\n'
  probe=$(play_api POST "/applications/${PACKAGE_NAME}/edits" "" || true)
  printf '%s\n' "$probe"
  EDIT_ID=$(printf '%s' "$probe" | jq -r '.id // empty')
  if [[ -z "$EDIT_ID" ]]; then
    printf 'No new edit created. Inspect 409 conflict info above.\n' >&2
    exit 1
  fi
fi

printf 'Deleting edit: %s\n' "$EDIT_ID"
play_api DELETE "/applications/${PACKAGE_NAME}/edits/${EDIT_ID}" "" >/dev/null

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

printf '  → deleted\n'
