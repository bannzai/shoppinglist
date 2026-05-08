#!/usr/bin/env bash
# Subscription をレビュー提出する（2 回目以降）
# 初回 Subscription はバイナリ提出と同時の Web 操作が必須
# Usage: submit_subscription.sh --subscription-id SUB_ID

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/_common.sh"

require_jq

SUB_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --subscription-id) SUB_ID="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

: "${SUB_ID:?--subscription-id is required}"

body=$(jq -n --arg sid "$SUB_ID" \
  '{data: {type: "subscriptionSubmissions", relationships: {subscription: {data: {type: "subscriptions", id: $sid}}}}}')

JWT_TOKEN=$(generate_jwt)
export JWT_TOKEN

printf 'Submitting subscription %s for review\n' "$SUB_ID"
response=$(asc_api POST "/v1/subscriptionSubmissions" "$body")

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  exit 0
fi

sub_submission_id=$(printf '%s' "$response" | jq -r '.data.id // empty')
if [[ -z "$sub_submission_id" ]]; then
  printf 'Failed. Response: %s\n' "$response" >&2
  printf '\nNote: 初回 Subscription はバイナリ提出と一緒に App Store Connect Web から提出する必要があります。\n' >&2
  exit 1
fi
printf '  → submitted: id=%s\n' "$sub_submission_id"
printf '\n[次のステップ] State を polling: GET /v1/subscriptions/%s\n' "$SUB_ID"
