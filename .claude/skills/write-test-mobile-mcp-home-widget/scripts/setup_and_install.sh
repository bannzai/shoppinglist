#!/bin/bash
set -euo pipefail

# ホーム画面ウィジェットテスト用のiOSシミュレータをセットアップし、アプリをインストールする
# 環境変数:
#   MOBILE_MCP_IOS_SIMULATOR: 使用するシミュレータのUDID（設定済みならこのデバイスを優先使用）
# 引数:
#   $1 (任意): デバイス名 (デフォルト: "iPhone 16 Pro")
#   $2 (任意): アプリパス (デフォルト: "build/ios/iphonesimulator/Runner.app")

PROJECT_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$PROJECT_ROOT"

DEVICE_NAME="${1:-iPhone 16 Pro}"
APP_PATH="${2:-build/ios/iphonesimulator/Runner.app}"
SIM_NAME="WidgetTest"

echo "=== ホーム画面ウィジェットテスト セットアップ ==="
echo "Project root: $PROJECT_ROOT"
echo "Device name: $DEVICE_NAME"

# MOBILE_MCP_IOS_SIMULATOR が設定されていればそのデバイスを優先使用
if [ -n "${MOBILE_MCP_IOS_SIMULATOR:-}" ]; then
    DEVICE_ID="$MOBILE_MCP_IOS_SIMULATOR"
    echo "--- MOBILE_MCP_IOS_SIMULATOR で指定されたデバイスを使用: $DEVICE_ID"
else
    # 利用可能な最新iOSランタイムを確認
    echo ""
    echo "--- 利用可能なiOSランタイムを確認中..."
    RUNTIME=$(xcrun simctl list runtimes --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
ios_runtimes = [r for r in data.get('runtimes', []) if 'iOS' in r.get('name', '') and r.get('isAvailable', False)]
ios_runtimes.sort(key=lambda r: r.get('version', '0'), reverse=True)
if ios_runtimes:
    print(ios_runtimes[0]['identifier'])
else:
    print('', end='')
")

    if [ -z "$RUNTIME" ]; then
        echo "ERROR: 利用可能なiOSランタイムが見つかりません"
        xcrun simctl list runtimes
        exit 1
    fi
    echo "--- ランタイム: $RUNTIME"

    # 既存のWidgetTestシミュレータを確認
    echo ""
    echo "--- テスト用シミュレータを確認中..."
    EXISTING_ID=$(xcrun simctl list devices --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    for d in devices:
        if d.get('name') == '${SIM_NAME}' and d.get('isAvailable', False):
            print(d['udid'])
            sys.exit(0)
print('', end='')
")

    if [ -n "$EXISTING_ID" ]; then
        DEVICE_ID="$EXISTING_ID"
        echo "--- 既存のテスト用シミュレータを使用: $DEVICE_ID"
    else
        echo "--- テスト用シミュレータを作成中..."
        DEVICE_ID=$(xcrun simctl create "$SIM_NAME" "$DEVICE_NAME" "$RUNTIME")
        echo "--- 作成完了: $DEVICE_ID"
    fi
fi

# 他のシミュレータをシャットダウンし、テスト用のみ起動
echo ""
echo "--- 他のシミュレータをシャットダウン中..."
xcrun simctl shutdown all 2>/dev/null || true

echo "--- テスト用シミュレータを起動中..."
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator
xcrun simctl bootstatus "$DEVICE_ID" -b

# アプリをビルド
echo ""
echo "--- iOS Simulator用ビルド中..."
flutter build ios --simulator

# アプリをインストール
echo ""
echo "--- アプリをインストール中..."
if [ -d "$APP_PATH" ]; then
    xcrun simctl install "$DEVICE_ID" "$APP_PATH"
    echo "--- インストール完了"
else
    echo "ERROR: アプリが見つかりません: $APP_PATH"
    exit 1
fi

# 結果出力
echo ""
echo "=== セットアップ完了 ==="
echo "DEVICE_ID=$DEVICE_ID"
echo "SIM_NAME=$SIM_NAME"
echo ""
echo "次のステップ: mobile-mcpでアプリを起動してテストを開始"
