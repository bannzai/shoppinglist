---
name: run-pr-quality-checks
description: |
  複数PRに対してコーディング規約チェックとレビューコメント対応をバッチ実行する。
  PR番号を引数として受け取るか、--base でベースブランチ指定で関連PRを自動検出する。
  使用例: "/run-pr-quality-checks 177 178 179", "/run-pr-quality-checks --base feature-branch"
user_invocable: true
context: fork
argument-hint: "<pr_numbers...> | --base <branch> [--dry-run]"
allowed-tools:
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/run_quality_checks.sh:*)
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/test_skill.sh:*)
  - Bash(ls:*)
  - Read
  - Glob
---

# run-pr-quality-checks

複数 PR に対して品質チェックをバッチ実行する。

## 実行

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/run_quality_checks.sh $ARGUMENTS
```

## 処理概要

スクリプトが以下を自動実行する:

1. 引数の PR 番号（または --base で自動検出したPR）を順に処理
2. 各 PR に対して check-coding-conventions → fix-pr-reviews を逐次実行
3. 完了済み PR はスキップ（status.json で追跡）
4. 完了サマリを出力

## オプション

- `--base <branch>`: ベースブランチ指定でマージ済みPRを自動検出
- `--skills check-coding-conventions`: 規約チェックのみ実行
- `--skills fix-pr-reviews`: レビュー対応のみ実行
- `--dry-run`: 対象PRの一覧を表示して終了（`--base` と併用）
- 省略時: 両方実行

## エラーハンドリング

- PR番号が不正な場合: `gh pr view` の終了コードを確認しエラーメッセージを表示
- `--base` で対象PRが0件の場合: 「対象PRが見つかりません」と表示して終了
- check-coding-conventionsまたはfix-pr-reviewsの実行中にエラーが発生した場合: status.jsonにエラーステータスを記録し、次のPRに進む

## 検証方法

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/test_skill.sh
```
