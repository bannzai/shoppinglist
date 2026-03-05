#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$PROJECT_ROOT"

SCREENSHOT_DIR="maestro/screenshots"
FLOW_FILE="maestro/flows/capture_all_previews.yaml"
DEVICE_NAME="iPhone 16 Pro"
ENTRY_POINT="lib/features/previews/main_preview.dart"

echo "=== UI Screenshot Review ==="
echo "Project root: $PROJECT_ROOT"

# スクリーンショットディレクトリをクリーン
rm -rf "$SCREENSHOT_DIR"
mkdir -p "$SCREENSHOT_DIR"

# iOSシミュレータを起動 (既に起動中なら何もしない)
echo "--- シミュレータを確認中..."
DEVICE_ID=$(xcrun simctl list devices booted --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    for d in devices:
        if d.get('state') == 'Booted':
            print(d['udid'])
            sys.exit(0)
" 2>/dev/null || true)

if [ -z "$DEVICE_ID" ]; then
    echo "--- シミュレータが起動していません。起動します..."
    DEVICE_ID=$(xcrun simctl list devices available --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS' in runtime:
        for d in devices:
            if '${DEVICE_NAME}' in d.get('name', ''):
                print(d['udid'])
                sys.exit(0)
")
    xcrun simctl boot "$DEVICE_ID"
    open -a Simulator
    sleep 5
fi
echo "--- シミュレータ UDID: $DEVICE_ID"

# Flutterアプリをインストール・起動
echo "--- プレビューアプリをビルド・起動中..."
flutter run -t "$ENTRY_POINT" -d "$DEVICE_ID" --no-hot &
FLUTTER_PID=$!

# アプリが起動するまで待機
echo "--- アプリの起動を待機中..."
sleep 30

# Maestroフローを実行
echo "--- Maestroフローを実行中..."
maestro test "$FLOW_FILE" || true

# Flutterプロセスを停止
echo "--- Flutterプロセスを停止中..."
kill $FLUTTER_PID 2>/dev/null || true

# 結果を表示
echo ""
echo "=== スクリーンショット一覧 ==="
ls -la "$SCREENSHOT_DIR"/ 2>/dev/null || echo "(スクリーンショットが見つかりません)"
echo ""
echo "=== 完了 ==="
