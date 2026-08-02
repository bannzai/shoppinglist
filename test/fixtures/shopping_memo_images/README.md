# shopping_memo_images（買い物メモ風テスト画像）

「写真から追加」（AI 画像認識・`generateShoppingListItemsFromImage`）の動作確認用テスト画像。
買い物メモを模した箇条書きの JPEG で、AI がアイテム名を安定して読み取れる内容にしてある
（Issue #530 の動作確認で使用した実績あり）。

## 内容

| ファイル | タイトル | アイテム |
| --- | --- | --- |
| `shopping_memo_1.jpg` | かいものメモ 1 | 牛乳・たまご・食パン・バナナ |
| `shopping_memo_2.jpg` | かいものメモ 2 | トマト・豚肉・チーズ |

## 使い方

### iOS Simulator の写真ライブラリへ追加する（手動・E2E 検証）

```bash
# 起動中の simulator へ追加（複数台起動時は UDID を明示する）
bash scripts/add_test_shopping_memo_photos.sh [simulator UDID]
```

追加後、アプリの FAB 長押し →「写真から追加」→ フォトライブラリで選択して検証する。
複数枚選択の検証には 2 枚とも追加して使う。

### flutter test での利用

`test/utils/image/shopping_memo_images_test.dart` が本ディレクトリの画像を読み込み、
アップロード前処理（`base64CompressImage`）で処理できることを保証している。
画像を差し替え・追加した場合もこのテストが通ることを確認する。

## 再生成・追加

```bash
python3 scripts/generate_test_shopping_memo_photos.py
```

生成済み画像はコミット済みのため通常は実行不要。アイテムの変更・メモの追加をしたい場合に
スクリプトを編集して再実行する（Pillow と macOS のヒラギノフォントが必要）。
