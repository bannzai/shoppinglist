#!/usr/bin/env bash
# =============================================================================
# スクリプト名: convert_for_google_play.sh
# 用途:
#   App Store 用に撮影したスクリーンショット (1320x2868) を Google Play の
#   縦横比制約に収まる形へ変換する。
#   Play は「長辺が短辺の 2 倍を超えてはならない」ため 1320x2868 (2.17 倍) は
#   そのまま入稿できない。背景色で左右を埋めて 9:16 相当へ広げる。
#   (上下をクロップするとキャッチコピーか端末が欠けるため、パディングを採る)
# 使い方:
#   bash scripts/generate_screenshots/convert_for_google_play.sh
# 引数:
#   なし (ios/fastlane/screenshots/ 配下の全 PNG を対象にする)
# 標準出力:
#   変換したファイルと出力後の寸法
# 終了コード:
#   0 成功 / 1 入力が無い・変換結果が Play の制約を満たさない
# 依存コマンド:
#   bash, magick (ImageMagick), sips
# =============================================================================
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPOSITORY_ROOT"

readonly SOURCE_DIRECTORY="ios/fastlane/screenshots"
readonly OUTPUT_DIRECTORY="artifacts/googleplay_screenshots"

# Play 推奨の縦向き比率 9:16。撮影元 (1320x2868) の高さを保ったまま、
# この比率になる幅までパディングする。
readonly TARGET_ASPECT_WIDTH=9
readonly TARGET_ASPECT_HEIGHT=16

# パディング色。撮影レイアウトの背景グラデーション下端と同色にして、
# 端末まわりの地の色と連続して見えるようにする。
readonly PAD_COLOR='#F1EDE4'

converted_count=0
while IFS= read -r source; do
  height="$(sips -g pixelHeight "$source" | awk '/pixelHeight/{print $2}')"
  target_width=$((height * TARGET_ASPECT_WIDTH / TARGET_ASPECT_HEIGHT))

  output="$OUTPUT_DIRECTORY/${source#"$SOURCE_DIRECTORY"/}"
  mkdir -p "$(dirname "$output")"
  magick "$source" -background "$PAD_COLOR" -gravity center \
    -extent "${target_width}x${height}" "$output"

  output_width="$(sips -g pixelWidth "$output" | awk '/pixelWidth/{print $2}')"
  output_height="$(sips -g pixelHeight "$output" | awk '/pixelHeight/{print $2}')"
  if [ $((output_height)) -gt $((output_width * 2)) ]; then
    echo "[NG] $output は ${output_width}x${output_height} で、長辺が短辺の 2 倍を超える" >&2
    exit 1
  fi
  echo "--- $output (${output_width}x${output_height})"
  converted_count=$((converted_count + 1))
done < <(find "$SOURCE_DIRECTORY" -name '*.png' 2>/dev/null | sort)

if [ "$converted_count" -eq 0 ]; then
  echo "[NG] $SOURCE_DIRECTORY に PNG が無い。先に generate_appstore_screenshots.sh を実行する" >&2
  exit 1
fi
echo "--- Google Play 用に $converted_count 枚を変換した"
