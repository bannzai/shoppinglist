# 0018. 中立色パレットを「暖色を弱めて残す」方向へ調整（ADR 0015 の refine）

## Status

Accepted

- Date: 2026-06-04
- Decision-Makers: bannzai

## Context

ADR 0013 で「和紙テイスト」を掲げ、中立色（背景・テキスト・罫線）に暖色ベージュ／黄土系を採用した（`paper #ECE5D3` / `surface #F8F2E2` / `surface2 #FFFCF3` / `divider #E0D5BC` 等）。

ADR 0015 は、この薄茶トーンが複数の面に重なって境界が判別しづらく文字とのコントラストも弱い問題に対し「中立色を無彩色グレースケール化する」と決定した（Accepted）。しかし `lib/style/tokens.dart` には実装が着地しておらず、暖色値が残ったままだった（ファイルのコミット履歴に `#ECECEC` 等のグレースケール値が一度も存在しない）。ネイティブ Widget（iOS Swift / Android XML）の背景色も暖色 `#F6F0E2` のまま、Dart トークンともドリフトしていた。

今回、再び「グループ設定が茶色すぎて見づらい」「全体的に背景を整えてほしい。見づらい場所があるのは良くない」との報告を受けた。調査の結果、これはグループ設定固有ではなく、ほぼ全画面が背景に `neutral.paper` を直接敷いているためのアプリ全体の問題だった。方向性をユーザーに確認したところ、**完全グレースケール化（ADR 0015）ではなく、和紙の温かみを薄く残しつつ茶色味を低減しコントラストを底上げする中間案**を採用することになった。

## Decision

### 1. `AppNeutralColors.light` を「暖色を弱めて残す」中間案へ差し替える

`lib/style/tokens.dart` の LIGHT 中立色のうち、地・罫線・キャプション文字を脱飽和・明度調整する。明度順 `paper < surface < surface2 < card` を保ち面の奥行きを残す。

| トークン | 旧 | 新 | 意図 |
|---|---|---|---|
| `paper` | `#ECE5D3` | `#F1EDE4` | 明るく脱飽和した最外背景 |
| `surface` | `#F8F2E2` | `#F7F4EE` | 標準面 |
| `surface2` | `#FFFCF3` | `#FCFAF6` | 入れ子面・チップ背景 |
| `ink2` | `#5A5246` | `#57514A` | 副次文字を微中立化 |
| `ink3` | `#948A77` | `#837A6A` | キャプションを一段暗くしコントラスト改善 |
| `ink4` | `#BDB39E` | `#BBB2A4` | ヘアラインを微中立化 |
| `divider` | `#E0D5BC` | `#E5DFD3` | 黄味を抜き中立寄りに |
| `divider2` | `#EBE2C9` | `#EDE8DE` | 薄罫線も中立寄りに |
| `checked` | `#A89E89` | `#A39A89` | ほぼ維持・微中立化 |

`card`（純白 `#FFFFFF`）・`ink`（`#1B1813`）は維持。

### 2. アクセント・機能色・DARK・shadow は変更しない

- アクセント 5 色プリセット（朱 `#C2410C` 他）と `accentSoft` / `accentInk`、テーマカラー選択機能は維持。
- 機能色（`ok` 緑 / `danger` 赤 / `warn` 黄土）はセマンティックカラーのため維持。
- DARK パレットは near-black（`paper #13110D` 等）で茶色味が知覚されないため変更しない（変更最低限の原則）。
- フローティング影 / `ColorScheme.shadow`（`#1B1813` ベース α 8%）は「茶色すぎ」の主因ではないため変更しない。

### 3. ホームウィジェットの LIGHT paper を手動同期する

ウィジェット背景は Dart トークンと連動せず native にハードコードされている（ADR 0014 Decision 5 の構造）。LIGHT paper を新 `#F1EDE4` へ同期する。DARK `#13110D` は不変。

- iOS: `ios/ShoppingListWidget/ShoppingListWidgetView.swift` の `paper`（light `#F1EDE4`）
- Android: `android/app/src/main/res/layout/shopping_list_widget.xml` の `android:background`（light `#F1EDE4`）

**代替案と却下理由**:

- 完全グレースケール化（ADR 0015）→ 視認性は最大化されるが和紙テイストの世界観が大きく後退するため、今回はユーザー判断で不採用。本 ADR が refine する。
- グループ設定画面のみ修正 → 茶色味は `neutral.paper` を全画面が使うアプリ全体の問題であり、1 画面修正では「全体的に整えて」の要望を満たさないため却下。

## Consequences

### Positive

- 背景の茶色味が弱まり、面境界（paper/surface/card）と文字（特にキャプション `ink3`）のコントラストが向上。中立色トークン差し替えのみで全画面に自動波及する（ADR 0013 の SSOT 構造は不変）。
- 和紙の温かみを薄く残すため、ブランドの世界観の後退は限定的。
- アクセントの朱・機能色が不変のため、識別色とセマンティクスは保たれる。

### Negative / Trade-offs

- ADR 0015 が掲げた「完全無彩色化による最大視認性」は採用しない。視認性向上は中間的。
- ウィジェットの中立色は Flutter ↔ iOS Swift ↔ Android XML の 3 箇所で手動同期が残る（ADR 0014 Decision 5 と同じ構造的負債）。

## References

### 実装ファイル
- `lib/style/tokens.dart`（`AppNeutralColors.light`）
- `ios/ShoppingListWidget/ShoppingListWidgetView.swift`
- `android/app/src/main/res/layout/shopping_list_widget.xml`
- `design_handoff_shoppinglist/preview/tokens.jsx`、`styles.css`（参照同期）
- `test/style/tokens_test.dart`（背景の明度順不変条件テスト）

### 関連 ADR
- ADR 0015（中立色の無彩色化）: 本 ADR は 0015 を refine する。完全グレースケール化は採らず、暖色を弱めて残す方向に上書きする。0015 は未実装のまま本 ADR で置き換える。
- ADR 0013（和紙テイスト基盤）: トークン構造とアクセント方針を継承。
- ADR 0014（ShoppingListPage 再設計）: ウィジェット native 同期の構造を踏襲。
