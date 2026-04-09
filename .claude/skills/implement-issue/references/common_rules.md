# 共通ルール

## プロジェクト規約
- CLAUDE.md を読んでプロジェクト全体の規約を把握する
- .claude/rules/plan-checklist.md を読んで検証チェックリストの形式を把握する
- 既存の lib/features/ の構成パターンを踏襲する（Feature ごとにディレクトリ）

## コーディング規約
- Entity のフィールド名は省略しない
- Firestore操作は `call` クラス Provider 経由
- 関数・コンストラクタ引数は `{required}` をつける（timestamp等メタデータ除く）
- build内は ref.watch、コールバック・操作は ref.read
- Firebase Functions は GenKit で定義する。onDocumentCreated/onDocumentUpdated トリガー禁止

## ブランチ & PR
- ブランチ名: `feature/premium-issue-{{ISSUE_NUMBER}}`
- ベースブランチ: `{{BASE_BRANCH}}`
- git add と git commit は別コマンドで実行する
- PR body に `Closes #{{ISSUE_NUMBER}}` を含める

## テスト作成
- Widget Test: 新規・変更したWidgetに対して積極的に書く（isPremium分岐、UI表示条件等）
- Maestro E2E: 実装した機能に対応する maestro flow を `maestro/flows/` に新規作成する
- Firebase Functions: 新規/変更関数に対するJestテスト

## 検証コマンド
Flutter 変更がある場合:
1. `dart run build_runner build`
2. `flutter analyze`
3. `flutter test`
4. `flutter build ios`
5. `maestro test maestro/flows/`

Firebase 変更がある場合（`firebase/functions/functions/` で実行）:
1. `npm run lint`
2. `npm run build`
3. `npm test`

## 動作確認チェックリスト
- 実装完了後に `tmp/implement-issue/checklists/issue_{{ISSUE_NUMBER}}_checklist.md` を作成
- PLAN.md のフォーマットに準拠（セクション別チェック項目 + 動作確認エビデンス）
- 画像は `<img src="URL" width="320">` タグ
