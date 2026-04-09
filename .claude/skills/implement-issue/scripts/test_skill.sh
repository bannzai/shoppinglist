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

echo "=== implement-issue テスト ==="

# スクリプト存在
check "run_implement_issues.sh が存在する" test -f "$SCRIPT_DIR/run_implement_issues.sh"
check "generate_issue_prompts.sh が存在する" test -f "$SCRIPT_DIR/generate_issue_prompts.sh"

# スクリプト実行権限
check "run_implement_issues.sh に実行権限がある" test -x "$SCRIPT_DIR/run_implement_issues.sh"
check "generate_issue_prompts.sh に実行権限がある" test -x "$SCRIPT_DIR/generate_issue_prompts.sh"

# references存在
check "references/prompt_template.md が存在する" test -f "$SKILL_DIR/references/prompt_template.md"
check "references/coding_review_prompt.md が存在する" test -f "$SKILL_DIR/references/coding_review_prompt.md"
check "references/common_rules.md が存在する" test -f "$SKILL_DIR/references/common_rules.md"

# 引数なしで run_implement_issues.sh → config必須でエラー終了
check "run_implement_issues.sh 引数なし → 終了コード1" bash -c "! bash $SCRIPT_DIR/run_implement_issues.sh 2>&1"

# 外部コマンド利用可能
check "gh CLI が利用可能" command -v gh
check "jq が利用可能" command -v jq

echo ""
echo "結果: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
