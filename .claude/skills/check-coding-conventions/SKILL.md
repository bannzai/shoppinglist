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
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/generate_check_prompt.sh:*)
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/run_check_conventions.sh:*)
  - Bash(ls:*)
  - Read
  - Glob
---

# check-coding-conventions

PR のコーディング規約チェックと違反修正を実行する。

## 実行

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/run_check_conventions.sh --pr $ARGUMENTS
```

## 処理概要

スクリプトが以下を自動実行する:

1. PR 情報取得 → プロンプトテンプレートにプレースホルダ置換
2. ccnipre でプロンプトを実行（plan → review → execute）
3. ccnipre 内で: 規約読込（`.claude/rules/`, `documents/`, `CLAUDE.md`）→ 差分チェック → 違反修正 → 検証 → fix PR → CI → マージ → ベースPR更新

詳細な指示は `references/prompt_template.md` を参照。
