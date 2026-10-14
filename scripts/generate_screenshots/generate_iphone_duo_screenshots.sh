#!/usr/bin/env bash
# =============================================================================
# スクリプト名: generate_iphone_duo_screenshots.sh
# 用途:
#   App Store へ提出する iPhone Duo (外側・内側ディスプレイ) のスクリーンショットを生成し、
#   alpha を落として ios/fastlane/screenshots_iphone_duo/{locale}/ に配置する。
#   レイアウトを iPhone Duo の論理サイズでシミュレータ上に描画して書き出すため、
#   撮影機は iPhone Duo でなくてよい (理由は integration_test/app_store_screenshots_iphone_duo_test.dart)。
#   fastlane deliver 2.241.0 の deliver/lib/deliver/app_screenshot.rb の DEVICE_RESOLUTIONS に
#   Duo の寸法が無く、ios/fastlane/screenshots/ に置くと upload_appstore_screenshots.sh の
#   検証 (Screenshot size is not supported) で全体が止まるため、別のディレクトリに置く。
# 使い方:
#   bash scripts/generate_screenshots/generate_iphone_duo_screenshots.sh [-d UDID]
# 例:
#   bash scripts/generate_screenshots/generate_iphone_duo_screenshots.sh
# 引数:
#   -d UDID   : 撮影に使うシミュレータの UDID。省略時は SIM_NAME のシミュレータを sim-boot で起動して使う
# 環境変数 (任意):
#   SIM_NAME  : 撮影用シミュレータ名 (既定: shoppinglist-appstore-screenshot。
#               generate_appstore_screenshots.sh と同じシミュレータを使い回すため)
# 標準出力:
#   撮影の進捗と、配置したファイルの一覧
# 終了コード:
#   0 成功 / 1 撮影失敗・寸法・alpha・枚数の不一致 / 2 引数不正
# 依存コマンド:
#   bash, flutter, magick, sips, sim-boot (bannzai/.bin)
# =============================================================================
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPOSITORY_ROOT"

# 撮影機の機種。描画する寸法は撮影機に依存しないため、
# generate_appstore_screenshots.sh と同じ機種にしてシミュレータを使い回す。
readonly SIMULATOR_DEVICE_TYPE="iPhone 16 Pro Max"

readonly INTERMEDIATE_DIRECTORY="artifacts/appstore_screenshots_iphone_duo"
readonly OUTPUT_DIRECTORY="ios/fastlane/screenshots_iphone_duo"

# ロケール数 (ja / en-US) × ページ数 (lib/screenshot/screenshot_pages.dart の 5 ページ)。
# 撮影が途中で止まっても exit 0 になる事故を、枚数の検証で検出する。
readonly EXPECTED_COUNT_PER_DISPLAY=10

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

# 前回の画像が残ると、今回撮れなかったページを枚数の検証で見逃すため消してから撮る。
rm -rf "$INTERMEDIATE_DIRECTORY"

echo "--- 撮影中 (外側・内側 × 全ロケール・全ページ)"
flutter drive \
  --driver=test_driver/screenshot_test.dart \
  --target=integration_test/app_store_screenshots_iphone_duo_test.dart \
  -d "$DEVICE_UDID"

# toImage の PNG は不透明でも alpha チャンネルを持つため、提出前に落とす。
# 寸法の基準は Apple の「Screenshot specifications」の iPhone Duo の節。
verify_and_flatten() {
  local display="$1"
  local required_width="$2"
  local required_height="$3"
  local count=0
  while IFS= read -r screenshot; do
    magick "$screenshot" -alpha remove -alpha off "$screenshot"
    local width height has_alpha
    width="$(sips -g pixelWidth "$screenshot" | awk '/pixelWidth/{print $2}')"
    height="$(sips -g pixelHeight "$screenshot" | awk '/pixelHeight/{print $2}')"
    has_alpha="$(sips -g hasAlpha "$screenshot" | awk '/hasAlpha/{print $2}')"
    if [ "$width" != "$required_width" ] || [ "$height" != "$required_height" ] || [ "$has_alpha" != "no" ]; then
      echo "[NG] $screenshot は ${width}x${height} hasAlpha=${has_alpha}。${required_width}x${required_height} hasAlpha=no が必要" >&2
      exit 1
    fi
    count=$((count + 1))
  done < <(find "$INTERMEDIATE_DIRECTORY" -name "${display}_*.png" 2>/dev/null)
  if [ "$count" -ne "$EXPECTED_COUNT_PER_DISPLAY" ]; then
    echo "[NG] ${display} は ${count} 枚。${EXPECTED_COUNT_PER_DISPLAY} 枚が必要" >&2
    exit 1
  fi
  echo "--- ${display}: ${count} 枚 (${required_width}x${required_height}, alpha なし)"
}
verify_and_flatten outer 1398 2034
verify_and_flatten inner 2853 2007

for locale_directory in "$INTERMEDIATE_DIRECTORY"/*/; do
  [ -d "$locale_directory" ] || continue
  locale="$(basename "$locale_directory")"
  mkdir -p "$OUTPUT_DIRECTORY/$locale"
  find "$OUTPUT_DIRECTORY/$locale" -name '*.png' -delete
  cp "$locale_directory"*.png "$OUTPUT_DIRECTORY/$locale/"
  echo "--- 配置: $OUTPUT_DIRECTORY/$locale ($(find "$OUTPUT_DIRECTORY/$locale" -name '*.png' | wc -l | tr -d ' ') 枚)"
done

find "$OUTPUT_DIRECTORY" -name '*.png' | sort
