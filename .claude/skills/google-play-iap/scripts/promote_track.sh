#!/usr/bin/env bash
# 既存 versionCode を別 track に昇格させる
# Usage: promote_track.sh --package-name com.foo.bar --version-code 12 --from internal --to closed

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

PACKAGE_NAME=""
VERSION_CODE=""
FROM_TRACK=""
TO_TRACK=""
USER_FRACTION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package-name) PACKAGE_NAME="$2"; shift 2 ;;
    --version-code) VERSION_CODE="$2"; shift 2 ;;
    --from) FROM_TRACK="$2"; shift 2 ;;
    --to) TO_TRACK="$2"; shift 2 ;;
    --user-fraction) USER_FRACTION="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${PACKAGE_NAME:?--package-name is required}"
: "${VERSION_CODE:?--version-code is required}"
: "${TO_TRACK:?--to is required (internal|alpha|beta|production)}"

ACCESS_TOKEN=$(get_access_token)
export ACCESS_TOKEN

# Step 1: edit 作成
edit_response=$(play_api POST "/applications/${PACKAGE_NAME}/edits" "")
EDIT_ID=$(printf '%s' "$edit_response" | jq -r '.id // empty')
if [[ -z "$EDIT_ID" && "${DRY_RUN:-0}" != "1" ]]; then
  printf 'Failed to create edit. Response: %s\n' "$edit_response" >&2
  exit 1
fi

# Step 2: track update
release_obj=$(jq -n --arg vc "$VERSION_CODE" '{versionCodes: [$vc], status: "completed"}')
if [[ -n "$USER_FRACTION" ]]; then
  release_obj=$(printf '%s' "$release_obj" | jq --argjson uf "$USER_FRACTION" '. + {status: "inProgress", userFraction: $uf}')
fi

track_body=$(jq -n --arg t "$TO_TRACK" --argjson r "$release_obj" '{track: $t, releases: [$r]}')

printf 'Promoting versionCode %s to %s track\n' "$VERSION_CODE" "$TO_TRACK"
play_api PUT "/applications/${PACKAGE_NAME}/edits/${EDIT_ID}/tracks/${TO_TRACK}" "$track_body" >/dev/null

# Step 3: edit commit
play_api POST "/applications/${PACKAGE_NAME}/edits/${EDIT_ID}:commit" "" >/dev/null

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

printf '  → promoted to %s\n' "$TO_TRACK"
