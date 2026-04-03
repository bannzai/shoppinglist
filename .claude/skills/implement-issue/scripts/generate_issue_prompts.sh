#!/usr/bin/env bash
set -euo pipefail

# generate_issue_prompts.sh - Issue別プロンプトファイル生成
# 使い方: bash generate_issue_prompts.sh --config ./implement_issues.json [--output ./tmp/implement-issue/prompts]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE=""
OUTPUT_DIR="./tmp/implement-issue/prompts"

while [[ $# -gt 0 ]]; do
  case $1 in
    --config) CONFIG_FILE="$2"; shift 2 ;;
    --output) OUTPUT_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "Usage: $0 --config <json_file> [--output <dir>]" >&2
  exit 1
fi

BASE_BRANCH=$(jq -r '.base_branch' "$CONFIG_FILE")
ISSUE_COUNT=$(jq '.issues | length' "$CONFIG_FILE")

mkdir -p "$OUTPUT_DIR"

TEMPLATE=$(cat "${SKILL_DIR}/references/prompt_template.md")
COMMON_RULES=$(cat "${SKILL_DIR}/references/common_rules.md")
COMMON_RULES="${COMMON_RULES//\{\{BASE_BRANCH\}\}/$BASE_BRANCH}"

for i in $(seq 0 $((ISSUE_COUNT - 1))); do
  num=$(jq -r ".issues[$i].number" "$CONFIG_FILE")
  priority=$(jq -r ".issues[$i].priority" "$CONFIG_FILE")
  slug=$(jq -r ".issues[$i].slug" "$CONFIG_FILE")
  title=$(jq -r ".issues[$i].title" "$CONFIG_FILE")

  prompt="$TEMPLATE"
  prompt="${prompt//\{\{ISSUE_NUMBER\}\}/$num}"
  prompt="${prompt//\{\{ISSUE_TITLE\}\}/$title}"
  prompt="${prompt//\{\{PRIORITY\}\}/$priority}"
  prompt="${prompt//\{\{BASE_BRANCH\}\}/$BASE_BRANCH}"
  prompt="${prompt//\{\{COMMON_RULES\}\}/$COMMON_RULES}"

  output_file="${OUTPUT_DIR}/issue_${num}_${slug}.txt"
  echo "$prompt" > "$output_file"
  echo "Generated: $output_file"
done

echo ""
echo "全 ${ISSUE_COUNT} 件のプロンプトを生成しました: $OUTPUT_DIR"
