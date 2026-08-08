#!/usr/bin/env bash
# =============================================================================
# スクリプト名: generate_appstore_screenshots.sh
# 用途:
#   App Store / Google Play へ提出するスクリーンショットを、シミュレータの実描画で
#   撮影して fastlane 形式へ配置する。
#   撮影対象の定義は lib/screenshot/ にあり、本スクリプトは実行と配置だけを担う。
# 使い方:
#   bash scripts/generate_screenshots/generate_appstore_screenshots.sh [-d UDID]
# 例:
#   bash scripts/generate_screenshots/generate_appstore_screenshots.sh
# 引数:
#   -d UDID   : 撮影に使うシミュレータの UDID。省略時は SIM_NAME のシミュレータを sim-boot で起動して使う
# 環境変数 (任意):
#   SIM_NAME  : 撮影用シミュレータ名 (既定: shoppinglist-appstore-screenshot)
# 標準出力:
#   撮影の進捗と、配置したファイルの一覧
# 終了コード:
#   0 成功 / 1 撮影失敗・寸法不一致 / 2 引数不正
# 依存コマンド:
#   bash, flutter, xcrun, sips, sim-boot (bannzai/.bin)
# =============================================================================
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPOSITORY_ROOT"

# App Store の 6.9 インチ (iPhone 16 Pro Max 相当) の提出解像度。
# 2026-08 時点で App Store Connect が必須とするサイズ。
readonly REQUIRED_WIDTH=1320
readonly REQUIRED_HEIGHT=2868

# 撮影用シミュレータの機種。REQUIRED_WIDTH x REQUIRED_HEIGHT のネイティブ解像度を持つ。
readonly SIMULATOR_DEVICE_TYPE="iPhone 16 Pro Max"

readonly INTERMEDIATE_DIRECTORY="artifacts/appstore_screenshots"
readonly FASTLANE_DIRECTORY="ios/fastlane/screenshots"

SIM_NAME="${SIM_NAME:-shoppinglist-appstore-screenshot}"
DEVICE_UDID=""

while getopts "d:" option; do
  case "$option" in
    d) DEVICE_UDID="$OPTARG" ;;
    *)
      echo "使い方: $0 [-d UDID]" >&2
      exit 2
      ;;
  esac
done

if [ -z "$DEVICE_UDID" ]; then
  echo "--- 撮影用シミュレータを起動: $SIM_NAME ($SIMULATOR_DEVICE_TYPE)"
  DEVICE_UDID="$(SCRIPT_QUIET=1 sim-boot "$SIM_NAME" "$SIMULATOR_DEVICE_TYPE" 2>/dev/null | sed -n 's/^DEVICE_UDID=//p' | tail -1)"
fi
if [ -z "$DEVICE_UDID" ]; then
  echo "[NG] 撮影用シミュレータの UDID を解決できなかった" >&2
  exit 1
fi
echo "--- 撮影デバイス: $DEVICE_UDID"

drive_arguments=(
  --driver=test_driver/screenshot_test.dart
  --target=integration_test/app_store_screenshots_test.dart
  -d "$DEVICE_UDID"
)
echo "--- 撮影中 (全ロケール・全ページ)"
flutter drive "${drive_arguments[@]}"

# 撮影された PNG がストア要求の解像度どおりか検証する。
# シミュレータの機種違いや向きの取り違えは、この寸法チェックでしか気付けない。
screenshot_count=0
while IFS= read -r screenshot; do
  width="$(sips -g pixelWidth "$screenshot" | awk '/pixelWidth/{print $2}')"
  height="$(sips -g pixelHeight "$screenshot" | awk '/pixelHeight/{print $2}')"
  if [ "$width" != "$REQUIRED_WIDTH" ] || [ "$height" != "$REQUIRED_HEIGHT" ]; then
    echo "[NG] $screenshot は ${width}x${height}。${REQUIRED_WIDTH}x${REQUIRED_HEIGHT} が必要" >&2
    exit 1
  fi
  screenshot_count=$((screenshot_count + 1))
done < <(find "$INTERMEDIATE_DIRECTORY" -name '*.png' 2>/dev/null)

if [ "$screenshot_count" -eq 0 ]; then
  echo "[NG] $INTERMEDIATE_DIRECTORY に PNG が生成されていない" >&2
  exit 1
fi
echo "--- 撮影完了: $screenshot_count 枚 (${REQUIRED_WIDTH}x${REQUIRED_HEIGHT})"

# fastlane deliver は画像の px 寸法で表示クラスを判定するため、言語ディレクトリへ
# そのまま置くだけでよい。ファイル名の先頭の連番が提出順になる。
for locale_directory in "$INTERMEDIATE_DIRECTORY"/*/; do
  [ -d "$locale_directory" ] || continue
  locale="$(basename "$locale_directory")"
  mkdir -p "$FASTLANE_DIRECTORY/$locale"
  find "$FASTLANE_DIRECTORY/$locale" -name '*.png' -delete
  cp "$locale_directory"*.png "$FASTLANE_DIRECTORY/$locale/"
  echo "--- 配置: $FASTLANE_DIRECTORY/$locale ($(find "$FASTLANE_DIRECTORY/$locale" -name '*.png' | wc -l | tr -d ' ') 枚)"
done

find "$FASTLANE_DIRECTORY" -name '*.png' | sort
