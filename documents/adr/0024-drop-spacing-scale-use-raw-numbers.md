# 0024. spacing scale を廃止し余白は生の数値リテラルに統一する

## Status
Accepted

## Context
ADR 0013 でデザイントークン基盤（中立色 21 + アクセント 5 プリセット + spacing / radius / shadow）を `ThemeExtension` に集約する SSOT を採用した。このうち spacing は `AppTokens.s2`〜`s32`（`2.0`〜`32.0` の static const、12 個）として定義していた。

運用を経て、この spacing scale には以下の問題があった。

- 実体はマジックナンバーを定数名に置き換えただけで、`s12` という名前から余白の意味（用途・文脈）は読み取れない。命名による可読性向上の効果が薄い。
- 「1 つの値を変えれば全体に反映される」というトークン本来の運用が成立していない。各定数は固有の値を持ち、`s12` の値を変えても文脈の異なる別箇所まで一括で変わるだけで、意図した一括調整にはならない。
- 実使用は 5 箇所のみ（`progress_pill.dart` の `s12`/`s6`、`shopping_list/page.dart` の `s16` ×2、`shopping_list_items.dart` の `s32`）に留まり、その他の余白は `EdgeInsets` のリテラルや `Column`/`Row` の標準 `spacing:` 引数で直接書かれており、トークン適用が徹底されていなかった。

あわせて、トークンを保持する `ThemeExtension` クラスの名前 `AppTokens` が「これが `ThemeExtension` である」ことを示さず分かりにくいという課題もあった。

## Decision
- spacing scale（`AppThemeExtension.s2`〜`s32`）を**廃止**し、余白指定は生の数値リテラル（`12`, `6`, `16`, `32` など）に統一する。値そのものが意味を持つマジックナンバーとして、使用箇所に直接書く。
- `ThemeExtension` クラス名を `AppTokens` → `AppThemeExtension` にリネームし、取得用の糖衣 getter を `context.tokens` → `context.appTheme` に変更する。
- color（`AppNeutralColors` / `AccentPreset`）・`radius*`・`shadowLight` の `ThemeExtension` 集約（SSOT）は**維持**する。これらは「アクセント切替で全体に波及する」「テーマ補間で `lerp` される」など、トークンとして集約する実利があるため。

ADR 0013 で定めたデザイントークン基盤のうち spacing 部分のみを本 ADR で見直す。color/radius/shadow を `ThemeExtension` に集約する基本方針は不変のため、ADR 0013 全体を Superseded にはしない。

## Consequences
- 良い点
  - 余白の値が使用箇所で直接読め、`s12` の定義元を辿る必要がなくなる。
  - 「使われていないトークン定数」「適用が徹底されていないトークン」という中途半端な状態が解消される。
  - クラス名 `AppThemeExtension` から `ThemeExtension` であることが明確になり、`context.appTheme` の意味も分かりやすくなる。
- 悪い点・トレードオフ
  - 同じ余白値を複数箇所で使う場合でも一括変更はできない（各箇所を個別に直す）。ただし spacing scale でも実質同じ運用だったため、実質的な後退はない。
  - 将来、余白を体系的なスケールで管理したくなった場合は再設計が必要になる。その時点で本決定を見直す。
- 影響範囲
  - `lib/style/tokens.dart` から spacing scale を削除。`AppTokens`→`AppThemeExtension`、`context.tokens`→`context.appTheme` を全参照に適用。
  - `flutter analyze`（No issues）・`flutter test`（全件パス）・`flutter build ios` 成功を確認済み。
  - 既存 ADR（0013/0015/0021）に残る `AppTokens` / `context.tokens` という記述は、決定時点の履歴として原文のまま残す（現行のコード上の名称は `AppThemeExtension` / `context.appTheme`）。
