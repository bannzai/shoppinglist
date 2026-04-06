---
name: run-pr-quality-checks
description: |
  複数PRに対してコーディング規約チェックとレビューコメント対応をバッチ実行する。
  PR番号を引数として受け取り、各PRに対して
  check-coding-conventions → fix-pr-reviews を逐次実行する。
  使用例: "/run-pr-quality-checks 177 178 179"
user_invocable: true
context: fork
argument-hint: "<pr_numbers...>"
allowed-tools:
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/run_quality_checks.sh:*)
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

1. 引数の PR 番号を順に処理
2. 各 PR に対して check-coding-conventions → fix-pr-reviews を逐次実行
3. 完了済み PR はスキップ（status.json で追跡）
4. 完了サマリを出力

## オプション

- `--skills check-coding-conventions`: 規約チェックのみ実行
- `--skills fix-pr-reviews`: レビュー対応のみ実行
- 省略時: 両方実行
