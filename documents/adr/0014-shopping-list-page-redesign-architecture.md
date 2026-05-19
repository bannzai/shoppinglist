# 0014. 買い物リスト UI 全面再設計の本体実装（AppBar 廃止 / リスト操作の再配置 / AI 処理 Provider）

## Status

Accepted

- Date: 2026-05-11
- Decision-Makers: bannzai

## Context

ADR 0013 で確立したデザイントークン基盤の上に、`design_handoff_shopping_list/` の全 17 画面 + 共通基盤 + ホームウィジェット再スキンを実装するにあたり、`ShoppingListPage` 周辺で次の構造的な意思決定が必要になった。

1. `Scaffold(appBar: ShoppingListAppBar)` の単一 AppBar に集約されていたメニュー（リスト切替 DropdownButton / 設定 IconButton / PopupMenu 5 機能 / 下端 FilterChip 2 個）を、新デザインの 4 段構造（ListTopBar 52 / GroupChipsBar 46 / FilterChipsBar 44 / ProgressBlock 72）へどう移植するか
2. 旧 `ShoppingListAppBar` の PopupMenu に詰め込まれていた「リスト追加 / 複製 / 写真 / URL / テキスト貼付 / エクスポート」の 6 機能を、新デザインの FAB（4 メニュー想定）にどう収め、収まらないものをどこへ寄せるか
3. AI（写真 / URL）処理中のシマー表示（`AIProcessingBanner`）を、画像ピッカー or URL ダイアログから出てくる ShoppingListPage 本体へどう伝えるか
4. 初回起動時のオンボーディング画面（新規追加 OnboardingPage）を、既存の `RootPage → AppResolvers → AuthResolver → ...` resolver chain にどこで挟むか
5. iOS WidgetKit / Android Glance の widget が同期で受け取るテーマカラー HEX が、旧 10 色プリセット（`#673AB7` 等）を含んだまま流れてくる可能性がある。新 5 色プリセット移行後にネイティブ側で何を許容するか
6. ShoppingListPage の中核 UX「リスト行が TextField で Enter で末尾空行追加 / 空行 Backspace で削除」を支えている `RawKeyboardListener` が Flutter SDK で deprecated になっている。後継 `KeyboardListener` は iOS / Android のソフトキーボードの Backspace を拾えない既知問題があり、機能を失わずにどう扱うか

## Decision

### 1. `Scaffold(appBar: null)` + Column 4 段構造に再構築する

旧 `ShoppingListAppBar`（`PreferredSize` で 96px 占有）と `GroupSwitcher` を廃止し、`_Body` の `Scaffold.body` 直下に縦並びコンポーネントを配置する。

```
Column [
  ListTopBar(52),      // リスト名 + ▼ + アバタースタック + 設定アイコン
  GroupChipsBar(46),   // ShoppingListPage 外側に置く（旧 GroupSwitcher 後継）
  FilterChipsBar(44),  // 「チェック済み表示」「カテゴリ順」AppChip 2 個
  ProgressBlock(72),   // done/total mono + 進捗バー
  AllDoneBanner?,
  AIProcessingBanner?,
  Expanded(ShoppingListItems),
  RetentionBanner?,
]
```

リスト切替の `DropdownButton` は `ListPickerSheet`（`appShowModalBottomSheet`）に置き換え、選択中のリストに `accent` のチェックマークを出す。

**代替案と却下理由**:

- `Scaffold(appBar: PreferredSizeWidget)` のまま `AppBar.bottom` を 3 段に積む案: AppBar の `bottom` は 1 つしか取れず、`PreferredSize` の入れ子で 138px の AppBar を作ることになる。レイアウトの自由度が低く、`ListTopBar` の `AppRoundButton` / アバタースタックを AppBar 規格に合わせるのも歪。
- `SliverAppBar` の `flexibleSpace` に詰める案: `ListTopBar` だけならハマるが、`GroupChipsBar` をスクロール時に常に表示したい要件と合わない。

### 2. FAB は 4 メニューに絞り、リスト追加 / 複製 / エクスポートを SettingPage に移す

`ExpandableFab` に「写真から追加」「URL から追加」「テキスト貼り付け」「空行を追加」の 4 メニューを置く（写真 / URL は AI バッジ付き）。旧 PopupMenu に含まれていた以下は別ルートへ移す:

- リスト追加（新規作成）: `ListPickerSheet` の末尾「+ 新しいリストを追加」 row
- 現在のリストを複製: `ShoppingListSettingPage` の「リストの操作」セクション
- リストをエクスポート: 同上（プレミアム機能）

**代替案と却下理由**:

- FAB に 7 メニューを詰める案: デザインの「4 メニュー」と乖離し、目的別に整理しないと使いづらい。アイテム追加系（写真 / URL / 貼付 / 空行）と、リスト操作系（追加 / 複製 / エクスポート）は性質が異なるので寄せ場所を分ける方が筋がよい。
- リスト追加 / 複製 / エクスポートを ExpandableFab の「リスト操作」サブメニューに入れる案: ネスト構造になり、片手親指 UX のメリットを損なう。

### 3. `AIProcessingProvider` を画面横断のシングルトン flag として導入する

`lib/provider/ai_processing.dart` に `@riverpod class AIProcessing` を新設し、`AIProcessingType?`（image / url / null）を state として持たせる。

- 起動側（`ExpandableFab` の image picker / URL dialog）: 処理開始時に `start(AIProcessingType.image | url)`、終了時に `end()`
- 表示側（`ShoppingListPage._Body`）: `ref.watch(aIProcessingProvider) != null` のとき `AIProcessingBanner(type: ...)` を ProgressBlock の下に挿入

**代替案と却下理由**:

- ScaffoldMessenger に AI 処理中の SnackBar を出す案: SnackBar は 5 秒で消えるため処理時間 (10-30 秒) と合わない。
- `ExpandableFab` の親に `ValueNotifier<AIProcessingType?>` を持たせて prop drill する案: ShoppingListPage の階層が深く、3 階層以上の prop drill が必要。Provider にする方が薄い。

### 4. `AuthResolver` で `hasSeenOnboarding == false && user == null` のときに OnboardingPage を返す

新しい `OnboardingResolver` を独立 Widget として作らず、`AuthResolver.build` 内の `user == null` 分岐に `hasSeenOnboarding` 判定を追加する。完了時 `HasSeenOnboarding.markAsSeen()` で SharedPreferences に true を保存。

```dart
if (user == null || (!kDebugMode && user.isAnonymous)) {
  if (!hasSeenOnboarding) return const OnboardingPage();
  return const AuthPage();
}
```

**代替案と却下理由**:

- `RootPage` で `OnboardingResolver(AppResolvers)` のように一番外で分岐する案: `AppResolvers` の前にあると、まだ初期化されてない Firebase Auth / Firestore 等の依存が必要になる場面で扱いづらい。`AuthResolver` 内なら `firebaseUserChangesProvider` が見えており、自然。
- 認証済みユーザーに対しても release バージョンで Onboarding を再表示する案: 既存ユーザー体験を壊すので却下。今回は新規ユーザー初回のみに限定。

### 5. ホームウィジェット側で 5 色プリセット allowlist を強制し、それ以外は朱にフォールバックする

`lib/features/home_widget/home_widget_data_sync.dart` の `_normalizeThemeColorHex` で、HEX フォーマット検査に加えて 5 色プリセット allowlist を通す。同じ allowlist を `ios/ShoppingListWidget/ShoppingListWidget.swift` の `normalizeThemeColorHex` と `android/.../ShoppingListWidgetProvider.kt` にも複製する（Set 定義）。

```
const supportedHexes = { '#C2410C', '#1F6B4E', '#0F4C81', '#1B1B1B', '#B45309' }
```

旧 10 色 HEX（`#673AB7` 等）が SharedPreferences に残っていてもウィジェットは朱で描画される。Flutter 側 `resolveAccentPreset` と同じセマンティクス。

**代替案と却下理由**:

- ネイティブ側でフォーマット検査のみ通す案: 旧 10 色のままウィジェットが描画されアプリ本体とテーマがズレる。
- ネイティブ側で「読み取り時に書き戻す」マイグレーション案: ウィジェット側で Firestore 書き込み権限がないので不可。

### 6. `RawKeyboardListener` deprecated を `// ignore: deprecated_member_use` で意図的に維持する

`text_shopping_list_item.dart` の `TextShoppingListItemTextField` 内で「空文字で Backspace 押下時にこの行を削除」するロジックは、`RawKeyboardListener` でないと iOS / Android のソフトキーボードの Backspace を拾えない（後継 `KeyboardListener` は Mac ハードウェアキーボードのみ反応する既知問題）。

- `// ignore: deprecated_member_use` を該当箇所に置き、「ソフトキーボードの Backspace を拾うため意図して維持」のコメントを添える
- Flutter SDK で `HardwareKeyboard.instance.addHandler` 等の代替 API がソフトキーボードに対応したら置換タスクを別途切る

**代替案と却下理由**:

- `KeyboardListener` に置き換える案: iOS シミュレータ + Mac ハードウェアキーボードでは動くが、実機 / Android では Backspace が拾えず連続入力 UX が壊れる。
- `TextField.onChanged` で前の値との差分から Backspace を検知する案: 空文字状態から「何も変わらない」場合の検知ができない（既に空なので `onChanged` が発火しない）。

## Consequences

### Positive

- `Scaffold.body` 直下に縦並びすることで各セクションの高さ / 余白が明示的になり、デザインとの差分が出にくい
- リスト追加 / 複製 / エクスポートが「リストごとの設定」セクションに集まることで、機能の意味的な所属が一致
- `AIProcessingProvider` で AI バナーを 1 箇所に固定でき、画像 / URL 両方の起動点から同じ UI を出せる
- Onboarding が AuthResolver 内分岐になることで、認証済みユーザーへの誤表示リスクがゼロ
- ウィジェット側の HEX allowlist で旧プリセットの混入を防ぎ、テーマ追従の一貫性が出る

### Negative

- `RawKeyboardListener` の deprecated 警告を抱え続けるため、Flutter SDK の major update 時に動かなくなる可能性がある。代替 API が安定したら別途置換タスクが必要
- ExpandableFab の 4 メニューに「空行を追加」が入ったため、デザインの「複製」メニューは現在反映していない。リスト複製は SettingPage 経由（ListPickerSheet 末尾の「+ 新しいリストを追加」もある）
- ホームウィジェット側の native コード (Swift / Kotlin) と Flutter 側の AccentPreset を二重管理。プリセット追加時は 3 箇所 (Flutter / iOS / Android) の同期が必要

### 不可逆性

- `lib/features/shopping_list/components/app_bar.dart` / `group_switcher.dart` を廃止プレースホルダ化（コメントのみ）。`git rm` 推奨だが、PR レビュー時に「廃止理由のコメント」を残すために一旦コメントファイルにしてある
- 旧 `_ProgressSection` (ShoppingListPage 内 inline) → `ProgressBlock` (independent widget) に置換。ロジックは保持

## References

- ADR 0013（基盤フェーズ）
- プランファイル `plans/design-handoff-shopping-list-readme-md-soft-owl.md`
- Issue #250 / #251
- design_handoff_shopping_list/README.md
