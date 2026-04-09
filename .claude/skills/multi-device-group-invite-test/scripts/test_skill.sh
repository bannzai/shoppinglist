#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(cd "$SKILL_DIR/../../../" && pwd)"

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

echo "=== multi-device-group-invite-test テスト ==="

# スクリプト存在・実行権限
check "setup_devices.sh が存在する" test -f "$SCRIPT_DIR/setup_devices.sh"
check "setup_devices.sh に実行権限がある" test -x "$SCRIPT_DIR/setup_devices.sh"

# Maestroテストスクリプト存在
check "maestro/scripts/run_group_sync_test.sh が存在する" test -f "$PROJECT_ROOT/maestro/scripts/run_group_sync_test.sh"

# 外部コマンド利用可能
check "xcrun が利用可能" command -v xcrun
check "flutter が利用可能" command -v flutter
check "maestro が利用可能" command -v maestro

# iOS Simulator が利用可能（iPhone 16 Plus）
check "iPhone 16 Plus ランタイムが存在する" xcrun simctl list devices | grep -q "iPhone 16 Plus"

echo ""
echo "結果: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
