#!/usr/bin/env python3
"""「写真から追加」（AI 画像認識）検証用の買い物メモ風テスト画像を生成する。

test/fixtures/shopping_memo_images/ に JPEG を出力する（既存ファイルは上書き。冪等）。
実行には Pillow と macOS のヒラギノフォントが必要（開発機での再生成・追加用。
生成済み画像はリポジトリにコミット済みのため、通常は実行不要）。

使い方: python3 scripts/generate_test_shopping_memo_photos.py
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

# 生成先はリポジトリの fixtures ディレクトリ固定（スクリプト位置から解決）
output_directory = (
    Path(__file__).resolve().parent.parent / "test/fixtures/shopping_memo_images"
)

# AI 画像認識（Gemini）がテキストを読み取りやすいよう、明るい無地背景に
# 大きめ（64pt）の箇条書きで描画する。W4 は手書きメモに近すぎない中庸なウェイト。
font = ImageFont.truetype("/System/Library/Fonts/ヒラギノ角ゴシック W4.ttc", 64)


def generate_shopping_memo_image(
    file_name: str, title: str, item_names: list[str]
) -> None:
    """タイトルと箇条書きアイテムを描画した買い物メモ風 JPEG を1枚生成する。"""
    # 800x1000 は縦長の紙メモ比率。base64CompressImage の縮小上限（長辺1000px）と同じで、
    # アップロード時に画質劣化する再圧縮のみでリサイズが起きないサイズにしている。
    image = Image.new("RGB", (800, 1000), "#fdfbf5")
    draw = ImageDraw.Draw(image)
    draw.text((60, 40), title, fill="#333333", font=font)
    y = 180
    for item_name in item_names:
        draw.text((80, y), f"・{item_name}", fill="#222222", font=font)
        y += 110
    # quality 90: 文字の可読性を保ちつつファイルサイズを抑える（本文用途の一般的な設定）
    image.save(output_directory / file_name, "JPEG", quality=90)


generate_shopping_memo_image(
    "shopping_memo_1.jpg", "かいものメモ 1", ["牛乳", "たまご", "食パン", "バナナ"]
)
generate_shopping_memo_image(
    "shopping_memo_2.jpg", "かいものメモ 2", ["トマト", "豚肉", "チーズ"]
)
print(f"generated into {output_directory}")
