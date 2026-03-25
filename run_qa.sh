#!/usr/bin/env bash
set -euo pipefail

# run_qa.sh - QAテストプラン動作確認スクリプト
#
# 使い方:
#   ./run_qa.sh        # 全セクション順次実行
#   ./run_qa.sh 1      # セクション1のみ実行
#   ./run_qa.sh 3 5 8  # セクション3, 5, 8を実行

PROMPT_DIR="./tmp/prompts"

# セクション番号とプロンプトファイルのマッピング
SECTIONS=(
  "01:section_01_auth.txt"
  "02:section_02_home.txt"
  "03:section_03_shopping_list.txt"
  "04:section_04_shopping_list_setting.txt"
  "05:section_05_group_switcher.txt"
  "06:section_06_group.txt"
  "07:section_07_shopping_location.txt"
  "08:section_08_category.txt"
  "09:section_09_setting.txt"
  "10:section_10_push_notification.txt"
  "11:section_11_force_update.txt"
  "12:section_12_firebase_functions.txt"
  "13:section_13_security_rules.txt"
  "14:section_14_realtime_sync.txt"
  "15:section_15_home_widget.txt"
  "16:section_16_edge_cases.txt"
  "17:section_17_implementation_check.txt"
  "18:section_18_existing_tests.txt"
  "19:section_19_platform_specific.txt"
)

BASE_BRANCH="manual-testing-for-first-release"

run_section() {
  local num="$1"
  local file="$2"
  local prompt_path="${PROMPT_DIR}/${file}"
  local branch_name="qa/section-${num}"

  if [ ! -f "$prompt_path" ]; then
    echo "エラー: プロンプトファイルが見つかりません: $prompt_path" >&2
    return 1
  fi

  echo "=========================================="
  echo "セクション ${num} を実行中: ${file}"
  echo "=========================================="

  # セクション用ブランチを作成（ベースブランチから）
  echo "ブランチ ${branch_name} を作成中..."
  git checkout "$BASE_BRANCH" || true
  git checkout -b "$branch_name" || git checkout "$branch_name" || true

  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local log_dir="./tmp/logs"
  local log_file="${log_dir}/section_${num}_${timestamp}.log"
  mkdir -p "$log_dir"

  ccnipre -f "$prompt_path" 2>&1 | tee "$log_file"

  # PLAN.md の変更をコミット（失敗しても続行）
  echo "PLAN.md をコミット中..."
  git add PLAN.md || true
  git commit -m "QA: セクション${num} 動作確認完了" || true

  # push して PR を作成
  echo "ブランチ ${branch_name} を push して PR を作成中..."
  git push -u origin "$branch_name" || true
  gh pr create --base "$BASE_BRANCH" --title "QA: セクション${num} 動作確認" --body "セクション${num}のQA動作確認結果" || true

  echo "セクション ${num} 完了"
  echo ""
}

if [ $# -eq 0 ]; then
  # 引数なし: 全セクション順次実行
  for entry in "${SECTIONS[@]}"; do
    num="${entry%%:*}"
    file="${entry#*:}"
    run_section "$num" "$file"
  done
else
  # 引数あり: 指定セクションのみ実行
  for target in "$@"; do
    target_padded=$(printf "%02d" "$target")
    found=0
    for entry in "${SECTIONS[@]}"; do
      num="${entry%%:*}"
      file="${entry#*:}"
      if [ "$num" = "$target_padded" ]; then
        run_section "$num" "$file"
        found=1
        break
      fi
    done
    if [ "$found" -eq 0 ]; then
      echo "エラー: セクション ${target} が見つかりません" >&2
    fi
  done
fi

echo "=========================================="
echo "QAテスト完了"
echo "=========================================="
