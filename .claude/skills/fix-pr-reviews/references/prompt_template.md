PR #{{PR_NUMBER}} ({{PR_URL}}) のレビューコメント対応を行ってください。

## PR 情報
- PR: #{{PR_NUMBER}}
- URL: {{PR_URL}}
- HEAD ブランチ: {{HEAD_BRANCH}}
- BASE ブランチ: {{BASE_BRANCH}}

## 手順

### 1. レビューコメント取得

1. `git fetch origin`
2. `git checkout {{HEAD_BRANCH}}` で PR の head ブランチに切り替え
   - **重要**: `gh-pr-comments` は現在のブランチの PR を自動検出するため、先にブランチを切り替える
3. `gh-pr-comments --no-resolved` で未解決のレビューコメントを取得
4. コメントがない場合: 「未解決のレビューコメントなし」と報告して終了

各コメントから以下を記録:
- `thread_id` (スレッド ID、`PRT_...` 形式)
- `comment.path` (ファイルパス)
- `comment.line` (行番号)
- `comment.author` (投稿者)
- `comment.body` (コメント本文)

### 2. コメント評価とプラン作成

各レビューコメントについて:

1. `comment.path` のファイルを Read で読み、`comment.line` 周辺のコードを確認
2. `comment.body` の指摘内容を理解
3. プロジェクトの規約ファイル（`.claude/rules/`, `documents/`）と照合
4. 評価結果を分類（詳細は `.claude/skills/fix-pr-reviews/references/review-evaluation-guide.md`）:

| 分類 | 条件 | アクション |
|------|------|-----------|
| **accept** | 規約違反、バグ、改善が妥当 | 修正する |
| **reject** | 誤検知、規約と矛盾、既存パターンに合致 | 理由を説明して reject |
| **already-fixed** | 既に修正済み | その旨を返信 |

5. 分類結果をプランとして表示（accept/reject/already-fixed の件数と各理由）

### 3. 修正の実施

accept 分類のコメントがある場合のみ:

1. fix ブランチを作成: `git checkout -b fix/pr-reviews-pr-{{PR_NUMBER}}`
2. accept 分類の各コメントについて、指摘に沿ってコードを修正
3. Dart ファイルに変更がある場合: `dart format .`

### 4. スレッドへの返信と resolve

全コメントに対して返信を投稿し、resolve する。

#### 返信（accept / reject / already-fixed 共通）

```bash
gh api graphql -f thread="{THREAD_ID}" -f body="{返信内容}" -F query=@{{REPLY_GRAPHQL_PATH}}
```

- **accept**: 「修正しました。{修正内容の簡潔な説明}」
- **reject**: reject の理由を具体的に説明
- **already-fixed**: 「既に修正済みです」

#### resolve

```bash
gh api graphql -f thread="{THREAD_ID}" -F query=@{{RESOLVE_GRAPHQL_PATH}}
```

### 5. 検証

accept 分類のコメントがあり修正を行った場合のみ実行する。

### 6. コミット & fix PR 作成

accept 分類のコメントがあり修正を行った場合のみ。

### 7. CI 確認 & マージ

### 8. ベースブランチ PR の更新

{{COMMON_RULES}}
