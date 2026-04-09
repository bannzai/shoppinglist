#!/bin/bash
set -euo pipefail

# UI競合調査の出力先ディレクトリを準備する

PROJECT_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== UI Competitive Research ディレクトリ準備 ==="

mkdir -p .local/ui-research/references
mkdir -p .local/ui-research/analysis

echo "出力先ディレクトリを作成しました:"
echo "  .local/ui-research/references/  — 競合アプリのスクリーンショット"
echo "  .local/ui-research/analysis/     — 分析結果・改善プラン"

# 自アプリのスクリーンショットディレクトリの存在確認
if [ -d ".local/screenshots" ]; then
    SCREENSHOT_COUNT=$(ls .local/screenshots/*.png 2>/dev/null | wc -l | tr -d ' ')
    echo ""
    echo "自アプリのスクリーンショット: ${SCREENSHOT_COUNT}枚 (.local/screenshots/)"
else
    echo ""
    echo "注意: 自アプリのスクリーンショットがありません (.local/screenshots/)"
    echo "  ui-screenshot-review スキルで撮影してください"
fi

echo ""
echo "=== 準備完了 ==="
