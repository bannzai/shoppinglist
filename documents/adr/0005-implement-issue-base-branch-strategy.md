# 0005. プレミアム機能一括実装のGitブランチ戦略

## Status

Accepted

## Context

プレミアム機能のGitHub Issue（11件）を「1 issue = 1 plan = 1 PR」で自動実装するスキル `implement-issue` を設計している。

各IssueのPRをどのブランチに向けるかの選択肢:
1. **mainに直接**: 各featureブランチを `main` から分岐し、PRも `main` へ。Issue間の依存（前のIssueで追加したコードを次のIssueが参照）を解決するために、PRマージ後に次のIssueを開始する必要がある
2. **中間ベースブランチ**: `implement-issue-{datetime}` を `main` から作成し、全featureブランチをここに集約。最終的にベースブランチを `main` にマージ

## Decision

**中間ベースブランチ方式**を採用する。

- `run_implement_issues.sh` 初回実行時に `implement-issue-{YYYYMMDD_HHMMSS}` ブランチを `main` から自動作成
- `implement_issues.json` の `base_branch` に書き戻し（レジューム時に同じブランチを使用）
- 各featureブランチはベースブランチから分岐し、PRもベースブランチに向けて作成
- Issue完了後、スクリプトがfeatureブランチをベースブランチに自動マージ
- 全Issue完了後、ユーザーが `implement-issue-{datetime}` → `main` へPRを作成

## Consequences

- 各Issueが順次ベースブランチにマージされるため、後続Issueが前のIssueのコードを参照可能
- `main` ブランチが汚れない（全体完了後にまとめてマージ）
- PRレビューは個別featureブランチ単位で行える
- 万一途中で中断しても、ベースブランチの状態で途中成果が残る
