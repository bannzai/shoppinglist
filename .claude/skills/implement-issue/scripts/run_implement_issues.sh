#!/usr/bin/env bash
set -uo pipefail

# run_implement_issues.sh - Issue一括実装スクリプト
#
# 使い方:
#   bash run_implement_issues.sh --config ./implement_issues.json          # 全Issue順次実行
#   bash run_implement_issues.sh --config ./implement_issues.json 76 151  # 指定Issueのみ
#
# 環境変数:
#   MAX_ROUNDS      fix-ai-review-loop の最大ラウンド数（デフォルト: 5）

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

# ADR-0005: base_branch が "main" の場合、中間ベースブランチを作成してJSONに書き戻す
if [ "$BASE_BRANCH" = "main" ]; then
  BASE_BRANCH="implement-issue-$(date +"%Y%m%d_%H%M%S")"
  echo "ベースブランチを作成: $BASE_BRANCH (from main)"
  git checkout main
  git pull origin main
  git checkout -b "$BASE_BRANCH"
  git push -u origin "$BASE_BRANCH"

  tmp_json=$(mktemp)
  jq --arg b "$BASE_BRANCH" '.base_branch = $b' "$CONFIG_FILE" > "$tmp_json"
  mv "$tmp_json" "$CONFIG_FILE"
  echo "implement_issues.json の base_branch を更新: $BASE_BRANCH"
fi

# [改善1] ベースブランチPRを先行作成
create_base_branch_pr() {
  local base_branch="$1"

  local existing_pr
  existing_pr=$(gh pr list --repo bannzai/shoppinglist --head "$base_branch" --base main --json url --jq '.[0].url' 2>/dev/null || echo "")
  if [ -n "$existing_pr" ]; then
    echo "ベースブランチPR既存: $existing_pr"
    return 0
  fi

  git checkout "$base_branch"
  git commit --allow-empty -m "chore: 一括実装開始 ($base_branch)"
  git push origin "$base_branch"

  local issue_list
  issue_list=$(jq -r '.issues[] | "- #\(.number) \(.title)"' "$CONFIG_FILE")

  gh pr create \
    --repo bannzai/shoppinglist \
    --base main \
    --head "$base_branch" \
    --title "一括実装: $(jq -r '.issues[0].title' "$CONFIG_FILE") 他" \
    --body "## 概要
一括実装ブランチ。各Issueのfeatureブランチがこのブランチにマージされます。

## 対象Issue
${issue_list}"

  echo "ベースブランチPR作成完了"
}

create_base_branch_pr "$BASE_BRANCH"

# プロンプトファイルを生成
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "プロンプトファイルを生成中..."
bash "${SCRIPT_DIR}/generate_issue_prompts.sh" --config "$CONFIG_FILE" --output "$PROMPT_DIR"

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

# [改善3] コーディング規約レビュー
run_coding_review() {
  local issue_num="$1"
  local base_branch="$2"
  local feature_branch="feature/premium-issue-${issue_num}"

  echo "コーディング規約レビュー: Issue #${issue_num}"
  git checkout "$feature_branch"

  local skill_dir
  skill_dir="$(dirname "$SCRIPT_DIR")"

  local review_prompt
  review_prompt=$(cat "${skill_dir}/references/coding_review_prompt.md")
  review_prompt="${review_prompt//\{\{ISSUE_NUMBER\}\}/$issue_num}"
  review_prompt="${review_prompt//\{\{BASE_BRANCH\}\}/$base_branch}"

  ccnipre -f <(echo "$review_prompt")
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

  # Phase A: plan → review → implement → commit → PR
  local ts
  ts=$(date +"%Y%m%d_%H%M%S")
  local log_file="${LOG_DIR}/issue_${num}_${ts}.log"

  set +e
  ccnipre -P -f "$prompt_path" 2>&1 | tee "$log_file"
  local exit_code=$?
  set -e

  if [ $exit_code -ne 0 ]; then
    update_status "$num" "failed"
    echo "Issue #${num}: 失敗（ログ: ${log_file}）"
    git checkout "$BASE_BRANCH" 2>/dev/null || true
    return 1
  fi

  # Phase B: コーディング規約レビュー
  run_coding_review "$num" "$BASE_BRANCH"

  # Phase C: Geminiレビュー反映（fix-ai-review-loop スクリプト使用）
  echo "Geminiレビュー反映: Issue #${num}"
  git checkout "feature/premium-issue-${num}"
  fix-ai-review-loop gemini || echo "Issue #${num}: Geminiレビュー反映が最大ラウンドに達しました"

  # Phase D: ベースブランチにマージ
  echo "Issue #${num}: ベースブランチ ($BASE_BRANCH) にマージ中..."
  git checkout "$BASE_BRANCH"
  if git merge --no-ff "feature/premium-issue-${num}" -m "Merge feature/premium-issue-${num} into ${BASE_BRANCH}"; then
    git push origin "$BASE_BRANCH"
    echo "Issue #${num}: マージ完了"
  else
    echo "Issue #${num}: マージコンフリクト発生。手動解決が必要です。" >&2
    git merge --abort
  fi

  local pr_url
  pr_url=$(gh pr list --repo bannzai/shoppinglist --head "feature/premium-issue-${num}" --json url --jq '.[0].url' 2>/dev/null || echo "")
  update_status "$num" "completed" "$pr_url"
  echo "Issue #${num}: 完了 ${pr_url}"

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
