# Gemini Code Assistant レビュー反映: Issue #{{ISSUE_NUMBER}}

PR #{{PR_NUMBER}} に対する Gemini Code Assistant のレビューコメントを確認し、妥当な指摘のみ反映する。

## 重要な注意事項
- **Gemini Code Assistant の指摘が間違いである可能性は十分にある**
- 各指摘について、プロジェクトの規約（.claude/rules/）・既存コードのパターン・技術的正確性を基準に妥当性を判断する
- 判断に迷う場合は修正しない（保守的に判断する）
- 指摘がプロジェクト固有の規約と矛盾する場合、**プロジェクト規約を優先**する
- Geminiが提案するコード変更が既存パターンと合わない場合は却下する

## 手順

### 1. レビューコメント取得
以下のコマンドでGeminiのレビューコメントを取得する:
```
gh api repos/bannzai/shoppinglist/pulls/{{PR_NUMBER}}/comments \
  --jq '.[] | select(.user.login == "gemini-code-assist[bot]") | {path: .path, line: .line, body: .body}'
```

コメントがなければ「Geminiレビューコメントなし」と報告して終了する。

### 2. 各コメントの妥当性判断
各コメントについて以下を確認:
1. 指摘されたファイル・行を読み、コンテキストを理解する
2. .claude/rules/ 配下の規約と照合する
3. 技術的に正しいか検証する
4. 既存コードのパターンと整合するか確認する

判断結果を記録:
- **採用**: 技術的に正しく、プロジェクト規約に沿っている
- **却下**: 技術的に間違い、プロジェクト規約と矛盾、または既存パターンと不整合
- 却下理由を必ず明記する

### 3. 採用した指摘のみ修正
修正後:
1. `git add` で変更をステージング
2. `git commit -m "fix: Issue #{{ISSUE_NUMBER}} Gemini Code Assistantレビュー指摘反映"`
3. `git push origin feature/premium-issue-{{ISSUE_NUMBER}}`

修正がなければ「反映なし」と報告して終了する。
