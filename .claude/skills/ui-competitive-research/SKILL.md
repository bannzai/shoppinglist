---
name: ui-competitive-research
description: |
  Web上から競合・類似アプリのUIスクリーンショットを収集し、自アプリと比較分析してUI改善プランを策定するスキル。
  「買い物リスト」「grocery」等のキーワードで類似アプリを検索し、共通UIパターンを抽出する。
  使用例: "/ui-competitive-research" (キーワード「shopping list」で検索)
  使用例: "/ui-competitive-research grocery app"
---

# UI Competitive Research Skill

競合・類似アプリのUIスクリーンショットをWebから収集し、自アプリと比較分析して改善案を導き出すスキル。

## 出力先ディレクトリ

```
.local/ui-research/
├── references/                      # 競合アプリのスクリーンショット
│   └── {app-name}/
│       ├── screenshot_01.png
│       └── screenshot_02.png
├── analysis/
│   └── improvement-plan.md          # 分析結果・改善プラン
└── README.md                        # リサーチの概要・メタデータ
```

自アプリのスクリーンショットは `.local/screenshots/` を参照する。

---

## Step 1: 競合アプリの検索・選定

引数でキーワードが指定されている場合はそれを使う。未指定の場合は「shopping list app」を使用する。

### 検索

以下のキーワードでWebSearchを実行する:

- `{keyword} app iOS screenshots`
- `best {keyword} app 2025`
- `{keyword} app UI design`

### 候補選定

検索結果から人気の高い競合アプリを3〜5個選定する。以下は定番の候補:

- **AnyList** - リスト管理の定番
- **Bring!** - ビジュアル重視の買い物リスト
- **Our Groceries** - 家族共有に強い
- **Listonic** - スマートな買い物リスト
- **Grocery Smart Shopping List** - 価格比較機能付き
- **Todoist** - タスク管理兼用
- **Apple Reminders** - OS標準

### ユーザー確認

AskUserQuestionで調査対象アプリのリストを提示し、確認する。ユーザーが追加・削除を指示した場合は反映する。

---

## Step 2: スクリーンショットの収集・保存

### 準備

```bash
mkdir -p .local/ui-research/references
```

### 収集方法

各アプリについて以下の手順で収集する:

1. `agent-browser` スキルを使用してApp Store（apps.apple.com）の各アプリページにアクセスする
2. iPhoneデバイスエミュレーションを設定する: `agent-browser set device "iPhone 15"`
3. アプリページのスクリーンショットギャラリーから画像URLを取得する
4. `curl` で画像をダウンロードし `.local/ui-research/references/{app-name}/` に保存する

### フォールバック

画像URLが取得できない場合:
- `agent-browser screenshot` でブラウザ画面をキャプチャする
- Google画像検索で `{app-name} app screenshot iOS` を検索し画像を取得する

### 収集枚数

各アプリから最低3枚を目標とする:
- メイン画面（リスト一覧）
- アイテム追加・編集画面
- 設定またはカテゴリ画面

### 保存先

```
.local/ui-research/references/{app-name}/
├── screenshot_01.png
├── screenshot_02.png
└── screenshot_03.png
```

`{app-name}` はkebab-case（例: `any-list`, `bring`, `our-groceries`）。

---

## Step 3: 比較分析

### 自アプリのスクリーンショット読み込み

`.local/screenshots/` ディレクトリ内の画像をReadツールで読み込む。存在しない場合はユーザーに撮影を依頼する（`ui-screenshot-review` スキルの `run_maestro_screenshots.sh` を案内する）。

### 競合アプリのスクリーンショット読み込み

`.local/ui-research/references/` ディレクトリ内の各アプリの画像をReadツールで読み込む。

### 分析の実施

`references/analysis-criteria.md` の評価基準に沿って比較分析を行う。

分析の流れ:
1. 競合アプリ間の**共通UIパターン**を抽出する
2. 自アプリと競合の**ギャップ**を特定する
3. 各ギャップについて**改善の優先度**を判断する（高・中・低）
4. 具体的な**改善アクション**を策定する

---

## Step 4: 改善プラン策定

### 出力ファイル

分析結果を `.local/ui-research/analysis/improvement-plan.md` に出力する。

```bash
mkdir -p .local/ui-research/analysis
```

### improvement-plan.md の構成

```markdown
# UI改善プラン

## リサーチ概要
- 調査日: YYYY-MM-DD
- 調査対象アプリ: (リスト)
- 検索キーワード: (使用したキーワード)

## 競合アプリの共通パターン
(競合間で共通して見られるUIパターンをまとめる)

## 画面別改善提案

### {画面名}
- **現状**: (自アプリの現在のUI)
- **競合の傾向**: (競合アプリではどうなっているか)
- **改善案**: (具体的な変更内容)
- **優先度**: 高/中/低
- **修正対象ファイル**: (ソースファイルパス)

## 総合的な改善方針
(全体を通した改善の方向性)
```

### 修正対象ファイルの特定

スクリーンショット名から対応するソースファイルを特定するには、`lib/features/` 配下を画面名で検索する。

### README.md の出力

リサーチの概要を `.local/ui-research/README.md` に出力する。

```markdown
# UI Competitive Research

## メタデータ
- 実施日: YYYY-MM-DD
- 調査対象: (アプリ名リスト)
- 収集スクリーンショット数: N枚

## ディレクトリ構成
- `references/` - 競合アプリのスクリーンショット
- `analysis/improvement-plan.md` - 分析結果・改善プラン
```

---

## エラーハンドリング

### agent-browserが利用できない場合
WebSearchとWebFetchで代替する。App Storeのプレビュー画像URLを直接取得してcurlでダウンロードする。

### スクリーンショットが取得できない場合
ユーザーにAskUserQuestionで報告し、手動でスクリーンショットを `.local/ui-research/references/{app-name}/` に配置するよう依頼する。配置後にStep 3から再開する。

### 自アプリのスクリーンショットが存在しない場合
ユーザーに以下を案内する:
1. `run_maestro_screenshots.sh` を実行してスクリーンショットを撮影
2. `.local/screenshots/` にスクリーンショットをコピー
3. 準備完了後にStep 3から再開
