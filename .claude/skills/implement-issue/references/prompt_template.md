GitHub Issue #{{ISSUE_NUMBER}} の仕様を実装してください。

## Issue 情報
- タイトル: {{ISSUE_TITLE}}
- 優先度: {{PRIORITY}}
- URL: https://github.com/bannzai/shoppinglist/issues/{{ISSUE_NUMBER}}

## 手順

1. `gh issue view {{ISSUE_NUMBER}} --repo bannzai/shoppinglist` で Issue の全内容を確認
2. `gh issue view {{ISSUE_NUMBER}} --repo bannzai/shoppinglist --comments` でコメントも確認
3. CLAUDE.md と .claude/rules/plan-checklist.md を読む
4. 関連する既存実装（lib/features/ 配下）を探索してパターンを把握
5. lib/utils/purchase/purchase.dart の isPremium 判定パターンを確認
6. ブランチ `feature/premium-issue-{{ISSUE_NUMBER}}` を `{{BASE_BRANCH}}` から作成
7. plans/ にプランファイルを作成（plan-checklist.md のチェックリスト付き）
8. プランに沿って実装
9. テストを作成:
   - Widget Test: 新規・変更Widgetに対して積極的に書く（isPremium分岐、UI表示条件等）
   - Maestro E2E: 実装した機能に対応する maestro flow を maestro/flows/ に新規作成
   - Firebase Functions テスト: 新規/変更関数に対するJestテスト
10. 検証を実行:
    - dart run build_runner build
    - flutter analyze
    - flutter test
    - flutter build ios
    - maestro test maestro/flows/
    - (Firebase変更がある場合) firebase/functions/functions/ で npm run lint, npm run build, npm test
11. 検証エラーがあれば修正
12. 動作確認チェックリストを `tmp/implement-issue/checklists/issue_{{ISSUE_NUMBER}}_checklist.md` に作成（PLAN.md形式）
13. 変更を論理単位で git commit（git add と git commit は別コマンド）
14. git push -u origin feature/premium-issue-{{ISSUE_NUMBER}}
15. gh pr create --base {{BASE_BRANCH}} --title "{{ISSUE_TITLE}}" で PR 作成。body に "Closes #{{ISSUE_NUMBER}}" を含める

{{COMMON_RULES}}
