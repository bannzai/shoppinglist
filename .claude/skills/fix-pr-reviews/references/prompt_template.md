PR #{{PR_NUMBER}} ({{PR_URL}}) のレビューコメント対応を行ってください。

## PR 情報
- PR: #{{PR_NUMBER}}
- URL: {{PR_URL}}
- HEAD ブランチ: {{HEAD_BRANCH}}
- BASE ブランチ: {{BASE_BRANCH}}

## 手順

1. `git fetch origin`
2. `git checkout {{HEAD_BRANCH}}` で PR の head ブランチに切り替え
3. `gh-pr-comments --no-resolved` で未解決のレビューコメントを取得する
4. 各コメントから `thread_id`（`PRT_...`形式）、`comment.path`、`comment.line`、`comment.author`、`comment.body` を記録する
5. `.claude/rules/` と `documents/` の規約ファイルを読み込む
6. 各コメントについて `comment.path` のファイルを Read で読み、`comment.line` 周辺のコードを確認する
7. 各コメントを `.claude/skills/fix-pr-reviews/references/review-evaluation-guide.md` の基準に従って accept / reject / already-fixed に分類する
8. 分類結果をプランとして記録する（accept/reject/already-fixed の件数と各理由）
9. fix ブランチを作成: `git checkout -b fix/pr-reviews-pr-{{PR_NUMBER}}`
10. accept 分類の各コメントについて、指摘に沿ってコードを修正する（accept がなければ修正なしで続行）
11. Dart ファイルに変更がある場合: `dart format .`
12. 全コメントに対して返信を投稿する（accept: 「修正しました。{説明}」、reject: 理由の説明、already-fixed: 「既に修正済みです」）
    ```bash
    gh api graphql -f thread="{THREAD_ID}" -f body="{返信内容}" -F query=@{{REPLY_GRAPHQL_PATH}}
    ```
13. 全コメントのスレッドを resolve する
    ```bash
    gh api graphql -f thread="{THREAD_ID}" -F query=@{{RESOLVE_GRAPHQL_PATH}}
    ```
14. 変更スコープに応じて検証を実行する
15. `git add` で変更をステージング
16. `git diff --cached` で差分を確認し、修正がなければ「修正対象のコメントなし」と報告して終了
17. `git commit -m "fix: レビューコメント対応 (PR #{{PR_NUMBER}})"`
18. `git push -u origin fix/pr-reviews-pr-{{PR_NUMBER}}`
19. `gh pr create --base {{HEAD_BRANCH}} --head fix/pr-reviews-pr-{{PR_NUMBER}} --title "fix: レビューコメント対応 (PR #{{PR_NUMBER}})"` で fix PR を作成。body に対象PR `#{{PR_NUMBER}}` へのリンクと accept/reject 件数・修正内容を記載
20. `gh pr checks` で CI の状態を確認。失敗していれば修正して再 push
21. CI が通ったら: `gh pr merge --squash --delete-branch`
22. `git checkout {{HEAD_BRANCH}}` && `git pull origin {{HEAD_BRANCH}}`
23. `gh pr list --base main --head {{HEAD_BRANCH}} --json number --jq '.[0].number'` でベースブランチの PR 番号を取得し、取得できた場合は `/update-pr-body {ベースブランチPR番号}` を実行

{{COMMON_RULES}}
