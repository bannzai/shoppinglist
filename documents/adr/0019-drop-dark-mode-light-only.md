# 0019. ダークモード対応の全廃とライトモード固定

## Status

Accepted

## Context

アプリは `MaterialApp` の `theme` / `darkTheme` を `buildAppTheme(brightness:)` で生成し、`themeMode: ThemeMode.system` で OS のライト/ダーク設定に追従していた。デザイントークン体系（`AppTokens` / `AppNeutralColors` / `AccentPreset`）も `brightness` を軸にライト/ダークの色を出し分ける構造だった。

しかし運用の結果、ダークモード時に UI の色崩れ（コントラスト不足、影の白浮き、`neutral.ink` がダークで明色化して白く光る等）が散発し、品質を担保できていなかった。当面ダークモードに対応する予定もない。

選択肢は2つあった。

1. **ライト固定のみ（最小）**: `themeMode: ThemeMode.light` 相当にしてダーク色定義はコードに残す。
2. **ダークコード全削除（徹底）**: ライト固定に加え、トークン体系から `brightness` 次元を物理的に除去する。

実行時の見た目はどちらも同一（常にライト）で、差は「コードに未使用のダーク分岐・色を残すか否か」のみだった。

## Decision

選択肢2（全削除）を採用する。

- `MaterialApp` は `theme` のみを指定し、`darkTheme` / `themeMode` を提供しない（OS がダークでも常にライト表示）。
- デザイントークン体系から `brightness` 次元を完全に削除し、ライトのみに簡約する。
  - `AppTokens.brightness` フィールド・`isDark` getter、`accent`/`accentSoft`/`accentInk` のライト/ダーク分岐
  - `AppNeutralColors.dark`、`AppTokens.shadowDark`
  - `AccentPreset` 各プリセットの `dark` / `softDark` / `inkDark`（5プリセット×3色）
  - `buildAppTheme` / `AppTokens.of` の `brightness` 引数と、それに基づく `ThemeData` / `ColorScheme` / `textTheme` の分岐
- `app_chip.dart` / `theme_color_selection_page.dart` の `isDark` 分岐、`loading.dart` のダークモード前提コメントも整理する。

採用理由: ダークの色崩れを個別に直すより、当面ダーク対応の予定がない以上、未使用コード・分岐を残さず簡約する方が保守性が高く、UI デバッグ時に「どちらの brightness か」を考慮する必要がなくなる。

ライト表示の色・スタイルは変更前と同一（既存のライト分岐値をそのまま採用）にとどめ、見た目の回帰を出さない。

## Consequences

### 良い点
- 保守対象の `brightness` 分岐・未使用のダーク色定義が消え、トークン体系がライト単一でシンプルになる。
- UI の確認・デバッグで brightness の場合分けを考えなくてよくなる。
- ダーク時の色崩れという品質リスクが原理的に消える。

### トレードオフ・悪い点
- 将来ダークモードに対応する場合は、`brightness` 次元とダーク色パレット・トークン体系を再構築する必要がある（本 ADR を Superseded とし、新 ADR で再設計を記録する）。
- フィールド名 `light` / `softLight` / `inkLight`、定数 `shadowLight` はダーク対と無くなった後も名称を維持している（改名の波及を避けた最小変更のため）。

### 関連
- `documents/adr/0015-neutral-palette-grayscale-for-legibility.md`
- `documents/adr/0018-neutral-palette-warm-but-lighter.md`（ライトの中立色定義）
