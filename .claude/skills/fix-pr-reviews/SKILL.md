---
name: fix-pr-reviews
description: |
  PRのインラインレビューコメント（Gemini Code Assistant・人間レビュアー）を評価し、
  妥当な指摘を修正してfix PRを作成、ベースブランチにマージする。
  スレッドへの返信・resolve も自動で行う。
  --base オプションでベースブランチ指定による一括実行も可能。
  使用例: "/fix-pr-reviews 180", "/fix-pr-reviews --base feature-branch"
user_invocable: true
context: fork
argument-hint: "<PR number> | --base <branch> [--dry-run]"
allowed-tools:
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/generate_review_prompt.sh:*)
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/run_fix_reviews.sh:*)
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/test_skill.sh:*)
  - Bash(ls:*)
  - Read
  - Glob
---

# fix-pr-reviews

PR のインラインレビューコメントを取得・評価し、妥当な指摘を修正する。

## 実行

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/run_fix_reviews.sh $ARGUMENTS
```

## 処理概要

スクリプトが以下を自動実行する:

1. PR 情報取得 → プロンプトテンプレートにプレースホルダ置換
2. ccnipre でプロンプトを実行（plan → review → execute）
3. ccnipre 内で: コメント取得 → accept/reject/already-fixed 分類 → 修正 → 返信・resolve → 検証 → fix PR → CI → マージ → ベースPR更新

## オプション

- `--pr <number>` / `<number>`: 単一PR指定
- `--base <branch>`: ベースブランチ指定で未解決コメントがあるPRを一括実行
- `--dry-run`: 対象PRの一覧を表示して終了（`--base` と併用）

詳細な指示は `references/prompt_template.md`、評価基準は `references/review-evaluation-guide.md` を参照。

## スクリプト

- `scripts/run_fix_reviews.sh` — PR番号またはベースブランチ指定でレビューコメント対応を実行
- `scripts/generate_review_prompt.sh` — PR情報とレビューコメントからプロンプトファイルを生成
- `scripts/test_skill.sh` — スキルの動作確認テスト

## エラーハンドリング

- PRが存在しない場合: `gh pr view` の終了コードを確認しエラーメッセージを表示
- レビューコメントが0件の場合: 「対応するレビューコメントがありません」と表示して終了
- ccnipreが失敗した場合: ログ出力を確認し、プロンプトテンプレートの問題を調査

## 検証方法

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/test_skill.sh
```
