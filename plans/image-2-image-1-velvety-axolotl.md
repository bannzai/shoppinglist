# 中立色パレットの白黒化（視認性改善）

## Context

現状アプリは「和紙テイスト」として中立色（背景・テキスト・罫線）に暖色ベージュ／黄土系を採用している（ADR 0013）。しかし実機スクリーンショットで確認したところ、`paper #ECE5D3` / `surface #F8F2E2` / `surface2 #FFFCF3` / `divider #E0D5BC` といった近接した薄茶トーンが重なり、面の境界・文字とのコントラストが弱く視認性が悪い。

ユーザー要望は「シンプルに白色・黒色を組み合わせて視認性を上げる」こと。以下の方針で確定済み（本セッションでヒアリング）:

- **中立色のみ無彩色（白黒グレースケール）化**。アクセントの朱（FAB・選択状態の `#C2410C`）は維持
- ライトは **純白 + 薄グレーで面を差別化**（フラット一色にはしない）
- **5色アクセントプリセット選択機能は維持**（設定→テーマカラー）
- **ライト・ダーク両方**を調整

機能色（`ok`=緑 / `danger`=赤 / `warn`=黄土）はセマンティックカラーであり「背景の地の色」ではないため**今回は変更しない**（警告の `warn #B47B1F` も警告色として黄系を維持）。アクセントの薄塗り背景 `softLight #FBE4D0`（薄オレンジ）も朱アイデンティティの一部として維持する。

### カラー管理構造（調査結果）

- SSOT は `lib/style/tokens.dart` の `AppNeutralColors.light` / `.dark`（ADR 0013）。全画面が `context.tokens.neutral.*` 経由で参照しており、ここ1箇所の変更で30+ファイルに自動波及する
- **ホームウィジェットの背景色だけは自動追従しない**。iOS（Swift）/ Android（XML）にベージュ値が独立ハードコードされており、手動同期が必要
- HEX を直接アサートするテスト・golden テストは**存在しない**ため、色変更でテストは壊れない
- `design_handoff_shoppinglist/preview/tokens.jsx` / `styles.css` はデザイン参照用（実装の真実ではない）。整合のため更新するが任意

## 変更内容

### 1. `lib/style/tokens.dart` — 中立色 LIGHT（74-91行を置換）

明度順 `paper`(最暗) < `surface` < `surface2` < `card`(最明) を維持したまま無彩色化する。

```dart
  /// LIGHT モードの中立色。無彩色グレースケール（card のみ純白）。
  static const light = AppNeutralColors(
    paper: Color(0xFFECECEC),
    surface: Color(0xFFF4F4F4),
    surface2: Color(0xFFFAFAFA),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF1A1A1A),
    ink2: Color(0xFF595959),
    ink3: Color(0xFF8C8C8C),
    ink4: Color(0xFFC2C2C2),
    divider: Color(0xFFE0E0E0),
    divider2: Color(0xFFEEEEEE),
    ok: Color(0xFF2F6B43),
    okSoft: Color(0xFFDCEBDF),
    warn: Color(0xFFB47B1F),
    danger: Color(0xFFB53D3D),
    dangerSoft: Color(0xFFF4DEDB),
    checked: Color(0xFFAEAEAE),
  );
```

変更する色: `paper` `surface` `surface2` `ink` `ink2` `ink3` `ink4` `divider` `divider2` `checked`（茶系→無彩色）。維持する色: `card`(既に純白) `ok` `okSoft` `warn` `danger` `dangerSoft`（機能色）。

### 2. `lib/style/tokens.dart` — 中立色 DARK（94-111行を置換）

`divider` は `card #2E2E2E` 上で視認できるよう一段明るい `#333333` にする。

```dart
  /// DARK モードの中立色。純黒寄りグレースケール。
  static const dark = AppNeutralColors(
    paper: Color(0xFF0D0D0D),
    surface: Color(0xFF1A1A1A),
    surface2: Color(0xFF242424),
    card: Color(0xFF2E2E2E),
    ink: Color(0xFFF5F5F5),
    ink2: Color(0xFFB3B3B3),
    ink3: Color(0xFF808080),
    ink4: Color(0xFF595959),
    divider: Color(0xFF333333),
    divider2: Color(0xFF3D3D3D),
    ok: Color(0xFF6BB07F),
    okSoft: Color(0xFF1F3325),
    warn: Color(0xFFE1B05A),
    danger: Color(0xFFE47A7A),
    dangerSoft: Color(0xFF3A2020),
    checked: Color(0xFF595959),
  );
```

### 3. `lib/style/tokens.dart` — コメント・影色の更新

- 3行目: `/// 和紙テイストの中立色パレット（accent を除く）。` → `/// 無彩色（グレースケール）の中立色パレット（accent を除く）。`
- 7行目: `/// アプリ全体の最外側に敷く暖色ベージュ（和紙イメージ）。` → `/// アプリ全体の最外側に敷く背景。`
- 18行目: `/// 主要テキスト（墨色）。` → `/// 主要テキスト。`
- 73行目: `/// LIGHT モードの中立色。\`design_handoff_shopping_list/source/tokens.jsx#LIGHT\` と一致させる。` → 上記1のコメントに置換（stale パス参照を除去）
- 93行目: 同様に上記2のコメントに置換
- フローティング影（306-309行）を墨色ベース→無彩色へ:

```dart
  /// LIGHT モード時のフローティング影。
  static const shadowLight = <BoxShadow>[
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 6), blurRadius: 18),
  ];
```

（`shadowDark` は既に `#000000` ベースなので変更不要）

### 4. `lib/style/theme.dart` — ColorScheme.shadow（95行）

墨色ベースの影を無彩色へ。

```dart
    shadow: const Color(0x14000000),
```

### 5. iOS ウィジェット `ios/ShoppingListWidget/ShoppingListWidgetView.swift`（24-36行）

`paper` を新しい中立色に同期する（現状 light は `#F6F0E2` でアプリ本体ともズレている）。

```swift
    /// ウィジェット背景。tokens.dart の AppNeutralColors.{light,dark}.paper と一致。
    private var paper: Color {
        colorScheme == .dark
            ? Color(hex: "#0D0D0D")
            : Color(hex: "#ECECEC")
    }

    /// card 背景。tokens.dart の AppNeutralColors.{light,dark}.card と一致。
    private var card: Color {
        colorScheme == .dark
            ? Color(hex: "#2E2E2E")
            : Color(hex: "#FFFFFF")
    }
```

### 6. Android ウィジェット背景

`android/app/src/main/res/layout/shopping_list_widget.xml`（14行）:

```xml
    android:background="#ECECEC">
```

`android/app/src/main/res/layout-night/shopping_list_widget.xml`（13行）:

```xml
    android:background="#0D0D0D">
```

冒頭コメントの `bg \`#F6F0E2\`（仕様固定の和紙色）` / `bg \`#13110D\`` も新値・「無彩色背景」に更新する。

### 7. ADR 0015 作成（`/write-adr` スキル使用）

ADR 0013 が「和紙テイスト」を正式採用しているため、中立色の白黒化は方針変更にあたる。新規 ADR で記録する。骨子:

- **Context**: 和紙テイストの近接した薄茶トーンが面境界・文字コントラストを弱め視認性を損なっていた（実機スクショで確認）
- **Decision**: `AppNeutralColors.light/dark` を無彩色グレースケール化。アクセント5色プリセット（朱含む）・機能色（ok/danger/warn）・accent soft は維持。ウィジェット native 側（iOS Swift / Android XML）も同じ無彩色へ手動同期
- **Consequences**: 和紙の世界観は薄れるが視認性が向上。アクセントの朱は残るため和の名残は維持。ADR 0013 の「21色トークン SSOT」「`primary = tokens.accent`」構造は不変（破壊的変更なし）

### 8. design_handoff 同期（任意・推奨）

`design_handoff_shoppinglist/preview/tokens.jsx` の `LIGHT` / `DARK` 中立色と `styles.css`（10-11行 `#ECE5D3` / `#1B1813`）を上記新値に揃える。実装・テストには影響しないが整合のため。

## 検証

### 静的・ビルド
- `flutter analyze` — エラーなし（色定数の差し替えのみ、参照シンボルは不変）
- `flutter test` — 全件パス（`test/theme_color_test.dart` は `AccentPreset` のみ検証、中立色非依存。HEX 直アサート・golden ともゼロ）
- `flutter build ios` 成功
- `flutter build apk` 成功
- ※ `tokens.dart` は手書きクラスで `build_runner` 生成対象外。コード生成は不要

### ビジュアル確認（mobile-mcp / iOS Simulator は iPhone 16 Plus 固定）
スクショで「茶色味が消え、面の境界（paper/surface/card）と文字コントラストが明確になった」ことを確認する。確認画面:

1. 買い物リスト一覧（`shopping_list/page.dart`）— 背景・カード・FAB(朱維持)・フィルタチップ
2. 買い物リスト設定モーダル（`shopping_list_setting/page.dart`）— セクションカード・区切り線・トグル・アップグレードPill(朱soft維持)
3. 設定タブ（`settings/page.dart`）
4. ダークモード: 上記1-2をOS ダーク設定で再確認（純黒背景・カード段差・文字可読性）

### ウィジェット確認（`/write-test-mobile-mcp-home-widget` スキル）
ホーム画面にウィジェット追加→背景が無彩色（light `#ECECEC` / dark `#0D0D0D`）になり、タイトル・カウント・チェックの朱アクセントが維持されることを確認。

### 任意: 不変条件テスト
将来の色変更ガードとして、`paper` < `surface` < `surface2` < `card` の輝度順を検証する単体テストを `test/theme_color_test.dart` に追加可能（HEX 直値ではなく `computeLuminance()` の順序を assert）。

## 確認したい点（実装前）

- **ホームウィジェットも今回スコープに含める**前提（含めないとアプリと色が食い違う）。不要なら Phase 5-6 を外す
- **機能色 `warn`（黄土 `#B47B1F`）は警告色として維持**する想定。これも無彩色化したい場合は指示があれば対応

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新（※今回は生成対象なし・不要）
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios` 成功
- [ ] Android ビルド: `flutter build apk` 成功
- [ ] 新規・変更機能に対するテストが存在する（色定数変更のためビジュアル確認で代替。任意で輝度順テスト追加）
- [ ] Maestro E2E: 該当する maestro flow があれば実行（色変更のため新規作成は不要）
- [ ] Entity命名: フィールド名が省略されていない（該当なし）
- [ ] DB操作: Firestore操作は `call` クラスのProvider経由（該当なし）
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり（該当なし）
- [ ] ref使い分け: build内は `ref.watch`、コールバック・操作は `ref.read`（該当なし）
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（該当なし）

### ネイティブ（ios/ android/ に変更がある場合）
- [ ] iOS ウィジェット背景の HEX を tokens.dart と一致させた
- [ ] Android ウィジェット背景（layout / layout-night 両方）の HEX を tokens.dart と一致させた
- [ ] ウィジェット実機/シミュレータで背景・アクセント表示を確認

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）（該当なし）
- [ ] ADR 0015 を作成し方針変更を記録した
