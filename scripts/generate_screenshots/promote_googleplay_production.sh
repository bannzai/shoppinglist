#!/usr/bin/env bash
# =============================================================================
# スクリプト名: promote_googleplay_production.sh
# 用途:
#   internal トラックにある最新の versionCode を production トラックへ昇格し、
#   審査へ提出する。flutter-deploy が internal までアップロードした後に実行する。
# 使い方:
#   bash scripts/generate_screenshots/promote_googleplay_production.sh [-v VERSION_CODE] [-n RELEASE_NAME]
# 引数:
#   -v VERSION_CODE : 昇格する versionCode。省略時は internal トラックの最大値
#   -n RELEASE_NAME : リリース名。省略時は pubspec.yaml の version から組み立てる
# 環境変数 (必須):
#   GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64 : サービスアカウント JSON (base64)
# 標準出力:
#   昇格した versionCode と commit した edit の ID
# 終了コード:
#   0 成功 / 1 internal に対象が無い・API エラー
# 依存コマンド:
#   bash, curl, jq
# =============================================================================
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPOSITORY_ROOT"

readonly PACKAGE_NAME="com.bannzai.shoppinglist"
readonly API_HOST="https://androidpublisher.googleapis.com"

# 初回公開は段階的公開にせず全ユーザーへ出す。
readonly RELEASE_STATUS="completed"

VERSION_CODE=""
RELEASE_NAME=""

while getopts "v:n:" option; do
  case "$option" in
    v) VERSION_CODE="$OPTARG" ;;
    n) RELEASE_NAME="$OPTARG" ;;
    *)
      echo "使い方: $0 [-v VERSION_CODE] [-n RELEASE_NAME]" >&2
      exit 2
      ;;
  esac
done

if [ -z "${GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64:-}" ]; then
  echo "[NG] GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64 が未設定" >&2
  exit 1
fi

access_token="$(PLAY_SA_JSON_BASE64="$GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64" \
  bash "$HOME/.claude/skills/googleplay-in-app-purchase/scripts/play_token.sh")"

edit_id="$(curl -s -X POST -H "Authorization: Bearer $access_token" \
  -H 'Content-Type: application/json' \
  "$API_HOST/androidpublisher/v3/applications/$PACKAGE_NAME/edits" -d '{}' | jq -r '.id')"
if [ -z "$edit_id" ] || [ "$edit_id" = "null" ]; then
  echo "[NG] edit を作成できなかった" >&2
  exit 1
fi

if [ -z "$VERSION_CODE" ]; then
  VERSION_CODE="$(curl -s -H "Authorization: Bearer $access_token" \
    "$API_HOST/androidpublisher/v3/applications/$PACKAGE_NAME/edits/$edit_id/tracks/internal" \
    | jq -r '[.releases[].versionCodes[]?] | map(tonumber) | max // empty')"
fi
if [ -z "$VERSION_CODE" ]; then
  echo "[NG] internal トラックに versionCode が無い。先に flutter-deploy を実行する" >&2
  exit 1
fi

if [ -z "$RELEASE_NAME" ]; then
  RELEASE_NAME="$(grep '^version:' pubspec.yaml | sed 's/version: *\([^+]*\).*/\1/' | tr -d ' ')"
fi

echo "--- production へ昇格: versionCode=$VERSION_CODE name=$RELEASE_NAME"

update_response="$(curl -s -X PUT -H "Authorization: Bearer $access_token" \
  -H 'Content-Type: application/json' \
  "$API_HOST/androidpublisher/v3/applications/$PACKAGE_NAME/edits/$edit_id/tracks/production" \
  --data-binary "$(jq -n \
    --arg name "$RELEASE_NAME" \
    --arg status "$RELEASE_STATUS" \
    --argjson versionCode "$VERSION_CODE" \
    '{track: "production", releases: [{name: $name, versionCodes: [$versionCode|tostring], status: $status}]}')")"
if ! echo "$update_response" | jq -e '.track' > /dev/null 2>&1; then
  echo "[NG] production トラックの更新に失敗: $(echo "$update_response" | jq -c '.error.message // .')" >&2
  exit 1
fi

commit_response="$(curl -s -X POST -H "Authorization: Bearer $access_token" \
  -H 'Content-Type: application/json' \
  "$API_HOST/androidpublisher/v3/applications/$PACKAGE_NAME/edits/$edit_id:commit" -d '{}')"
if ! echo "$commit_response" | jq -e '.id' > /dev/null 2>&1; then
  echo "[NG] edit の commit に失敗: $(echo "$commit_response" | jq -c '.error.message // .')" >&2
  exit 1
fi
echo "--- commit 完了: $(echo "$commit_response" | jq -r '.id')"
