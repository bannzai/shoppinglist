---
name: ui-screenshot-review
description: |
  UIのスクリーンショットをMaestroで自動撮影し、確認・改善を行うスキル。
  プレビューアプリをiOSシミュレータで起動し、全画面のスクリーンショットを撮影する。
  UI改善が必要な箇所を特定し、ソースファイルを修正する。
  使用例: "/ui-screenshot-review"
allowed-tools:
  - "Bash(bash ${CLAUDE_SKILL_DIR}/scripts/run_maestro_screenshots.sh:*)"
  - Bash
  - Read
---

# UIスクリーンショットレビュー

Maestroフローでプレビューアプリの全画面スクリーンショットを自動撮影し、UIの確認・改善を行う。

## ワークフロー

### Step 1: スクリーンショット撮影

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/run_maestro_screenshots.sh
```

### Step 2: スクリーンショット確認

`maestro/screenshots/` 内の画像をReadツールで確認する。

### Step 3: UI改善

問題点を分析し、該当するソースファイルを修正する。修正後、再度スクリーンショットを撮影して確認する。

## ソースファイルの特定

スクリーンショット名から対応するソースファイルを特定するには、`lib/features/` 配下を画面名で検索する。

## エラーハンドリング

### シミュレータが起動していない場合
スクリプトが自動的にiPhone 16 Proシミュレータを検索・起動する。デバイスが見つからない場合は `xcrun simctl list devices available` で利用可能なデバイスを確認する。

### Maestroフローが失敗する場合
- Maestro CLIがインストールされているか確認: `which maestro`
- フローファイルが存在するか確認: `ls maestro/flows/capture_all_previews.yaml`
- シミュレータを再起動してリトライ

### スクリーンショットが0枚の場合
- `maestro/screenshots/` ディレクトリの中身を確認
- Maestroのテスト結果ログを `maestro/test-results/` で確認
- プレビューアプリが正常に起動しているかスクリーンショットで確認

## 注意事項

- `maestro/config.yaml` でテスト出力先が `maestro/test-results/` に設定されている。Maestroのテスト成果物（スクリーンショット、ログ、AIレポート）はそこに出力される
- プレビューではFirebaseが未初期化のため、`SettingPage`の一部機能（プロフィール保存など）は動作しない
- モックデータは `lib/features/previews/mock/mock_data.dart` で定義
- Maestroフローは `maestro/flows/capture_all_previews.yaml`

## 検証方法

1. `run_maestro_screenshots.sh` がシミュレータ上でプレビューアプリを起動できることを確認
2. `maestro/screenshots/` にスクリーンショットが出力されることを確認
3. 出力されたスクリーンショットをReadツールで読み込み、画像として表示できることを確認
