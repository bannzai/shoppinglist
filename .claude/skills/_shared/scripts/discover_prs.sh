#!/usr/bin/env bash
set -euo pipefail

# discover_prs.sh - ベースブランチからマージ済みPRを検出
#
# 使い方:
#   bash discover_prs.sh --base <branch> [--require-unresolved-comments] [--dry-run]
#
# 出力 (stdout): JSON配列
#   [{"number":177,"title":"feat: ...","headRefName":"feature/..."},...]

BASE_BRANCH=""
REQUIRE_UNRESOLVED=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --base) BASE_BRANCH="$2"; shift 2 ;;
    --require-unresolved-comments) REQUIRE_UNRESOLVED=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help)
      echo "使い方: $0 --base <branch> [--require-unresolved-comments] [--dry-run]"
      exit 0
      ;;
    *) echo "不明な引数: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$BASE_BRANCH" ]; then
  echo "エラー: --base <branch> を指定してください" >&2
  exit 1
fi

# リポジトリ情報取得
REPO_OWNER=$(gh repo view --json owner -q '.owner.login')
REPO_NAME=$(gh repo view --json name -q '.name')

# マージ済みPR取得 + fix:/chore: タイトル除外
pr_json=$(gh pr list --search "base:${BASE_BRANCH}" --state merged \
  --json number,title,headRefName --limit 100 \
  | jq '[.[] | select(.title | test("^(fix|chore):"; "i") | not)]')

pr_count=$(echo "$pr_json" | jq 'length')

if [ "$pr_count" -eq 0 ]; then
  if [ "$DRY_RUN" = true ]; then
    echo "ベースブランチ: $BASE_BRANCH"
    echo "フィルター: fix:/chore: タイトルを除外"
    echo ""
    echo "対象PR: 0件"
  else
    echo "[]"
  fi
  exit 0
fi

# 未解決コメントフィルタリング
if [ "$REQUIRE_UNRESOLVED" = true ]; then
  filtered="[]"
  while IFS= read -r pr_num; do
    unresolved_count=$(gh api graphql \
      -f owner="$REPO_OWNER" \
      -f name="$REPO_NAME" \
      -F number="$pr_num" \
      -f query='
      query($owner:String!, $name:String!, $number:Int!) {
        repository(owner:$owner, name:$name) {
          pullRequest(number:$number) {
            reviewThreads(last:100) {
              nodes {
                isResolved
              }
            }
          }
        }
      }' | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)] | length')

    if [ "$unresolved_count" -gt 0 ]; then
      entry=$(echo "$pr_json" | jq --argjson n "$pr_num" --argjson c "$unresolved_count" \
        '[.[] | select(.number == $n)] | .[0] + {unresolvedCount: $c}')
      filtered=$(echo "$filtered" | jq --argjson e "$entry" '. + [$e]')
    fi
  done < <(echo "$pr_json" | jq -r '.[].number')
  pr_json="$filtered"
fi

# dry-run: 人間向けフォーマット出力
if [ "$DRY_RUN" = true ]; then
  echo "ベースブランチ: $BASE_BRANCH"
  echo "フィルター: fix:/chore: タイトルを除外"
  if [ "$REQUIRE_UNRESOLVED" = true ]; then
    echo "フィルター: 未解決レビューコメントありのみ"
  fi
  echo ""
  filtered_count=$(echo "$pr_json" | jq 'length')
  echo "対象PR一覧 (${filtered_count}件):"
  if [ "$REQUIRE_UNRESOLVED" = true ]; then
    echo "$pr_json" | jq -r '.[] | "  #\(.number) \(.title) (未解決コメント: \(.unresolvedCount)件)"'
  else
    echo "$pr_json" | jq -r '.[] | "  #\(.number) \(.title) (\(.headRefName))"'
  fi
  exit 0
fi

# 通常モード: JSON配列出力
echo "$pr_json"
