PR #{{PR_NUMBER}} ({{PR_URL}}) のコーディング規約チェックと違反修正を行ってください。

## PR 情報
- PR: #{{PR_NUMBER}}
- URL: {{PR_URL}}
- HEAD ブランチ: {{HEAD_BRANCH}}
- BASE ブランチ: {{BASE_BRANCH}}

## 手順

1. `.claude/rules/` 配下の全 `.md` ファイルを読み込んで規約を把握する
2. `documents/` 配下の全 `.md` ファイルを読み込む
3. `CLAUDE.md` を読み込む
4. `git fetch origin`
5. `git checkout {{HEAD_BRANCH}}`
6. `git diff origin/{{BASE_BRANCH}}...HEAD -- '*.dart' '*.ts'` で変更コードを取得
7. `git diff origin/{{BASE_BRANCH}}...HEAD --name-only` で変更ファイル一覧を取得
8. 変更ファイルが `.dart` か `.ts` かでスコープを判定（Flutter / Firebase / 両方）
9. 読み込んだ規約に対して差分コードをチェックし、違反一覧を作成する（ファイルパス、行番号、違反内容、修正方針）
10. fix ブランチを作成: `git checkout -b fix/coding-conventions-pr-{{PR_NUMBER}}`
11. 違反を直接修正する（違反がなかった場合は修正なしで続行）
12. Dart ファイルに変更がある場合: `dart format .`
13. 変更スコープに応じて検証を実行する
14. `git add` で変更をステージング
15. `git diff --cached` で差分を確認し、修正がなければ「規約違反なし」と報告して終了
16. `git commit -m "fix: コーディング規約違反の修正 (PR #{{PR_NUMBER}})"`
17. `git push -u origin fix/coding-conventions-pr-{{PR_NUMBER}}`
18. `gh pr create --base {{HEAD_BRANCH}} --head fix/coding-conventions-pr-{{PR_NUMBER}} --title "fix: コーディング規約違反の修正 (PR #{{PR_NUMBER}})"` で fix PR を作成。body に対象PR `#{{PR_NUMBER}}` へのリンクと違反一覧・修正内容を記載
19. `gh pr checks` で CI の状態を確認。失敗していれば修正して再 push
20. CI が通ったら: `gh pr merge --squash --delete-branch`
21. `git checkout {{HEAD_BRANCH}}` && `git pull origin {{HEAD_BRANCH}}`
22. `gh pr list --base {{BASE_BRANCH}} --head {{HEAD_BRANCH}} --json number --jq '.[0].number'` でベースブランチの PR 番号を取得し、取得できた場合は `/update-pr-body {ベースブランチPR番号}` を実行

{{COMMON_RULES}}
