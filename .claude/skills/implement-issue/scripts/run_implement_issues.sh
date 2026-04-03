#!/usr/bin/env bash
set -uo pipefail

# run_implement_issues.sh - Issue一括実装スクリプト
#
# 使い方:
#   bash run_implement_issues.sh --config ./implement_issues.json          # 全Issue順次実行
#   bash run_implement_issues.sh --config ./implement_issues.json 76 151  # 指定Issueのみ

PROMPT_DIR="./tmp/implement-issue/prompts"
LOG_DIR="./tmp/implement-issue/logs"
STATUS_FILE="./tmp/implement-issue/status.json"
CONFIG_FILE=""
TARGETS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --config) CONFIG_FILE="$2"; shift 2 ;;
    *) TARGETS+=("$1"); shift ;;
  esac
done

if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "Usage: $0 --config <json_file> [issue_numbers...]" >&2
  exit 1
fi

BASE_BRANCH=$(jq -r '.base_branch' "$CONFIG_FILE")
ISSUE_COUNT=$(jq '.issues | length' "$CONFIG_FILE")

mkdir -p "$LOG_DIR"

if [ ! -f "$STATUS_FILE" ]; then
  echo '{}' > "$STATUS_FILE"
fi

get_status() {
  jq -r --arg key "$1" '.[$key].status // "pending"' "$STATUS_FILE"
}

update_status() {
  local num="$1" status="$2" pr_url="${3:-}"
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local tmp
  tmp=$(mktemp)
  jq --arg k "$num" --arg s "$status" --arg t "$timestamp" --arg p "$pr_url" \
    '.[$k] = {status: $s, timestamp: $t, pr_url: $p}' "$STATUS_FILE" > "$tmp"
  mv "$tmp" "$STATUS_FILE"
}

should_run() {
  local num="$1"
  if [ ${#TARGETS[@]} -eq 0 ]; then
    return 0
  fi
  for t in "${TARGETS[@]}"; do
    if [ "$t" = "$num" ]; then
      return 0
    fi
  done
  return 1
}

run_issue() {
  local num="$1"
  local slug="$2"
  local prompt_path="${PROMPT_DIR}/issue_${num}_${slug}.txt"

  if [ ! -f "$prompt_path" ]; then
    echo "エラー: プロンプトファイルが見つかりません: $prompt_path" >&2
    return 1
  fi

  local current_status
  current_status=$(get_status "$num")
  if [ "$current_status" = "completed" ]; then
    echo "Issue #${num}: 完了済み、スキップ"
    return 0
  fi

  if gh pr list --repo bannzai/shoppinglist --head "feature/premium-issue-${num}" --json state --jq '.[0].state' 2>/dev/null | grep -q "OPEN"; then
    echo "Issue #${num}: PR既存、スキップ"
    update_status "$num" "completed"
    return 0
  fi

  echo "=========================================="
  echo "Issue #${num} を実装中"
  echo "=========================================="

  git checkout "$BASE_BRANCH"

  if [ -n "$(git status --porcelain)" ]; then
    echo "Warning: dirty working tree. Stashing..."
    git stash
  fi

  update_status "$num" "in_progress"

  local ts
  ts=$(date +"%Y%m%d_%H%M%S")
  local log_file="${LOG_DIR}/issue_${num}_${ts}.log"

  set +e
  ccnipre -P -f "$prompt_path" 2>&1 | tee "$log_file"
  local exit_code=$?
  set -e

  if [ $exit_code -eq 0 ]; then
    local pr_url
    pr_url=$(gh pr list --repo bannzai/shoppinglist --head "feature/premium-issue-${num}" --json url --jq '.[0].url' 2>/dev/null || echo "")
    update_status "$num" "completed" "$pr_url"
    echo "Issue #${num}: 完了 ${pr_url}"
  else
    update_status "$num" "failed"
    echo "Issue #${num}: 失敗（ログ: ${log_file}）"
  fi

  git checkout "$BASE_BRANCH" 2>/dev/null || true
  echo ""
}

# メインループ: JSONからIssueを読み込み
for i in $(seq 0 $((ISSUE_COUNT - 1))); do
  num=$(jq -r ".issues[$i].number" "$CONFIG_FILE")
  slug=$(jq -r ".issues[$i].slug" "$CONFIG_FILE")

  should_run "$num" || continue
  run_issue "$num" "$slug"
done

echo "=========================================="
echo "実装完了サマリ:"
jq -r 'to_entries[] | "  #\(.key): \(.value.status) \(.value.pr_url // "")"' "$STATUS_FILE"
echo "=========================================="
