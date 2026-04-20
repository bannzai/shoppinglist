#!/usr/bin/env bash
# iap-orchestrator 共通ライブラリ

set -euo pipefail

readonly ORCH_PRODUCT_ID_REGEX='^[a-z][a-z0-9]*_[0-9]+yen_(1month|6month|1year|consumable|lifetime)$'
# 本 Skill はプロジェクト固有 (.claude/skills/) に配置されている前提で、隣接 Skill を相対パスで参照
readonly _ORCH_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly _SKILLS_ROOT="$(cd "${_ORCH_SCRIPT_DIR}/../.." && pwd)"
readonly RC_SETUP_SKILL="${_SKILLS_ROOT}/revenuecat-setup/scripts"
readonly ASC_IAP_SKILL="${_SKILLS_ROOT}/app-store-connect-iap/scripts"
readonly PLAY_IAP_SKILL="${_SKILLS_ROOT}/google-play-iap/scripts"

# Product ID を組み立てる
# Usage: build_product_id "shoppinglist" 480 "1month"  → shoppinglist_480yen_1month
build_product_id() {
  local project="$1"
  local price="$2"
  local type="$3"
  printf '%s_%dyen_%s' "$project" "$price" "$type"
}

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    printf 'Error: jq is required. Install with `brew install jq`.\n' >&2
    exit 1
  fi
}

# 全 Skill が必要とする環境変数を 1 度にチェック
require_all_env() {
  local missing=0
  for var in ASC_KEY_P8_BASE64 ASC_KEY_ID ASC_ISSUER_ID GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64 REVENUECAT_V2_SECRET_KEY REVENUECAT_PROJECT_ID; do
    if [[ -z "${!var:-}" ]]; then
      printf 'Missing env var: %s\n' "$var" >&2
      missing=1
    fi
  done
  if [[ $missing -eq 1 ]]; then
    exit 1
  fi
}

# config から各 Product ID を生成
# Usage: list_product_ids config.json
list_product_ids() {
  local config="$1"
  local project
  project=$(jq -r '.project' "$config")
  jq -r --arg p "$project" '.products[] | "\($p)_\(.price_jp)yen_\(.type)"' "$config"
}

# product type 判定
# Subscription type: 1month / 6month / 1year
is_subscription_type() {
  case "$1" in
    1month|6month|1year) return 0 ;;
    *) return 1 ;;
  esac
}

# IAP V2 type: lifetime / consumable
is_iap_v2_type() {
  case "$1" in
    lifetime|consumable) return 0 ;;
    *) return 1 ;;
  esac
}
