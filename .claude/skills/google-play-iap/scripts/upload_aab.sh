#!/usr/bin/env bash
# AAB をアップロードして指定 track にリリースする
# Usage:
#   upload_aab.sh \
#     --package-name com.foo.bar \
#     --aab-path build/app/outputs/bundle/release/app-release.aab \
#     --track internal \
#     --release-notes-ja "初回リリース" --release-notes-en "Initial release"

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

PACKAGE_NAME=""
AAB_PATH=""
TRACK="internal"
RELEASE_NOTES_JA=""
RELEASE_NOTES_EN=""
USER_FRACTION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package-name) PACKAGE_NAME="$2"; shift 2 ;;
    --aab-path) AAB_PATH="$2"; shift 2 ;;
    --track) TRACK="$2"; shift 2 ;;
    --release-notes-ja) RELEASE_NOTES_JA="$2"; shift 2 ;;
    --release-notes-en) RELEASE_NOTES_EN="$2"; shift 2 ;;
    --user-fraction) USER_FRACTION="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${PACKAGE_NAME:?--package-name is required}"
: "${AAB_PATH:?--aab-path is required}"
: "${TRACK:?--track is required (internal|alpha|beta|production)}"

if [[ ! -f "$AAB_PATH" ]]; then
  printf 'Error: AAB not found: %s\n' "$AAB_PATH" >&2
  exit 1
fi

ACCESS_TOKEN=$(get_access_token)
export ACCESS_TOKEN

# Step 1: edits insert
printf 'Inserting new edit\n'
edit_response=$(play_api POST "/applications/${PACKAGE_NAME}/edits" "")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  EDIT_ID="dry_run_edit_id"
else
  EDIT_ID=$(printf '%s' "$edit_response" | jq -r '.id // empty')
  if [[ -z "$EDIT_ID" ]]; then
    printf 'Failed to create edit. Response: %s\n' "$edit_response" >&2
    exit 1
  fi
  printf '  → edit_id=%s\n' "$EDIT_ID"
fi

# Step 2: AAB upload (multipart, バイナリ送信のため curl 直接)
printf 'Uploading AAB (%s)\n' "$AAB_PATH"
upload_url="https://androidpublisher.googleapis.com/upload/androidpublisher/v3/applications/${PACKAGE_NAME}/edits/${EDIT_ID}/bundles?uploadType=media"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  printf '[DRY RUN] curl --upload-file %s -H "Authorization: Bearer ..." -H "Content-Type: application/octet-stream" %s\n' "$AAB_PATH" "$upload_url" >&2
  VERSION_CODE=999
else
  upload_response=$(curl -sS \
    -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/octet-stream" \
    --data-binary "@${AAB_PATH}" \
    "$upload_url")
  VERSION_CODE=$(printf '%s' "$upload_response" | jq -r '.versionCode // empty')
  if [[ -z "$VERSION_CODE" ]]; then
    printf 'AAB upload failed. Response: %s\n' "$upload_response" >&2
    exit 1
  fi
  printf '  → versionCode=%s\n' "$VERSION_CODE"
fi

# Step 3: track update
release_obj=$(jq -n --argjson vc "$VERSION_CODE" --arg ja "$RELEASE_NOTES_JA" --arg en "$RELEASE_NOTES_EN" \
  '{
    versionCodes: [$vc | tostring],
    status: "completed",
    releaseNotes: [
      {language: "ja-JP", text: $ja},
      {language: "en-US", text: $en}
    ]
  }')

if [[ -n "$USER_FRACTION" ]]; then
  release_obj=$(printf '%s' "$release_obj" | jq --argjson uf "$USER_FRACTION" '. + {status: "inProgress", userFraction: $uf}')
fi

track_body=$(jq -n --arg t "$TRACK" --argjson r "$release_obj" '{track: $t, releases: [$r]}')

printf 'Updating track: %s\n' "$TRACK"
play_api PUT "/applications/${PACKAGE_NAME}/edits/${EDIT_ID}/tracks/${TRACK}" "$track_body" >/dev/null

# Step 4: edit commit
printf 'Committing edit\n'
play_api POST "/applications/${PACKAGE_NAME}/edits/${EDIT_ID}:commit" "" >/dev/null

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

printf '  → committed: versionCode=%s, track=%s\n' "$VERSION_CODE" "$TRACK"
