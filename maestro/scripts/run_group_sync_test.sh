#!/bin/bash
set -e

# 設定画面の「開発者オプション」タイルから各操作を実行する方式。
# シェイク不要のため各フェーズを直接 maestro test で順次実行する。

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FLOWS_DIR="$SCRIPT_DIR/../flows/virtual_pairing"
OUTPUT_DIR="$PROJECT_ROOT/maestro/test-results/virtual_pairing"

# デバイスUDID: 環境変数 MAESTRO_DEVICE_ID で上書き可能（デフォルト: iPhone 16 Plus）
DEVICE_ID="${MAESTRO_DEVICE_ID:-A440EFCF-F99F-473D-940C-6E0E52FF526C}"

# テスト対象アプリの bundle id。各 flow の appId: ${APP_ID} に -e で渡す。
# 環境変数 APP_ID で上書き可能（デフォルト: prod）。dev 検証時は APP_ID=com.bannzai.shoppinglist.dev。
APP_ID="${APP_ID:-com.bannzai.shoppinglist}"

mkdir -p "$OUTPUT_DIR"

MAESTRO_OPTS="--device $DEVICE_ID -e APP_ID=$APP_ID --debug-output $OUTPUT_DIR --flatten-debug-output"

echo "=== 仮想ペアリング グループ同期 E2E テスト ==="
echo "対象アプリ: $APP_ID"
echo "出力先: $OUTPUT_DIR"

# Phase 1: サインイン + グループ作成
echo "--- Phase 1: サインイン + グループ作成 ---"
maestro test $MAESTRO_OPTS "$FLOWS_DIR/01_setup_group.yaml"

# Phase 2: デバッグユーザー作成
echo "--- Phase 2: デバッグユーザー作成 ---"
maestro test $MAESTRO_OPTS "$FLOWS_DIR/02_create_debug_user.yaml"

# Phase 3: グループにデバッグユーザー追加
echo "--- Phase 3: グループにデバッグユーザー追加 ---"
maestro test $MAESTRO_OPTS "$FLOWS_DIR/03_add_to_group.yaml"

# Phase 4: デバッグユーザーとしてアイテム追加
echo "--- Phase 4: デバッグユーザーとしてアイテム追加 ---"
maestro test $MAESTRO_OPTS "$FLOWS_DIR/04_add_item.yaml"

# Phase 5: リアルタイム同期確認
echo "--- Phase 5: リアルタイム同期確認 ---"
maestro test $MAESTRO_OPTS "$FLOWS_DIR/05_verify_sync.yaml"

# Phase 6: クリーンアップ
echo "--- Phase 6: クリーンアップ ---"
maestro test $MAESTRO_OPTS "$FLOWS_DIR/06_cleanup.yaml"

echo "=== テスト完了 ==="
echo "結果: $OUTPUT_DIR"
