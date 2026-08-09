#!/usr/bin/env bash
# =============================================================================
# スクリプト名: upload_appstore_screenshots.sh
# 用途:
#   ios/fastlane/screenshots/ のスクリーンショットを App Store Connect の
#   対象バージョンへアップロードする。App Store Connect API の
#   予約 (reserve) → アップロード (upload operations) → コミット (commit) の
#   3 段階を実行する。冪等: 実行のたびに対象 displayType の既存画像を削除して入れ直す。
# 使い方:
#   bash scripts/generate_screenshots/upload_appstore_screenshots.sh -v VERSION_ID
# 引数:
#   -v VERSION_ID : アップロード先の appStoreVersion の ID (必須)
# 環境変数 (必須):
#   ASC_API_KEY_ID / ASC_API_KEY_ISSUER_ID / ASC_API_KEY_P8_BASE64
#   (appstore-in-app-purchase skill の iap_api.sh が読む名前と同じ)
# 標準出力:
#   ロケールごとのアップロード結果
# 終了コード:
#   0 成功 / 1 API エラー / 2 引数不正
# 依存コマンド:
#   bash, curl, jq, python3, openssl
# =============================================================================
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPOSITORY_ROOT"

readonly SCREENSHOT_DIRECTORY="ios/fastlane/screenshots"
readonly API_SCRIPT="$HOME/.claude/skills/appstore-in-app-purchase/scripts/iap_api.sh"

# 撮影解像度 1320x2868 (6.9 インチ) を入れる App Store の表示クラス。
# API に APP_IPHONE_69 は無く、6.9 インチは 6.7 インチと同じ枠で受け付けられる。
readonly DISPLAY_TYPE="APP_IPHONE_67"

VERSION_ID=""
while getopts "v:" option; do
  case "$option" in
    v) VERSION_ID="$OPTARG" ;;
    *)
      echo "使い方: $0 -v VERSION_ID" >&2
      exit 2
      ;;
  esac
done

if [ -z "$VERSION_ID" ]; then
  echo "[NG] -v VERSION_ID が必要" >&2
  exit 2
fi

for locale_directory in "$SCREENSHOT_DIRECTORY"/*/; do
  [ -d "$locale_directory" ] || continue
  locale="$(basename "$locale_directory")"

  localization_id="$(bash "$API_SCRIPT" GET \
    "/v1/appStoreVersions/$VERSION_ID/appStoreVersionLocalizations" 2>/dev/null \
    | jq -r --arg locale "$locale" '.data[] | select(.attributes.locale == $locale) | .id')"
  if [ -z "$localization_id" ]; then
    echo "[NG] $locale のバージョンローカライズが無い" >&2
    exit 1
  fi

  # 既存の同 displayType のスクリーンショットセットを消してから作り直す。
  existing_set_id="$(bash "$API_SCRIPT" GET \
    "/v1/appStoreVersionLocalizations/$localization_id/appScreenshotSets" 2>/dev/null \
    | jq -r --arg type "$DISPLAY_TYPE" '.data[] | select(.attributes.screenshotDisplayType == $type) | .id')"
  if [ -n "$existing_set_id" ]; then
    bash "$API_SCRIPT" DELETE "/v1/appScreenshotSets/$existing_set_id" > /dev/null 2>&1 || true
  fi

  set_id="$(bash "$API_SCRIPT" POST "/v1/appScreenshotSets" "$(jq -n \
    --arg type "$DISPLAY_TYPE" --arg localizationId "$localization_id" \
    '{data: {type: "appScreenshotSets", attributes: {screenshotDisplayType: $type},
      relationships: {appStoreVersionLocalization: {data: {type: "appStoreVersionLocalizations", id: $localizationId}}}}}')" \
    2>/dev/null | jq -r '.data.id')"
  if [ -z "$set_id" ] || [ "$set_id" = "null" ]; then
    echo "[NG] $locale のスクリーンショットセットを作成できなかった" >&2
    exit 1
  fi

  while IFS= read -r screenshot; do
    file_name="$(basename "$screenshot")"
    file_size="$(wc -c < "$screenshot" | tr -d ' ')"

    reserved="$(bash "$API_SCRIPT" POST "/v1/appScreenshots" "$(jq -n \
      --arg fileName "$file_name" --argjson fileSize "$file_size" --arg setId "$set_id" \
      '{data: {type: "appScreenshots", attributes: {fileName: $fileName, fileSize: $fileSize},
        relationships: {appScreenshotSet: {data: {type: "appScreenshotSets", id: $setId}}}}}')" 2>/dev/null)"
    screenshot_id="$(echo "$reserved" | jq -r '.data.id')"
    if [ -z "$screenshot_id" ] || [ "$screenshot_id" = "null" ]; then
      echo "[NG] $screenshot の予約に失敗: $(echo "$reserved" | jq -c '.errors // .')" >&2
      exit 1
    fi

    # uploadOperations は分割アップロードの指示。各 chunk を指定の URL / メソッドで送る。
    echo "$reserved" | jq -c '.data.attributes.uploadOperations[]' | while IFS= read -r operation; do
      url="$(echo "$operation" | jq -r '.url')"
      method="$(echo "$operation" | jq -r '.method')"
      offset="$(echo "$operation" | jq -r '.offset')"
      length="$(echo "$operation" | jq -r '.length')"
      header_arguments=()
      while IFS= read -r header; do
        header_arguments+=(-H "$header")
      done < <(echo "$operation" | jq -r '.requestHeaders[] | "\(.name): \(.value)"')

      python3 -c "
import sys
with open('$screenshot', 'rb') as f:
    f.seek($offset)
    sys.stdout.buffer.write(f.read($length))
" | curl -s -X "$method" "${header_arguments[@]}" --data-binary @- "$url" > /dev/null
    done

    checksum="$(md5 -q "$screenshot")"
    committed="$(bash "$API_SCRIPT" PATCH "/v1/appScreenshots/$screenshot_id" "$(jq -n \
      --arg id "$screenshot_id" --arg checksum "$checksum" \
      '{data: {type: "appScreenshots", id: $id, attributes: {uploaded: true, sourceFileChecksum: $checksum}}}')" 2>/dev/null)"
    state="$(echo "$committed" | jq -r '.data.attributes.assetDeliveryState.state')"
    echo "--- $locale / $file_name : $state"
  done < <(find "$locale_directory" -name '*.png' | sort)
done
