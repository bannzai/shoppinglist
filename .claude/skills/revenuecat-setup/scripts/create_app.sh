#!/usr/bin/env bash
# RevenueCat に App を作成する
# Usage:
#   create_app.sh --type app_store --bundle-id com.foo.bar --name "Foo App"
#   create_app.sh --type play_store --package-name com.foo.bar --name "Foo App (Android)"
#   create_app.sh --type app_store --bundle-id com.foo.bar --name "Foo" --dry-run

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

APP_TYPE=""
BUNDLE_ID=""
PACKAGE_NAME=""
APP_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type) APP_TYPE="$2"; shift 2 ;;
    --bundle-id) BUNDLE_ID="$2"; shift 2 ;;
    --package-name) PACKAGE_NAME="$2"; shift 2 ;;
    --name) APP_NAME="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${APP_TYPE:?--type is required (app_store|play_store|amazon|mac_app_store|stripe|rc_billing|paddle)}"
: "${APP_NAME:?--name is required}"

case "$APP_TYPE" in
  app_store|mac_app_store)
    : "${BUNDLE_ID:?--bundle-id is required for $APP_TYPE}"
    body=$(jq -n --arg type "$APP_TYPE" --arg name "$APP_NAME" --arg bid "$BUNDLE_ID" \
      '{type: $type, name: $name, app_store: {bundle_id: $bid}}')
    ;;
  play_store|amazon)
    : "${PACKAGE_NAME:?--package-name is required for $APP_TYPE}"
    body=$(jq -n --arg type "$APP_TYPE" --arg name "$APP_NAME" --arg pn "$PACKAGE_NAME" \
      '{type: $type, name: $name, play_store: {package_name: $pn}}')
    ;;
  *)
    printf 'Unsupported app type: %s\n' "$APP_TYPE" >&2
    exit 1
    ;;
esac

response=$(rc_api_v2 POST "/projects/{project_id}/apps" "$body")
if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

app_id=$(printf '%s' "$response" | jq -r '.id // empty')

# 既存 App がある場合 (409 resource_already_exists) は GET /apps から該当 App の ID を取得して再利用
if [[ -z "$app_id" ]] && printf '%s' "$response" | jq -e '.type == "resource_already_exists"' >/dev/null 2>&1; then
  printf 'App already exists, looking up existing ID...\n' >&2
  list_response=$(rc_api_v2 GET "/projects/{project_id}/apps?limit=50")
  case "$APP_TYPE" in
    app_store|mac_app_store)
      app_id=$(printf '%s' "$list_response" | jq -r --arg bid "$BUNDLE_ID" \
        '.items[] | select(.type == "app_store" or .type == "mac_app_store") | select(.app_store.bundle_id == $bid) | .id' | head -1)
      ;;
    play_store|amazon)
      app_id=$(printf '%s' "$list_response" | jq -r --arg pn "$PACKAGE_NAME" \
        '.items[] | select(.type == "play_store" or .type == "amazon") | select(.play_store.package_name == $pn or .amazon.package_name == $pn) | .id' | head -1)
      ;;
  esac
  if [[ -n "$app_id" ]]; then
    printf 'Reusing existing App: id=%s name=%s type=%s\n' "$app_id" "$APP_NAME" "$APP_TYPE"
    exit 0
  fi
  printf 'Could not find existing app. List response: %s\n' "$list_response" >&2
  exit 1
fi

if [[ -z "$app_id" ]]; then
  printf 'Failed to create app. Response: %s\n' "$response" >&2
  exit 1
fi

printf 'Created App: id=%s name=%s type=%s\n' "$app_id" "$APP_NAME" "$APP_TYPE"

if [[ "$APP_TYPE" == "play_store" || "$APP_TYPE" == "amazon" ]]; then
  printf '\n[次の手動ステップ] Google Play Service Account JSON を Dashboard から手動アップロードしてください:\n'
  printf '  https://app.revenuecat.com/projects/%s/apps/%s\n' "$REVENUECAT_PROJECT_ID" "$app_id"
fi
