---
name: check-coding-conventions
description: |
  PRの変更コードがコーディング規約に準拠しているか検査し、違反があれば修正PRを作成してベースブランチにマージする。
  PR番号を引数として受け取り、差分コードを全規約ファイルと照合して違反を検出・自動修正する。
  使用例: "/check-coding-conventions 180"
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

# check-coding-conventions

PR の変更コードをプロジェクトのコーディング規約と照合し、違反を検出・修正する。修正がある場合は fix PR を作成してベースブランチにマージする。

## Phase 1: PR 情報取得

1. `gh pr view $ARGUMENTS --json number,title,headRefName,baseRefName,url,state` で PR 情報を取得
2. 以下の変数を記録:
   - `PR_NUMBER`: $ARGUMENTS
   - `HEAD_BRANCH`: PR の head ブランチ
   - `BASE_BRANCH`: PR の base ブランチ
   - `PR_URL`: PR の URL
3. 「PR #${PR_NUMBER} (${PR_URL}) のコーディング規約チェックを開始」と表示

## Phase 2: 規約ファイルの読み込み

以下のファイルをすべて読み込んで規約を把握する:

1. `.claude/rules/` 配下の全 `.md` ファイル
2. `documents/` 配下の全 `.md` ファイル
3. `CLAUDE.md`

詳細なチェック観点は `${CLAUDE_SKILL_DIR}/references/convention-checklist.md` を参照。

## Phase 3: 差分の取得とチェック

1. `git fetch origin`
2. `git checkout {HEAD_BRANCH}`
3. `git diff origin/{BASE_BRANCH}...HEAD -- '*.dart' '*.ts'` で変更コードを取得
4. `git diff origin/{BASE_BRANCH}...HEAD --name-only` で変更ファイル一覧を取得
5. 変更ファイルが `.dart` か `.ts` かでスコープを判定（Flutter / Firebase / 両方）
6. 各規約に対して差分コードをチェック（references/convention-checklist.md の観点に従う）
7. 違反がなければ「規約違反なし」と報告して終了

## Phase 4: プラン作成 & 違反修正

1. 検出した違反一覧をプランとして表示（ファイルパス、行番号、違反内容、修正方針）
2. fix ブランチを作成: `git checkout -b fix/coding-conventions-pr-{PR_NUMBER}`
3. 違反を直接修正
4. Dart ファイルに変更がある場合: `dart format .`

## Phase 5: 検証

変更スコープに応じて該当する検証をすべて実行:

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

## Phase 6: コミット & fix PR 作成

1. `git add` で変更をステージング
2. `git commit -m "fix: コーディング規約違反の修正 (PR #${PR_NUMBER})"`
   - git add と git commit は別コマンドで実行
   - commit メッセージに Claude が author であることは書かない
3. `git push -u origin fix/coding-conventions-pr-{PR_NUMBER}`
4. fix PR を作成:
   ```
   gh pr create \
     --base {BASE_BRANCH} \
     --head fix/coding-conventions-pr-{PR_NUMBER} \
     --title "fix: コーディング規約違反の修正 (PR #{PR_NUMBER})" \
     --body "..."
   ```
   - body に対象 PR へのリンク `#{PR_NUMBER}` を含める
   - body に違反一覧と修正内容を記載
   - body に Claude が author であることは書かない

## Phase 7: CI 確認 & マージ

1. `gh pr checks` で CI の状態を確認。失敗していれば修正して再 push
2. CI が通ったら: `gh pr merge --squash --delete-branch`
3. マージ後:
   - `git checkout {BASE_BRANCH}`
   - `git pull origin {BASE_BRANCH}`

## Phase 8: ベースブランチ PR の更新

1. `gh pr list --base main --head {BASE_BRANCH} --json number --jq '.[0].number'` でベースブランチの PR 番号を取得
2. PR 番号が取得できた場合、`/update-pr-body {ベースブランチPR番号}` を実行

## エラーハンドリング

- PR が見つからない場合: エラーを報告して終了
- 規約違反がない場合: 「規約違反なし」と報告して終了
- 検証が失敗し修正不能な場合: 現状を報告して終了（fix PR は作成しない）
- マージ競合が発生した場合: 競合を解消して再 push
