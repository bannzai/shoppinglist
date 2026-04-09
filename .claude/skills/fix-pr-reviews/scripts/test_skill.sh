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

echo "=== fix-pr-reviews テスト ==="

# スクリプト存在
check "run_fix_reviews.sh が存在する" test -f "$SCRIPT_DIR/run_fix_reviews.sh"
check "generate_review_prompt.sh が存在する" test -f "$SCRIPT_DIR/generate_review_prompt.sh"

# --help が終了コード0で動作する
check "run_fix_reviews.sh --help → 終了コード0" bash "$SCRIPT_DIR/run_fix_reviews.sh" --help
check "generate_review_prompt.sh --help → 終了コード0" bash "$SCRIPT_DIR/generate_review_prompt.sh" --help

# references存在
check "references/prompt_template.md が存在する" test -f "$SKILL_DIR/references/prompt_template.md"
check "references/review-evaluation-guide.md が存在する" test -f "$SKILL_DIR/references/review-evaluation-guide.md"
check "references/common_rules.md が存在する" test -f "$SKILL_DIR/references/common_rules.md"
check "references/reply.graphql が存在する" test -f "$SKILL_DIR/references/reply.graphql"
check "references/resolve.graphql が存在する" test -f "$SKILL_DIR/references/resolve.graphql"

# 共有スクリプト存在
check "_shared/scripts/discover_prs.sh が存在する" test -f "$SKILL_DIR/../_shared/scripts/discover_prs.sh"

# 外部コマンド利用可能
check "gh CLI が利用可能" command -v gh
check "jq が利用可能" command -v jq
check "ccnipre が利用可能" command -v ccnipre

echo ""
echo "結果: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
