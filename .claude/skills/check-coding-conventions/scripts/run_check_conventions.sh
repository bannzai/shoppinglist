#!/usr/bin/env bash
set -euo pipefail

# run_check_conventions.sh - コーディング規約チェック実行スクリプト
#
# 使い方:
#   bash run_check_conventions.sh --pr <number>
#
# 前提:
#   - ccnipre コマンドが PATH に通っている
#   - gh CLI でリポジトリにアクセス可能

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPT_DIR="./tmp/check-conventions/prompts"
LOG_DIR="./tmp/check-conventions/logs"
PR_NUMBER=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --pr) PR_NUMBER="$2"; shift 2 ;;
    -h|--help)
      echo "使い方: $0 --pr <number>"
      exit 0
      ;;
    *) echo "不明な引数: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$PR_NUMBER" ]; then
  echo "エラー: --pr <number> を指定してください" >&2
  exit 1
fi

# プロンプト生成
echo "プロンプトファイルを生成中..."
bash "${SCRIPT_DIR}/generate_check_prompt.sh" --pr "$PR_NUMBER" --output "$PROMPT_DIR"

prompt_path="${PROMPT_DIR}/check_pr_${PR_NUMBER}.txt"
if [ ! -f "$prompt_path" ]; then
  echo "エラー: プロンプトファイルが見つかりません: $prompt_path" >&2
  exit 1
fi

# ログ準備
mkdir -p "$LOG_DIR"
ts=$(date +"%Y%m%d_%H%M%S")
log_file="${LOG_DIR}/check_pr_${PR_NUMBER}_${ts}.log"

echo "=========================================="
echo "PR #${PR_NUMBER} のコーディング規約チェックを実行中"
echo "=========================================="

# ccnipre で実行
ccnipre -f "$prompt_path" 2>&1 | tee "$log_file"

echo "=========================================="
echo "コーディング規約チェック完了"
echo "=========================================="
