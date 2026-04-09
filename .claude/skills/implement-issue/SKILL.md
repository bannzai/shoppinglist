---
name: implement-issue
description: |
  GitHub Issueの仕様を読み取り、実装プラン作成→実装→検証→PR作成を一括実行する。
  プレミアム機能issueの実装に使用。
  使用例: "/implement-issue 76"
user_invocable: true
argument-hint: "<issue number>"
allowed-tools:
  - Bash(git checkout:*)
  - Bash(git branch:*)
  - Bash(git add:*)
  - Bash(git commit:*)
  - Bash(git push:*)
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(gh issue view:*)
  - Bash(gh pr create:*)
  - Bash(gh pr view:*)
  - Bash(gh pr list:*)
  - Bash(dart run build_runner build:*)
  - Bash(flutter analyze:*)
  - Bash(flutter test:*)
  - Bash(flutter build:*)
  - Bash(npm run lint:*)
  - Bash(npm run build:*)
  - Bash(npm test:*)
  - Bash(mkdir:*)
  - Bash(ls:*)
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/run_implement_issues.sh:*)
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/generate_issue_prompts.sh:*)
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/test_skill.sh:*)
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Agent
---

# implement-issue スキル

GitHub Issue の仕様を読み取り、実装→検証→PR作成までを実行する。

## Phase 1: Issue 読み込み

1. `gh issue view $ARGUMENTS --repo bannzai/shoppinglist` で Issue 全文を取得
2. `gh issue view $ARGUMENTS --repo bannzai/shoppinglist --comments` でコメント取得
3. スコープ判定: Flutter変更（`lib/`）/ Firebase変更（`firebase/`）/ 両方

## Phase 2: コードベース探索

1. `CLAUDE.md` と `.claude/rules/plan-checklist.md` を読む
2. 関連する既存Feature（`lib/features/` 配下）を探索しパターン把握
3. 既存Entity（`lib/entity/`）でデータモデル確認
4. `lib/utils/purchase/purchase.dart` で `isPremium` 判定の既存パターン確認
5. Firebase変更がある場合は `firebase/functions/src/functions/` の既存関数パターン確認

## Phase 3: プラン作成

1. ブランチ `feature/premium-issue-{$ARGUMENTS}` を `main` から作成
2. `plans/` にプランファイル作成
3. プランには以下を含める:
   - 変更対象ファイル一覧
   - ファイルごとの具体的なコード提案（コードブロック）
   - `.claude/rules/plan-checklist.md` のチェックリスト

## Phase 4: 実装 & 検証

1. プランに沿って実装
2. テストを作成:
   - Widget Test: 新規・変更したWidgetに対して積極的に書く（isPremium分岐、UI表示条件等）
   - Maestro E2E: 実装した機能に対応する maestro flow を `maestro/flows/` に新規作成する
   - Firebase Functions テスト: 新規/変更関数に対するJestテスト
3. 検証を実行（該当するもの全て）:
   - `dart run build_runner build`（freezed/riverpod_generator対象の場合）
   - `flutter analyze`
   - `flutter test`
   - `flutter build ios`
   - `maestro test maestro/flows/`
   - Firebase変更がある場合: `firebase/functions/functions/` で `npm run lint`, `npm run build`, `npm test`
4. エラーがあれば修正して再検証

## スクリプト

- `scripts/run_implement_issues.sh` — 複数Issue一括実行。ccnipreでプロンプトを順次実行する
- `scripts/generate_issue_prompts.sh` — Issue番号からプロンプトファイルを自動生成する
- `scripts/test_skill.sh` — スキルの動作確認テスト

## 参照ファイル

- `references/prompt_template.md` — Issue実装のプロンプトテンプレート
- `references/coding_review_prompt.md` — 実装後コーディング規約レビュー用プロンプト
- `references/common_rules.md` — プロジェクト規約・検証コマンド・チェックリスト

## 検証方法

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/test_skill.sh
```

## Phase 4.5: 動作確認チェックリスト作成

実装完了後、`tmp/implement-issue/checklists/issue_{$ARGUMENTS}_checklist.md` に動作確認チェックリストを作成する。

フォーマット（PLAN.md準拠）:
```markdown
# Issue #{$ARGUMENTS} 動作確認チェックリスト

## 前提
- テスト環境: {環境情報}
- 生成日: {YYYY-MM-DD}

---

## {機能名}

### {サブカテゴリ}
- [ ] **{テスト項目}**: {期待動作}

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>
<img src="（gh-r2-imageでアップロードしたURL）" width="320">
</details>
```

ルール:
- 画像は `<img src="URL" width="320">` タグで埋め込む
- mobile-mcp/maestroで確認困難な項目は「なぜ困難か」を明記し代替手段を提示
- チェック項目は `- [ ]` 形式
- 実行して確認が取れたら `- [x]` に更新

## Phase 5: Commit & PR

1. 変更を論理単位で git commit する（git add と git commit は別コマンドで実行）
2. `git push -u origin feature/premium-issue-{$ARGUMENTS}`
3. `gh pr create --base main --title "{Issue タイトル}" --body "..."` で PR 作成
   - body に `Closes #{$ARGUMENTS}` を含める
   - body に実装内容の説明を記載
