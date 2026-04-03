# プレミアム機能の一括実装: スキル & スクリプト設計

## Context

プレミアム機能のGitHub Issue（11件）を「1 issue = 1 plan = 1 PR」で順次実装するための自動化基盤を構築する。

既存の `release-test` スキルはQAテスト専用（差分分析→テストプラン→スクリーンショット検証）で、コード実装・PR作成のワークフローには対応していない。そのため新規スキル `implement-issue` を作成する。

### 対象Issue（優先度順）

| # | タイトル | 優先度 |
|---|---|---|
| 76 | テーマカラー変更 | P0 |
| 151 | AI画像認識の回数制限 | P1 |
| 152 | URLから買い物リスト生成（AI） | P1 |
| 153 | 買い物リストの表示期間制限解除 | P1 |
| 155 | リスト作成数の上限緩和 | P2 |
| 156 | グループ作成数の上限緩和 | P2 |
| 159 | リストのエクスポート | P2 |
| 160 | 買い物場所ごとのカテゴリ並び替え | P2 |
| 154 | アイテムへの写真添付 | P3 |
| 157 | 位置情報リマインダー | P3 |
| 158 | ホームウィジェット拡張 | P3 |

※ #150（広告削除）は広告未実装のため除外

---

## 成果物

### ディレクトリ構成

```
.claude/skills/implement-issue/
├── SKILL.md                          # スキル定義
├── references/
│   ├── common_rules.md               # 全プロンプト共通ルール
│   └── prompt_template.md            # プロンプトテンプレート
└── scripts/
    ├── generate_issue_prompts.sh      # プロンプト生成スクリプト
    └── run_implement_issues.sh        # オーケストレーションスクリプト

implement_issues.json                 # Issue定義（スクリプトの入力）
tmp/implement-issue/                        # 実行時生成（.gitignore対象）
├── prompts/                          # Issue別プロンプトファイル
├── checklists/                       # 動作確認チェックリスト
├── logs/                             # 実行ログ
└── status.json                       # 進捗管理（レジューム用）
```

---

## 1. SKILL.md

**ファイル**: `.claude/skills/implement-issue/SKILL.md`

```yaml
---
name: implement-issue
description: |
  GitHub Issueの仕様を読み取り、実装プラン作成→実装→検証→PR作成を一括実行する。
  プレミアム機能issueの実装に使用。
  使用例: "/implement-issue 76"
user_invocable: true
argument-hint: "<issue number>"
allowed-tools:
  - Bash(git checkout:*)
  - Bash(git branch:*)
  - Bash(git add:*)
  - Bash(git commit:*)
  - Bash(git push:*)
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(gh issue view:*)
  - Bash(gh pr create:*)
  - Bash(gh pr view:*)
  - Bash(gh pr list:*)
  - Bash(dart run build_runner build:*)
  - Bash(flutter analyze:*)
  - Bash(flutter test:*)
  - Bash(flutter build:*)
  - Bash(npm run lint:*)
  - Bash(npm run build:*)
  - Bash(npm test:*)
  - Bash(mkdir:*)
  - Bash(ls:*)
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Agent
---

# implement-issue スキル

GitHub Issue の仕様を読み取り、実装→検証→PR作成までを実行する。

## Phase 1: Issue 読み込み

1. `gh issue view $ARGUMENTS --repo bannzai/shoppinglist` で Issue 全文を取得
2. `gh issue view $ARGUMENTS --repo bannzai/shoppinglist --comments` でコメント取得
3. スコープ判定: Flutter変更（`lib/`）/ Firebase変更（`firebase/`）/ 両方

## Phase 2: コードベース探索

1. `CLAUDE.md` と `.claude/rules/plan-checklist.md` を読む
2. 関連する既存Feature（`lib/features/` 配下）を探索しパターン把握
3. 既存Entity（`lib/entity/`）でデータモデル確認
4. `lib/utils/purchase/purchase.dart` で `isPremium` 判定の既存パターン確認
5. Firebase変更がある場合は `firebase/functions/src/functions/` の既存関数パターン確認

## Phase 3: プラン作成

1. ブランチ `feature/premium-issue-{$ARGUMENTS}` をベースブランチ（`implement_issues.json` の `base_branch`）から作成
2. `plans/` にプランファイル作成
3. プランには以下を含める:
   - 変更対象ファイル一覧
   - ファイルごとの具体的なコード提案（コードブロック）
   - `.claude/rules/plan-checklist.md` のチェックリスト

## Phase 4: 実装 & 検証

1. プランに沿って実装
2. テストを作成:
   - Widget Test: 新規・変更したWidgetに対して積極的に書く（isPremium分岐、UI表示条件等）
   - Maestro E2E: 実装した機能に対応する maestro flow を `maestro/flows/` に新規作成する
   - Firebase Functions テスト: 新規/変更関数に対するJestテスト
3. 検証を実行（該当するもの全て）:
   - `dart run build_runner build`（freezed/riverpod_generator対象の場合）
   - `flutter analyze`
   - `flutter test`
   - `flutter build ios`
   - `flutter build apk`
   - `maestro test maestro/flows/`
   - Firebase変更がある場合: `firebase/functions/functions/` で `npm run lint`, `npm run build`, `npm test`
4. エラーがあれば修正して再検証

## Phase 4.5: 動作確認チェックリスト作成

実装完了後、`tmp/implement-issue/checklists/issue_{$ARGUMENTS}_checklist.md` に動作確認チェックリストを作成する。

フォーマット（PLAN.md準拠）:
```markdown
# Issue #{$ARGUMENTS} 動作確認チェックリスト

## 前提
- テスト環境: {環境情報}
- 生成日: {YYYY-MM-DD}

---

## {機能名}

### {サブカテゴリ}
- [ ] **{テスト項目}**: {期待動作}

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>
<img src="（gh-r2-imageでアップロードしたURL）" width="320">
</details>
```

ルール:
- 画像は `<img src="URL" width="320">` タグで埋め込む
- mobile-mcp/maestroで確認困難な項目は「なぜ困難か」を明記し代替手段を提示
- チェック項目は `- [ ]` 形式
- 実行して確認が取れたら `- [x]` に更新

## Phase 5: Commit & PR

1. 変更を論理単位で git commit する（git add と git commit は別コマンドで実行）
2. `git push -u origin feature/premium-issue-{$ARGUMENTS}`
3. `gh pr create --base {ベースブランチ} --title "{Issue タイトル}" --body "..."` で PR 作成
   - body に `Closes #{$ARGUMENTS}` を含める
   - body に実装内容の説明を記載
```

---

## 2. references/common_rules.md

**ファイル**: `.claude/skills/implement-issue/references/common_rules.md`

```markdown
# 共通ルール

## プロジェクト規約
- CLAUDE.md を読んでプロジェクト全体の規約を把握する
- .claude/rules/plan-checklist.md を読んで検証チェックリストの形式を把握する
- 既存の lib/features/ の構成パターンを踏襲する（Feature ごとにディレクトリ）

## コーディング規約
- Entity のフィールド名は省略しない
- Firestore操作は `call` クラス Provider 経由
- 関数・コンストラクタ引数は `{required}` をつける（timestamp等メタデータ除く）
- build内は ref.watch、コールバック・操作は ref.read
- Firebase Functions は GenKit で定義する。onDocumentCreated/onDocumentUpdated トリガー禁止

## ブランチ & PR
- ブランチ名: `feature/premium-issue-{{ISSUE_NUMBER}}`
- ベースブランチ: `{{BASE_BRANCH}}`
- git add と git commit は別コマンドで実行する
- PR body に `Closes #{{ISSUE_NUMBER}}` を含める

## テスト作成
- Widget Test: 新規・変更したWidgetに対して積極的に書く（isPremium分岐、UI表示条件等）
- Maestro E2E: 実装した機能に対応する maestro flow を `maestro/flows/` に新規作成する
- Firebase Functions: 新規/変更関数に対するJestテスト

## 検証コマンド
Flutter 変更がある場合:
1. `dart run build_runner build`
2. `flutter analyze`
3. `flutter test`
4. `flutter build ios`
5. `flutter build apk`
6. `maestro test maestro/flows/`

Firebase 変更がある場合（`firebase/functions/functions/` で実行）:
1. `npm run lint`
2. `npm run build`
3. `npm test`

## 動作確認チェックリスト
- 実装完了後に `tmp/implement-issue/checklists/issue_{{ISSUE_NUMBER}}_checklist.md` を作成
- PLAN.md のフォーマットに準拠（セクション別チェック項目 + 動作確認エビデンス）
- 画像は `<img src="URL" width="320">` タグ
```

---

## 3. references/prompt_template.md

**ファイル**: `.claude/skills/implement-issue/references/prompt_template.md`

```markdown
GitHub Issue #{{ISSUE_NUMBER}} の仕様を実装してください。

## Issue 情報
- タイトル: {{ISSUE_TITLE}}
- 優先度: {{PRIORITY}}
- URL: https://github.com/bannzai/shoppinglist/issues/{{ISSUE_NUMBER}}

## 手順

1. `gh issue view {{ISSUE_NUMBER}} --repo bannzai/shoppinglist` で Issue の全内容を確認
2. `gh issue view {{ISSUE_NUMBER}} --repo bannzai/shoppinglist --comments` でコメントも確認
3. CLAUDE.md と .claude/rules/plan-checklist.md を読む
4. 関連する既存実装（lib/features/ 配下）を探索してパターンを把握
5. lib/utils/purchase/purchase.dart の isPremium 判定パターンを確認
6. ブランチ `feature/premium-issue-{{ISSUE_NUMBER}}` を `{{BASE_BRANCH}}` から作成
7. plans/ にプランファイルを作成（plan-checklist.md のチェックリスト付き）
8. プランに沿って実装
9. テストを作成:
   - Widget Test: 新規・変更Widgetに対して積極的に書く（isPremium分岐、UI表示条件等）
   - Maestro E2E: 実装した機能に対応する maestro flow を maestro/flows/ に新規作成
   - Firebase Functions テスト: 新規/変更関数に対するJestテスト
10. 検証を実行:
    - dart run build_runner build
    - flutter analyze
    - flutter test
    - flutter build ios
    - flutter build apk
    - maestro test maestro/flows/
    - (Firebase変更がある場合) firebase/functions/functions/ で npm run lint, npm run build, npm test
11. 検証エラーがあれば修正
12. 動作確認チェックリストを `tmp/implement-issue/checklists/issue_{{ISSUE_NUMBER}}_checklist.md` に作成（PLAN.md形式）
13. 変更を論理単位で git commit（git add と git commit は別コマンド）
14. git push -u origin feature/premium-issue-{{ISSUE_NUMBER}}
15. gh pr create --base {{BASE_BRANCH}} --title "{{ISSUE_TITLE}}" で PR 作成。body に "Closes #{{ISSUE_NUMBER}}" を含める

{{COMMON_RULES}}
```

---

## 4. implement_issues.json（Issue定義ファイル）

**ファイル**: `implement_issues.json`（プロジェクトルート）

スクリプトにIssue情報をハードコードせず、JSON設定ファイルから読み込む。

`base_branch` は `run_implement_issues.sh` の初回実行時に `implement-issue-{YYYYMMDD_HHMMSS}` 形式で `main` から自動作成され、JSONに書き戻される。全featureブランチはこのベースブランチから分岐し、PRもここにマージする。最終的にベースブランチを `main` にマージする。

```json
{
  "base_branch": "",
  "issues": [
    { "number": 76,  "priority": "P0", "slug": "theme_color",       "title": "テーマカラー変更" },
    { "number": 151, "priority": "P1", "slug": "ai_image_limit",    "title": "AI画像認識の回数制限" },
    { "number": 152, "priority": "P1", "slug": "url_shopping_list",  "title": "URLから買い物リスト生成（AI）" },
    { "number": 153, "priority": "P1", "slug": "display_period",     "title": "買い物リストの表示期間制限解除" },
    { "number": 155, "priority": "P2", "slug": "list_limit",         "title": "リスト作成数の上限緩和" },
    { "number": 156, "priority": "P2", "slug": "group_limit",        "title": "グループ作成数の上限緩和" },
    { "number": 159, "priority": "P2", "slug": "export",             "title": "リストのエクスポート" },
    { "number": 160, "priority": "P2", "slug": "category_sort",      "title": "買い物場所ごとのカテゴリ並び替え" },
    { "number": 154, "priority": "P3", "slug": "photo_attachment",    "title": "アイテムへの写真添付" },
    { "number": 157, "priority": "P3", "slug": "location_reminder",   "title": "位置情報リマインダー" },
    { "number": 158, "priority": "P3", "slug": "home_widget",         "title": "ホームウィジェット拡張" }
  ]
}
```

Issue追加・順序変更はこのJSONのみ編集すればよい。

---

## 5. scripts/generate_issue_prompts.sh

**ファイル**: `.claude/skills/implement-issue/scripts/generate_issue_prompts.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# generate_issue_prompts.sh - Issue別プロンプトファイル生成
# 使い方: bash generate_issue_prompts.sh --config ./implement_issues.json [--output ./tmp/implement-issue/prompts]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE=""
OUTPUT_DIR="./tmp/implement-issue/prompts"

while [[ $# -gt 0 ]]; do
  case $1 in
    --config) CONFIG_FILE="$2"; shift 2 ;;
    --output) OUTPUT_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "Usage: $0 --config <json_file> [--output <dir>]" >&2
  exit 1
fi

BASE_BRANCH=$(jq -r '.base_branch' "$CONFIG_FILE")
ISSUE_COUNT=$(jq '.issues | length' "$CONFIG_FILE")

if [ -z "$BASE_BRANCH" ] || [ "$BASE_BRANCH" = "null" ]; then
  echo "エラー: base_branch が未設定です。先に run_implement_issues.sh を実行してベースブランチを作成してください" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

TEMPLATE=$(cat "${SKILL_DIR}/references/prompt_template.md")
COMMON_RULES_TEMPLATE=$(cat "${SKILL_DIR}/references/common_rules.md")
COMMON_RULES_TEMPLATE="${COMMON_RULES_TEMPLATE//\{\{BASE_BRANCH\}\}/$BASE_BRANCH}"

for i in $(seq 0 $((ISSUE_COUNT - 1))); do
  num=$(jq -r ".issues[$i].number" "$CONFIG_FILE")
  priority=$(jq -r ".issues[$i].priority" "$CONFIG_FILE")
  slug=$(jq -r ".issues[$i].slug" "$CONFIG_FILE")
  title=$(jq -r ".issues[$i].title" "$CONFIG_FILE")

  # COMMON_RULES内の{{ISSUE_NUMBER}}もIssueごとに置換する
  common_rules="${COMMON_RULES_TEMPLATE//\{\{ISSUE_NUMBER\}\}/$num}"

  prompt="$TEMPLATE"
  prompt="${prompt//\{\{ISSUE_NUMBER\}\}/$num}"
  prompt="${prompt//\{\{ISSUE_TITLE\}\}/$title}"
  prompt="${prompt//\{\{PRIORITY\}\}/$priority}"
  prompt="${prompt//\{\{BASE_BRANCH\}\}/$BASE_BRANCH}"
  prompt="${prompt//\{\{COMMON_RULES\}\}/$common_rules}"

  output_file="${OUTPUT_DIR}/issue_${num}_${slug}.txt"
  echo "$prompt" > "$output_file"
  echo "Generated: $output_file"
done

echo ""
echo "全 ${ISSUE_COUNT} 件のプロンプトを生成しました: $OUTPUT_DIR"
```

---

## 6. scripts/run_implement_issues.sh

**ファイル**: `.claude/skills/implement-issue/scripts/run_implement_issues.sh`

```bash
#!/usr/bin/env bash
set -uo pipefail

# run_implement_issues.sh - Issue一括実装スクリプト
#
# 使い方:
#   bash run_implement_issues.sh --config ./implement_issues.json          # 全Issue順次実行
#   bash run_implement_issues.sh --config ./implement_issues.json 76 151  # 指定Issueのみ

PROMPT_DIR="./tmp/implement-issue/prompts"
LOG_DIR="./tmp/implement-issue/logs"
STATUS_FILE="./tmp/implement-issue/status.json"
CONFIG_FILE=""
TARGETS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --config) CONFIG_FILE="$2"; shift 2 ;;
    *) TARGETS+=("$1"); shift ;;
  esac
done

if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "Usage: $0 --config <json_file> [issue_numbers...]" >&2
  exit 1
fi

ISSUE_COUNT=$(jq '.issues | length' "$CONFIG_FILE")

mkdir -p "$LOG_DIR"

if [ ! -f "$STATUS_FILE" ]; then
  echo '{}' > "$STATUS_FILE"
fi

# ベースブランチの作成または復元
BASE_BRANCH=$(jq -r '.base_branch' "$CONFIG_FILE")
if [ -z "$BASE_BRANCH" ] || [ "$BASE_BRANCH" = "null" ]; then
  BASE_BRANCH="implement-issue-$(date +"%Y%m%d_%H%M%S")"
  echo "ベースブランチを作成: $BASE_BRANCH"
  git checkout main
  git pull origin main
  git checkout -b "$BASE_BRANCH"
  git push -u origin "$BASE_BRANCH"

  # JSONに書き戻し
  tmp_json=$(mktemp)
  jq --arg b "$BASE_BRANCH" '.base_branch = $b' "$CONFIG_FILE" > "$tmp_json"
  mv "$tmp_json" "$CONFIG_FILE"
  echo "implement_issues.json を更新: base_branch=$BASE_BRANCH"
else
  echo "既存ベースブランチを使用: $BASE_BRANCH"
  git checkout "$BASE_BRANCH"
  git pull origin "$BASE_BRANCH"
fi

get_status() {
  jq -r --arg key "$1" '.[$key].status // "pending"' "$STATUS_FILE"
}

update_status() {
  local num="$1" status="$2" pr_url="${3:-}"
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local tmp
  tmp=$(mktemp)
  jq --arg k "$num" --arg s "$status" --arg t "$timestamp" --arg p "$pr_url" \
    '.[$k] = {status: $s, timestamp: $t, pr_url: $p}' "$STATUS_FILE" > "$tmp"
  mv "$tmp" "$STATUS_FILE"
}

should_run() {
  local num="$1"
  if [ ${#TARGETS[@]} -eq 0 ]; then
    return 0
  fi
  for t in "${TARGETS[@]}"; do
    if [ "$t" = "$num" ]; then
      return 0
    fi
  done
  return 1
}

run_issue() {
  local num="$1"
  local slug="$2"
  local prompt_path="${PROMPT_DIR}/issue_${num}_${slug}.txt"

  if [ ! -f "$prompt_path" ]; then
    echo "エラー: プロンプトファイルが見つかりません: $prompt_path" >&2
    return 1
  fi

  local current_status
  current_status=$(get_status "$num")
  if [ "$current_status" = "completed" ]; then
    echo "Issue #${num}: 完了済み、スキップ"
    return 0
  fi

  if gh pr list --repo bannzai/shoppinglist --head "feature/premium-issue-${num}" --json state --jq '.[0].state' 2>/dev/null | grep -q "OPEN"; then
    echo "Issue #${num}: PR既存、スキップ"
    update_status "$num" "completed"
    return 0
  fi

  echo "=========================================="
  echo "Issue #${num} を実装中"
  echo "=========================================="

  git checkout "$BASE_BRANCH"

  local stashed=false
  if [ -n "$(git status --porcelain)" ]; then
    echo "Warning: dirty working tree. Stashing..."
    git stash
    stashed=true
  fi

  update_status "$num" "in_progress"

  local ts
  ts=$(date +"%Y%m%d_%H%M%S")
  local log_file="${LOG_DIR}/issue_${num}_${ts}.log"

  set +e
  ccnipre -P -f "$prompt_path" 2>&1 | tee "$log_file"
  local exit_code=$?
  set -e

  if [ $exit_code -eq 0 ]; then
    local pr_url
    pr_url=$(gh pr list --repo bannzai/shoppinglist --head "feature/premium-issue-${num}" --json url --jq '.[0].url' 2>/dev/null || echo "")
    update_status "$num" "completed" "$pr_url"
    echo "Issue #${num}: 完了 ${pr_url}"

    # PRをベースブランチにマージ（次のIssueが前のIssueのコードを参照できるようにする）
    echo "Issue #${num}: ベースブランチにマージ中..."
    git checkout "$BASE_BRANCH"
    git merge "feature/premium-issue-${num}" --no-edit
    git push origin "$BASE_BRANCH"
    echo "Issue #${num}: ベースブランチへのマージ完了"
  else
    update_status "$num" "failed"
    echo "Issue #${num}: 失敗（ログ: ${log_file}）"
    git checkout "$BASE_BRANCH" 2>/dev/null || true
  fi

  if [ "$stashed" = true ]; then
    echo "Restoring stashed changes..."
    git stash pop || echo "Warning: git stash pop failed"
  fi

  echo ""
}

# プロンプト生成（base_branchが確定した状態で実行）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "プロンプトを生成中..."
bash "${SCRIPT_DIR}/generate_issue_prompts.sh" --config "$CONFIG_FILE" --output "$PROMPT_DIR"

# メインループ: JSONからIssueを読み込み
for i in $(seq 0 $((ISSUE_COUNT - 1))); do
  num=$(jq -r ".issues[$i].number" "$CONFIG_FILE")
  slug=$(jq -r ".issues[$i].slug" "$CONFIG_FILE")

  should_run "$num" || continue
  run_issue "$num" "$slug"
done

echo "=========================================="
echo "実装完了サマリ:"
jq -r 'to_entries[] | "  #\(.key): \(.value.status) \(.value.pr_url // "")"' "$STATUS_FILE"
echo "=========================================="
```

---

## 実行フロー

```bash
# Step 1: ベースブランチ作成 & 全Issue実装（初回実行時にブランチ自動作成 → JSONに書き戻し）
bash .claude/skills/implement-issue/scripts/run_implement_issues.sh --config ./implement_issues.json

# Step 1.5: プロンプトのみ生成したい場合（base_branch が設定済みであること）
bash .claude/skills/implement-issue/scripts/generate_issue_prompts.sh --config ./implement_issues.json

# 特定Issueのみ
bash .claude/skills/implement-issue/scripts/run_implement_issues.sh --config ./implement_issues.json 76 151

# 単独実行（インタラクティブ）
/implement-issue 76

# 全Issue完了後: ベースブランチ → main へPR作成（手動）
gh pr create --base main --head implement-issue-{datetime} --title "プレミアム機能一括実装"
```

---

## Git ワークフロー

```
main
 └── implement-issue-{datetime}  ← ベースブランチ（mainから作成）
      ├── feature/premium-issue-76   → PR → マージ → ベースブランチ
      ├── feature/premium-issue-151  → PR → マージ → ベースブランチ
      ├── feature/premium-issue-152  → PR → マージ → ベースブランチ
      └── ...
      最終的に implement-issue-{datetime} → main へマージ
```

- `run_implement_issues.sh` 初回実行時に `implement-issue-{YYYYMMDD_HHMMSS}` ブランチを `main` から作成
- 各featureブランチはベースブランチから分岐し、PRもベースブランチに向けて作成
- Issue完了後、スクリプトが自動でベースブランチにマージ（次のIssueが前のコードを参照可能）
- `status.json` でレジューム可能（完了済みIssueはスキップ）
- 全Issue完了後、ユーザーが `implement-issue-{datetime}` → `main` へPRを作成・マージ

---

## release-test スキルとの比較

| 観点 | release-test | implement-issue |
|---|---|---|
| 目的 | QA検証 | コード実装 |
| コード変更 | 最小限 | Feature実装 |
| 入力 | RELEASE_TEST_PLAN.md | GitHub Issue |
| ブランチ | `qa/section-{NN}` | `feature/premium-issue-{N}` |
| レジューム | セクション番号指定 | `status.json` |
| PR内容 | QAエビデンス | 実装コード |
