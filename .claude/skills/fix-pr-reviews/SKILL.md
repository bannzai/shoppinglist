---
name: fix-pr-reviews
description: |
  PRのインラインレビューコメント（Gemini Code Assistant・人間レビュアー）を評価し、
  妥当な指摘を修正してfix PRを作成、ベースブランチにマージする。
  スレッドへの返信・resolve も自動で行う。
  使用例: "/fix-pr-reviews 180"
user_invocable: true
context: fork
argument-hint: "<PR number>"
allowed-tools:
  - Bash(git checkout:*)
  - Bash(git branch:*)
  - Bash(git add:*)
  - Bash(git commit:*)
  - Bash(git push:*)
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git fetch:*)
  - Bash(git pull:*)
  - Bash(gh pr view:*)
  - Bash(gh pr create:*)
  - Bash(gh pr edit:*)
  - Bash(gh pr merge:*)
  - Bash(gh pr list:*)
  - Bash(gh pr checks:*)
  - Bash(gh-pr-comments:*)
  - Bash(gh api graphql:*)
  - Bash(dart run build_runner build:*)
  - Bash(dart format:*)
  - Bash(flutter analyze:*)
  - Bash(flutter test:*)
  - Bash(flutter build:*)
  - Bash(npm run lint:*)
  - Bash(npm run build:*)
  - Bash(npm test:*)
  - Bash(ls:*)
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Agent
  - Skill
---

# fix-pr-reviews

PR のインラインレビューコメントを取得・評価し、妥当な指摘を修正する。修正後に fix PR を作成してベースブランチにマージし、スレッドへの返信・resolve を行う。

## Phase 1: PR 情報取得

1. `gh pr view $ARGUMENTS --json number,title,headRefName,baseRefName,url,state` で PR 情報を取得
2. 以下の変数を記録:
   - `PR_NUMBER`: $ARGUMENTS
   - `HEAD_BRANCH`: PR の head ブランチ
   - `BASE_BRANCH`: PR の base ブランチ
   - `PR_URL`: PR の URL
3. 「PR #${PR_NUMBER} (${PR_URL}) のレビューコメント対応を開始」と表示

## Phase 2: レビューコメント取得

1. `git fetch origin`
2. `git checkout {HEAD_BRANCH}` で PR の head ブランチに切り替え
   - **重要**: `gh-pr-comments` は現在のブランチの PR を自動検出するため、先にブランチを切り替える必要がある
3. `gh-pr-comments --no-resolved` で未解決のレビューコメントを取得
4. コメントがない場合: 「未解決のレビューコメントなし」と報告して終了

各コメントから以下を記録:
- `thread_id` (スレッド ID、`PRT_...` 形式)
- `comment.path` (ファイルパス)
- `comment.line` (行番号)
- `comment.author` (投稿者)
- `comment.body` (コメント本文)

## Phase 3: コメント評価とプラン作成

各レビューコメントについて:

1. `comment.path` のファイルを Read で読み、`comment.line` 周辺のコードを確認
2. `comment.body` の指摘内容を理解
3. プロジェクトの規約ファイル（`.claude/rules/`, `documents/`）と照合
4. 評価結果を分類（詳細は `${CLAUDE_SKILL_DIR}/references/review-evaluation-guide.md`）:

| 分類 | 条件 | アクション |
|------|------|-----------|
| **accept** | 規約違反、バグ、改善が妥当 | 修正する |
| **reject** | 誤検知、規約と矛盾、既存パターンに合致 | 理由を説明して reject |
| **already-fixed** | 既に修正済み | その旨を返信 |

5. 分類結果をプランとして表示（accept/reject/already-fixed の件数と各理由）

## Phase 4: 修正の実施

accept 分類のコメントがある場合のみ:

1. fix ブランチを作成: `git checkout -b fix/pr-reviews-pr-{PR_NUMBER}`
2. accept 分類の各コメントについて、指摘に沿ってコードを修正
3. Dart ファイルに変更がある場合: `dart format .`

## Phase 5: スレッドへの返信と resolve

全コメントに対して返信を投稿し、resolve する。
GraphQL mutation ファイルは `references/` に事前配置済み。

### 返信（accept / reject / already-fixed 共通）

```bash
gh api graphql -f thread="{THREAD_ID}" -f body="{返信内容}" -F query=@${CLAUDE_SKILL_DIR}/references/reply.graphql
```

- **accept**: 「修正しました。{修正内容の簡潔な説明}」
- **reject**: reject の理由を具体的に説明
- **already-fixed**: 「既に修正済みです」

### resolve

```bash
gh api graphql -f thread="{THREAD_ID}" -F query=@${CLAUDE_SKILL_DIR}/references/resolve.graphql
```

## Phase 6: 検証

accept 分類のコメントがあり修正を行った場合のみ。変更スコープに応じて実行:

### Flutter (lib/ に変更がある場合)
1. `dart run build_runner build`（freezed/riverpod_generator 対象の場合）
2. `flutter analyze`
3. `flutter test`
4. `flutter build ios`

### Firebase (firebase/ に変更がある場合)
`firebase/functions/` ディレクトリで:
1. `npm run lint`
2. `npm run build`
3. `npm test`

検証でエラーが出た場合は修正して再検証する。

## Phase 7: コミット & fix PR 作成

accept 分類のコメントがあり修正を行った場合のみ:

1. `git add` で変更をステージング
2. `git commit -m "fix: レビューコメント対応 (PR #${PR_NUMBER})"`
   - git add と git commit は別コマンドで実行
   - commit メッセージに Claude が author であることは書かない
3. `git push -u origin fix/pr-reviews-pr-{PR_NUMBER}`
4. fix PR を作成:
   ```
   gh pr create \
     --base {BASE_BRANCH} \
     --head fix/pr-reviews-pr-{PR_NUMBER} \
     --title "fix: レビューコメント対応 (PR #{PR_NUMBER})" \
     --body "..."
   ```
   - body に対象 PR へのリンク `#{PR_NUMBER}` を含める
   - body に accept/reject 件数と修正内容を記載
   - body に Claude が author であることは書かない

## Phase 8: CI 確認 & マージ

1. `gh pr checks` で CI の状態を確認。失敗していれば修正して再 push
2. CI が通ったら: `gh pr merge --squash --delete-branch`
3. マージ後:
   - `git checkout {BASE_BRANCH}`
   - `git pull origin {BASE_BRANCH}`

## Phase 9: ベースブランチ PR の更新

1. `gh pr list --base main --head {BASE_BRANCH} --json number --jq '.[0].number'` でベースブランチの PR 番号を取得
2. PR 番号が取得できた場合、`/update-pr-body {ベースブランチPR番号}` を実行

## エラーハンドリング

- PR が見つからない場合: エラーを報告して終了
- 未解決コメントがない場合: 「未解決コメントなし」と報告して終了
- 全コメントが reject の場合: 返信と resolve のみ行い、fix PR は作成しない
- 検証が失敗し修正不能な場合: 現状を報告して終了
- マージ競合が発生した場合: 競合を解消して再 push
