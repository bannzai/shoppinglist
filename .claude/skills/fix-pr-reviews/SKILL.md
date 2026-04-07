---
name: fix-pr-reviews
description: |
  PRのインラインレビューコメント（Gemini Code Assistant・人間レビュアー）を評価し、
  妥当な指摘を修正してfix PRを作成、ベースブランチにマージする。
  スレッドへの返信・resolve も自動で行う。
  使用例: "/fix-pr-reviews 180"
user_invocable: true
context: fork
argument-hint: "<PR number>"
allowed-tools:
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/generate_review_prompt.sh:*)
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/run_fix_reviews.sh:*)
  - Bash(ls:*)
  - Read
  - Glob
---

# fix-pr-reviews

PR のインラインレビューコメントを取得・評価し、妥当な指摘を修正する。

## 実行

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/run_fix_reviews.sh --pr $ARGUMENTS
```

## 処理概要

スクリプトが以下を自動実行する:

1. PR 情報取得 → プロンプトテンプレートにプレースホルダ置換
2. ccnipre でプロンプトを実行（plan → review → execute）
3. ccnipre 内で: コメント取得 → accept/reject/already-fixed 分類 → 修正 → 返信・resolve → 検証 → fix PR → CI → マージ → ベースPR更新

詳細な指示は `references/prompt_template.md`、評価基準は `references/review-evaluation-guide.md` を参照。
