# design_handoff_shoppinglist v2 完全準拠 実装計画書

Issue #261 メタプランの Step 2 として作成。Issue #260 の design_handoff_shoppinglist v2 完全準拠を 9 PR に分けて段階的に達成する。

> 補足: Plan mode のファイル名規約上、ファイル名は `261-warm-engelbart.md` だが、Issue では `plans/design-handoff-shoppinglist-v2-perfect-compliance.md` が想定。実装時にリネーム判断を行う。

## Context

`design_handoff_shoppinglist/` (handoff v2) の UI 仕様を、現行 `lib/` / `ios/ShoppingListWidget/` / `android/app/src/main/` 実装に完全反映させる。Issue #261 で主要判断 (5 accent 固定、ShoppingLocation の場所名無料 / 地図 PRO、Android Widget は RemoteViews 継続等) は確定済み。

**Phase 1 探索で判明した実装状態の要点**:

| 領域 | 現状 |
|---|---|
| tokens / theme / textTheme / 5 accent | 実装済み |
| Frame 基礎 (AppPill / AppRoundButton / AppCheckbox / AppChip / AppSectionCard / AppLargeAppBar / AppBottomTabBar) | 実装済み |
| 17 画面 | 全画面で部分以上に実装あり |
| microinteraction (checkbox pop / FAB / notify member bar / AI processing stripe / all-done banner / progress mono / paywall / onboarding dots / map halo pulse / theme color swatch / retention banner / group_list avatar / invitation code mono) | 実装済み |
| iOS Widget (5 色プリセット, widgets-and-micro.jsx 準拠コメント) | 実装済み |
| Entity 拡張 (iconName / autoNotifyEnabled / address / regex) | **未実装 4 件** |
| Frame 追加 (AppFrameAppBar compact / AppCell / AppDivider / AppDialogShell) | **未実装 4 件** |
| AI review sheet (写真 / URL レビュー UI) | **未実装** |
| 長押し context menu / 右スワイプチェック | **未実装** |
| LocationPicker の address 永続化 | **逆ジオ結果を捨てている** |
| autoNotify をリスト単位に切替 | **現状はグローバル SharedPreferences** |
| Android Widget dark resource (`res/layout-night/`) | **未追加** |
| Maestro design_v2 系 flows | **0 件 → 新規追加要** |
| preview_flows 拡張 | **13 → 17 画面に拡張要** |

## 確定事項 (Phase 3 の追加判断)

| 項目 | 判断 |
|---|---|
| Onboarding 3 スライドのコピー SSOT | `design_handoff_shoppinglist/preview/screens-onboarding.jsx` 順守。タイトル 3 つは現行のまま (`家族と作る、買い物リスト` / `同じリストを同時に編集` / `お店の近くで、そっと思い出す`)、ボディ 3 つを JSX exact 文に差し替え |
| `i-1〜i-21` ID 体系 | Issue #261 オリジナル番号。本実装計画書では「i-N → preview の MicroXxx / styles.css keyframe / README §8 行 / 該当ファイル:行」の対応表を 1-B 章に保持 |
| ThemeColorSelectionPage 色数 | M-2 通り 5 色 canonical (`shu` / `matcha` / `ai` / `sumi` / `kuchiba`) 固定 (JSX 10 色は採用しない) |
| Auth ゲストリンク | 本番導線にしない (現行通り debug 匿名サインインのみ) |

## 運用ルール (claude / codex goal コマンド向け)

各 PR は **GitHub Issue 化** され、共通ラベル `design-handoff-v2` を貼る。`goal` コマンドはラベル付き issue を 1 つずつ消化する想定で、以下のループを各 issue で完走させる:

1. **仕様 SSOT 確認**
   - `design_handoff_shoppinglist/preview/買い物リスト UI再設計.html` を **agent-browser で開いてスクショ** (または `open` コマンドでブラウザ起動して該当画面まで遷移)
   - `design_handoff_shoppinglist/preview/*.jsx` の該当画面ファイルを Read
   - `design_handoff_shoppinglist/README.md` の該当セクションを Read
2. **実装**: 本プラン (`plans/261-warm-engelbart.md`) のコード提案に従う
3. **検証ループ (Styling / Layout / Functional 3 軸)**
   a. iOS Simulator iPhone 16 Plus 起動 (`/sim-manager`)、対象画面まで遷移 (`/verify-ui-mobile-mcp` または Maestro)、Light / Dark 両方でスクショ
   b. Android Emulator も同様にスクショ (Light / Dark)
   c. agent-browser で Web HTML preview のスクショ (同じ画面・同じテーマ)
   d. Claude が iOS / Android / Web の 3 枚を画像比較し FAIL を file:line + 修正案で列挙
   e. FAIL があれば修正 → c に戻る
4. **PASS の条件**: 上記 a / b / c の 3 環境が一致する。ただし以下「決定事項」の差分は **意図的な乖離** として許容する:
   - **Onboarding コピー**: JSX SSOT 採用 (README §7-1 と乖離)
   - **ThemeColorSelection 色数**: 5 色 canonical 固定 (JSX 10 色は不採用)
   - **Auth ゲストリンク**: 本番導線なし (現行 debug 匿名のみ)
   - **i-N ID 体系**: Issue #261 オリジナル番号 (preview / README には存在しない)
   - **5 accent**: shu / matcha / ai / sumi / kuchiba に固定
   - **ShoppingLocation 地図設定**: PRO 限定 (場所名のみ無料)
   - **Android Widget**: `AppWidgetProvider` + `RemoteViews` 継続 (Compose 非採用)
   - **AI アイコン生成タイル**: Group / Category 共に表示しない
   - **ItemRow 担当者**: 今回除外、長押しメニューにも出さない
   - **画像素材**: PR-0 で生成・同梱したものを使用 (Web の placeholder と意匠が違って OK)
   - **フォント**: 実機は `google_fonts`、Web は CSS `font-family` 直書きの差は許容
5. **CI 合格**: `flutter analyze` / `flutter test` / `flutter build ios --no-codesign` / `flutter build apk --debug` / 該当 maestro flow / (Firebase 変更時) `npm run lint && npm run build && npm test`
6. **Issue クローズ**: PASS + CI 合格でコミット → push → 担当 issue をクローズ。次の issue へ。

PASS 基準を満たさない限り **同じ issue 内で何度でも修正を繰り返す**。issue 横断のフォローは禁止 (次の PR で修正、ではなく当該 PR 内で完結する)。

## PR 分割と着地点

| PR | Issue 種別 | スコープ | 主要変更 |
|---|---|---|---|
| PR-0 | 前準備 | 画像素材生成 | AppIcon / Onboarding x3 / AuthArt / Category 補完 |
| PR-1 | 実装 | Entity / DS foundation | 4 entity 拡張 + 4 frame widget 追加 + textTheme 直書き解消 |
| PR-2 | 実装 | Entry | Onboarding body 差し替え + Auth 文言 SSOT 化 + Home の paper surface |
| PR-3 | 実装 | List Core | AI review sheet 新規 + 長押し context menu + 右スワイプチェック + SnackBar 統一 |
| PR-4 | 実装 | List Settings | autoNotifyEnabled をリスト単位に + Filter hifi |
| PR-5 | 実装 | Groups | GroupCreate iconName 保存 + 作成後招待 + GroupSetting 再構成 |
| PR-6 | 実装 | Categories & Locations | regex マッチング + 店舗別カテゴリ並び順 + address 永続化 + map PRO gate |
| PR-7 | 実装 | Settings & Paywall | SettingPage hifi + サインアウト追加 + Paywall 状態差分 |
| PR-8 | 実装 | Widgets | iOS dark mode 検証 + Android `layout-night/` 追加 |
| PR-9 | 検証 | Verification hardening | preview_flows 17 画面化 + design_v2 maestro flows 追加 + Light/Dark 目視マトリクス |

ブランチは Issue 確定通り `refactor/design-handoff-v2-round4` を継続する。各 PR は同ブランチからの追加コミット / 個別 PR のいずれでもよい (PR-0 / PR-1 のみ独立 PR 化推奨)。

---

## PR-0: 画像素材生成 (前準備)

PR-1 以降のすべての実装 PR が前提とするアセットを生成し、リポジトリに同梱する。Web preview の placeholder と意匠が違っても良い (運用ルール 4 で許容済)。

### 対象アセット

> 注: 既存リポジトリは `pubspec.yaml` で `images/` トップレベル配置を採用済 (`images/undraw_shopping-app_b80f.svg` 等)。新規アセットも `images/` 直下のサブディレクトリに配置する。

| # | アセット | サイズ | 配置先 | 推奨 skill |
|---|---|---|---|---|
| 1 | アプリアイコン | 1024×1024 | `ios/Runner/Assets.xcassets/AppIcon.appiconset/`、`android/app/src/main/res/mipmap-*/` | `/ios-app-icon-generator` |
| 2 | Onboarding Slide 1 (TiltedList) | 縦 ~400px | `images/onboarding/slide_1.png` | `/gemini-image-generator` |
| 3 | Onboarding Slide 2 (AvatarOrbit) | 縦 ~400px | `images/onboarding/slide_2.png` | `/gemini-image-generator` |
| 4 | Onboarding Slide 3 (MapHalo) | 縦 ~400px | `images/onboarding/slide_3.png` | `/gemini-image-generator` |
| 5 | AuthArt | 縦 ~280px | `images/auth/auth_art.png` | `/gemini-image-generator` |
| 6 | カテゴリプリセット補完 | 32×32 SVG | `images/categories/` | 既存 `lib/style/category_presets.dart` の不足分のみ手動 / Material Icons |

### 意匠ガイド

- **AppIcon**: accent 朱 (`#C2410C`) bg + 抽象的な紙袋 (画用紙風) または「買」一文字。和紙テクスチャ感を控えめに
- **Onboarding Slide 1 (TiltedList)**: 紙質の手書きチェックリストが軽く傾いて配置。チェックマークは accent 朱
- **Onboarding Slide 2 (AvatarOrbit)**: 中央の小さな paper card を 3 つのアバター (家族) が円周配置
- **Onboarding Slide 3 (MapHalo)**: 簡略化した地図ピン + halo pulse (現行 `_MapHaloArt` の Flutter 描画と整合)
- **AuthArt**: 紙袋 + 葉物野菜 + tag。`screens-onboarding.jsx` L196-L210 の `AuthArtIllustration` 参照

### 実装手順

1. `pubspec.yaml` の `assets:` に `images/onboarding/`, `images/auth/`, `images/categories/` を追加
2. `/gemini-image-generator` で Onboarding 3 枚 + AuthArt を生成 → 配置
3. `/ios-app-icon-generator` で AppIcon を生成 → 配置 (dark/tinted variant も維持)
4. `lib/features/onboarding/page.dart` の `artBuilder` を `Image.asset('images/onboarding/slide_N.png')` に差し替え、現行の `_TiltedListArt` / `_AvatarOrbitArt` / `_MapHaloArt` (Flutter 描画) は **fallback として残す** (`errorBuilder` で利用)
5. `lib/features/auth/page.dart` の SVG / 描画 widget を `Image.asset('images/auth/auth_art.png')` に差し替え (文言は PR-2 で更新)

### Acceptance Criteria (PR-0)

- [ ] `images/onboarding/slide_{1,2,3}.png` が同梱されている
- [ ] `images/auth/auth_art.png` が同梱されている
- [ ] `ios/Runner/Assets.xcassets/AppIcon.appiconset/` に全サイズの AppIcon が揃う (dark/tinted variant も保持)
- [ ] `android/app/src/main/res/mipmap-*/` に AppIcon が配置される
- [ ] `pubspec.yaml` の `assets:` に新規ディレクトリが追加され、`flutter pub get` が成功
- [ ] Onboarding 画面の Slide 1-3 で画像が描画される (Light / Dark 共に)
- [ ] Auth 画面で AuthArt が描画される
- [ ] `flutter analyze` / `flutter test` パス
- [ ] `flutter build ios --no-codesign` / `flutter build apk --debug` 成功

---

## PR-1: Entity / Design System foundation

### 対象ファイル

- `lib/entity/group.dart`
- `lib/entity/group_shopping_list.dart`
- `lib/entity/group_shopping_location.dart`
- `lib/entity/group_category_keyword.dart`
- `lib/components/frame/app_frame_app_bar.dart` (新規)
- `lib/components/frame/app_cell.dart` (新規)
- `lib/components/frame/app_divider.dart` (新規)
- `lib/components/frame/app_dialog_shell.dart` (新規)
- `lib/style/theme.dart` (themeAnimationDuration / cross-fade 確認)
- `test/components/frame/frame_widgets_test.dart` (4 新規 Widget smoke 追記)
- `test/entity/*_test.dart` (4 entity の JSON ラウンドトリップ)
- `firebase/firestore.rules` 必要なら field 名チェックのみ修正 (Issue `firestore-rules-simplicity.md` 準拠で深入りしない)
- `firebase/functions/functions/src/entity/*.ts` (該当 entity helper)
- `dart run build_runner build --delete-conflicting-outputs` で生成ファイル更新

### Entity 拡張

**1. `lib/entity/group.dart` — `iconName` フィールド追加**

```dart
/// 家族 / 同居人グループ。`memberUserIDs` の users が共有してリストを管理する。
@freezed
abstract class Group with _$Group {
  /// preview/screens-groups.jsx の GroupCreatePage で選択された絵柄を `iconName` に保存する。
  /// 値は `home` / `cart` / `fork` / `cookie` / `pets` / `bag` のいずれか。
  /// 既存 Group は未指定のため default で `home`。
  @JsonSerializable(explicitToJson: true)
  const factory Group({
    required String id,
    required List<String> memberUserIDs,
    required String? name,
    String? ownerUserID,
    @Default('home') String iconName,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}
```

**2. `lib/entity/group_shopping_list.dart` — `autoNotifyEnabled` 追加**

```dart
/// リスト単位の自動通知設定。`true` のときアイテム追加 / チェック切替で
/// グループ全員に通知 SnackBar を表示する。preview/screens-list-settings.jsx 準拠。
/// 既存ドキュメントは `false` 互換。グローバル SharedPreferences 設定とは別軸で、
/// グローバル ON ∧ リスト ON のとき送信する。
@JsonSerializable(explicitToJson: true)
const factory GroupShoppingList({
  required String id,
  required String createUserID,
  required String groupID,
  @Default('') String name,
  @Default(GroupShoppingListStatus.active) GroupShoppingListStatus status,
  @Default(false) bool autoNotifyEnabled,
  String? shoppingLocationID,
  String? duplicatedFromGroupShoppingListID,
  @TimestampConverter() required DateTime? ttlExpiresDateTime,
  @ClientCreatedTimestamp() DateTime? createdDateTime,
  @ClientUpdatedTimestamp() DateTime? updatedDateTime,
  @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
  @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
}) = _GroupShoppingList;
```

**3. `lib/entity/group_shopping_location.dart` — `address` 追加**

```dart
/// 場所登録 (無料機能)。`address` は LocationPicker の逆ジオコード結果を保存する。
/// 地図で `latitude` / `longitude` を設定する操作は PRO 限定 (paywall gate)。
@JsonSerializable(explicitToJson: true)
const factory GroupShoppingLocation({
  required String id,
  required String groupID,
  required String name,
  @Default('') String address,
  required double? latitude,
  required double? longitude,
  required double? geofenceRadiusMeters,
  @ClientCreatedTimestamp() DateTime? createdDateTime,
  @ClientUpdatedTimestamp() DateTime? updatedDateTime,
  @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
  @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
}) = _GroupShoppingLocation;
```

**4. `lib/entity/group_category_keyword.dart` — `regex` 追加**

```dart
/// カテゴリ自動分類のキーワードマッチ方式。
enum GroupCategoryKeywordMatchingType {
  /// 完全一致。
  @JsonValue('exact')
  exact,
  /// 部分一致 (substring)。
  @JsonValue('partial')
  partial,
  /// 正規表現マッチ。`keyword` を `RegExp` として評価し、`FormatException` 時は false。
  @JsonValue('regex')
  regex,
}
```

### Frame Widget 追加

**`lib/components/frame/app_frame_app_bar.dart`** (compact 48px)

```dart
/// `preview/frame.jsx` の AppBar (large=false) 相当。`AppLargeAppBar` は 52px+subtitle 構成のため、
/// 48px の compact 用に分離して提供する。bottom 0.5px divider と paper 背景を持つ。
class AppFrameAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppFrameAppBar({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.accent = false,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool accent;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: tokens.neutral.paper,
        border: Border(
          bottom: BorderSide(color: tokens.neutral.divider, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          SizedBox(width: 36, child: leading),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: accent ? tokens.accent : tokens.neutral.ink,
              ),
            ),
          ),
          SizedBox(width: 36, child: trailing),
        ],
      ),
    );
  }
}
```

**`lib/components/frame/app_cell.dart`** (min-height 52, icon tile 32×32 + chev-r or switch)

```dart
/// `preview/screens-list-settings.jsx` の Cell 相当。
/// 左 icon tile (32×32 radius 9, t.surface2 bg) + title + subtitle (optional) + 右 chev-r か switch。
/// `onTap` 指定で全面タップ、`onSwitch` 指定でスイッチ Cell になる。
class AppCell extends StatelessWidget {
  const AppCell({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onSwitch,
    this.switchValue,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSwitch;
  final bool? switchValue;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final iconColor = danger ? tokens.danger : tokens.accent;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: tokens.neutral.surface2,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyLarge),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: tokens.neutral.ink3,
                              )),
                    ],
                  ],
                ),
              ),
              if (onSwitch != null && switchValue != null)
                Switch(value: switchValue!, onChanged: onSwitch)
              else if (onTap != null)
                Icon(Icons.chevron_right, size: 18, color: tokens.neutral.ink3),
            ],
          ),
        ),
      ),
    );
  }
}
```

**`lib/components/frame/app_divider.dart`** (0.5px inset 60)

```dart
/// `preview/frame.jsx` の Divider 相当。height 0.5, left inset 60 (icon tile 幅 + spacing 分)。
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.inset = 60});

  final double inset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: inset),
      child: Container(height: 0.5, color: context.tokens.neutral.divider),
    );
  }
}
```

**`lib/components/frame/app_dialog_shell.dart`** (overlay + top 32% card)

```dart
/// `preview/screens-list-settings.jsx` の DialogShell 相当。
/// 背景 overlay rgba(15,12,8,0.4) + blur 2px、card は left/right 24, top 32%, radius 20。
/// `showDialog` の builder で `AppDialogShell(child: ...)` を返す形で使う。
class AppDialogShell extends StatelessWidget {
  const AppDialogShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(
        color: const Color(0x660F0C08),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).size.height * 0.32, 24, 24),
            child: Material(
              color: tokens.neutral.card,
              borderRadius: BorderRadius.circular(20),
              elevation: 0,
              child: Padding(padding: const EdgeInsets.all(20), child: child),
            ),
          ),
        ),
      ),
    );
  }
}
```

### textTheme 直書き解消

```bash
rg -n "TextStyle\\(|GoogleFonts\\." lib/features/ lib/components/ | grep -v '\\.g\\.dart' | grep -v '\\.freezed\\.dart'
```

上記で出てきた直書き `TextStyle(` を `Theme.of(context).textTheme.<role>.copyWith(...)` か `monoTextStyle()` に置き換える。

### Acceptance Criteria (PR-1)

- [ ] `dart run build_runner build --delete-conflicting-outputs` 成功
- [ ] `flutter analyze` エラーなし
- [ ] `flutter test test/entity/` パス (4 entity JSON ラウンドトリップ)
- [ ] `flutter test test/components/frame/frame_widgets_test.dart` パス (4 新規 widget smoke 追加)
- [ ] `flutter build ios --no-codesign` 成功
- [ ] `flutter build apk --debug` 成功
- [ ] Firestore Rules は本 PR で field 増えても fail しないこと (rules-simplicity 準拠で深いガードは入れない)

---

## PR-2: Entry (Onboarding / Auth / Home)

### 対象ファイル

- `lib/features/onboarding/page.dart` (body 3 件差し替え)
- `lib/features/auth/page.dart` (文言 SSOT 化)
- `lib/features/home/page.dart` (paper surface 確認)
- `maestro/flows/design_v2_entry.yaml` (新規)

### Onboarding body 差し替え

```dart
final slides = <_SlideContent>[
  _SlideContent(
    eyebrowIndex: 1,
    title: '家族と作る、\n買い物リスト',
    body: '家で思いついたものを誰かが追加して、店頭で別の誰かがチェック。'
        '「買ってきて」のやり取りを、ぜんぶこの一枚に。',
    artBuilder: (tokens) => _TiltedListArt(tokens: tokens),
  ),
  _SlideContent(
    eyebrowIndex: 2,
    title: '同じリストを\n同時に編集',
    body: '家族・パートナー・同居人を招待コードで招くと、'
        '同じリストを編集できます。誰が追加したかではなく、'
        '何を買い忘れずに済むかを大切に。',
    artBuilder: (tokens) => _AvatarOrbitArt(tokens: tokens),
  ),
  _SlideContent(
    eyebrowIndex: 3,
    title: 'お店の近くで、\nそっと思い出す',
    body: '登録した店舗の近くに来ると、買い物リストをやさしくお知らせ。'
        '通知は必要な時だけ、押し付けがましくなく。',
    artBuilder: (tokens) => _MapHaloArt(tokens: tokens),
  ),
];
```

### Auth 文言 SSOT 化 (screens-onboarding.jsx L196-L231 を採用)

```dart
// lib/features/auth/page.dart の title / body / 規約注記を以下に統一
const title = '家族の買い物を、\nひとつのリストへ';
const body = 'サインインすると端末をまたいでリストが同期します。'
    '広告もメールマガジンもありません。';
const termsNote = '続けることで 利用規約 と プライバシーポリシー に同意したものとみなされます。';
const errorMessage = 'サインインに失敗しました。もう一度お試しください。';
```

ゲストリンクは UI に出さない (現行通り debug ボタンのみ)。

### Maestro flow

```yaml
# maestro/flows/design_v2_entry.yaml
appId: com.bannzai.shoppinglist
---
- clearState
- launchApp
- assertVisible: "家族と作る"
- swipe:
    direction: LEFT
- assertVisible: "同じリストを"
- swipe:
    direction: LEFT
- assertVisible: "お店の近くで"
- tapOn: "はじめる"
- assertVisible: "家族の買い物を"
- assertVisible: "Apple でサインイン"
- assertVisible: "Google でサインイン"
- assertNotVisible: "ゲストとして使う"
```

### Acceptance Criteria (PR-2)

- [ ] `flutter analyze` / `flutter test` パス
- [ ] `maestro test maestro/flows/design_v2_entry.yaml` パス
- [ ] iOS Simulator iPhone 16 Plus で Light / Dark 目視 (3 スライド + Auth + Home)
- [ ] Android Emulator で Light / Dark 目視
- [ ] eyebrow `01/03` mono accent 11px が描画されている

---

## PR-3: List Core (ShoppingList / ItemRow / FAB / AI review sheet / SnackBar)

### 対象ファイル

- `lib/features/shopping_list/page.dart`
- `lib/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart`
- `lib/features/shopping_list/components/ai_review_sheet.dart` (新規)
- `lib/features/shopping_list/components/expandable_fab.dart`
- `lib/features/shopping_list/components/notification_member_bar.dart`
- `lib/provider/ai_shopping_list_candidate.dart` (新規)
- `maestro/flows/design_v2_list_core.yaml` (新規)
- `maestro/flows/design_v2_ai_review.yaml` (新規)

### AI review sheet 新規

```dart
/// 写真 / URL から AI で抽出したアイテムを「追加前にレビュー」する Bottom Sheet。
/// preview/widgets-and-micro.jsx の MicroAIProgress (NEW バッジ候補リスト) と
/// preview/screens-list.jsx の AI Processing 状態 → 確定までの間をつなぐ。
@freezed
abstract class AIShoppingListCandidate with _$AIShoppingListCandidate {
  const factory AIShoppingListCandidate({
    required String name,
    required bool selected,
    required String? groupCategoryID,
  }) = _AIShoppingListCandidate;

  factory AIShoppingListCandidate.fromJson(Map<String, dynamic> json) =>
      _$AIShoppingListCandidateFromJson(json);
}

/// レビュー結果を返す。`null` はキャンセル、空 List は「全件除外して閉じる」。
Future<List<AIShoppingListCandidate>?> showAIReviewSheet({
  required BuildContext context,
  required List<String> rawNames,
}) {
  return showModalBottomSheet<List<AIShoppingListCandidate>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.tokens.neutral.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) => AIReviewSheet(rawNames: rawNames),
  );
}
```

### 長押し context menu

```dart
// text_shopping_list_item.dart に GestureDetector(onLongPress) で
// preview/screens-list.jsx 準拠の context menu を出す。担当者項目は今回除外。
Future<void> _showLongPressMenu(BuildContext context, WidgetRef ref) async {
  analytics.logEvent(name: 'long_press_shopping_list_item', parameters: {
    'groupShoppingListItemID': item.id,
  });
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.tokens.neutral.card,
    builder: (sheetContext) => AppDialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.content_copy),
            title: const Text('複製'),
            onTap: () => ref.read(duplicateShoppingListItemProvider).call(
                  groupShoppingListItemID: item.id,
                ),
          ),
          ListTile(
            leading: const Icon(Icons.notes),
            title: const Text('メモを追加'),
            onTap: () => /* メモ追加ダイアログ */,
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: context.tokens.danger),
            title: Text('削除', style: TextStyle(color: context.tokens.danger)),
            onTap: () => ref.read(deleteShoppingListItemProvider).call(
                  groupShoppingListItemID: item.id,
                ),
          ),
        ],
      ),
    ),
  );
}
```

### 右スワイプでチェック切替

```dart
// text_shopping_list_item.dart の Dismissible を ConfirmDismissOrToggle に変更
Dismissible(
  key: ValueKey(item.id),
  background: Container(
    color: context.tokens.ok,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: const Icon(Icons.check, color: Colors.white),
  ),
  secondaryBackground: Container(
    color: context.tokens.danger,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: const Icon(Icons.delete_outline, color: Colors.white),
  ),
  confirmDismiss: (direction) async {
    if (direction == DismissDirection.startToEnd) {
      analytics.logEvent(name: 'swipe_toggle_shopping_list_item',
          parameters: {'groupShoppingListItemID': item.id});
      await ref.read(toggleShoppingListItemCheckProvider).call(
            groupShoppingListItemID: item.id,
          );
      return false; // 行を消さない
    }
    analytics.logEvent(name: 'swipe_delete_shopping_list_item',
        parameters: {'groupShoppingListItemID': item.id});
    return true;
  },
  // ...
)
```

### Acceptance Criteria (PR-3)

- [ ] `flutter analyze` / `flutter test` パス
- [ ] AI review sheet の widget test 追加 (3 件 → 1 件除外 → 2 件追加)
- [ ] `maestro test maestro/flows/design_v2_list_core.yaml` パス
- [ ] `maestro test maestro/flows/design_v2_ai_review.yaml` パス
- [ ] iOS / Android で Light / Dark 目視 (連続入力 / checkbox pop / swipe / long press)

---

## PR-4: List Settings (ShoppingListSetting / Filter)

### 対象ファイル

- `lib/features/shopping_list_setting/page.dart` (README 優先で再構成、AppCell / AppDivider 活用)
- `lib/features/shopping_list_item_filter/page.dart` (hifi 化、AppSectionCard / AppCell 活用)
- `lib/provider/shopping_list_setting.dart` (autoNotifyEnabled の get / update を追加)
- `firebase/functions/functions/src/shopping_list/update_auto_notify.ts` (Functions 側で更新を許可)
- `maestro/flows/design_v2_list_settings.yaml` (新規)

### autoNotifyEnabled UI

```dart
// shopping_list_setting/page.dart の自動通知セクション
AppSectionCard(
  title: '通知',
  child: AppCell(
    icon: Icons.notifications_active_outlined,
    title: 'アイテム追加で家族に通知',
    subtitle: 'このリストに追加・チェックがあったとき',
    onSwitch: (value) async {
      analytics.logEvent(name: 'toggle_list_auto_notify', parameters: {
        'groupShoppingListID': shoppingList.id,
        'value': value.toString(),
      });
      await ref.read(updateShoppingListAutoNotifyProvider).call(
            groupShoppingListID: shoppingList.id,
            autoNotifyEnabled: value,
          );
    },
    switchValue: shoppingList.autoNotifyEnabled,
  ),
),
```

### Acceptance Criteria (PR-4)

- [ ] `flutter analyze` / `flutter test` パス
- [ ] `maestro test maestro/flows/design_v2_list_settings.yaml` パス
- [ ] グローバル ON ∧ リスト OFF → 通知出ない、グローバル ON ∧ リスト ON → 通知出る、を Maestro で assert

---

## PR-5: Groups (GroupList / GroupCreate / GroupSetting / Invitation)

### 対象ファイル

- `lib/features/group_create/page.dart` (iconName 選択 GridView 追加 + 作成後に招待画面 push)
- `lib/features/group_setting/page.dart` (README/preview 優先で再構成、カテゴリ / 場所のインライン管理を外す)
- `lib/features/group_invitation/page.dart` (verifying 状態色を AppDialogShell ベースに)
- `lib/provider/group.dart` (CreateGroup の引数に iconName / setAsDefault 追加)
- `firebase/functions/functions/src/group/createGroup.ts` (引数 iconName 受け取り)
- `maestro/flows/design_v2_groups.yaml` (新規)

### GroupCreate iconName + 作成後招待

```dart
/// `preview/screens-groups.jsx` の GroupCreatePage 準拠。
/// アイコン 6 種 (home / cart / fork / cookie / pets / bag) を 3×2 GridView で選択。
/// AI アイコン生成タイルは表示しない (M-3 確定)。
class CreateGroup {
  final Ref ref;
  CreateGroup(this.ref);

  Future<String> call({
    required AppUser appUser,
    required String? name,
    required String iconName,
    required bool setAsDefault,
  }) async {
    final functions = ref.read(firebaseFunctionsProvider);
    final result = await functions.httpsCallable('createGroup').call({
      'createUserID': appUser.id,
      'name': name,
      'iconName': iconName,
      'setAsDefault': setAsDefault,
    });
    return result.data['groupID'] as String;
  }
}
```

### Acceptance Criteria (PR-5)

- [ ] `flutter analyze` / `flutter test` パス
- [ ] `firebase/functions/functions/` で `npm run lint && npm run build && npm test` パス
- [ ] `maestro test maestro/flows/design_v2_groups.yaml` パス
- [ ] iOS / Android で Light / Dark 目視 (GroupCreate icon + 作成後招待 + GroupSetting owner/member 切替)

---

## PR-6: Categories & Locations (regex / 店舗別並び順 / address / map PRO)

### 対象ファイル

- `lib/utils/category_matcher.dart` (regex 分岐)
- `lib/features/group_category/category_edit_page.dart` (matchingType セレクタに regex 追加)
- `lib/features/shopping_location/page.dart` (address 表示)
- `lib/features/shopping_location/location_picker_page.dart` (address 永続化 + map gate)
- `lib/provider/shopping_location.dart` (Add / Update に address 引数追加)
- `firebase/functions/functions/src/shopping_location/*.ts`
- `firebase/firestore.rules` (新 field 名を含むケースは深入りしない、Issue rules-simplicity 準拠)
- `maestro/flows/design_v2_category_location.yaml` (新規)

### regex マッチング

```dart
/// `category_matcher.dart` で keyword の matchingType に応じてマッチ判定する。
/// regex は `RegExp(keyword.keyword).hasMatch(message)`。FormatException 時は false。
bool matchesGroupCategoryKeyword({
  required String message,
  required GroupCategoryKeyword keyword,
}) {
  switch (keyword.matchingType) {
    case GroupCategoryKeywordMatchingType.exact:
      return message == keyword.keyword;
    case GroupCategoryKeywordMatchingType.partial:
      return message.contains(keyword.keyword);
    case GroupCategoryKeywordMatchingType.regex:
      try {
        return RegExp(keyword.keyword).hasMatch(message);
      } on FormatException {
        return false;
      }
  }
}
```

### LocationPicker の address 永続化

```dart
// lib/features/shopping_location/location_picker_page.dart
// 逆ジオコード結果 (placemark.thoroughfare 等) を State から Provider 経由で保存する
Future<void> _save() async {
  final placemarks = await placemarkFromCoordinates(
    cameraPosition.target.latitude,
    cameraPosition.target.longitude,
  );
  final address = placemarks.isNotEmpty
      ? '${placemarks.first.administrativeArea ?? ''}'
        '${placemarks.first.locality ?? ''}'
        '${placemarks.first.thoroughfare ?? ''}'
      : '';

  analytics.logEvent(name: 'save_shopping_location', parameters: {
    'groupShoppingLocationID': location.id,
    'hasAddress': (address.isNotEmpty).toString(),
  });
  await ref.read(updateShoppingLocationProvider).call(
        groupShoppingLocationID: location.id,
        name: name,
        address: address,
        latitude: cameraPosition.target.latitude,
        longitude: cameraPosition.target.longitude,
        geofenceRadiusMeters: geofenceRadiusMeters,
      );
}
```

### map PRO gate

```dart
// shopping_location/page.dart の AddLocationDialog
// 場所名のみは無料、「地図で位置を設定」ボタンは PRO バッジを表示し、
// 非 Premium タップ時に Paywall 画面へ push する (M-4 確定)。
AppPill(
  label: '地図で位置を設定',
  variant: AppPillVariant.soft,
  trailing: const AppProBadge(),
  onPressed: () async {
    if (!isPremium) {
      analytics.logEvent(name: 'tap_location_map_gate_non_premium',
          parameters: {});
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const PaywallPage(source: 'location_map_gate')));
      return;
    }
    // PRO 時は LocationPickerPage へ
  },
),
```

### Acceptance Criteria (PR-6)

- [ ] `flutter analyze` / `flutter test` (`category_matcher_test.dart` に regex ケース追加) パス
- [ ] `maestro test maestro/flows/design_v2_category_location.yaml` パス
- [ ] LocationPicker で逆ジオが取れたとき `address` が Firestore に保存されることを確認
- [ ] 非 Premium で「地図で位置を設定」タップ → Paywall 画面遷移

---

## PR-7: Settings & Paywall

### 対象ファイル

- `lib/features/settings/page.dart` (hifi + サインアウト追加 + AppCell 活用)
- `lib/features/settings/theme_color_selection_page.dart` (5 色 canonical を再確認 / 不要 props 整理)
- `lib/features/paywall/paywall_page.dart` (loading / error / no-plans の 3 状態が JSX 準拠か再確認)
- `lib/provider/auth.dart` (signOut の analytics + 確認ダイアログ)
- `maestro/flows/design_v2_settings_paywall.yaml` (新規)

### サインアウト追加

```dart
// settings/page.dart の最下部に「サインアウト」Cell を追加
AppCell(
  icon: Icons.logout,
  title: 'サインアウト',
  danger: true,
  onTap: () async {
    analytics.logEvent(name: 'tap_sign_out', parameters: {});
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppDialogShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('サインアウトしますか?',
                style: Theme.of(dialogContext).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: AppPill(
                    label: 'キャンセル',
                    variant: AppPillVariant.ghost,
                    onPressed: () => Navigator.pop(dialogContext, false))),
                const SizedBox(width: 12),
                Expanded(child: AppPill(
                    label: 'サインアウト',
                    variant: AppPillVariant.danger,
                    onPressed: () => Navigator.pop(dialogContext, true))),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await ref.read(signOutProvider).call();
    }
  },
),
```

### Acceptance Criteria (PR-7)

- [ ] `flutter analyze` / `flutter test` パス
- [ ] `maestro test maestro/flows/design_v2_settings_paywall.yaml` パス
- [ ] Paywall の plans / loading / error / no-plans 4 状態を iOS / Android で Light / Dark 確認

---

## PR-8: Widgets (iOS / Android)

### 対象ファイル

- `ios/ShoppingListWidget/ShoppingListWidgetView.swift` (dark mode 色定義の明示化)
- `android/app/src/main/res/layout-night/shopping_list_widget.xml` (新規 dark variant)
- `android/app/src/main/kotlin/com/bannzai/shoppinglist/ShoppingListWidgetProvider.kt` (dark resource 切替対応)
- `lib/features/home_widget/home_widget_data_sync.dart` (現状維持 / 動作確認のみ)
- `maestro/flows/design_v2_widgets.yaml` (新規、addWidget は手動扱い)

### Android Widget dark variant

```xml
<!-- android/app/src/main/res/layout-night/shopping_list_widget.xml -->
<!--
  preview/widgets-and-micro.jsx の WAndroid (dark) 準拠。
  bg #13110D (paper dark), text @android:color/system_neutral1_50。
-->
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#FF13110D"
    android:orientation="vertical"
    android:padding="12dp">
  <!-- 既存 layout/shopping_list_widget.xml と同構造 -->
  <!-- 色だけ paper dark / surface dark / card dark / divider dark に差し替え -->
</LinearLayout>
```

### iOS Widget dark mode 明示化

```swift
// ShoppingListWidgetView.swift
@Environment(\.colorScheme) var colorScheme

private var paper: Color {
  colorScheme == .dark
    ? Color(hex: "#13110D")
    : Color(hex: "#F6F0E2")
}
private var card: Color {
  colorScheme == .dark
    ? Color(hex: "#26221C")
    : Color(hex: "#FFFFFF")
}
```

### Acceptance Criteria (PR-8)

- [ ] iOS Simulator で OS dark mode に切り替えて Widget の paper/card が切り替わることを確認
- [ ] Android Emulator で OS dark mode に切り替えて Widget の paper/card が切り替わることを確認
- [ ] 5 accent それぞれで Widget の accent / progress sliver が切り替わることを確認
- [ ] チェック切替 (`ToggleItemIntent` / `ACTION_TOGGLE_ITEM`) が Light / Dark 両方で動くことを確認

---

## PR-9: Verification hardening

### 対象ファイル

- `maestro/preview_flows/capture_all_previews.yaml` (13 → 17 画面に拡張)
- `maestro/flows/design_v2_dark_mode.yaml` (新規)
- 既存 maestro flows の Light/Dark 切替パスを追加 (1-F dark mode 章準拠)
- `documents/design-handoff-v2-verification.md` (新規、17 画面 × 状態 × Light/Dark のマトリクス完了)

### 17 画面 preview 拡張

```yaml
# maestro/preview_flows/capture_all_previews.yaml 末尾に 4 画面追加
- tapOn: "次のプレビューへ"
- assertVisible: "店舗別カテゴリ並び順"
- takeScreenshot: shopping_location_order_premium

- tapOn: "次のプレビューへ"
- assertVisible: "招待コードを入力"
- takeScreenshot: group_invitation_verifying

- tapOn: "次のプレビューへ"
- assertVisible: "AI で抽出した候補"
- takeScreenshot: ai_review_sheet

- tapOn: "次のプレビューへ"
- assertVisible: "サインアウトしますか"
- takeScreenshot: sign_out_dialog
```

### Acceptance Criteria (PR-9)

- [ ] preview_flows で 17 画面分のスクショが取れている
- [ ] `documents/design-handoff-v2-verification.md` に 17 画面 × Light/Dark の PASS/FAIL マトリクスを記録
- [ ] design_v2 系 maestro flows がすべて CI でパスしている

---

## 検証 (全 PR 共通)

各 PR で必ず実施:

- [ ] `dart run build_runner build --delete-conflicting-outputs` (生成ファイル更新)
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter build ios --no-codesign`
- [ ] `flutter build apk --debug`
- [ ] 該当 maestro flow パス
- [ ] iOS Simulator iPhone 16 Plus で Light / Dark 目視 (`mobile-mcp` で操作 + スクショ + Claude 画像分析)
- [ ] Android Emulator で Light / Dark 目視
- [ ] Widget 該当時は Widget 追加 + 表示 + toggle 動作確認
- [ ] 5 accent それぞれで主要 UI に accent が伝搬

Firebase 側変更がある PR (PR-4 / PR-5 / PR-6) は追加で:

- [ ] `npm run lint` (firebase/functions/functions/)
- [ ] `npm run build`
- [ ] `npm test`

---

## 1-B. マイクロインタラクション ID 対応表 (Issue #261 番号 → 実体)

| Issue ID | Issue 期待挙動 | preview / styles.css / README 該当 | 現実装 file:line | PR |
|---|---|---|---|---|
| i-1 | ItemRow テキスト部タップ | screens-list.jsx ItemRow focus | `text_shopping_list_item.dart:42, 72-91` | PR-3 (現状維持) |
| i-2 | Checkbox tap pop | styles.css L54-58 `@keyframes checkbox-pop` | `app_checkbox.dart:32-49`, `text_shopping_list_item.dart:276-323` | (実装済み) |
| i-3 | フェイクキャレット | styles.css L42-51 `caret-blink 1.06s` | Flutter cursor 標準動作で代替 | (許容) |
| i-4 | return で空行追加 | screens-list.jsx + README §8-1 | `text_shopping_list_item.dart:395` | PR-3 (現状維持) |
| i-5 | 空行 backspace | README §8-1 | `text_shopping_list_item.dart:357` | PR-3 (現状維持) |
| i-6 | 長押し context menu | screens-list.jsx (担当者は除外) | **未実装 → PR-3 で追加** | PR-3 |
| i-7 | 左スワイプ削除 | README §8 | `text_shopping_list_item.dart:221` 既に左スワイプ | (実装済み) |
| i-8 | 右スワイプチェック | README §8 | **未実装 → PR-3 で追加** | PR-3 |
| i-9 | ヘッダー名タップ | screens-list.jsx list switch | `list_top_bar.dart` (実装済) | (実装済み) |
| i-10 | FAB bottom sheet | screens-list.jsx `easeOutBack` | `expandable_fab.dart:40-155` | (実装済み) |
| i-11 | 写真 / URL AI review | widgets-and-micro.jsx MicroAIProgress | **未実装 → PR-3 で追加** | PR-3 |
| i-12 | 追加 SnackBar | widgets-and-micro.jsx MicroNotifySnack | `notification_member_bar.dart:11-342` | (実装済み、文言確認のみ) |
| i-13 | premium tap | screens-settings.jsx Paywall | `paywall_page.dart` (実装済) | (実装済み) |
| i-14 | dark cross-fade | README §11 dark tokens | `MaterialApp.themeAnimationDuration` 確認 | PR-1 |
| i-15 | group chip 切替 | screens-list.jsx GroupChipsRow | `group_chips_bar.dart` (実装済) | (実装済み) |
| i-16 | 連続入力 60fps / debounce | README §8-1 | `text_shopping_list_item.dart` 既存 debounce | (実装済み) |
| i-17 | AI banner + shimmer | screens-list.jsx AI Processing | `ai_processing_banner.dart:18-119` | (実装済み、PR-3 で review sheet 連携追加) |
| i-18 | MicroEnterFlow | widgets-and-micro.jsx L126 | Maestro `design_v2_list_core.yaml` で検証 | PR-3 / PR-9 |
| i-19 | MicroCheckFeedback | widgets-and-micro.jsx L173 | `app_checkbox.dart` 200ms pop 実装済、ring fade は許容 | (実装済み) |
| i-20 | MicroAIProgress | widgets-and-micro.jsx L205 | 既存 banner + PR-3 の review sheet で完了 | PR-3 |
| i-21 | MicroNotifySnack | widgets-and-micro.jsx L244 | `notification_member_bar.dart` (実装済) | (実装済み) |

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios` 成功
- [ ] Android ビルド: `flutter build apk` 成功
- [ ] 新規・変更機能に対するテストが存在する（なければ新規作成）
- [ ] Maestro E2E: 該当する maestro flow があれば実行、なければ新規作成
- [ ] Entity命名: フィールド名が省略されていない
- [ ] DB操作: Firestore操作は `call` クラスのProvider経由
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり（timestamp等メタデータ除く）
- [ ] ref使い分け: build内は `ref.watch`、コールバック・操作は `ref.read`
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（該当する場合）

### Firebase（firebase/ に変更がある場合）
- [ ] Lint: `npm run lint` パス（firebase/functions/functions/ で実行）
- [ ] ビルド: `npm run build` 成功
- [ ] テスト: `npm test` 全件パス
- [ ] クライアント呼び出し関数はGenKitで定義
- [ ] onDocumentCreated/onDocumentUpdated トリガーを使っていない
- [ ] 新規・変更機能に対するテストが存在する（なければ新規作成）

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
