#!/usr/bin/env bash
set -euo pipefail

# run_qa.sh - リリースQAテスト実行スクリプト
#
# RELEASE_TEST_PLAN.md のセクションごとにブランチを作成し、
# ccnipre でテストを順次実行する。
#
# 使い方:
#   run_qa.sh --base <branch>           # 全セクション順次実行
#   run_qa.sh --base <branch> 1 3 5     # 指定セクションのみ実行
#   run_qa.sh -h                        # ヘルプ表示
#
# 引数:
#   --base <branch>  必須。ベースブランチ名（PRの作成先）
#   [numbers...]     省略時は全セクション。指定時はそのセクションのみ
#
# 前提:
#   - RELEASE_TEST_PLAN.md がプロジェクトルートに存在する
#   - tmp/prompts/ にセクションプロンプトが生成済み
#   - ccnipre コマンドがPATHに通っている

show_help() {
    cat << 'EOF'
run_qa.sh - リリースQAテスト実行スクリプト

使い方:
  run_qa.sh --base <branch>           # 全セクション順次実行
  run_qa.sh --base <branch> 1 3 5     # 指定セクションのみ実行
  run_qa.sh -h                        # ヘルプ表示

引数:
  --base <branch>  必須。ベースブランチ名（PRの作成先）
  [numbers...]     省略時は全セクション。指定時はそのセクションのみ

前提:
  - RELEASE_TEST_PLAN.md がプロジェクトルートに存在すること
  - tmp/prompts/ にセクションプロンプトが生成済みであること
  - ccnipre コマンドがPATHに通っていること
EOF
}

# --- 引数解析 ---
BASE_BRANCH=""
SECTIONS_TO_RUN=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --base)
            if [[ -z "${2:-}" ]]; then
                echo "エラー: --base にブランチ名を指定してください" >&2
                exit 1
            fi
            BASE_BRANCH="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            SECTIONS_TO_RUN+=("$1")
            shift
            ;;
    esac
done

if [[ -z "$BASE_BRANCH" ]]; then
    echo "エラー: --base <branch> を指定してください" >&2
    show_help
    exit 1
fi

# --- 設定 ---
PLAN_FILE="./RELEASE_TEST_PLAN.md"
PROMPT_DIR="./tmp/prompts"

if [[ ! -f "$PLAN_FILE" ]]; then
    echo "エラー: ${PLAN_FILE} が見つかりません" >&2
    exit 1
fi

if [[ ! -d "$PROMPT_DIR" ]]; then
    echo "エラー: ${PROMPT_DIR} が見つかりません。generate_section_prompts.sh を先に実行してください" >&2
    exit 1
fi

# --- RELEASE_TEST_PLAN.md からセクション番号を動的検出 ---
DETECTED_SECTIONS=()
while IFS= read -r line; do
    if [[ "$line" =~ ^##\ ([0-9]+)\. ]]; then
        num="${BASH_REMATCH[1]}"
        padded=$(printf "%02d" "$num")
        DETECTED_SECTIONS+=("$padded")
    fi
done < "$PLAN_FILE"

if [[ ${#DETECTED_SECTIONS[@]} -eq 0 ]]; then
    echo "エラー: ${PLAN_FILE} にセクション（## N. 形式）が見つかりません" >&2
    exit 1
fi

echo "検出されたセクション数: ${#DETECTED_SECTIONS[@]}"

# --- 実行対象セクションの決定 ---
RUN_TARGETS=()
if [[ ${#SECTIONS_TO_RUN[@]} -eq 0 ]]; then
    RUN_TARGETS=("${DETECTED_SECTIONS[@]}")
else
    for target in "${SECTIONS_TO_RUN[@]}"; do
        padded=$(printf "%02d" "$target")
        found=0
        for detected in "${DETECTED_SECTIONS[@]}"; do
            if [[ "$detected" == "$padded" ]]; then
                found=1
                break
            fi
        done
        if [[ "$found" -eq 1 ]]; then
            RUN_TARGETS+=("$padded")
        else
            echo "警告: セクション ${target} は ${PLAN_FILE} に存在しません。スキップします" >&2
        fi
    done
fi

# --- プロンプトファイル検出関数 ---
find_prompt_file() {
    local num="$1"
    local files=("${PROMPT_DIR}"/section_${num}_*.txt)
    if [[ -f "${files[0]}" ]]; then
        echo "${files[0]}"
    else
        echo ""
    fi
}

# --- セクション実行関数 ---
run_section() {
    local num="$1"
    local prompt_path
    prompt_path=$(find_prompt_file "$num")
    local branch_name="qa/section-${num}"

    if [[ -z "$prompt_path" ]]; then
        echo "エラー: セクション ${num} のプロンプトファイルが見つかりません (${PROMPT_DIR}/section_${num}_*.txt)" >&2
        return 1
    fi

    echo "=========================================="
    echo "セクション ${num} を実行中: $(basename "$prompt_path")"
    echo "=========================================="

    # ベースブランチに戻る
    git checkout "$BASE_BRANCH" || true

    # セクション用ブランチを作成（既存なら切り替え）
    echo "ブランチ ${branch_name} を作成中..."
    git checkout -b "$branch_name" 2>/dev/null || git checkout "$branch_name" || true

    # ログファイル準備
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local log_dir="./tmp/logs"
    local log_file="${log_dir}/section_${num}_${timestamp}.log"
    mkdir -p "$log_dir"

    # ccnipre で実行（-P: 完了後にコミット・PR作成）
    ccnipre -P -f "$prompt_path" 2>&1 | tee "$log_file"

    echo "セクション ${num} 完了"
    echo ""
}

# --- メイン実行 ---
echo "=========================================="
echo "QAテスト開始"
echo "ベースブランチ: ${BASE_BRANCH}"
echo "実行セクション: ${RUN_TARGETS[*]}"
echo "=========================================="

for num in "${RUN_TARGETS[@]}"; do
    run_section "$num"
done

echo "=========================================="
echo "QAテスト完了"
echo "=========================================="
