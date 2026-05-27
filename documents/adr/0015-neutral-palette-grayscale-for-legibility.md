# 0015. 中立色パレットの白黒（無彩色）化

## Status

Accepted

- Date: 2026-05-25
- Decision-Makers: bannzai

## Context

ADR 0013 で「和紙テイスト」を掲げ、中立色（背景・テキスト・罫線）に暖色ベージュ／黄土系を採用した（`paper #ECE5D3` / `surface #F8F2E2` / `surface2 #FFFCF3` / `divider #E0D5BC` 等）。

しかし実機の「買い物リスト設定」「買い物リスト一覧」画面のスクリーンショットで、近接した薄茶トーンが複数の面に重なって境界が判別しづらく、文字とのコントラストも弱いため視認性が悪いことが判明した。ユーザーから「シンプルに白と黒を組み合わせて視認性を上げたい」との要望を受けた。

## Decision

### 1. AppNeutralColors.light / dark を無彩色グレースケール化する

`lib/style/tokens.dart` の中立色のうち、地・文字・罫線・チェック済み色（`paper` / `surface` / `surface2` / `ink` / `ink2` / `ink3` / `ink4` / `divider` / `divider2` / `checked`）を彩度ゼロのグレースケールへ置き換える。

- LIGHT: `card` のみ純白を維持し、`paper #ECECEC` < `surface #F4F4F4` < `surface2 #FAFAFA` < `card #FFFFFF` の明度差で面の奥行きを残す（フラット一色にはしない）
- DARK: `paper #0D0D0D`（純黒寄り）< `surface #1A1A1A` < `surface2 #242424` < `card #2E2E2E`。`divider` はカード上で視認できるよう `#333333` に一段持ち上げる
- フローティング影（`AppTokens.shadowLight`）と `ColorScheme.shadow` の墨色ベース（`#1B1813`）を無彩色 `#000000` ベースへ

### 2. アクセント 5 色プリセット・機能色は変更しない

- アクセント（`AccentPreset` の朱 `#C2410C` 他 5 色、`accentSoft` / `accentInk`）は維持。設定→テーマカラーの選択機能もそのまま。FAB・選択状態・進捗バー・カーソルの朱はアプリの識別色として残す
- 機能色（`ok` 緑 / `danger` 赤 / `warn` 黄土）はセマンティックカラーであり「地の色」ではないため維持。警告の `warn #B47B1F` も黄系のまま

### 3. ホームウィジェットの背景色を手動で同期する

ウィジェット背景は Dart の中立色トークンと連動しておらず、ネイティブ側に独立ハードコードされている（ADR 0014 Decision 5 の構造）。同じ無彩色へ手動同期する。

- iOS: `ios/ShoppingListWidget/ShoppingListWidgetView.swift` の `paper`（light `#ECECEC` / dark `#0D0D0D`）・`card`（dark `#2E2E2E`）
- Android: `android/app/src/main/res/layout/shopping_list_widget.xml`（light `#ECECEC`）と `layout-night/shopping_list_widget.xml`（dark `#0D0D0D`）の `android:background`

**代替案と却下理由**:

- 完全フラット（全面 `#FFFFFF`）→ 面の階層が消えカード・セクションの区切りが視認できなくなるため却下。薄グレーの明度差を残す
- アクセントもモノクロ化（FAB も黒）→ アプリの識別色が失われ、CTA と通常要素の区別がつきにくくなるため却下

## Consequences

### Positive

- 背景の茶色味が消え、面境界（paper/surface/card）と文字（ink）のコントラストが明確になり視認性が向上
- ADR 0013 の「中立色 + アクセントを `ThemeExtension<AppTokens>` に集約する SSOT」「`primary = tokens.accent`」構造は不変。中立色定数の差し替えのみで全画面に自動波及し、`flutter analyze` / `flutter test`（154 件）も無改修でパス（中立色の HEX を直アサートするテスト・golden は存在しない）
- アクセントの朱が残るため、ブランドの一貫性は保たれる

### Negative / Trade-offs

- ADR 0013 が掲げた「和紙テイスト」の世界観は大きく後退する。`design_handoff_shoppinglist/preview/tokens.jsx` / `styles.css` は参照用として新値へ同期したが、デザインバンドルのコンセプト（和紙テクスチャ等）とは乖離する
- ウィジェットの中立色は Flutter ↔ iOS Swift ↔ Android XML の 3 箇所で手動同期が残る（ADR 0014 Decision 5 と同じ構造的負債）

## References

### 実装ファイル
- `lib/style/tokens.dart`（`AppNeutralColors.light` / `.dark`、`AppTokens.shadowLight`）
- `lib/style/theme.dart`（`ColorScheme.shadow`）
- `ios/ShoppingListWidget/ShoppingListWidgetView.swift`
- `android/app/src/main/res/layout/shopping_list_widget.xml`、`layout-night/shopping_list_widget.xml`
- `design_handoff_shoppinglist/preview/tokens.jsx`、`styles.css`（参照同期）

### 関連 ADR
- ADR 0013（和紙テイスト基盤）: 本 ADR は 0013 の中立色のみを上書きし、トークン構造とアクセント方針は継承する
- ADR 0014（ShoppingListPage 再設計）: ウィジェット native 同期の構造を踏襲

### プラン
- `plans/image-2-image-1-velvety-axolotl.md`
