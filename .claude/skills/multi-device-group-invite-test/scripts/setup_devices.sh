#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$PROJECT_ROOT"

DEVICE_NAME="iPhone 16 Plus"
APP_BUNDLE_ID="com.bannzai.shoppinglist"

echo "=== 仮想ペアリング テスト環境セットアップ (iOS Simulator) ==="
echo "Project root: $PROJECT_ROOT"

# ===== iOS Simulator =====
echo ""
echo "--- [iOS] シミュレータを確認中..."
IOS_DEVICE_ID=$(xcrun simctl list devices booted --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS' in runtime:
        for d in devices:
            if d.get('state') == 'Booted':
                print(d['udid'])
                sys.exit(0)
" 2>/dev/null || true)

if [ -z "$IOS_DEVICE_ID" ]; then
    echo "--- [iOS] シミュレータが起動していません。${DEVICE_NAME} を起動します..."
    IOS_DEVICE_ID=$(xcrun simctl list devices available --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS' in runtime:
        for d in devices:
            if '${DEVICE_NAME}' in d.get('name', ''):
                print(d['udid'])
                sys.exit(0)
print('', end='')
")
    if [ -z "$IOS_DEVICE_ID" ]; then
        echo "ERROR: ${DEVICE_NAME} が見つかりません。利用可能なデバイス:"
        xcrun simctl list devices available | grep iPhone
        exit 1
    fi
    xcrun simctl boot "$IOS_DEVICE_ID"
    open -a Simulator
    sleep 5
fi
echo "--- [iOS] シミュレータ UDID: $IOS_DEVICE_ID"

# ===== Flutter ビルド =====
echo ""
echo "--- [Flutter] iOS Simulator用debugビルド中..."
flutter build ios --simulator --debug

# ===== アプリインストール =====
echo ""
echo "--- [iOS] アプリをインストール中..."
IOS_APP_PATH="build/ios/iphonesimulator/Runner.app"
if [ -d "$IOS_APP_PATH" ]; then
    xcrun simctl install "$IOS_DEVICE_ID" "$IOS_APP_PATH"
    echo "--- [iOS] インストール完了"
else
    echo "ERROR: iOS アプリが見つかりません: $IOS_APP_PATH"
    exit 1
fi

# ===== 結果出力 =====
echo ""
echo "=== セットアップ完了 ==="
echo "IOS_DEVICE_ID=$IOS_DEVICE_ID"
echo ""
echo "次のステップ:"
echo "  bash maestro/scripts/run_group_sync_test.sh"
