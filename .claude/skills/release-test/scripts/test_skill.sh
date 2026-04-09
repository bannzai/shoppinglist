#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

PASS=0
FAIL=0

check() {
  local desc="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "✓ $desc"
    PASS=$((PASS + 1))
  else
    echo "✗ $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== release-test テスト ==="

# スクリプト存在
check "generate_section_prompts.sh が存在する" test -f "$SCRIPT_DIR/generate_section_prompts.sh"
check "run_qa.sh が存在する" test -f "$SCRIPT_DIR/run_qa.sh"

# --help が終了コード0で動作する
check "generate_section_prompts.sh --help → 終了コード0" bash "$SCRIPT_DIR/generate_section_prompts.sh" --help
check "run_qa.sh --help → 終了コード0" bash "$SCRIPT_DIR/run_qa.sh" --help

# references存在
check "references/common_rules.md が存在する" test -f "$SKILL_DIR/references/common_rules.md"
check "references/section_prompt_template.md が存在する" test -f "$SKILL_DIR/references/section_prompt_template.md"

# 外部コマンド利用可能
check "gh CLI が利用可能" command -v gh
check "ccnipre が利用可能" command -v ccnipre

echo ""
echo "結果: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
