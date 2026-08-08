#!/usr/bin/env bash
# =============================================================================
# スクリプト名: submit_appstore_review.sh
# 用途:
#   App Store Connect でアプリバージョンを審査提出する。
#   ビルドの紐付け → review submission の作成 → item 追加 → 提出までを行う。
#   審査待ちのサブスクリプション・買い切り商品はバージョンの提出に含めてレビューされる。
# 使い方:
#   bash scripts/generate_screenshots/submit_appstore_review.sh -a APP_ID -v VERSION_ID [-b BUILD_VERSION]
# 引数:
#   -a APP_ID        : App Store Connect の App ID (必須)
#   -v VERSION_ID    : 提出する appStoreVersion の ID (必須)
#   -b BUILD_VERSION : バージョンへ紐付けるビルド番号。省略時は VALID な最新ビルド
# 環境変数 (必須):
#   ASC_API_KEY_ID / ASC_API_KEY_ISSUER_ID / ASC_API_KEY_P8_BASE64
# 標準出力:
#   紐付けたビルド、submission に入れた item、提出結果
# 終了コード:
#   0 成功 / 1 API エラー / 2 引数不正
# 依存コマンド:
#   bash, curl, jq
# =============================================================================
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPOSITORY_ROOT"

readonly API_SCRIPT="$HOME/.claude/skills/appstore-in-app-purchase/scripts/iap_api.sh"
readonly PLATFORM="IOS"

APP_ID=""
VERSION_ID=""
BUILD_VERSION=""

while getopts "a:v:b:" option; do
  case "$option" in
    a) APP_ID="$OPTARG" ;;
    v) VERSION_ID="$OPTARG" ;;
    b) BUILD_VERSION="$OPTARG" ;;
    *)
      echo "使い方: $0 -a APP_ID -v VERSION_ID [-b BUILD_VERSION]" >&2
      exit 2
      ;;
  esac
done

if [ -z "$APP_ID" ] || [ -z "$VERSION_ID" ]; then
  echo "[NG] -a APP_ID と -v VERSION_ID が必要" >&2
  exit 2
fi

# 1. ビルドをバージョンへ紐付ける。
builds="$(bash "$API_SCRIPT" GET \
  "/v1/builds?filter[app]=$APP_ID&limit=10&sort=-uploadedDate&fields[builds]=version,processingState" 2>/dev/null)"
if [ -n "$BUILD_VERSION" ]; then
  build_id="$(echo "$builds" | jq -r --arg version "$BUILD_VERSION" \
    '.data[] | select(.attributes.version == $version) | .id' | head -1)"
else
  build_id="$(echo "$builds" | jq -r \
    '[.data[] | select(.attributes.processingState == "VALID")][0].id')"
fi
if [ -z "$build_id" ] || [ "$build_id" = "null" ]; then
  echo "[NG] 紐付けるビルドが見つからない (BUILD_VERSION=${BUILD_VERSION:-最新の VALID})" >&2
  exit 1
fi
build_version="$(echo "$builds" | jq -r --arg id "$build_id" \
  '.data[] | select(.id == $id) | .attributes.version')"
echo "--- ビルドを紐付け: $build_version ($build_id)"

bash "$API_SCRIPT" PATCH "/v1/appStoreVersions/$VERSION_ID/relationships/build" \
  "$(jq -n --arg id "$build_id" '{data: {type: "builds", id: $id}}')" > /dev/null 2>&1

# 2. review submission を作る。作成済みで未提出のものがあれば再利用する。
submission_id="$(bash "$API_SCRIPT" GET \
  "/v1/reviewSubmissions?filter[app]=$APP_ID&filter[state]=READY_FOR_REVIEW" 2>/dev/null \
  | jq -r '.data[0].id // empty')"
if [ -z "$submission_id" ]; then
  submission_id="$(bash "$API_SCRIPT" POST "/v1/reviewSubmissions" "$(jq -n \
    --arg platform "$PLATFORM" --arg appId "$APP_ID" \
    '{data: {type: "reviewSubmissions", attributes: {platform: $platform},
      relationships: {app: {data: {type: "apps", id: $appId}}}}}')" 2>/dev/null | jq -r '.data.id')"
fi
if [ -z "$submission_id" ] || [ "$submission_id" = "null" ]; then
  echo "[NG] review submission を作成できなかった" >&2
  exit 1
fi
echo "--- review submission: $submission_id"

# submission に item を 1 件追加する。既に入っていれば 409 になるので握りつぶす。
add_submission_item() {
  local relationship_name="$1"
  local relationship_type="$2"
  local relationship_id="$3"

  local response
  # iap_api.sh は 4xx で非ゼロ終了する。set -e で関数ごと打ち切られないよう握る。
  response="$(bash "$API_SCRIPT" POST "/v1/reviewSubmissionItems" "$(jq -n \
    --arg submissionId "$submission_id" --arg name "$relationship_name" \
    --arg type "$relationship_type" --arg id "$relationship_id" \
    '{data: {type: "reviewSubmissionItems",
      relationships: ({reviewSubmission: {data: {type: "reviewSubmissions", id: $submissionId}}}
        + {($name): {data: {type: $type, id: $id}}})}}')" 2>&1 || true)"
  if echo "$response" | jq -e '.data.id' > /dev/null 2>&1; then
    echo "--- item 追加: $relationship_name $relationship_id"
  else
    echo "--- item 追加をスキップ: $relationship_name $relationship_id ($(echo "$response" | jq -r '[.. | objects | select(has("code")) | .code] | first // "既存"' 2>/dev/null))"
  fi
}

add_submission_item appStoreVersion appStoreVersions "$VERSION_ID"

# サブスクリプション・買い切り商品は reviewSubmissionItems の relationship に無く
# ('subscription' is not a relationship on the resource 'reviewSubmissionItems')、
# アプリバージョンの提出に含めてレビューされる。ここで個別に追加しない。

# 3. 提出する。
submitted="$(bash "$API_SCRIPT" PATCH "/v1/reviewSubmissions/$submission_id" "$(jq -n \
  --arg id "$submission_id" \
  '{data: {type: "reviewSubmissions", id: $id, attributes: {submitted: true}}}')" 2>&1 || true)"
if echo "$submitted" | jq -e '.data.attributes.state' > /dev/null 2>&1; then
  echo "--- 提出完了: state=$(echo "$submitted" | jq -r '.data.attributes.state')"
else
  echo "[NG] 提出に失敗: $(echo "$submitted" | jq -c '.errors // .' 2>/dev/null)" >&2
  exit 1
fi
