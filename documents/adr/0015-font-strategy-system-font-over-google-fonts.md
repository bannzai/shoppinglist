# 0015. フォント戦略 - google_fonts 廃止と OS 標準フォントの採用

## Status
Accepted

## Context
アプリ起動時に「最初は Roboto などのデフォルトフォントで描画され、しばらくして Noto Sans JP / Zen Kaku Gothic New / IBM Plex Mono に差し替わる」現象が発生していた。

原因は `lib/style/theme.dart` および 8 ファイルの直接呼び出しで `google_fonts` パッケージを使用しており、初回起動時にネットワークから .ttf をランタイム DL する仕組みになっていたこと。`main.dart` での `GoogleFonts.pendingFonts(...)` プリロードも行われておらず、`pubspec.yaml` の `fonts:` セクション・`assets/fonts/` 配置・iOS `UIAppFonts` / Android XML フォントいずれも未設定だった。

ADR 0013 (`design-handoff-foundation`) では「pendingFonts プリロード or `assets/fonts/` 同梱」が次フェーズ検討事項として明記されていたが、未対応のままになっていた。

検討した選択肢:

1. **`GoogleFonts.pendingFonts(...)` で起動前にプリロード** - フォントを保ちつつ DL を待つ。初回起動時のネットワーク待ち時間が増え、オフラインだとフォールバックが発生する点は変わらない。
2. **`.ttf` を `assets/fonts/` に同梱 + `pubspec.yaml fonts:` 宣言** - DL 不要・見た目完全維持。アプリサイズが日本語フォント分で 5〜10MB 増える。
3. **OS 標準フォントに切り替え（fontFamily 未指定）** - iOS は San Francisco / Hiragino Sans、Android は Roboto / Noto Sans CJK JP を使用。DL もアセット追加も不要で起動時のフォント差し替わりは原理的に起きない。Android は実質 Noto Sans CJK JP となり現状と近い見た目を維持できる。

ユーザーは「フォントは DL してまでこだわらない、今のものと近いもので良い」と判断した。

## Decision
**OS 標準フォント（システムフォント）を採用する**。

- `lib/style/theme.dart` の `sans` / `serif` / `monoTextStyle` / `notoSansJpTextTheme` を全て `TextStyle`（`fontFamily` 未指定）に置き換える。
- 見出し用の `serif` 関数（Zen Kaku Gothic New）は廃止し、`displayLarge` / `displayMedium` を `sans` の `FontWeight.w800` で表現してフォントの種類を一本化する。
- 数値表示用 `monoTextStyle` は IBM Plex Mono を廃止し、`fontFeatures: [FontFeature.tabularFigures()]` だけ残して進捗・価格・コードの桁を縦に揃える。`letterSpacing` 引数を追加して既存呼び出しのコード詰め間隔を維持する。
- 各 feature 直下で `GoogleFonts.ibmPlexMono` / `GoogleFonts.zenKakuGothicNew` を直接呼び出していた 8 ファイル（settings, theme_color_selection, group_list, shopping_list_setting/invitation_code_dialog, paywall, group_create, onboarding）も同様に `monoTextStyle` または `TextStyle` に置き換える。
- `pubspec.yaml` から `google_fonts` 依存を削除する。

## Consequences

### Positive
- 起動時のフォント差し替わり現象が原理的に解消する（ネットワーク DL を一切行わない）。
- アプリサイズが軽くなる（`google_fonts` パッケージおよびキャッシュ管理コードが不要）。
- オフライン環境でも一貫した見た目で動作する。
- フォント描画パスがプラットフォーム最適化されたパス（OS 標準）に乗るためレンダリングが軽い可能性がある。
- ADR 0013 で「次フェーズ検討事項」として残っていた pendingFonts / assets 同梱の判断が不要になる。

### Negative / Trade-off
- iOS は San Francisco / Hiragino Sans が使われるため、Noto Sans JP ベースだった既存の見た目とは細部が変わる（特に仮名の字面）。Android は実質 Noto Sans CJK JP になるため見た目変化は最小。
- 見出しの Zen Kaku Gothic New の柔らかい字面が失われ、本文と同じフォントの太字で表現することになる。
- `monoTextStyle` は完全な等幅フォントではなくなる（OS 標準のプロポーショナルフォント + tabularFigures）。数字の縦揃えは保たれるが、招待コードなどの「コードっぽい等幅見た目」は失われ、プロポーショナル + `letterSpacing` で代替する。
- `palt` (プロポーショナル詰め組) feature は引き続き指定するが、OS 標準フォントがこの feature をサポートしない場合は無視される。

### Future
- 将来「やはり Noto Sans JP の見た目に戻したい」となった場合は、選択肢 2（`.ttf` を `assets/fonts/` に同梱）に切り替える。その時点で本 ADR を Superseded にして新規 ADR を起こす。
- `monoTextStyle` の関数名は歴史的経緯（旧 IBM Plex Mono）由来で、現状は「tabularFigures を持つ数値用スタイル」を返すヘルパー。リネームは呼び出し箇所への波及が大きいため見送り、ドキュメンテーションコメントで役割を明示する形に留める。
