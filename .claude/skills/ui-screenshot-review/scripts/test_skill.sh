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

echo "=== ui-screenshot-review テスト ==="

# スクリプト存在・実行権限
check "run_maestro_screenshots.sh が存在する" test -f "$SCRIPT_DIR/run_maestro_screenshots.sh"
check "run_maestro_screenshots.sh に実行権限がある" test -x "$SCRIPT_DIR/run_maestro_screenshots.sh"

# Maestroフローファイル存在
check "capture_all_previews.yaml が存在する" test -f "$PROJECT_ROOT/maestro/flows/capture_all_previews.yaml"

# screenshotsディレクトリ存在（またはフロー実行で作成される）
check "maestro/screenshots ディレクトリが存在する" test -d "$PROJECT_ROOT/maestro/screenshots"

# Maestro CLI利用可能
check "maestro CLI が利用可能" command -v maestro

# SKILL.md フロントマター検証
check "SKILL.md に name フィールドがある" grep -q "^name:" "$SKILL_DIR/SKILL.md"
check "SKILL.md に description フィールドがある" grep -q "^description:" "$SKILL_DIR/SKILL.md"
check "SKILL.md に allowed-tools がある" grep -q "allowed-tools:" "$SKILL_DIR/SKILL.md"

echo ""
echo "結果: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
