#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$PROJECT_ROOT"

DEVICE_NAME="iPhone 16 Pro"
APP_BUNDLE_ID="com.bannzai.shoppinglist"

echo "=== マルチデバイス テスト環境セットアップ ==="
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

# ===== Android Emulator =====
echo ""
echo "--- [Android] エミュレータを確認中..."
ANDROID_DEVICE_ID=$(adb devices 2>/dev/null | grep -E "emulator-[0-9]+" | head -1 | awk '{print $1}' || true)

if [ -z "$ANDROID_DEVICE_ID" ]; then
    echo "--- [Android] エミュレータが起動していません。起動します..."
    AVD_NAME=$(emulator -list-avds 2>/dev/null | head -1 || true)
    if [ -z "$AVD_NAME" ]; then
        echo "--- [Android] AVD が見つかりません。API 35 の AVD を自動作成します..."
        SYSTEM_IMAGE="system-images;android-35;google_apis;arm64-v8a"
        AVD_NAME="test_device_api35"

        # システムイメージがなければダウンロード
        if ! sdkmanager --list_installed 2>/dev/null | grep -q "$SYSTEM_IMAGE"; then
            echo "--- [Android] システムイメージをダウンロード中: $SYSTEM_IMAGE"
            yes | sdkmanager "$SYSTEM_IMAGE"
        fi

        # AVD作成
        echo "--- [Android] AVD '$AVD_NAME' を作成中..."
        echo "no" | avdmanager create avd -n "$AVD_NAME" -k "$SYSTEM_IMAGE" -d pixel_6
        echo "--- [Android] AVD '$AVD_NAME' を作成しました"
    fi

    # 既存AVDがAPI 36の場合に警告
    AVD_INI="$HOME/.android/avd/${AVD_NAME}.avd/config.ini"
    if [ -f "$AVD_INI" ] && grep -q "android-36" "$AVD_INI" 2>/dev/null; then
        echo ""
        echo "WARNING: AVD '$AVD_NAME' は API 36 です。"
        echo "  API 36 では Maestro inputText の既知バグ (GitHub #2718) があり、テストが失敗する可能性があります。"
        echo "  API 35 以下の AVD を推奨します。"
        echo ""
    fi
    echo "--- [Android] AVD: $AVD_NAME を起動中..."
    emulator -avd "$AVD_NAME" -no-snapshot-load &
    EMULATOR_PID=$!

    # エミュレータの起動を待機
    echo "--- [Android] エミュレータの起動を待機中..."
    for i in $(seq 1 60); do
        ANDROID_DEVICE_ID=$(adb devices 2>/dev/null | grep -E "emulator-[0-9]+" | head -1 | awk '{print $1}' || true)
        if [ -n "$ANDROID_DEVICE_ID" ]; then
            # boot完了を待つ
            BOOT_COMPLETED=$(adb -s "$ANDROID_DEVICE_ID" shell getprop sys.boot_completed 2>/dev/null || true)
            if [ "$BOOT_COMPLETED" = "1" ]; then
                break
            fi
        fi
        sleep 2
    done

    if [ -z "$ANDROID_DEVICE_ID" ]; then
        echo "ERROR: Android エミュレータの起動がタイムアウトしました"
        exit 1
    fi
fi
echo "--- [Android] エミュレータ ID: $ANDROID_DEVICE_ID"

# ===== Flutter ビルド =====
echo ""
echo "--- [Flutter] iOS Simulator用ビルド中..."
flutter build ios --simulator

echo ""
echo "--- [Flutter] Android APK ビルド中（debugビルド）..."
flutter build apk --debug

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

echo ""
echo "--- [Android] アプリをインストール中..."
ANDROID_APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
if [ -f "$ANDROID_APK_PATH" ]; then
    adb -s "$ANDROID_DEVICE_ID" install -r "$ANDROID_APK_PATH"
    echo "--- [Android] インストール完了"
else
    echo "ERROR: Android APK が見つかりません: $ANDROID_APK_PATH"
    exit 1
fi

# ===== 結果出力 =====
echo ""
echo "=== セットアップ完了 ==="
echo "iOS_DEVICE_ID=$IOS_DEVICE_ID"
echo "ANDROID_DEVICE_ID=$ANDROID_DEVICE_ID"
echo ""
echo "次のステップ:"
echo "  maestro test --device $IOS_DEVICE_ID maestro/flows/multi_device/device_a_setup_and_invite.yaml"
echo "  maestro test --device $ANDROID_DEVICE_ID maestro/flows/multi_device/device_b_sign_in.yaml"
