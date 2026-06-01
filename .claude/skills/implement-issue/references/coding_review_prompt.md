# コーディング規約レビュー: Issue #{{ISSUE_NUMBER}}

feature/premium-issue-{{ISSUE_NUMBER}} の実装がコーディング規約に適合しているか確認し、違反があれば修正する。

## 手順

### 1. 規約ファイルを読む
以下のディレクトリ内のファイルをすべて読んで規約を把握する:
- `.claude/rules/` 配下の全 `.md` ファイル

### 2. 変更差分を確認する
`git diff {{BASE_BRANCH}}...HEAD -- '*.dart' '*.ts'` で変更コードを確認する。

### 3. 規約違反を洗い出す
各規約に対して変更コードをチェックする。主な観点:
- Entity命名: フィールド名が省略されていないか
- Provider: Firestore操作が `call` クラス Provider 経由か
- 引数: `{required}` がついているか（timestamp等メタデータ除く）
- ref: build内は `ref.watch`、コールバック・操作は `ref.read`
- Analytics: ユーザー操作のコールバック先頭で `analytics.logEvent` を呼んでいるか
- Firebase Functions: GenKitで定義しているか、onDocumentCreatedトリガー不使用
- Hooks: `useState` の誤用がないか
- トランザクション: group配下のドキュメント操作で `runTransaction` を使っているか

### 4. 違反があれば修正する
発見した違反を直接修正する。修正後:
1. `git add` で変更をステージング
2. `git commit -m "fix: Issue #{{ISSUE_NUMBER}} コーディング規約違反の修正"`
3. `git push origin feature/premium-issue-{{ISSUE_NUMBER}}`

違反がなければ「規約違反なし」と報告して終了する。
