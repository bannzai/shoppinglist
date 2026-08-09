#!/usr/bin/env bash
# =============================================================================
# スクリプト名: upload_googleplay_assets.sh
# 用途:
#   Google Play のストア掲載画像 (スクリーンショット / フィーチャーグラフィック /
#   アイコン) を Google Play Developer API でアップロードする。
#   1 つの edit にまとめて反映し、最後に commit する。冪等: 実行のたびに
#   対象 imageType の既存画像を全削除してから入れ直す。
# 使い方:
#   bash scripts/generate_screenshots/upload_googleplay_assets.sh
# 前提:
#   - convert_for_google_play.sh と generate_googleplay_graphics.sh が実行済み
#   - 環境変数 GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64 にサービスアカウント JSON (base64)
# 標準出力:
#   アップロードしたファイルと、commit した edit の ID
# 終了コード:
#   0 成功 / 1 入力不足・API エラー
# 依存コマンド:
#   bash, curl, jq, python3
# =============================================================================
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPOSITORY_ROOT"

readonly PACKAGE_NAME="com.bannzai.shoppinglist"
readonly SCREENSHOT_DIRECTORY="artifacts/googleplay_screenshots"
readonly GRAPHICS_DIRECTORY="artifacts/googleplay_graphics"
readonly API_HOST="https://androidpublisher.googleapis.com"

# ストアのロケール識別子。撮影側 (ios/fastlane/metadata) のディレクトリ名との対応。
readonly LOCALE_MAPPING="ja:ja-JP en-US:en-US"

if [ -z "${GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64:-}" ]; then
  echo "[NG] GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64 が未設定" >&2
  exit 1
fi

access_token="$(PLAY_SA_JSON_BASE64="$GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64" \
  bash "$HOME/.claude/skills/googleplay-in-app-purchase/scripts/play_token.sh")"
if [ -z "$access_token" ]; then
  echo "[NG] アクセストークンを取得できなかった" >&2
  exit 1
fi

edit_id="$(curl -s -X POST -H "Authorization: Bearer $access_token" \
  -H 'Content-Type: application/json' \
  "$API_HOST/androidpublisher/v3/applications/$PACKAGE_NAME/edits" -d '{}' \
  | jq -r '.id')"
if [ -z "$edit_id" ] || [ "$edit_id" = "null" ]; then
  echo "[NG] edit を作成できなかった" >&2
  exit 1
fi
echo "--- edit: $edit_id"

# 指定 imageType の既存画像を削除してから、渡されたファイルを順にアップロードする。
upload_images() {
  local language="$1"
  local image_type="$2"
  shift 2

  curl -s -X DELETE -H "Authorization: Bearer $access_token" \
    "$API_HOST/androidpublisher/v3/applications/$PACKAGE_NAME/edits/$edit_id/listings/$language/$image_type" \
    > /dev/null

  local file
  for file in "$@"; do
    [ -f "$file" ] || continue
    local response
    response="$(curl -s -X POST -H "Authorization: Bearer $access_token" \
      -H 'Content-Type: image/png' \
      --data-binary "@$file" \
      "$API_HOST/upload/androidpublisher/v3/applications/$PACKAGE_NAME/edits/$edit_id/listings/$language/$image_type?uploadType=media")"
    if ! echo "$response" | jq -e '.image.id' > /dev/null 2>&1; then
      echo "[NG] $file のアップロードに失敗: $(echo "$response" | jq -c '.error.message // .')" >&2
      exit 1
    fi
    echo "--- $language / $image_type <- $file"
  done
}

for mapping in $LOCALE_MAPPING; do
  source_locale="${mapping%%:*}"
  play_language="${mapping##*:}"

  screenshots=()
  while IFS= read -r screenshot; do
    screenshots+=("$screenshot")
  done < <(find "$SCREENSHOT_DIRECTORY/$source_locale" -name '*.png' 2>/dev/null | sort)
  if [ "${#screenshots[@]}" -eq 0 ]; then
    echo "[NG] $SCREENSHOT_DIRECTORY/$source_locale に PNG が無い" >&2
    exit 1
  fi
  upload_images "$play_language" phoneScreenshots "${screenshots[@]}"
  upload_images "$play_language" featureGraphic "$GRAPHICS_DIRECTORY/feature_graphic.png"
  upload_images "$play_language" icon "$GRAPHICS_DIRECTORY/icon.png"
done

commit_response="$(curl -s -X POST -H "Authorization: Bearer $access_token" \
  -H 'Content-Type: application/json' \
  "$API_HOST/androidpublisher/v3/applications/$PACKAGE_NAME/edits/$edit_id:commit" -d '{}')"
if ! echo "$commit_response" | jq -e '.id' > /dev/null 2>&1; then
  echo "[NG] edit の commit に失敗: $(echo "$commit_response" | jq -c '.error.message // .')" >&2
  exit 1
fi
echo "--- commit 完了: $(echo "$commit_response" | jq -r '.id')"
