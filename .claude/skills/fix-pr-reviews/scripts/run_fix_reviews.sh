#!/usr/bin/env bash
set -euo pipefail

# run_fix_reviews.sh - レビューコメント対応実行スクリプト
#
# 使い方:
#   bash run_fix_reviews.sh --pr <number>
#   bash run_fix_reviews.sh <number>                  # 位置引数も可
#   bash run_fix_reviews.sh --base <branch>           # 一括実行
#   bash run_fix_reviews.sh --base <branch> --dry-run # 対象確認のみ
#
# 前提:
#   - ccnipre コマンドが PATH に通っている
#   - gh CLI でリポジトリにアクセス可能
#   - gh-pr-comments コマンドが PATH に通っている

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHARED_SCRIPTS="$(dirname "$(dirname "$SCRIPT_DIR")")/_shared/scripts"
PROMPT_DIR="./tmp/fix-reviews/prompts"
LOG_DIR="./tmp/fix-reviews/logs"
PR_NUMBER=""
BASE_BRANCH=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --pr) PR_NUMBER="$2"; shift 2 ;;
    --base) BASE_BRANCH="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help)
      echo "使い方: $0 --pr <number> | --base <branch> [--dry-run]"
      exit 0
      ;;
    *)
      # 数字なら PR_NUMBER として扱う（後方互換）
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        PR_NUMBER="$1"; shift
      else
        echo "不明な引数: $1" >&2; exit 1
      fi
      ;;
  esac
done

# --base モード: 未解決コメントがあるPRを一括実行
if [ -n "$BASE_BRANCH" ]; then
  discover_args=(--base "$BASE_BRANCH" --require-unresolved-comments)
  if [ "$DRY_RUN" = true ]; then
    discover_args+=(--dry-run)
    bash "$SHARED_SCRIPTS/discover_prs.sh" "${discover_args[@]}"
    exit 0
  fi

  pr_json=$(bash "$SHARED_SCRIPTS/discover_prs.sh" "${discover_args[@]}")
  mapfile -t pr_numbers < <(echo "$pr_json" | jq -r '.[].number')

  if [ ${#pr_numbers[@]} -eq 0 ]; then
    echo "未解決レビューコメントを持つPRが見つかりませんでした (base: $BASE_BRANCH)"
    exit 0
  fi

  echo "ベースブランチ $BASE_BRANCH から ${#pr_numbers[@]} 件のPRを検出（未解決コメントあり）:"
  echo "$pr_json" | jq -r '.[] | "  #\(.number) \(.title) (未解決: \(.unresolvedCount)件)"'
  echo ""

  for pr_num in "${pr_numbers[@]}"; do
    echo "=========================================="
    echo "PR #${pr_num} のレビューコメント対応"
    echo "=========================================="

    bash "${SCRIPT_DIR}/generate_review_prompt.sh" --pr "$pr_num" --output "$PROMPT_DIR"
    prompt_path="${PROMPT_DIR}/review_pr_${pr_num}.txt"

    if [ ! -f "$prompt_path" ]; then
      echo "エラー: プロンプトファイルが見つかりません: $prompt_path" >&2
      continue
    fi

    mkdir -p "$LOG_DIR"
    ts=$(date +"%Y%m%d_%H%M%S")
    log_file="${LOG_DIR}/review_pr_${pr_num}_${ts}.log"

    set +e
    ccnipre -f "$prompt_path" 2>&1 | tee "$log_file"
    set -e

    echo ""
  done

  exit 0
fi

# 単一PRモード
if [ -z "$PR_NUMBER" ]; then
  echo "エラー: --pr <number> または --base <branch> を指定してください" >&2
  exit 1
fi

# プロンプト生成
echo "プロンプトファイルを生成中..."
bash "${SCRIPT_DIR}/generate_review_prompt.sh" --pr "$PR_NUMBER" --output "$PROMPT_DIR"

prompt_path="${PROMPT_DIR}/review_pr_${PR_NUMBER}.txt"
if [ ! -f "$prompt_path" ]; then
  echo "エラー: プロンプトファイルが見つかりません: $prompt_path" >&2
  exit 1
fi

# ログ準備
mkdir -p "$LOG_DIR"
ts=$(date +"%Y%m%d_%H%M%S")
log_file="${LOG_DIR}/review_pr_${PR_NUMBER}_${ts}.log"

echo "=========================================="
echo "PR #${PR_NUMBER} のレビューコメント対応を実行中"
echo "=========================================="

# ccnipre で実行
ccnipre -f "$prompt_path" 2>&1 | tee "$log_file"

echo "=========================================="
echo "レビューコメント対応完了"
echo "=========================================="
