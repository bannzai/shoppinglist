#!/usr/bin/env bash
# 全手動チェックポイントを表示する
# Usage: manual_checkpoints.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

cat "${SKILL_DIR}/references/manual-checkpoints.md"
