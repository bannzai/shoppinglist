PR #{{PR_NUMBER}} ({{PR_URL}}) のコーディング規約チェックと違反修正を行ってください。

## PR 情報
- PR: #{{PR_NUMBER}}
- URL: {{PR_URL}}
- HEAD ブランチ: {{HEAD_BRANCH}}
- BASE ブランチ: {{BASE_BRANCH}}

## 手順

### 1. 規約ファイルの読み込み

以下のファイルをすべて読み込んで規約を把握する:

1. `.claude/rules/` 配下の全 `.md` ファイル
2. `documents/` 配下の全 `.md` ファイル
3. `CLAUDE.md`

### 2. 差分の取得とチェック

1. `git fetch origin`
2. `git checkout {{HEAD_BRANCH}}`
3. `git diff origin/{{BASE_BRANCH}}...HEAD -- '*.dart' '*.ts'` で変更コードを取得
4. `git diff origin/{{BASE_BRANCH}}...HEAD --name-only` で変更ファイル一覧を取得
5. 変更ファイルが `.dart` か `.ts` かでスコープを判定（Flutter / Firebase / 両方）
6. 読み込んだ規約に対して差分コードをチェック
7. 違反がなければ「規約違反なし」と報告して終了

### 3. 違反修正

1. 検出した違反一覧をプランとして表示（ファイルパス、行番号、違反内容、修正方針）
2. fix ブランチを作成: `git checkout -b fix/coding-conventions-pr-{{PR_NUMBER}}`
3. 違反を直接修正
4. Dart ファイルに変更がある場合: `dart format .`

### 4. 検証

変更スコープに応じて該当する検証をすべて実行する。

### 5. コミット & fix PR 作成

### 6. CI 確認 & マージ

### 7. ベースブランチ PR の更新

{{COMMON_RULES}}
