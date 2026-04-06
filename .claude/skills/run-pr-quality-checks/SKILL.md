---
name: run-pr-quality-checks
description: |
  複数PRに対してコーディング規約チェックとレビューコメント対応をバッチ実行する。
  PR番号リストを含むJSON設定ファイルを受け取り、各PRに対して
  check-coding-conventions → fix-pr-reviews を逐次実行する。
  使用例: "/run-pr-quality-checks --config ./pr_quality_checks.json"
user_invocable: true
context: fork
argument-hint: "--config <json_file> [pr_numbers...]"
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

1. JSON 設定ファイルから PR 番号リストを読み込み
2. 各 PR に対して check-coding-conventions → fix-pr-reviews を逐次実行
3. 完了済み PR はスキップ（status.json で追跡）
4. 完了サマリを出力

## 設定 JSON 形式

```json
{
  "pr_numbers": [177, 178, 179],
  "skills": ["check-coding-conventions", "fix-pr-reviews"]
}
```

- `pr_numbers`: 対象 PR 番号の配列（必須）
- `skills`: 実行するスキル（省略時: 両方実行）
