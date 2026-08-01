#!/usr/bin/env bash
# templates/paywall.png を Subscription の Review Screenshot としてアップロードする
# Usage: upload_review_screenshot.sh --subscription-id SUB_ID

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
source "${SCRIPT_DIR}/_common.sh"

require_jq

SUB_ID=""
PNG_PATH="${SKILL_DIR}/templates/paywall.png"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --subscription-id) SUB_ID="$2"; shift 2 ;;
    --file) PNG_PATH="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${SUB_ID:?--subscription-id is required}"

if [[ ! -f "$PNG_PATH" ]]; then
  printf 'Error: review screenshot not found: %s\n' "$PNG_PATH" >&2
  printf '       Place a paywall PNG there first.\n' >&2
  exit 1
fi

file_size=$(stat -f%z "$PNG_PATH" 2>/dev/null || stat -c%s "$PNG_PATH")
file_name=$(basename "$PNG_PATH")
md5_checksum=$(md5 -q "$PNG_PATH" 2>/dev/null || md5sum "$PNG_PATH" | cut -d' ' -f1)

JWT_TOKEN=$(generate_jwt)
export JWT_TOKEN

# Step 1: アセット予約
reserve_body=$(jq -n \
  --argjson size "$file_size" \
  --arg name "$file_name" \
  --arg sid "$SUB_ID" \
  '{
    data: {
      type: "subscriptionAppStoreReviewScreenshots",
      attributes: { fileSize: $size, fileName: $name },
      relationships: { subscription: { data: { type: "subscriptions", id: $sid } } }
    }
  }')

printf 'Reserving upload slot for %s (%d bytes)\n' "$file_name" "$file_size"
reserve_response=$(asc_api POST "/v1/subscriptionAppStoreReviewScreenshots" "$reserve_body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

asset_id=$(printf '%s' "$reserve_response" | jq -r '.data.id // empty')
upload_url=$(printf '%s' "$reserve_response" | jq -r '.data.attributes.uploadOperations[0].url // empty')

if [[ -z "$asset_id" || -z "$upload_url" ]]; then
  printf 'Reserve failed. Response: %s\n' "$reserve_response" >&2
  exit 1
fi
printf '  → asset_id=%s\n' "$asset_id"

# Step 2: PUT (JWT 不要、署名付き URL)
# ヘッダ値に空白を含む ("Content-Type: image/png" 等) ため、eval + 文字列連結ではなく
# 配列で curl に渡す (未クオートだと値が別引数に分割され curl が URL と誤認する)
printf 'Uploading file to signed URL\n'
declare -a upload_header_args=()
while IFS=$'\t' read -r header_name header_value; do
  upload_header_args+=(-H "${header_name}: ${header_value}")
done < <(printf '%s' "$reserve_response" | jq -r '.data.attributes.uploadOperations[0].requestHeaders[] | [.name, .value] | @tsv')
if ! curl -fsS -X PUT "${upload_header_args[@]}" --data-binary "@${PNG_PATH}" "$upload_url"; then
  printf 'Upload PUT failed. Aborting before commit.\n' >&2
  exit 1
fi

# Step 3: commit
commit_body=$(jq -n --arg cs "$md5_checksum" --arg aid "$asset_id" \
  '{data: {type: "subscriptionAppStoreReviewScreenshots", id: $aid, attributes: {uploaded: true, sourceFileChecksum: $cs}}}')

printf 'Committing upload\n'
asc_api PATCH "/v1/subscriptionAppStoreReviewScreenshots/${asset_id}" "$commit_body" >/dev/null

# Step 4: polling (最大 30秒)
printf 'Waiting for asset processing\n'
for i in 1 2 3 4 5 6; do
  sleep 5
  state_response=$(asc_api GET "/v1/subscriptionAppStoreReviewScreenshots/${asset_id}")
  state=$(printf '%s' "$state_response" | jq -r '.data.attributes.assetDeliveryState.state // "UNKNOWN"')
  printf '  → state=%s\n' "$state"
  if [[ "$state" == "COMPLETE" ]]; then
    break
  fi
done

if [[ "$state" != "COMPLETE" ]]; then
  printf 'Warning: state did not reach COMPLETE within 30s. Current: %s\n' "$state" >&2
fi
