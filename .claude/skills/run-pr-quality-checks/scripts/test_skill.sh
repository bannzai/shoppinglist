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

echo "=== run-pr-quality-checks テスト ==="

# スクリプト存在
check "run_quality_checks.sh が存在する" test -f "$SCRIPT_DIR/run_quality_checks.sh"

# --help が終了コード0で動作する
check "run_quality_checks.sh --help → 終了コード0" bash "$SCRIPT_DIR/run_quality_checks.sh" --help

# 依存スキルのスクリプト存在
check "check-coding-conventions/scripts/run_check_conventions.sh が存在する" \
  test -f "$SKILL_DIR/../check-coding-conventions/scripts/run_check_conventions.sh"
check "fix-pr-reviews/scripts/run_fix_reviews.sh が存在する" \
  test -f "$SKILL_DIR/../fix-pr-reviews/scripts/run_fix_reviews.sh"

# 共有スクリプト存在
check "_shared/scripts/discover_prs.sh が存在する" test -f "$SKILL_DIR/../_shared/scripts/discover_prs.sh"

# 外部コマンド利用可能
check "gh CLI が利用可能" command -v gh
check "jq が利用可能" command -v jq

echo ""
echo "結果: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
