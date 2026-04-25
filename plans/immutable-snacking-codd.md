# fastlane メタデータファイルのコミット & PR 作成

## Context

iOS App Store 向けの fastlane メタデータファイルを ja / en-US 2 ロケール分追加済みだが、まだ git 管理下に入っていない。これらをコミットして PR 化する。

### 現状

- `HEAD` は `origin/main` に detached 状態（新規ブランチが必要）
- 未追跡ファイル:
  - `ios/fastlane/metadata/ja/{name,subtitle,keywords,description}.txt`
  - `ios/fastlane/metadata/en-US/{name,subtitle,keywords,description}.txt`
  - `plans/immutable-coalescing-wren.md`（**今回の対象外** — ユーザー指示は「fastlane ファイル」のみ）
- `Fastfile` / `Appfile` 等は存在しない。メタデータ 8 ファイルのみ
- `.gitignore` に fastlane 関連の除外なし → コミット可能
- `.github/pull_request_template.md` なし → PR テンプレート不要
- デフォルトブランチ: `main`

### 対象ファイルの内容（要約）

| ファイル | 内容 |
| --- | --- |
| `ja/name.txt` | `買い物リスト` |
| `ja/subtitle.txt` | `家族やルームメイトと共有できるお買い物メモ` |
| `ja/keywords.txt` | 買い物メモ,共有,家族,... |
| `ja/description.txt` | 本文（主な機能・おすすめユーザー） |
| `en-US/name.txt` | `Shopping List` |
| `en-US/subtitle.txt` | `Share Grocery Lists with Family` |
| `en-US/keywords.txt` | grocery,todo,checklist,... |
| `en-US/description.txt` | 本文（KEY FEATURES・PERFECT FOR） |

アーキテクチャ変更・技術選定等は**含まれていない**ため `/write-adr` は不要。

---

## 実装手順（/commit-create-pr 準拠）

`/commit-create-pr` スキルの手順に従い、以下を順に実行する。`git add` と `git commit` は `&&` で繋げず分離して実行する。

### Step 1. 新規ブランチ作成

detached HEAD のため新規ブランチを作成する。ブランチ名は fastlane メタデータ追加を表す命名にする。

```bash
git checkout -b docs/ios-fastlane-metadata
```

### Step 2. fastlane ファイルのみステージング

`plans/immutable-coalescing-wren.md` を含めないよう、`ios/fastlane/` ディレクトリのみを指定する。

```bash
git add ios/fastlane/
```

ステージング後の確認:

```bash
git status
```

期待する `Changes to be committed`:

```
new file:   ios/fastlane/metadata/en-US/description.txt
new file:   ios/fastlane/metadata/en-US/keywords.txt
new file:   ios/fastlane/metadata/en-US/name.txt
new file:   ios/fastlane/metadata/en-US/subtitle.txt
new file:   ios/fastlane/metadata/ja/description.txt
new file:   ios/fastlane/metadata/ja/keywords.txt
new file:   ios/fastlane/metadata/ja/name.txt
new file:   ios/fastlane/metadata/ja/subtitle.txt
```

`plans/immutable-coalescing-wren.md` と `plans/immutable-snacking-codd.md`（このファイル）は untracked のままでよい。

### Step 3. コミット作成

コミットメッセージ案（conventional commits、既存の `docs:` 運用に準拠）:

```bash
git commit -m "docs: ios fastlane metadata追加 (ja/en-US)

App Store Connect 用のメタデータを fastlane deliver 形式で追加。
- ja: 買い物リスト / 家族やルームメイトと共有できるお買い物メモ
- en-US: Shopping List / Share Grocery Lists with Family

各ロケールに name, subtitle, keywords, description を配置。"
```

Claude が author であることはメッセージに含めない。

### Step 4. push

```bash
git push -u origin docs/ios-fastlane-metadata
```

### Step 5. PR 作成

ベースブランチは `main`（現在のブランチに既存 PR なし、デフォルトブランチにマージするため）。draft ではなくオープン状態で作成する。

```bash
gh pr create --base main --head docs/ios-fastlane-metadata --title "docs: ios fastlane metadata追加 (ja/en-US)" --body "$(cat <<'EOF'
## 概要

iOS App Store Connect 向けのメタデータを fastlane `deliver` 形式で追加します。
今後 `fastlane deliver` によるメタデータアップロードを可能にする準備です。

## 変更内容

`ios/fastlane/metadata/` 配下に 2 ロケール分のメタデータファイルを追加。

### ja (日本語)
- `name.txt`: 買い物リスト
- `subtitle.txt`: 家族やルームメイトと共有できるお買い物メモ
- `keywords.txt`: 買い物メモ,共有,家族,お買い物,ショッピング,カテゴリ,グループ,スーパー,買い忘れ,チェックリスト,食材管理
- `description.txt`: アプリ本文（主な機能・おすすめユーザー）

### en-US (英語)
- `name.txt`: Shopping List
- `subtitle.txt`: Share Grocery Lists with Family
- `keywords.txt`: grocery,todo,checklist,household,roommate,organize,drag drop,supermarket,shopping memo,shared
- `description.txt`: アプリ本文（KEY FEATURES・PERFECT FOR）

## 影響範囲

- テキストファイルのみの追加。Flutter / Firebase のコード変更なし。
- ビルド・テスト・静的解析への影響なし。
- `Fastfile` / `Appfile` は未追加のため、本 PR の時点では `fastlane deliver` の実行設定は別途必要。
EOF
)"
```

### Step 6. 完了後の注意

- このタスク完了後は勝手に commit / push / gh pr create / gh pr comment を追加で行わない（スキル指示どおり）。

---

## 検証方法

コード変更がないため Flutter / Firebase のビルド・テストは不要。git 操作が正しく完了しているかを確認する。

### コミット検証

```bash
git log --oneline -1
git show --stat HEAD
```

期待: 上記 8 ファイルが `new file` として記録されている。

### push 検証

```bash
git log --oneline origin/docs/ios-fastlane-metadata -1
```

### PR 検証

```bash
gh pr view --json number,title,state,baseRefName,headRefName
```

期待: `state: OPEN`、`baseRefName: main`、`headRefName: docs/ios-fastlane-metadata`。

### コンテンツの整合性確認

fastlane deliver 形式のメタデータはファイル末尾の改行・文字数制限に注意が必要。iOS App Store の制限:

- `name.txt`: 30 文字以内
- `subtitle.txt`: 30 文字以内
- `keywords.txt`: 100 文字以内（カンマ含む）
- `description.txt`: 4000 文字以内

コミット前に以下で文字数を確認する（超過があれば警告のみ、コミットは継続）:

```bash
wc -m ios/fastlane/metadata/ja/name.txt ios/fastlane/metadata/ja/subtitle.txt ios/fastlane/metadata/ja/keywords.txt
wc -m ios/fastlane/metadata/en-US/name.txt ios/fastlane/metadata/en-US/subtitle.txt ios/fastlane/metadata/en-US/keywords.txt
```

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している（fastlane deliver 標準レイアウト準拠）

### Git 操作（本プラン固有）
- [ ] 新規ブランチ `docs/ios-fastlane-metadata` を作成（detached HEAD から）
- [ ] `ios/fastlane/` のみを `git add`（`plans/` を含めない）
- [ ] `git add` と `git commit` を別コマンドで実行（`&&` で繋げない）
- [ ] commit / PR body に Claude が author であることを記載しない
- [ ] `gh pr create` を draft ではなくオープン状態で実行
- [ ] ベースブランチは `main`

### 検証
- [ ] `git show --stat HEAD` で 8 ファイルが追加されていることを確認
- [ ] `gh pr view` で PR が OPEN かつ base=main になっていることを確認
- [ ] App Store の文字数制限（name/subtitle 各 30、keywords 100）を超えていないことを `wc -m` で確認

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
