# App Store / Google Play スクリーンショット生成

「背景 + キャッチコピー + デバイスフレーム + アプリ画面」を 1 つの Flutter Widget として組み立て、
シミュレータの実描画で撮影して提出用画像を作る。撮影後に画像を合成する後処理は無い。

## 構成

| 場所 | 役割 |
|---|---|
| `lib/screenshot/screenshot_app.dart` | 撮影・検証が共通で使う MaterialApp（l10n・テーマの設定を 1 か所に持つ） |
| `lib/screenshot/screenshot_copy.dart` | ロケール別のキャッチコピー（スクリーンショット専用の静的辞書） |
| `lib/screenshot/screenshot_layout.dart` | 背景・コピー・デバイスフレームの合成レイアウト |
| `lib/screenshot/screenshot_pages.dart` | 提出順のページ定義。アプリ画面は本番 Page を `previewProviderOverrides` の mock で動かす |
| `integration_test/app_store_screenshots_test.dart` | 撮影本体。ロケール × ページの数だけ撮る |
| `lib/screenshot/screenshot_iphone_duo_displays.dart` | iPhone Duo の外側・内側ディスプレイの寸法と使うレイアウト |
| `integration_test/app_store_screenshots_iphone_duo_test.dart` | iPhone Duo 用の撮影本体。ディスプレイ × ロケール × ページの数だけ書き出す |
| `test_driver/screenshot_test.dart` | 撮影結果をホスト側に PNG として書き出す driver |

## 実行

```bash
# 全ロケール・全ページ（撮影用シミュレータは自動で起動する）
bash scripts/generate_screenshots/generate_appstore_screenshots.sh

# Google Play 用に縦横比を変換（App Store 用の撮影後に実行する）
bash scripts/generate_screenshots/convert_for_google_play.sh

# iPhone Duo の外側 (1398x2034)・内側 (2853x2007)
bash scripts/generate_screenshots/generate_iphone_duo_screenshots.sh
```

出力先:

- 中間: `artifacts/appstore_screenshots/{locale}/`
- App Store 提出用: `ios/fastlane/screenshots/{locale}/`
- App Store 提出用 (iPhone Duo): `ios/fastlane/screenshots_iphone_duo/{locale}/`。
  `upload_appstore_screenshots.sh` (fastlane deliver) は Duo の寸法を受け付けないため対象外で、
  App Store Connect の iPhone Duo の枠へ別に上げる
- Google Play 提出用: `artifacts/googleplay_screenshots/{locale}/`

## 仕様上の制約

- App Store は 6.9 インチ（1320x2868）が必須。撮影機は `iPhone 16 Pro Max` に固定し、
  生成後に `sips` で寸法を検証して取り違えを検出する
- Google Play は「長辺が短辺の 2 倍以内」の制約があり、1320x2868（2.17 倍）はそのまま入稿できない。
  `convert_for_google_play.sh` が背景色で左右を埋めて 9:16 に変換する
- ロケール・ページの絞り込み機構は持たない。`--dart-define` で絞り込む方式は
  `flutter drive` が前回ビルドを再利用したときに古い条件のまま実行され、
  撮れたつもりで枚数が足りない事故になったため廃止した

## 変更するとき

- キャッチコピーを変える → `screenshot_copy.dart`。ページ数と各ロケールの要素数を揃える
- 見せる画面を変える → `screenshot_pages.dart`。アプリ画面は `lib/features/previews/` の
  preview を再利用し、スクリーンショット専用の UI は書かない
- レイアウト（余白・フォントサイズ・フレーム）を変える → `screenshot_layout.dart`
