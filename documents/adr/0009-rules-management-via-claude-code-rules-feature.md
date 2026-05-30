# 0009. コーディング規約を Claude Code の rules 機能で管理する

## Status
Accepted

## Context

これまでコーディング規約・ルール系ドキュメントは以下の二箇所に分散していた:

- `documents/` 配下: 詳細版のルール（`firestore-document-id-rules.md`, `firestore-fieldvalue-rules.md`, `flutter-hooks-rules.md` 等9ファイル）
- `.claude/rules/` 配下: 一部を要約・移植したルール（`firestore-composite-id.md`, `coding-conventions.md`, `hooks-and-consumer-widget.md` 等）

この二重管理には以下の問題があった:

- **SSOT 違反**: `firestore-composite-id.md`（要約版）と `firestore-document-id-rules.md`（詳細版）が別ファイルとして並存し、どちらが正なのか不明瞭だった
- **ロード機構の差**: `documents/` 配下は CLAUDE.md や個別ファイルからの `@import`/参照リンクで明示的に読み込む必要があった。一方 `.claude/rules/` は Claude Code の rules 機能により、frontmatter `paths:` の glob にマッチしたファイルを編集する際に自動ロードされる
- **規約適用率の低さ**: `documents/` 配下のルールは「読まれることが前提」だが、実際にエージェントが規約適用すべきタイミングで読み込まれない／読み忘れるケースがあった（例: `flutter-hooks-rules.md` の useEffect コメント規約準拠率が60-70%にとどまっていた）

ルールはエージェントが対象コードを編集する瞬間に自動でロードされるべきであり、明示参照に依存する構造は規約徹底に不利である。

## Decision

コーディング規約・ルール系ドキュメントは `.claude/rules/` に一元管理する。各ルールファイルには Claude Code 公式仕様に従い frontmatter で `paths:` を付与し、対象ファイル編集時に自動ロードされるようにする。

### 配置の使い分け

| 種別 | 配置先 | 例 |
|---|---|---|
| コーディング規約・ルール | `.claude/rules/` | `firestore-document-id-rules.md`, `flutter-hooks-rules.md` |
| プロジェクト仕様書 | `documents/PROJECT.md` | アプリ概要、機能一覧、ロードマップ |
| アーキテクチャ意思決定記録 | `documents/adr/` | 本 ADR を含む過去の決定履歴 |

### frontmatter のパススコープ規約

ルールの適用対象に応じて `paths:` を指定する:

- Dart コードに関するルール: `lib/**/*.dart`
- Firebase Functions コードに関するルール: `firebase/functions/**/*.ts`
- Entity 専用ルール: `lib/entity/**/*.dart`
- Feature 関連ルール: `lib/features/**/*.dart`
- 全体適用ルール: `paths:` を省略（セッション開始時に無条件ロード）

### CLAUDE.md・スキル参照の方針

CLAUDE.md は技術スタック・ビルドコマンド・全体方針のみを保持し、個別の規約詳細は `.claude/rules/` 配下に委ねる。スキルの `references/` から規約を参照する場合も `.claude/rules/` を参照先とする。

## Consequences

### 良い点

- **規約の自動適用**: 編集対象ファイルにマッチする規約が自動ロードされ、エージェントが規約違反を見逃しにくい
- **SSOT の徹底**: 各ルールが1ファイルに集約され、要約版／詳細版の二重管理が解消される
- **CLAUDE.md の軽量化**: 規約詳細を CLAUDE.md から `.claude/rules/` に移すことで、CLAUDE.md は200行以下のベストプラクティス範囲に収まりやすくなる
- **スキル連携の単純化**: `.claude/skills/` からの規約参照先が `.claude/rules/` に統一され、規約読み込み手順がシンプルになる

### 悪い点・トレードオフ

- **`paths:` のメンテナンス**: 新しいルール追加時に `paths:` の glob を適切に設定する必要がある。指定漏れがあるとロードされず、過剰指定するとコンテキストを圧迫する
- **Claude Code 以外のツール（Codex, Cursor 等）への波及**: 他ツールは `.claude/rules/` の frontmatter `paths:` を解釈しない可能性があるため、ツール間で規約適用挙動が異なる場合がある（ただし `~/.claude/rules/cc-bp-rules-rule.md` で公式仕様を参照しており、現状 Claude Code 利用を主軸とする）
- **過去ルールの整合確認コスト**: 移行時に各ルールが実装と乖離していないかの照合が必要となる（本移行では Explore エージェント3並列で照合し、`firebase-functions-call-rules.md` のコード違反は別 issue で追跡する形で処理した）

### 移行で生じた副次的なフォローアップ

- bannzai/shoppinglist#221: `firebase-functions-call-rules.md` に違反する既存コード（`lib/provider/group_create.dart`, `lib/provider/group_invitation.dart`）の修正
- bannzai/shoppinglist#222: `flutter-hooks-rules.md` の useEffect コメント未準拠箇所（`resolver/` 系等）の修正
