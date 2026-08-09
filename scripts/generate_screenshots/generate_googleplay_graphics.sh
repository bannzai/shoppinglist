#!/usr/bin/env bash
# =============================================================================
# スクリプト名: generate_googleplay_graphics.sh
# 用途:
#   Google Play のストア掲載に必須のグラフィック
#   (フィーチャーグラフィック 1024x500 / アプリアイコン 512x512) を生成する。
#   アイコンは iOS の AppIcon を流用し、フィーチャーグラフィックは
#   スクリーンショットと同じ配色でアイコンとキャッチコピーを組む。
# 使い方:
#   bash scripts/generate_screenshots/generate_googleplay_graphics.sh
# 引数:
#   なし
# 標準出力:
#   生成したファイルと寸法
# 終了コード:
#   0 成功 / 1 元アイコンが無い・生成結果の寸法が要件と違う
# 依存コマンド:
#   bash, magick (ImageMagick), sips
# =============================================================================
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPOSITORY_ROOT"

readonly SOURCE_ICON="ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
readonly OUTPUT_DIRECTORY="artifacts/googleplay_graphics"

# Play が要求する固定サイズ。
readonly FEATURE_GRAPHIC_WIDTH=1024
readonly FEATURE_GRAPHIC_HEIGHT=500
readonly PLAY_ICON_SIZE=512

# スクリーンショットのレイアウトと同じ配色。
readonly BACKGROUND_COLOR='#F1EDE4'
readonly INK_COLOR='#1B1813'
readonly ACCENT_COLOR='#C2410C'

# 日本語を含むため、macOS 標準のヒラギノをファミリー名で指定する。
# ImageMagick の既定フォントは日本語グリフを持たず豆腐になる。
# ファイルパス直接指定は、macOS のファイル名が NFD 正規化されていて
# シェルからの参照が壊れるため採らない。
readonly JAPANESE_FONT_FAMILY='Hiragino Sans'

if [ ! -f "$SOURCE_ICON" ]; then
  echo "[NG] 元アイコンが無い: $SOURCE_ICON" >&2
  exit 1
fi
# `magick -list font` にヒラギノは載らない (macOS のフォント解決に委ねられる) ため、
# 実際に日本語をレンダリングして、単色 (= グリフが出ていない) でないことで判定する。
font_probe_deviation="$(magick -size 200x80 xc:white -family "$JAPANESE_FONT_FAMILY" \
  -pointsize 48 -fill black -gravity center -annotate +0+0 '買物' \
  -format '%[fx:standard_deviation]' info:)"
if [ "$(printf '%.0f' "$(echo "$font_probe_deviation * 1000" | bc -l)")" -eq 0 ]; then
  echo "[NG] 日本語グリフが描画されない: $JAPANESE_FONT_FAMILY" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIRECTORY"

# Play のアイコンは 32bit PNG かつアルファ不可。白背景に合成して不透明にする。
magick "$SOURCE_ICON" -resize "${PLAY_ICON_SIZE}x${PLAY_ICON_SIZE}" \
  -background white -alpha remove -alpha off \
  "$OUTPUT_DIRECTORY/icon.png"

# フィーチャーグラフィック: 左にアイコン、右にアプリ名とキャッチコピー。
magick -size "${FEATURE_GRAPHIC_WIDTH}x${FEATURE_GRAPHIC_HEIGHT}" "xc:$BACKGROUND_COLOR" \
  \( "$SOURCE_ICON" -resize 260x260 -bordercolor none -border 0 \) \
  -gravity west -geometry +80+0 -composite \
  -family "$JAPANESE_FONT_FAMILY" \
  -weight 700 -fill "$INK_COLOR" -pointsize 76 -gravity northwest \
  -annotate +400+150 '買い物リスト' \
  -weight 400 -fill "$ACCENT_COLOR" -pointsize 34 -gravity northwest \
  -annotate +400+265 '家族と共有できる、お買い物メモ' \
  "$OUTPUT_DIRECTORY/feature_graphic.png"

for generated in "$OUTPUT_DIRECTORY/icon.png:$PLAY_ICON_SIZE:$PLAY_ICON_SIZE" \
                 "$OUTPUT_DIRECTORY/feature_graphic.png:$FEATURE_GRAPHIC_WIDTH:$FEATURE_GRAPHIC_HEIGHT"; do
  path="${generated%%:*}"
  expected="${generated#*:}"
  expected_width="${expected%%:*}"
  expected_height="${expected#*:}"
  width="$(sips -g pixelWidth "$path" | awk '/pixelWidth/{print $2}')"
  height="$(sips -g pixelHeight "$path" | awk '/pixelHeight/{print $2}')"
  if [ "$width" != "$expected_width" ] || [ "$height" != "$expected_height" ]; then
    echo "[NG] $path は ${width}x${height}。${expected_width}x${expected_height} が必要" >&2
    exit 1
  fi
  echo "--- $path (${width}x${height})"
done
