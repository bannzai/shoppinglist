#!/usr/bin/env bash
# iap-orchestrator 共通ライブラリ

set -euo pipefail

readonly ORCH_PRODUCT_ID_REGEX='^[a-z][a-z0-9]*_[0-9]+yen_(1month|6month|1year|consumable|lifetime)$'
readonly RC_SETUP_SKILL="$HOME/.claude/skills/revenuecat-setup/scripts"
readonly ASC_IAP_SKILL="$HOME/.claude/skills/app-store-connect-iap/scripts"
readonly PLAY_IAP_SKILL="$HOME/.claude/skills/google-play-iap/scripts"

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
  for var in APP_STORE_CONNECT_KEY_BASE64 APP_STORE_CONNECT_KEY_ID APP_STORE_CONNECT_ISSUER_ID GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64 REVENUECAT_V2_SECRET_KEY REVENUECAT_PROJECT_ID; do
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
