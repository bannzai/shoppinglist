# 0006. スキルのスクリプト委譲パターン統一

## Status

Accepted

## Context

Claude Code スキルの実装パターンとして、以下の2つが混在していた:

1. **インラインパターン**: SKILL.md にすべてのフェーズ指示を記述し、Claude が直接実行する（`check-coding-conventions`, `fix-pr-reviews`）
2. **スクリプト委譲パターン**: SKILL.md はスクリプト呼び出しのみ記述し、`scripts/` 内のシェルスクリプトが `ccnipre` でプロンプトを生成・実行する（`implement-issue`, `release-test`）

インラインパターンの課題:
- SKILL.md が巨大化する（141〜181行）
- プロンプトの再利用・テストが困難
- 他のスキルとの構成が不統一

## Decision

**全スキルをスクリプト委譲パターンに統一する。**

構成:
```
skill-name/
├── SKILL.md              # スクリプト呼び出しのみ（~35行）
├── scripts/
│   ├── generate_*.sh     # テンプレートからプロンプト生成
│   └── run_*.sh          # generate + ccnipre 実行
└── references/
    ├── prompt_template.md # Claude への詳細指示（プレースホルダ付き）
    └── common_rules.md   # 共通ルール（ワークフロー手順のみ）
```

- `generate_*.sh`: PR情報を取得し、テンプレートのプレースホルダを置換してプロンプトファイルを生成
- `run_*.sh`: generate を呼び出し、`ccnipre -f` でプロンプトを実行
- コーディング規約は `.claude/rules/` と `documents/` が Single Source of Truth。スキルの references/ にはコーディングルールを複製しない

## Consequences

- SKILL.md がシンプルになり、description のみで起動判断可能
- generate スクリプト単体でプロンプト生成をテスト可能
- コーディング規約の二重管理が解消（`convention-checklist.md` を削除）
- 新しいスキル作成時にテンプレートとして参照しやすい
