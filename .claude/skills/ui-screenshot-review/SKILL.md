---
name: ui-screenshot-review
description: |
  UIのスクリーンショットをMaestroで撮影し、確認・改善を行うスキル。
  スクリーンショット撮影→画像確認→UI問題点分析→ソース修正→再撮影のサイクルを実行する。
  使用例: "/ui-screenshot-review"
allowed-tools:
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/run_maestro_screenshots.sh:*)
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/test_skill.sh:*)
  - Bash(ls:*)
  - Read
  - Glob
  - Grep
---

# UI Screenshot Review Skill

UIのスクリーンショットを撮影し、確認・改善を行うスキル。

## 使い方

1. シミュレータでプレビューアプリを起動
2. Maestroフローでスクリーンショットを撮影
3. スクリーンショットを確認し、UI改善を実施

## 実行手順

### Step 1: スクリーンショット撮影

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/run_maestro_screenshots.sh
```

### Step 2: スクリーンショット確認

`maestro/screenshots/` 内の画像をReadツールで確認する。

### Step 3: UI改善

問題点を分析し、該当するソースファイルを修正する。修正後、再度スクリーンショットを撮影して確認する。

## スクリプト

- `scripts/run_maestro_screenshots.sh` — iOS Simulator上でMaestroフローを実行し、UIスクリーンショットを自動撮影する
- `scripts/test_skill.sh` — スキルの動作確認テスト

## ソースファイルの特定

スクリーンショット名から対応するソースファイルを特定するには、`lib/features/` 配下を画面名で検索する。

## エラーハンドリング

- Maestroが起動しない場合: `pkill -f "maestro"` で既存プロセスを停止してからリトライ
- シミュレータが見つからない場合: `xcrun simctl list devices available` でブート済みデバイスを確認
- スクリーンショットが空の場合: `maestro/flows/capture_all_previews.yaml` のフロー定義を確認

## 注意事項

- `maestro/config.yaml` でテスト出力先が `maestro/test-results/` に設定されている
- プレビューではFirebaseが未初期化のため、`SettingPage`の一部機能は動作しない
- モックデータは `lib/features/previews/mock/mock_data.dart` で定義
- Maestroフローは `maestro/flows/capture_all_previews.yaml`

## 検証方法

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/test_skill.sh
```
