#!/usr/bin/env bash
set -euo pipefail

# run_quality_checks.sh - PR品質チェックバッチ実行スクリプト
#
# 使い方:
#   bash run_quality_checks.sh 177 178 179                                  # 全スキル実行
#   bash run_quality_checks.sh --skills check-coding-conventions 177 178    # 規約チェックのみ
#   bash run_quality_checks.sh --skills fix-pr-reviews 177                  # レビュー対応のみ
#   bash run_quality_checks.sh --base <branch>                              # ベースブランチ指定
#   bash run_quality_checks.sh --base <branch> --dry-run                    # 対象確認のみ

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
SHARED_SCRIPTS="${SKILLS_ROOT}/_shared/scripts"
CHECK_CONVENTIONS_SCRIPT="${SKILLS_ROOT}/check-coding-conventions/scripts/run_check_conventions.sh"
FIX_REVIEWS_SCRIPT="${SKILLS_ROOT}/fix-pr-reviews/scripts/run_fix_reviews.sh"

LOG_DIR="./tmp/pr-quality-checks/logs"
STATUS_FILE="./tmp/pr-quality-checks/status.json"
SKILLS_FILTER=""
BASE_BRANCH=""
DRY_RUN=false
PR_NUMBERS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --skills) SKILLS_FILTER="$2"; shift 2 ;;
    --base) BASE_BRANCH="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help)
      echo "使い方: $0 [--skills <skill_name>] [--base <branch> | <pr_numbers...>] [--dry-run]"
      echo ""
      echo "オプション:"
      echo "  --skills <name>  実行するスキル (check-coding-conventions / fix-pr-reviews)"
      echo "                   省略時: 両方実行"
      echo "  --base <branch>  ベースブランチ指定でマージ済みPRを自動検出"
      echo "  --dry-run        対象PRの一覧を表示して終了"
      exit 0
      ;;
    *) PR_NUMBERS+=("$1"); shift ;;
  esac
done

if [ -n "$BASE_BRANCH" ]; then
  discover_args=(--base "$BASE_BRANCH")
  if [ "$DRY_RUN" = true ]; then
    discover_args+=(--dry-run)
    bash "$SHARED_SCRIPTS/discover_prs.sh" "${discover_args[@]}"
    exit 0
  fi

  pr_json=$(bash "$SHARED_SCRIPTS/discover_prs.sh" "${discover_args[@]}")
  mapfile -t PR_NUMBERS < <(echo "$pr_json" | jq -r '.[].number')

  if [ ${#PR_NUMBERS[@]} -eq 0 ]; then
    echo "対象PRが見つかりませんでした (base: $BASE_BRANCH)"
    exit 0
  fi

  echo "ベースブランチ $BASE_BRANCH から ${#PR_NUMBERS[@]} 件のPRを検出:"
  echo "$pr_json" | jq -r '.[] | "  #\(.number) \(.title)"'
  echo ""

  # ベースブランチ用ステータスファイル（スラッシュをアンダースコアに変換）
  SAFE_BRANCH_NAME=$(echo "$BASE_BRANCH" | tr '/' '_')
  STATUS_FILE="./tmp/pr-quality-checks/status_${SAFE_BRANCH_NAME}.json"
elif [ ${#PR_NUMBERS[@]} -eq 0 ]; then
  echo "エラー: PR番号を1つ以上指定するか --base <branch> を指定してください" >&2
  echo "使い方: $0 [--skills <skill_name>] [--base <branch> | <pr_numbers...>] [--dry-run]" >&2
  exit 1
fi

# 依存スクリプトの存在確認
for script in "$CHECK_CONVENTIONS_SCRIPT" "$FIX_REVIEWS_SCRIPT"; do
  if [ ! -f "$script" ]; then
    echo "エラー: スクリプトが見つかりません: $script" >&2
    exit 1
  fi
done

mkdir -p "$LOG_DIR"

if [ ! -f "$STATUS_FILE" ]; then
  echo '{}' > "$STATUS_FILE"
fi

get_status() {
  jq -r --arg pr "$1" --arg skill "$2" '.[$pr][$skill].status // "pending"' "$STATUS_FILE"
}

update_status() {
  local pr_num="$1" skill_key="$2" status="$3"
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local tmp
  tmp=$(mktemp)
  jq --arg pr "$pr_num" --arg skill "$skill_key" --arg s "$status" --arg t "$timestamp" \
    'if .[$pr] == null then .[$pr] = {} else . end | .[$pr][$skill] = {status: $s, timestamp: $t}' \
    "$STATUS_FILE" > "$tmp"
  mv "$tmp" "$STATUS_FILE"
}

skill_enabled() {
  [ -z "$SKILLS_FILTER" ] || [ "$SKILLS_FILTER" = "$1" ]
}

run_check_conventions() {
  local pr_num="$1"
  local ts
  ts=$(date +"%Y%m%d_%H%M%S")
  local log_file="${LOG_DIR}/check_conventions_pr_${pr_num}_${ts}.log"

  echo "PR #${pr_num}: コーディング規約チェック実行中"
  update_status "$pr_num" "check_conventions" "in_progress"

  set +e
  bash "$CHECK_CONVENTIONS_SCRIPT" --pr "$pr_num" 2>&1 | tee "$log_file"
  local exit_code=$?
  set -e

  if [ $exit_code -ne 0 ]; then
    update_status "$pr_num" "check_conventions" "failed"
    echo "PR #${pr_num}: コーディング規約チェック失敗（ログ: ${log_file}）"
    return 1
  fi

  update_status "$pr_num" "check_conventions" "completed"
  echo "PR #${pr_num}: コーディング規約チェック完了"
  return 0
}

run_fix_reviews() {
  local pr_num="$1"
  local ts
  ts=$(date +"%Y%m%d_%H%M%S")
  local log_file="${LOG_DIR}/fix_reviews_pr_${pr_num}_${ts}.log"

  echo "PR #${pr_num}: レビューコメント対応実行中"
  update_status "$pr_num" "fix_reviews" "in_progress"

  set +e
  bash "$FIX_REVIEWS_SCRIPT" --pr "$pr_num" 2>&1 | tee "$log_file"
  local exit_code=$?
  set -e

  if [ $exit_code -ne 0 ]; then
    update_status "$pr_num" "fix_reviews" "failed"
    echo "PR #${pr_num}: レビューコメント対応失敗（ログ: ${log_file}）"
    return 1
  fi

  update_status "$pr_num" "fix_reviews" "completed"
  echo "PR #${pr_num}: レビューコメント対応完了"
  return 0
}

# メインループ
for pr_num in "${PR_NUMBERS[@]}"; do
  echo "=========================================="
  echo "PR #${pr_num} の品質チェック開始"
  echo "=========================================="

  if skill_enabled "check-coding-conventions"; then
    current_status=$(get_status "$pr_num" "check_conventions")
    if [ "$current_status" = "completed" ]; then
      echo "PR #${pr_num}: check_conventions 完了済み、スキップ"
    else
      run_check_conventions "$pr_num" || true
    fi
  fi

  if skill_enabled "fix-pr-reviews"; then
    current_status=$(get_status "$pr_num" "fix_reviews")
    if [ "$current_status" = "completed" ]; then
      echo "PR #${pr_num}: fix_reviews 完了済み、スキップ"
    else
      run_fix_reviews "$pr_num" || true
    fi
  fi

  echo ""
done

echo "=========================================="
echo "PR品質チェック完了サマリ:"
jq -r 'to_entries[] | "  #\(.key): " + ([.value | to_entries[] | "\(.key)=\(.value.status)"] | join(", "))' "$STATUS_FILE"
echo "=========================================="
