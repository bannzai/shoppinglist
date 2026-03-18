# UI Screenshot Review Skill

UIのスクリーンショットを撮影し、確認・改善を行うスキル。

## 使い方

1. シミュレータでプレビューアプリを起動
2. Maestroフローでスクリーンショットを撮影
3. スクリーンショットを確認し、UI改善を実施

## 実行手順

### Step 1: スクリーンショット撮影

```bash
run_maestro_screenshots.sh
```

### Step 2: スクリーンショット確認

`maestro/screenshots/` 内の画像をReadツールで確認する。

### Step 3: UI改善

問題点を分析し、該当するソースファイルを修正する。修正後、再度スクリーンショットを撮影して確認する。

## ソースファイルの特定

スクリーンショット名から対応するソースファイルを特定するには、`lib/features/` 配下を画面名で検索する。

## 注意事項

- プレビューではFirebaseが未初期化のため、`SettingPage`の一部機能（プロフィール保存など）は動作しない
- モックデータは `lib/features/previews/mock/mock_data.dart` で定義
- Maestroフローは `maestro/flows/capture_all_previews.yaml`
