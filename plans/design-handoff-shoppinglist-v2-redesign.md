# 買い物リスト UI v2 redesign 計画

> **v1 計画は `plans/design-handoff-shopping-list-readme-md-soft-owl.md` にアーカイブ済み。本ファイルは新 `design_handoff_shoppinglist/`（リネーム + README/JSX 大幅書き換え）に基づく v2 計画。**

## Context

`design_handoff_shoppinglist/` （new bundle）の README §4「ブランド原則とサーフェスの使い分け」とハイブリッドサーフェスが新規導入された。`screens-list.jsx` も +117 行で再構成され、行 = TextField + フェイクキャレット / 4 アクション FAB / 6 状態バナー が canonical になった。これらの細部が現実装でまだ未対応のため、4 スコープ × 4 PR で完全準拠を目指す。アプリは未リリースで UI/UX を大胆に変えられる最後のタイミング。

新仕様の主要変更点:
- **ハイブリッドサーフェス**: ShoppingListPage は paper NavBar/TabBar + 白(card) コンテンツ部のハイブリッド構造
- **行 = TextField + フェイクキャレット**: 1.5px accent / 1.06s blink、フォーカスリングなし、accentSoft 60% オーバーレイ + 左 2px accent border
- **ProgressBlock**: mono 24/600 done / mono 24/400 total + 4px progress bar + caption「チェック済み」
- **FAB 4 アクション**: 写真AI / URL AI / テキスト貼り付け / 空行を追加
- **NotifySnack**: 26×26 avatar -6px overlap、accent 全員 pill、2 段テキスト、ink bg 5 秒
- **Free 50+ バナー**: surface2 + crown + 「詳しく」accent link
- **iOS 17+ Interactive Widget**: AppIntent + Button(intent:) 必須
- **Accent 5 プリセット**（shu/matcha/ai/sumi/kuchiba）が canonical
- **Paywall 3 プラン**: ¥480 月額 / ¥3,800 年間 おすすめ / ¥9,800 買い切り

## 全体方針: 4 スコープ × 4 PR

| PR | スコープ | 対象数 | 主目的 |
|---|---|---|---|
| PR-A | ShoppingListPage 中核細部 | 10 マイクロ修正 | ハイブリッドサーフェス + フェイクキャレット + NotifySnack 仕様 + バナー類 + EmptyHint |
| PR-B | 周辺画面 (Onboarding/Auth/Settings/Paywall/GroupInvitation) | 約 6 ファイル | 3 種イラスト・AuthArt 紙袋・Profile/Premium card・mono 価格・おすすめバッジ・規約フッタ |
| PR-C | PR4 集約 — 周辺 8 画面の新トークン移行（1 PR） | 8 ファイル | shopping_list_setting + group_list + group_create + group_setting + group_category(2) + shopping_location(2) を新トークン/Section card に置換 |
| PR-D | ホームウィジェット仕様準拠（RemoteViews 維持） | iOS 3 / Android 2 / Flutter 1 | iOS accent 四角・done/total・2.5px sliver・5×5 dot / Android 4×2 cell・#F6F0E2 bg・mono count・Material You |

---

## PR-A: ShoppingListPage 中核細部

| # | 変更対象 | 修正内容 |
|---|---|---|
| A1 | `lib/features/shopping_list/page.dart` | Scaffold `bg: surface(paper)`、コンテンツ Column の外側に `Container(color: tokens.neutral.card)` を挟みハイブリッドサーフェス化 |
| A2 | `lib/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart` | `cursorWidth: 0` で OS カーソル抑制、`Stack` で `FakeCaret`（1.5px / 1.06s blink）を重ねる |
| A3 | 同上 | focused 時 accentSoft オーバーレイ濃度を 40% → **60%** へ |
| A4 | `lib/features/shopping_list/components/notification_member_bar.dart` | アバター 32px → **26×26**（radius 13）、`-6px overlap`（Stack/Positioned）、全員 pill を **accent bg** へ、テキストを「『XXX』を追加」「家族に通知しますか？」の 2 段に分離 |
| A5 | `lib/features/shopping_list/components/shopping_list_items/category_section_header.dart` | `name` を `name.toUpperCase()` 表示に変更 |
| A6 | `lib/features/shopping_list/components/banners/ai_processing_banner.dart` | `_StripePainter`（45° 縞 CustomPainter）で 32×32 stripe-ph + 1.6s loop アニメ |
| A7 | `lib/features/shopping_list/components/banners/all_done_banner.dart` | 左 emoji + 2 段テキスト → **中央寄せ祝福 UI**（emoji 中央 / テキスト中央） |
| A8 | `lib/features/shopping_list/components/banners/retention_banner.dart` | accentSoft + premium icon → **surface2 + crown icon + 詳しく(accent link)** |
| A9 | `lib/features/shopping_list/components/progress_block.dart` | 全完了時表示を AllDoneBanner と二重化させない（progress 内は "✓ おつかれさま" のみ、バナーは別個に表示） |
| A10 | `lib/features/shopping_list/components/shopping_list_items/empty_text_shopping_list_item.dart` | dashed hint card の内側に `surface2` 塗りを追加 |

### 代表コード: A2 フェイクキャレット

```dart
// lib/features/shopping_list/components/shopping_list_items/fake_caret.dart
class FakeCaret extends StatefulWidget {
  final Color color;
  final double height;
  const FakeCaret({super.key, required this.color, this.height = 20});
  @override
  State<FakeCaret> createState() => _FakeCaretState();
}

class _FakeCaretState extends State<FakeCaret> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1060),
  )..repeat();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final visible = _ctrl.value < 0.5;
        return Opacity(
          opacity: visible ? 1.0 : 0.0,
          child: Container(width: 1.5, height: widget.height, color: widget.color),
        );
      },
    );
  }
}
```

`text_shopping_list_item.dart` 側で `cursorWidth: 0` または `showCursor: false` で OS カーソル抑制し、focused 時のみ `FakeCaret` を Stack で重ねる。

### 代表コード: A4 NotifySnack アバター仕様

```dart
// _MemberAvatarStack: 26×26、-6px overlap
class _MemberAvatarStack extends StatelessWidget {
  final List<GroupUserProfile> members;
  final void Function(String userID) onTap;
  const _MemberAvatarStack({required this.members, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final shown = members.take(3).toList();
    return SizedBox(
      width: shown.length * 20.0 + 6,
      height: 26,
      child: Stack(
        children: List.generate(shown.length, (i) {
          return Positioned(
            left: i * 20.0,
            child: GestureDetector(
              onTap: () => onTap(shown[i].userID),
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.3),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  shown[i].displayName?.substring(0,1).toUpperCase() ?? '?',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
```

### 検証
- `flutter test test/features/shopping_list/components/banners_test.dart`
- 新規 widget test: `test/features/shopping_list/components/fake_caret_test.dart`、`notification_member_bar_test.dart`
- `maestro test maestro/flows/add_and_check_item.yaml`
- 手動: iOS Simulator iPhone 16 Plus で ShoppingListPage 開いて focused 行のキャレットを目視確認

---

## PR-B: 周辺画面細部

| # | 変更対象 | 修正内容 |
|---|---|---|
| B1 | `lib/features/onboarding/page.dart` | 3 種イラスト `_TiltedListArt` / `_AvatarOrbitArt` / `_MapHaloArt` を CustomPainter or Stack で実装。eyebrow を `01/03` mono accent 表記に変更 |
| B2 | `lib/features/auth/page.dart`、`components/auth/apple.dart`、`google.dart` | Apple ボタン h=52/radius 14/black、Google ボタン h=52/surface2/divider に揃える。AuthArt を `_PaperBagArt`（紙袋+葉物 CustomPaint）に置換 |
| B3 | `lib/features/settings/page.dart` | `_ProfileCard`（48 avatar + name + email + Edit ghost pill）新規作成。`_PremiumCard` を free=surface2 / premium=LinearGradient(accent → #7C2A07) で出し分け。末尾に mono version 行 (`v1.4.2 (build 248)`) |
| B4 | `lib/features/settings/theme_color_selection_page.dart` | bg を `paper` に変更、ラベルを `serif` 12/600（`GoogleFonts.zenKakuGothicNew`）に |
| B5 | `lib/features/paywall/paywall_page.dart` | bg `paper`、Hero radius 18、価格 mono フォント、recommended バッジ「お得」→「おすすめ」、フッタに 利用規約/プライバシー/復元 の 3 リンク追加 |
| B6 | `lib/features/group_invitation/page.dart` | AppBar を `AppLargeAppBar`、ボタンを `AppPill(accent, large:true)` / `AppPill(ghost)` に置換 |

### 代表コード: B3 Premium card グラデ

```dart
class _PremiumCard extends ConsumerWidget {
  const _PremiumCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final isPremium = ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPremium
          ? const LinearGradient(
              colors: [Color(0xFFC2410C), Color(0xFF7C2A07)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            )
          : null,
        color: isPremium ? null : tokens.neutral.surface2,
        borderRadius: BorderRadius.circular(14),
        border: isPremium ? null : Border.all(color: tokens.neutral.divider, width: 0.5),
        boxShadow: isPremium ? tokens.cardShadow : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPremium ? Colors.white.withValues(alpha: 0.2) : tokens.accentSoft,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.workspace_premium,
              color: isPremium ? Colors.white : tokens.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isPremium ? 'プレミアム会員' : 'プレミアムにアップグレード',
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: isPremium ? Colors.white : tokens.neutral.ink)),
              const SizedBox(height: 2),
              Text(isPremium ? 'すべての機能が利用できます' : '5 色テーマ・AI 無制限など',
                style: TextStyle(fontSize: 11.5,
                  color: isPremium ? Colors.white.withValues(alpha: 0.85) : tokens.neutral.ink2)),
            ],
          )),
          if (!isPremium) AppPill(
            label: 'はじめる', variant: AppPillVariant.accent,
            onPressed: () => showPaywall(context: context),
          ),
        ],
      ),
    );
  }
}
```

### 検証
- `flutter test test/features/onboarding/`、`test/features/settings/`、`test/features/paywall/`
- `maestro test maestro/flows/onboarding_first_launch.yaml`（新規 or 既存）
- `maestro test maestro/flows/theme_color_change.yaml`
- 手動: iOS Simulator で Onboarding → Auth → Home → Settings → Paywall 全フロー目視

---

## PR-C: PR4 集約 — 周辺 8 画面の新トークン移行

| # | 変更対象 | 主要修正 |
|---|---|---|
| C1 | `lib/features/shopping_list_setting/page.dart` | `AppLargeAppBar` + `AppSectionCard` 4 セクション（リスト名 / 場所 / 保存期間 / 共有）+ 削除ボタン `AppPill(danger, large)`。InviteCodeDialog（mono 36/600 letterSpacing 8）、DeleteConfirmDialog を新規ダイアログ Widget で実装 |
| C2 | `lib/features/group_list/page.dart` | グループカードを `AppSectionCard` で実装。3-stack avatars (28×28 / -8px overlap)、デフォルトバッジ accentSoft / accent。FAB を accent / lock 切替（free-limit 時） |
| C3 | `lib/features/group_create/page.dart` | TextField 下線 1px accent、CTA `AppPill(accent, large)` 全幅。creating spinner、error 時 dangerSoft 帯 |
| C4 | `lib/features/group_setting/page.dart` | `AppLargeAppBar` + `AppSectionCard`（メンバー / 招待コード発行 pill / リストの軸 pin+tag Cell）。ロケーション/カテゴリのインライン CRUD を別ページ push に変更 |
| C5 | `lib/features/group_category/page.dart` | 並び順 surface2 row + ドロップダウンチップ。drag handle + 32×32 色付きアイコンタイル + 名前 + キーワード件数 + edit/trash。free-locked 時 surface2 + crown バナー |
| C6 | `lib/features/group_category/category_edit_page.dart` | 色 9 swatches + none + 2px ink ring、アイコン 6 列グリッド（未設定タイル + 12 emoji + AI 生成 dashed accent + crown）、キーワード mode(部分/完全/正規) + ×、追加 `AppPill(ghost)` |
| C7 | `lib/features/shopping_location/page.dart` | 場所カード 36×36 アイコンタイル（`pin-fill` accent or `store` ink3）、empty surface2 + dashed + store 36 icon。AddLocationDialog（名前 + 地図で場所を設定 dashed + PRO badge） |
| C8 | `lib/features/shopping_location/location_picker_page.dart` | 地図 + 中央 pin-fill 42 accent + drop-shadow、右下 crosshair 44×44、底カード radius 18、loading stripe-ph、`AppPill(accent, large)` |

### 代表コード: C2 グループカード（3-stack avatars）

```dart
class _GroupCard extends StatelessWidget {
  final Group group;
  final List<GroupUserProfile> members;
  final bool isDefault;
  final VoidCallback onTap;
  const _GroupCard({
    required this.group, required this.members,
    required this.isDefault, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final shown = members.take(3).toList();
    return AppSectionCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        SizedBox(
          width: shown.length * 20.0 + 8, height: 28,
          child: Stack(children: List.generate(shown.length, (i) => Positioned(
            left: i * 20.0,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.accentSoft,
                border: Border.all(color: tokens.neutral.card, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                shown[i].displayName?.substring(0,1).toUpperCase() ?? '?',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 11, fontWeight: FontWeight.w600, color: tokens.accent),
              ),
            ),
          ))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Flexible(child: Text(group.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis)),
              if (isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tokens.accentSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('デフォルト',
                    style: TextStyle(fontSize: 10, color: tokens.accent, fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
            const SizedBox(height: 2),
            Text('メンバー ${members.length}人',
              style: TextStyle(fontSize: 11.5, color: tokens.neutral.ink3)),
          ],
        )),
        Icon(Icons.chevron_right, color: tokens.neutral.ink4, size: 20),
      ]),
    );
  }
}
```

### 検証
- `flutter test`（既存 + 新規 widget test）
- `maestro test maestro/flows/`（group_create / group_setting / category_edit / shopping_location 系の既存 flow 全件パス。なければ新規追加）
- `flutter analyze` エラーなし
- 手動: 各画面を iOS Simulator で開き、design preview と並べてレイアウト目視

---

## PR-D: ホームウィジェット仕様準拠（RemoteViews 維持）

| # | 変更対象 | 主要修正 |
|---|---|---|
| D1 | `ios/ShoppingListWidget/ShoppingListWidgetView.swift` | 左上ロゴ: `18×18` accent 四角 + cart icon、右上: `done/total` mono Text 11.5pt、底に 2.5px progress sliver、checkbox 14×14、cat dot 5×5、フォント 11.5pt |
| D2 | `ios/ShoppingListWidget/ShoppingListWidget.swift`（Provider/Entry） | `Entry` 構造体に `done: Int` / `total: Int` フィールド追加。`FirestoreService` で集計してから return |
| D3 | `lib/features/home_widget/home_widget_data_sync.dart` | `widget_done_count_<group>_<list>` / `widget_total_count_<group>_<list>` を `HomeWidget.saveWidgetData` で書き込み |
| D4 | `android/app/src/main/res/layout/shopping_list_widget.xml` | bg を `#F6F0E2` 固定、count TextView を `android:fontFamily="monospace"` で実装、Material You 用 `@android:color/system_accent1_600` を accent 寄せに |
| D5 | `android/app/src/main/res/xml/shopping_list_widget_info.xml` | `targetCellWidth=4 / targetCellHeight=2 / minWidth=320dp / minHeight=200dp` に変更 |

### 代表コード: D1 progress sliver (Swift)

```swift
// ShoppingListWidgetView.swift — Small 用 footer
private var progressSliver: some View {
  GeometryReader { geo in
    ZStack(alignment: .bottomLeading) {
      Rectangle()
        .fill(Color(hex: entry.themeColorHex).opacity(0.15))
      Rectangle()
        .fill(Color(hex: entry.themeColorHex))
        .frame(width: geo.size.width * progressRatio)
    }
  }
  .frame(height: 2.5)
}

private var progressRatio: CGFloat {
  guard entry.total > 0 else { return 0 }
  return CGFloat(entry.done) / CGFloat(entry.total)
}
```

### 代表コード: D4 Android count TextView

```xml
<!-- shopping_list_widget.xml: top row -->
<TextView
  android:id="@+id/widget_count"
  android:layout_width="wrap_content"
  android:layout_height="wrap_content"
  android:fontFamily="monospace"
  android:textSize="14sp"
  android:textStyle="bold"
  android:textColor="@android:color/system_accent1_600"
  tools:text="3/8" />
```

### 検証
- iOS: シミュレータでウィジェット追加 → Small / Medium / Large 全てに done/total と progress sliver が表示される
- iOS 17+: ToggleItemIntent が動作するか確認（チェックボックス押下でアイテム状態が変わる）
- Android: エミュレータでウィジェット追加 → 4×2 セルで `#F6F0E2` 背景、mono count、Material You テーマ追従
- `flutter test`、`maestro` は影響なし（ウィジェットは E2E 対象外）
- 手動: テーマカラー 5 色全てを切り替えて、widget の accent が反映されるか確認

---

## 推奨実装順序

1. **PR-A** マージ → ShoppingListPage が新仕様に完全準拠（ユーザーが一番見る画面）
2. **PR-B** マージ → 周辺画面（Onboarding/Auth/Settings/Paywall）細部完成
3. **PR-C** マージ → 残 8 画面が新トークンに移行
4. **PR-D** マージ → ウィジェットも仕様準拠

各 PR は `flutter analyze` / `flutter test` / `flutter build ios --no-codesign` / `flutter build apk --debug` / 該当 `maestro` を必ずグリーンにしてマージ。PR-D マージ時に issue 250 / 251 を close。

## 共通検証（各 PR ごと）

- [ ] `flutter analyze` エラーなし
- [ ] `flutter test` 全件パス
- [ ] `flutter build ios --no-codesign` 成功
- [ ] `flutter build apk --debug` 成功
- [ ] 該当する `maestro/flows/*.yaml` 全件パス
- [ ] iOS Simulator iPhone 16 Plus で手動目視確認

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新（v2 では新規 provider なし、不要見込み）
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
- 今回スコープ外

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
