# App Store 製品ページヘッダー

`header.jpg` は全言語共通の文字なし入稿用画像。`prompt.txt` は生成に使用したプロンプト。

## 訴求と根拠

「家族の買い物がひとつにまとまる」を、ひとつの買い物かごと左右の食材で表現する。`ios/fastlane/metadata/ja/name.txt`・`subtitle.txt`・`description.txt` にある家族・ルームメイトとのリスト共有を訴求の根拠とした。

配色は `lib/style/tokens.dart` の既定アクセント「朱」と和紙風の中立色を参照。紙の立体造形と控えめな影で、`lib/style/theme.dart` の温かく落ち着いたトーンに合わせた。文字・数字・実在ロゴ・商品ラベルを使わず、言語に依存しない食材の抽象形だけで構成する。

## 仕様と制作

- 形式: JPEG、3840 × 1646 px、透過なし
- Art Safe Area: 左1097、上493、右2743、下1154 px
- 生成: Gemini `gemini-3-pro-image-preview`、21:9、4K指定
- 正規化: 中央クロップ・縮小後、`sips` でJPEG品質95に変換

Apple公式テンプレートを取得して寸法を実測した。これはテンプレートの作業領域であり、App Store Connectでの受理を確認した値ではない。

https://developer.apple.com/app-store/asset-best-practices/

## 検証

2026-09-09 にリポジトリルートから実行し、すべて exit 0。

```sh
bash ~/.agents/skills/appstore-header-creative/scripts/fetch_template_spec.sh --type header --cache-dir ./tmp/appstore-header-creative
bash ~/.agents/skills/appstore-header-creative/scripts/normalize_asset.sh ./tmp/header-generated-v3.png ./tmp/header-normalized-v3.jpg --type header
sips -s format jpeg -s formatOptions 95 ./tmp/header-normalized-v3.jpg --out appstore/product-page-header/header.jpg
bash ~/.agents/skills/appstore-header-creative/scripts/check_header_asset.sh appstore/product-page-header/header.jpg --type header
bash ~/.agents/skills/pr-attach-screenshots/scripts/check-upload-target.sh appstore/product-page-header/header.jpg
```

テンプレートの取得結果は上記寸法と一致。生成元6336×2688 pxからの縮小で、拡大なし。完成画像の検証結果:

```text
[OK] フォーマット: jpeg
[OK] サイズ: 3840x1646
[INFO] Art Safe Area (実画像換算): left=1097 top=493 right=2743 bottom=1154 — キーコンテンツ・コピーはこの範囲内に収める
```

`[OK]` 2件、`[WARN]` 0件、`[NG]` 0件。公開前の機械検査も `image/jpeg` として合格。完成ファイルを表示し、かご・果実・パン・葉野菜がセーフエリア内に収まり、文字・数字・実在ロゴ・秘匿情報・人物・QRコード・バーコード・価格・割引・受賞表現がないことを目視確認した。

生成時にSDKの自動関数呼び出しに関する非推奨警告、正規化時に `sysctlbyname for kern.hv_vmm_present failed with status -1` が出たが、両コマンドはexit 0で完了し、完成画像の検証に合格した。生成出力は拡張子がPNGでも実体がJPEGだったため、完成品ではJPEG形式と拡張子を明示的に揃えた。

アプリ実装に変更がないため、Flutter/Firebaseのビルド・テスト・Maestroは対象外。App Store Connectの入稿先確認・アップロード・審査提出・実表示の確認は今回の依頼に含まれず、未実施。

## セッション再開

```sh
cd /Users/bannzai/worktrees/bannzai/shoppinglist/appstore-header-creative
codex resume 01a08542-7e3d-7880-adcb-70365228285e
```
