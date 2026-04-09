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

echo "=== check-coding-conventions テスト ==="

# スクリプト存在
check "run_check_conventions.sh が存在する" test -f "$SCRIPT_DIR/run_check_conventions.sh"
check "generate_check_prompt.sh が存在する" test -f "$SCRIPT_DIR/generate_check_prompt.sh"

# --help が終了コード0で動作する
check "run_check_conventions.sh --help → 終了コード0" bash "$SCRIPT_DIR/run_check_conventions.sh" --help
check "generate_check_prompt.sh --help → 終了コード0" bash "$SCRIPT_DIR/generate_check_prompt.sh" --help

# references存在
check "references/prompt_template.md が存在する" test -f "$SKILL_DIR/references/prompt_template.md"
check "references/convention-checklist.md が存在する" test -f "$SKILL_DIR/references/convention-checklist.md"
check "references/common_rules.md が存在する" test -f "$SKILL_DIR/references/common_rules.md"

# 共有スクリプト存在
check "_shared/scripts/discover_prs.sh が存在する" test -f "$SKILL_DIR/../_shared/scripts/discover_prs.sh"

# 外部コマンド利用可能
check "gh CLI が利用可能" command -v gh
check "jq が利用可能" command -v jq
check "ccnipre が利用可能" command -v ccnipre

echo ""
echo "結果: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
