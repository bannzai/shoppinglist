#!/usr/bin/env bash
set -euo pipefail

# generate_review_prompt.sh - レビューコメント対応用プロンプト生成
#
# 使い方:
#   bash generate_review_prompt.sh --pr <number>
#   bash generate_review_prompt.sh --pr <number> --output ./tmp/fix-reviews/prompts

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
REFERENCES_DIR="${SKILL_DIR}/references"
PR_NUMBER=""
OUTPUT_DIR="./tmp/fix-reviews/prompts"

while [[ $# -gt 0 ]]; do
  case $1 in
    --pr) PR_NUMBER="$2"; shift 2 ;;
    --output) OUTPUT_DIR="$2"; shift 2 ;;
    -h|--help)
      echo "使い方: $0 --pr <number> [--output <dir>]"
      exit 0
      ;;
    *) echo "不明な引数: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$PR_NUMBER" ]; then
  echo "エラー: --pr <number> を指定してください" >&2
  exit 1
fi

# PR情報取得
PR_JSON=$(gh pr view "$PR_NUMBER" --json number,title,headRefName,baseRefName,url,state)
HEAD_BRANCH=$(echo "$PR_JSON" | jq -r '.headRefName')
BASE_BRANCH=$(echo "$PR_JSON" | jq -r '.baseRefName')
PR_URL=$(echo "$PR_JSON" | jq -r '.url')

echo "PR #${PR_NUMBER}: ${HEAD_BRANCH} → ${BASE_BRANCH}"

# テンプレート・共通ルール読み込み
TEMPLATE_FILE="${REFERENCES_DIR}/prompt_template.md"
COMMON_RULES_FILE="${REFERENCES_DIR}/common_rules.md"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "エラー: ${TEMPLATE_FILE} が見つかりません" >&2
  exit 1
fi
if [[ ! -f "$COMMON_RULES_FILE" ]]; then
  echo "エラー: ${COMMON_RULES_FILE} が見つかりません" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# GraphQL ファイルパスを解決
REPLY_GRAPHQL_PATH="${SKILL_DIR}/references/reply.graphql"
RESOLVE_GRAPHQL_PATH="${SKILL_DIR}/references/resolve.graphql"

# プレースホルダ置換（Python3で安全に処理）
output_file="${OUTPUT_DIR}/review_pr_${PR_NUMBER}.txt"

python3 -c "
import sys

template = open(sys.argv[1]).read()
common_rules = open(sys.argv[2]).read()

replacements = {
    '{{PR_NUMBER}}': sys.argv[3],
    '{{HEAD_BRANCH}}': sys.argv[4],
    '{{BASE_BRANCH}}': sys.argv[5],
    '{{PR_URL}}': sys.argv[6],
    '{{REPLY_GRAPHQL_PATH}}': sys.argv[7],
    '{{RESOLVE_GRAPHQL_PATH}}': sys.argv[8],
}

for key, val in replacements.items():
    common_rules = common_rules.replace(key, val)

for key, val in replacements.items():
    template = template.replace(key, val)

template = template.replace('{{COMMON_RULES}}', common_rules)

with open(sys.argv[9], 'w') as f:
    f.write(template)
" "$TEMPLATE_FILE" "$COMMON_RULES_FILE" "$PR_NUMBER" "$HEAD_BRANCH" "$BASE_BRANCH" "$PR_URL" "$REPLY_GRAPHQL_PATH" "$RESOLVE_GRAPHQL_PATH" "$output_file"

echo "Generated: $output_file"
