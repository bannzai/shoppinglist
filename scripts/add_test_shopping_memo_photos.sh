#!/bin/bash
# 「写真から追加」（AI 画像認識）の動作確認用に、買い物メモ風テスト画像
# （test/fixtures/shopping_memo_images/）を iOS Simulator の写真ライブラリへ追加する。
#
# 使い方: bash scripts/add_test_shopping_memo_photos.sh [simulator UDID]
#   UDID 省略時は booted（起動中の simulator）を対象にする。
#   複数台起動している場合は取り違え防止のため UDID を明示すること（sim-list で確認できる）。
#
# 冪等ではない: simctl addmedia は同じ画像でも実行のたびに写真ライブラリへ追加され、
# 重複を検出・スキップする手段が simctl に無いため。重複が増えたら
# simulator の Photos アプリから削除するか、simulator を作り直す。
set -euo pipefail

device_id="${1:-booted}"
fixtures_directory="$(cd "$(dirname "$0")/.." && pwd)/test/fixtures/shopping_memo_images"

xcrun simctl addmedia "$device_id" "$fixtures_directory"/*.jpg
echo "added to $device_id:"
basename -a "$fixtures_directory"/*.jpg
