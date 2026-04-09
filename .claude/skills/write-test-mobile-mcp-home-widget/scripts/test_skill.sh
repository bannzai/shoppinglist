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

echo "=== write-test-mobile-mcp-home-widget テスト ==="

# SKILL.md フロントマター検証
check "SKILL.md に name フィールドがある" grep -q "^name:" "$SKILL_DIR/SKILL.md"
check "SKILL.md に description フィールドがある" grep -q "^description:" "$SKILL_DIR/SKILL.md"

# 外部コマンド利用可能
check "xcrun が利用可能" command -v xcrun
check "flutter が利用可能" command -v flutter

echo ""
echo "結果: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
