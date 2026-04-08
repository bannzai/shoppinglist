# 0007. スキル間共有スクリプトの配置場所

## Status
Accepted

## Context
Issue #207 で `fix-pr-reviews` / `check-coding-conventions` / `run-pr-quality-checks` の3スキルに `--base` オプションを追加する際、PR検出ロジック（`gh pr list` + タイトルフィルタ + 未解決コメントGraphQLチェック）を共通化する必要が生じた。

配置候補として以下を検討した:
- `./scripts/` (プロジェクトルート): スキル専用ロジックをルートに置くのは範囲が広すぎる
- `.claude/scripts/`: `.claude/` 配下として統一感があるが、スキルからの相対パス解決がやや複雑
- `.claude/skills/_shared/scripts/`: スキル群と同階層で相対パスが自然

## Decision
`.claude/skills/_shared/scripts/` に共有スクリプトを配置する。

- `SKILL.md` を置かないことで Claude Code にスキルとして認識されない
- アンダースコアプレフィックス `_shared` で内部用ディレクトリであることを明示する
- 各スキルからは `$(dirname "$(dirname "$SCRIPT_DIR")")/_shared/scripts/` で参照可能

## Consequences
- スキルのスクリプトから相対パスで自然に辿れる
- プロジェクトルートや `.claude/` 直下を汚さない
- `_shared/` 配下のスクリプトが増えすぎた場合はサブディレクトリで整理が必要になる可能性がある
- 新しいスキルを追加する開発者は `_shared/` の存在を知る必要がある
