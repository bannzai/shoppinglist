#!/usr/bin/env bash
set -euo pipefail

# generate_section_prompts.sh - RELEASE_TEST_PLAN.md からセクションプロンプトを自動生成
#
# RELEASE_TEST_PLAN.md をパースし、各セクションに対応する
# プロンプトファイルを生成する。共通ルールテンプレートを結合して出力。
#
# 使い方:
#   generate_section_prompts.sh --base <branch>
#   generate_section_prompts.sh --base <branch> --plan ./RELEASE_TEST_PLAN.md --output ./tmp/prompts
#   generate_section_prompts.sh -h
#
# 引数:
#   --base <branch>   必須。ベースブランチ名（共通ルールの {{BASE_BRANCH}} 置換用）
#   --plan <file>     RELEASE_TEST_PLAN.md のパス（デフォルト: ./RELEASE_TEST_PLAN.md）
#   --output <dir>    プロンプト出力先ディレクトリ（デフォルト: ./tmp/prompts）
#   -h, --help        ヘルプ表示

# スクリプト自身のディレクトリを取得（references/ の参照用）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REFERENCES_DIR="${SCRIPT_DIR}/../references"

show_help() {
    cat << 'EOF'
generate_section_prompts.sh - RELEASE_TEST_PLAN.md からセクションプロンプトを自動生成

使い方:
  generate_section_prompts.sh --base <branch>
  generate_section_prompts.sh --base <branch> --plan ./RELEASE_TEST_PLAN.md --output ./tmp/prompts
  generate_section_prompts.sh -h

引数:
  --base <branch>   必須。ベースブランチ名
  --plan <file>     テストプランファイルのパス（デフォルト: ./RELEASE_TEST_PLAN.md）
  --output <dir>    出力ディレクトリ（デフォルト: ./tmp/prompts）
EOF
}

# --- 引数解析 ---
BASE_BRANCH=""
PLAN_FILE="./RELEASE_TEST_PLAN.md"
OUTPUT_DIR="./tmp/prompts"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --base)
            BASE_BRANCH="$2"
            shift 2
            ;;
        --plan)
            PLAN_FILE="$2"
            shift 2
            ;;
        --output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "不明な引数: $1" >&2
            show_help
            exit 1
            ;;
    esac
done

if [[ -z "$BASE_BRANCH" ]]; then
    echo "エラー: --base <branch> を指定してください" >&2
    exit 1
fi

if [[ ! -f "$PLAN_FILE" ]]; then
    echo "エラー: ${PLAN_FILE} が見つかりません" >&2
    exit 1
fi

# --- 共通ルールテンプレート読み込み ---
COMMON_RULES_FILE="${REFERENCES_DIR}/common_rules.md"
if [[ ! -f "$COMMON_RULES_FILE" ]]; then
    echo "エラー: ${COMMON_RULES_FILE} が見つかりません" >&2
    exit 1
fi

# {{BASE_BRANCH}} を実際のブランチ名で置換（ブランチ名に / を含む場合に備え区切り文字に | を使用）
COMMON_RULES=$(sed "s|{{BASE_BRANCH}}|${BASE_BRANCH}|g" "$COMMON_RULES_FILE")

# --- セクションプロンプトテンプレート読み込み ---
TEMPLATE_FILE="${REFERENCES_DIR}/section_prompt_template.md"
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "エラー: ${TEMPLATE_FILE} が見つかりません" >&2
    exit 1
fi

# --- 出力ディレクトリ作成 ---
mkdir -p "$OUTPUT_DIR"

# --- RELEASE_TEST_PLAN.md をセクション単位で分割 ---
SECTION_STARTS=()
SECTION_HEADERS=()
SECTION_NUMS=()
line_num=0
while IFS= read -r line; do
    line_num=$((line_num + 1))
    if [[ "$line" =~ ^##\ ([0-9]+)\.\ (.+)$ ]]; then
        num="${BASH_REMATCH[1]}"
        header="${BASH_REMATCH[2]}"
        padded=$(printf "%02d" "$num")
        SECTION_STARTS+=("$line_num")
        SECTION_HEADERS+=("$header")
        SECTION_NUMS+=("$padded")
    fi
done < "$PLAN_FILE"

total_sections=${#SECTION_NUMS[@]}
echo "検出されたセクション数: ${total_sections}"

if [[ "$total_sections" -eq 0 ]]; then
    echo "エラー: セクション（## N. 形式）が見つかりません" >&2
    exit 1
fi

# --- セクション名からスラッグを生成 ---
generate_slug() {
    local header="$1"
    local slug=""

    # 括弧内の英語名を抽出（例: "認証 (AuthPage)" → "auth_page"）
    if [[ "$header" =~ \(([A-Za-z]+)\) ]]; then
        slug="${BASH_REMATCH[1]}"
        # PascalCase → snake_case
        slug=$(echo "$slug" | sed 's/\([a-z]\)\([A-Z]\)/\1_\2/g' | tr '[:upper:]' '[:lower:]')
    else
        slug="general"
    fi

    echo "$slug"
}

# --- 各セクションのチェック項目を抽出 ---
extract_check_items() {
    local section_idx="$1"
    local start_line="${SECTION_STARTS[$section_idx]}"
    local end_line

    local next_idx=$((section_idx + 1))
    if [[ "$next_idx" -lt "$total_sections" ]]; then
        end_line=$((SECTION_STARTS[next_idx] - 1))
    else
        end_line=$(wc -l < "$PLAN_FILE")
    fi

    # セクション範囲内の "- [ ]" 行を抽出
    sed -n "${start_line},${end_line}p" "$PLAN_FILE" | grep '^\- \[ \]' || true
}

# --- 各セクションのプロンプト生成 ---
for i in $(seq 0 $((total_sections - 1))); do
    num="${SECTION_NUMS[$i]}"
    header="${SECTION_HEADERS[$i]}"
    slug=$(generate_slug "$header")
    section_number=$((10#$num))

    # チェック項目抽出
    check_items=$(extract_check_items "$i")
    if [[ -z "$check_items" ]]; then
        check_items="（RELEASE_TEST_PLAN.md の該当セクションを参照）"
    fi

    # プレースホルダ置換はPython3で行う（bash/sed/awkでは&や/等の特殊文字問題を回避）
    output_file="${OUTPUT_DIR}/section_${num}_${slug}.txt"

    check_items_file=$(mktemp)
    common_rules_file=$(mktemp)
    echo "$check_items" > "$check_items_file"
    echo "$COMMON_RULES" > "$common_rules_file"

    python3 -c "
import sys
template = open(sys.argv[1]).read()
check_items = open(sys.argv[2]).read().rstrip('\n')
common_rules = open(sys.argv[3]).read().rstrip('\n')
result = template.replace('{{SECTION_NUM}}', sys.argv[4])
result = result.replace('{{SECTION_NAME}}', sys.argv[5])
result = result.replace('{{CHECK_ITEMS}}', check_items)
result = result.replace('{{COMMON_RULES}}', common_rules)
with open(sys.argv[6], 'w') as f:
    f.write(result)
" "$TEMPLATE_FILE" "$check_items_file" "$common_rules_file" "$section_number" "$header" "$output_file"

    [[ -f "$check_items_file" ]] && unlink "$check_items_file"
    [[ -f "$common_rules_file" ]] && unlink "$common_rules_file"

    echo "  生成: ${output_file}"
done

echo ""
echo "プロンプト生成完了: ${total_sections} ファイル → ${OUTPUT_DIR}/"
