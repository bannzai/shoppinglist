# 0013. 買い物リスト UI 全面再設計の基盤（AppTokens / 5 色プリセット / google_fonts）

## Status

Accepted

- Date: 2026-05-10
- Decision-Makers: bannzai

## Context

`design_handoff_shopping_list/` に Anthropic Labs の Claude Design 経由で生成された High-fidelity デザインバンドル（issue #250 / #251 の指示書から得た成果物）が入った。これを Flutter 側で再現するにあたり、PR1（基盤フェーズ）として次の 3 つの意思決定が必要になった。

1. デザイントークン（21 色の中立色 + 5 色アクセントプリセット + spacing / radius / shadow）をどう Flutter ThemeData に乗せるか
2. プレミアム機能で切り替え可能なテーマカラーを、既存の 10 色プリセット（パープル / レッド / オレンジ / グリーン等）から、新デザインで指定された和の伝統色 5 色（朱 / 抹茶 / 藍 / 墨 / 朽葉）にどう移行するか。`users/{uid}.themeColorHex` は既存ユーザーが選択済みの可能性がある
3. デザインで指定されたフォント 3 種（Noto Sans JP / Zen Kaku Gothic New / IBM Plex Mono）と OpenType feature（`palt` プロポーショナル詰め組、`tnum` 等幅数字）をどう導入するか。プロジェクトに `google_fonts` も `assets/fonts/` 同梱もこれまでなかった

## Decision

### 1. ThemeExtension<AppTokens> をデザイントークンの SSOT に採用する

`ColorScheme.fromSeed(seedColor)` ベースのテーマ生成を廃止し、`ThemeExtension<AppTokens>` を新設してそこにデザイン固有色を集約する。

- `lib/style/tokens.dart` に `AppNeutralColors` (21 色 light/dark) / `AccentPreset` (5 色 enum) / `AppTokens extends ThemeExtension<AppTokens>` を定義
- `ColorScheme` には Material 互換マッピング（`surface` / `primary` / `error` 等）のみ載せ、`primary = tokens.accent` で揃える。これで既存の `Theme.of(context).colorScheme.primary` 参照が壊れない
- デザイン固有色（`paper` / `surface2` / `ink2-4` / `divider2` / `accentSoft` / `accentInk` / `checked` / `okSoft` / `dangerSoft` / `warn`）は AppTokens 側に分離
- 取得は `Theme.of(context).extension<AppTokens>()!` を `context.tokens` 拡張で糖衣化
- `lib/style/theme.dart` の `buildAppTheme(brightness, accent)` ファクトリで ThemeData を組み立て、`extensions: [tokens]` で注入する

**代替案と却下理由**:
- ColorScheme をそのまま使う → 情報量不足（21 色の中立階調を 1:1 で乗せられない）で却下
- Provider で AppTokens を配る → `ThemeMode.system` の OS ダーク追従や `ThemeData.lerp` のテーマ遷移補間が壊れるので却下

### 2. 5 色プリセット移行は読み取り fallback のみ。既存ユーザーの値は書き戻さない

`themeColorPresets` を 5 色（`shu` / `matcha` / `ai` / `sumi` / `kuchiba`）に差し替え、`defaultThemeColorHex` を `'#C2410C'`（朱）に変更する。

- Firestore `users/{uid}.themeColorHex` フィールドはそのまま使い続け、マイグレーションも Rules 変更も行わない
- `resolveAccentPreset(themeColorHex)` が以下を全部 `AccentPreset.shu` に倒す:
  - `null`（未設定の新規ユーザー）
  - 旧 10 色 HEX（`#673AB7` / `#F44336` / `#E91E63` / `#FF9800` / `#4CAF50` / `#009688` / `#2196F3` / `#3F51B5` / `#795548` / `#607D8B`）
  - その他の不正値
- 読み取り時のみフォールバックし、Firestore への書き戻しはしない。ユーザーが設定画面で 5 色のいずれかを選び直したタイミングではじめて新 HEX が永続化される
- `ThemeColorUpdate.call({preset})` を `AccentPreset` 受け取りに変更（旧 `call({themeColorHex})` 廃止）

**代替案と却下理由**:
- 一斉マイグレーション（読み取り時に旧 HEX を見たら即 Firestore を朱で上書き）→ ユーザーが設定画面を開いていないタイミングでサイレントに見た目が変わる体感悪さで却下
- 旧 10 色を併存させる → 朱・抹茶などの和の伝統色トーンと、Material のパレット由来色（パープル / インディゴ等）の世界観が衝突するので却下

### 3. フォントは google_fonts のランタイム DL を採用（静的同梱しない）

`pubspec.yaml` に `google_fonts: ^6.2.1` を追加し、`GoogleFonts.notoSansJp()` / `GoogleFonts.zenKakuGothicNew()` / `GoogleFonts.ibmPlexMono()` をランタイムでダウンロードする。

- `lib/style/theme.dart` の `buildAppTheme` で `textTheme` を Noto Sans JP ベースに組み立て、見出しを Zen Kaku Gothic New に切替
- OpenType feature: `palt`（プロポーショナル詰め組）を `TextStyle.fontFeatures: [FontFeature('palt')]` で textTheme 全体に、`tnum`（等幅数字）は `monoTextStyle()` ヘルパー経由で `done/total` 等の進捗カウンターに個別適用
- `assets/fonts/` への静的同梱はしない

**代替案と却下理由**:
- 静的同梱（assets/fonts/ に Noto Sans JP / Zen Kaku Gothic New / IBM Plex Mono の ttf を配置）→ 日本語フォントは数 MB あり、ストレージ・ビルドサイズが増える。オフライン要件が強まれば移行する含みは残す
- システムフォント → 日本語見出しの和紙テイスト（`palt` 詰め込み + Zen Kaku Gothic New の硬筆感）が再現できないので却下

## Consequences

### Positive

- デザイン固有色 21 + アクセント 5 が型付きで取得でき、各 Widget は `context.tokens.accent` / `context.tokens.neutral.paper` のように補完が効く
- ColorScheme との二重管理になっていないので、既存の Material3 ウィジェット（FilledButton / Card / Dialog 等）は `primary = tokens.accent` 経由で自然に新 accent に追従する
- 既存ユーザーの `themeColorHex` が旧 10 色のままでも、見た目は朱（新デフォルト）にフォールバックするだけで Firestore は触らないため、Rules や migration job は不要
- `google_fonts` 採用でフォントアセットを同梱せずにすみ、`pubspec.yaml` の `assets:` セクションを汚さない

### Negative / Trade-offs

- `Theme.of(context).extension<AppTokens>()!` の `!` 強制 unwrap は、`buildAppTheme` を経由しない `MaterialApp.theme` 直書きが他にあると null pointer になる。本 PR で `lib/app.dart` を全置換した前提に強く依存する
- `google_fonts` のランタイム DL は初回起動時にネット接続がないと Roboto にフォールバックする。`main.dart` で `GoogleFonts.pendingFonts(...)` によるプリロード、または将来 `assets/fonts/` への移行は次フェーズの検討事項
- 旧 10 色のユーザーは設定画面で再選択しない限り Firestore 上は旧 HEX のまま残る。長期的に見ると Firestore 上に旧 HEX が混在する状況が続くが、`isSupportedThemeColorHex` でテストしているとおり「読み取り時 fallback」が安定動作する限り問題ない

### Migration / Rollout

- 段階的 PR 分割の PR1。後続:
  - PR2: ShoppingListPage 中核改修（ListTopBar / GroupChipsBar / FilterChipsBar / ProgressBlock / ItemRow / ExpandableFab / バナー類 / SnackBar）
  - PR3 / PR4: 周辺 16 画面 + Onboarding
  - PR5: iOS WidgetKit / Android Glance のホームウィジェット再スキン
- 既存 `Theme.of(context).colorScheme.primary` 参照箇所は `primary = tokens.accent` のため自動で新 accent に切り替わる（破壊的変更なし）
- `lib/features/home_widget/home_widget_data_sync.dart` の `_defaultThemeColorHex = '#673AB7'` は本 PR では未変更。PR5（ホームウィジェット）で `#C2410C` に揃える

## References

### 実装ファイル
- `lib/style/tokens.dart`
- `lib/style/theme.dart`
- `lib/provider/theme_color.dart`
- `lib/app.dart`
- `lib/components/frame/{app_pill,app_round_button,app_checkbox,app_chip,app_large_app_bar,app_bottom_tab_bar,app_section_card}.dart`

### 関連ドキュメント
- プラン: `plans/design-handoff-shopping-list-readme-md-soft-owl.md`
- デザインバンドル: `design_handoff_shopping_list/README.md`、`source/tokens.jsx`、`source/frame.jsx`
- 関連 issue: #250（Claude Design 指示書）、#251（指示書再設計）

### 既存 ADR との関係
- ADR 0012（Firestore Rules 簡略化）と整合: 本 ADR でも `users/{uid}.themeColorHex` のクライアント直接書き込みは継続し、Rules はオーナー判定（既存）のまま変更しない
