---
name: release-test
description: |
  リリース前のQA手動テストを自動化するスキル。
  ブランチ間の変更差分を分析し、RELEASE_TEST_PLAN.mdを生成、
  セクション別プロンプトを自動作成してccnipreで順次実行する。
  使用例: "/release-test"
user_invocable: true
allowed-tools:
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git branch:*)
  - Bash(git status:*)
  - Bash(git remote:*)
  - Bash(git checkout:*)
  - Bash(git fetch:*)
  - Bash(gh pr view:*)
  - Bash(gh pr list:*)
  - Bash(gh pr diff:*)
  - Bash(mkdir:*)
  - Bash(ls:*)
  - Bash(wc:*)
  - Bash(chmod:*)
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/generate_section_prompts.sh:*)
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/run_qa.sh:*)
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - Agent
---

# release-test スキル

リリース前のQA手動テストを自動化する。変更差分の分析 → テストプラン生成 → セクション別プロンプト生成 → ccnipreで順次実行のワークフロー。

## Phase 1: 情報収集

AskUserQuestion で以下を収集する:

**質問1: ベースブランチ**
- テストのベースとなるブランチ名（例: `main`, `develop`, `release/1.0.0`）
- QA用の作業ブランチとして使う。各セクションのPR作成先になる

**質問2: 比較対象**
- 「PR番号」: `gh pr diff` で差分取得
- 「ブランチ名」: `git diff base...compare` で差分取得
- 「全機能テスト」: 差分ではなくプロジェクト全体をテスト対象にする（初回リリース等）

**質問3: テスト種別（複数選択）**
- mobile-mcp/maestro を使ったUIテスト
- Firebase Functions / バックエンドテスト
- ビルド確認（iOS/Android）
- 既存ユニットテスト・E2Eテスト実行
- セキュリティルール検証

## Phase 2: 変更差分の分析

### 比較対象が「PR番号」または「ブランチ名」の場合
1. `git diff --stat {base}...HEAD` または `gh pr diff {number} --stat` で変更ファイル一覧取得
2. `git diff {base}...HEAD` で詳細な差分を取得
3. 変更ファイルをカテゴリ分類:
   - `lib/` → Feature名（ディレクトリ名）ごとに分類
   - `firebase/` → Firebase Functions テスト対象
   - `maestro/` → E2Eフロー変更
   - `test/` → テストコード変更
   - その他（設定、アセット等）
4. 各Feature内のREADME.mdを読んで機能の概要を把握
5. プロジェクトのCLAUDE.mdを読んでテスト方法・規約を把握

### 比較対象が「全機能テスト」の場合
1. `lib/` のディレクトリ構造から全Feature列挙
2. 各Feature/README.md を読んで機能概要把握
3. `maestro/flows/` から既存E2Eフロー一覧取得
4. `firebase/functions/` の関数定義一覧取得
5. プロジェクトのCLAUDE.md、documents/ を参照

### 出力
テスト対象セクションのリスト（各セクションに対象理由を付記）

## Phase 3: RELEASE_TEST_PLAN.md 生成

Phase 2 の分析結果をもとに、プロジェクトルートに `RELEASE_TEST_PLAN.md` を生成する。このファイルはgit管理対象。

### ファイル構造

```markdown
# リリース QA テストプラン

## 前提
- テスト環境: {環境情報}
- 対象: {ベースブランチ} ← {比較対象}
- 生成日: {YYYY-MM-DD}

## スコープ外
- {テスト対象外とする機能・項目とその理由}

---

## 1. {セクション名}

### {サブカテゴリ}
- [ ] **{テスト項目}**: {期待動作}

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>
<img src="（gh-r2-imageでアップロードしたURL）" width="320">
</details>

---

## 2. {次のセクション名}
...
```

### セクション構成ルール
- `## N. セクション名` の形式で番号付きヘッダー
- チェック項目は `- [ ] **項目名**: 説明` 形式
- 各セクション末尾に `#### 動作確認` の details ブロック
- セクション間は `---` で区切り

### 動作確認セクションのルール
- 画像は `<img src="URL" width="320">` タグで埋め込む（heightは指定しない）。Markdown画像形式 `![](url)` は使用禁止
- mobile-mcp/maestroで確認困難な項目は **「なぜ困難か」を明記** すること
  - 例: `Googleサインイン: OAuthフローをiOS Simulatorで自動化不可`
- 困難な項目には **代替手段を提示・実装** する:
  - 代替手段がある場合はそれを利用（例: Googleログイン → 匿名ログインで代替）
  - 代替手段がない場合は新たに用意する:
    - debug mode用の導線追加（例: ログイン画面に匿名ログインボタン）
    - 開発者用画面でDB確認（やむを得ずモック値を入れる場合も含む）

### 生成後の確認
AskUserQuestion でユーザーにレビューを依頼する。修正要望があれば反映する。

## Phase 4: セクションプロンプト自動生成

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/generate_section_prompts.sh \
  --base {ベースブランチ} \
  --plan ./RELEASE_TEST_PLAN.md \
  --output ./tmp/prompts
```

生成されたプロンプトファイルの内容を確認し、必要に応じて手動修正する。

## Phase 5: テスト実行

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/run_qa.sh --base {ベースブランチ}
```

特定セクションのみ実行する場合:
```bash
bash ${CLAUDE_SKILL_DIR}/scripts/run_qa.sh --base {ベースブランチ} 1 3 5
```

## 注意事項
- RELEASE_TEST_PLAN.md はgit管理対象。テスト完了後もリポジトリに残す
- tmp/prompts/, tmp/logs/ は .gitignore に追加する
- 各セクションの実行は qa/section-{NN} ブランチで行われ、完了後にベースブランチへのPRが作成される
