# 買い物リスト UI 全面再設計（design_handoff_shopping_list 実装）— v1 アーカイブ

> **2026-05-13 v2 移行ノート**
>
> `design_handoff_shopping_list/` は `design_handoff_shoppinglist/` にリネームされ、README（391→562 行）と `screens-list.jsx`（+117 行）が大幅に書き換わった。具体的には次の変更が加わっている:
> - **ハイブリッドサーフェス**: ShoppingListPage は paper NavBar/TabBar + 白(card) コンテンツ部のハイブリッド構造（旧バージョンは単一面）
> - **行 = TextField + フェイクキャレット**: 1.5px accent / 1.06s blink、フォーカスリングなし、accentSoft 60% オーバーレイ + 左 2px accent border
> - **ProgressBlock 仕様確定**: mono 24/600 done / mono 24/400 total + 4px progress bar + caption「チェック済み」
> - **FAB 4 アクション正規化**: 写真AI / URL AI / テキスト貼り付け / 空行を追加
> - **NotifySnack 仕様**: 26×26 avatar -6px overlap、accent 全員 pill、2 段テキスト、ink bg 5 秒
> - **Free 50+ バナー**: surface2 + crown + 「詳しく」accent link
> - **iOS 17+ Interactive Widget**: AppIntent + Button(intent:) 必須
> - **Accent 5 プリセット**（shu/matcha/ai/sumi/kuchiba）が canonical（preview の 10 色は drift）
> - **Paywall 3 プラン**: ¥480 月額 / ¥3,800 年間 おすすめ / ¥9,800 買い切り
>
> v1 の進捗:
> - 共通基盤・frame Widget・shopping_list の中核 Widget・banners・onboarding・settings・paywall・group_invitation・home_widget の 5 色同期は実装済み（コミット履歴参照）。
> - 周辺 8 画面（shopping_list_setting / group_list / group_create / group_setting / group_category / group_category/category_edit / shopping_location / shopping_location/location_picker）は旧 Material default のままで新トークン未適用。
> - ShoppingListPage の細部（ハイブリッドサーフェス / フェイクキャレット / accentSoft 60% / NotifySnack 仕様 / CategoryHeader uppercase / AI Processing stripe-ph / RetentionBanner surface2 / AllDoneBanner 配置 / EmptyHint 内塗り）は未完。
> - Onboarding 3 種イラスト / AuthArt 紙袋 / Settings Profile/Premium card / Paywall mono 価格 / おすすめバッジ / 規約フッタは未完。
> - iOS ウィジェットの accent 四角 / done-total / 2.5px sliver / 5×5 dot、Android ウィジェットの 4×2 cell / `#F6F0E2` 背景 / mono / Material You 動的色は未完。
>
> **v2 redesign 計画は新ファイル `plans/design-handoff-shoppinglist-v2-redesign.md` に書く**（Plan mode 抜け直後の実装フェーズで作成する）。本 v1 ファイルは実装参考用として保持。

---

# v2 redesign 計画サマリ

> このセクションは v2 redesign の計画サマリ。Plan mode 抜け直後に新ファイル `plans/design-handoff-shoppinglist-v2-redesign.md` を作成して、本サマリを転記し、各 PR セクションのコード提案を詳細化する。

## v2 Context

`design_handoff_shoppinglist/` （new bundle）の README §4「ブランド原則とサーフェスの使い分け」とハイブリッドサーフェスが新規導入された。`screens-list.jsx` も +117 行で再構成され、行 = TextField + フェイクキャレット / 4 アクション FAB / 6 状態バナー が canonical になった。これらの細部が現実装でまだ未対応のため、4 スコープ × 4 PR で完全準拠を目指す。アプリは未リリースで UI/UX を大胆に変えられる最後のタイミング。

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
| A2 | `lib/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart` | `cursorWidth: 0` で OS カーソル抑制、`Stack` で `_FakeCaret`（1.5px / 1.06s blink）を重ねる |
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
// lib/features/shopping_list/components/shopping_list_items/_fake_caret.dart
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

`text_shopping_list_item.dart` 側で:

```dart
TextField(
  // ...既存設定
  cursorWidth: 0, // OS カーソル抑制
  showCursor: false,
)
// Stack で focused 時のみ FakeCaret を TextField の右側に重ねる（簡易実装）
```

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
- 手動: iOS Simulator で Onboarding → Auth → Home → Settings → Paywall 全部のフロー目視

---

## PR-C: PR4 集約 — 周辺 8 画面の新トークン移行

| # | 変更対象 | 主要修正 |
|---|---|---|
| C1 | `lib/features/shopping_list_setting/page.dart` | `AppLargeAppBar` + `AppSectionCard` 4 セクション（リスト名 / 場所 / 保存期間 / 共有）+ 削除ボタン `AppPill(danger, large)`。InviteCodeDialog（mono 36/600 letterSpacing 8）、DeleteConfirmDialog を新規ダイアログ Widget で実装 |
| C2 | `lib/features/group_list/page.dart` | グループカードを `AppSectionCard` で実装。3-stack avatars (28×28 / -8px overlap)、デフォルトバッジ accentSoft / accent。FAB を accent / lock 切替（free-limit 時） |
| C3 | `lib/features/group_create/page.dart` | TextField 下線 1px accent、CTA `AppPill(accent, large)` 全幅。creating spinner、error 時 dangerSoft 帯 |
| C4 | `lib/features/group_setting/page.dart` | `AppLargeAppBar` + `AppSectionCard`（メンバー / 招待コード発行 pill / リストの軸 pin+tag Cell）。ロケーション/カテゴリのインライン CRUD を別ページ push に変更 |
| C5 | `lib/features/group_category/page.dart` | 並び順 surface2 row + ドロップダウンチップ「イオン藤沢店」。drag handle + 32×32 色付きアイコンタイル + 名前 + キーワード件数 + edit/trash。free-locked 時 surface2 + crown バナー |
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
| D1 | `ios/ShoppingListWidget/ShoppingListWidgetView.swift` | 左上ロゴ: `18×18` accent 四角 + cart icon、右上: `done/total` mono Text 11.5pt、底に 2.5px progress sliver、checkbox 14×14、cat dot 5×5、フォント 11.5pt（`.system(size: 11.5)`） |
| D2 | `ios/ShoppingListWidget/ShoppingListWidget.swift`（Provider/Entry） | `Entry` 構造体に `done: Int` / `total: Int` フィールド追加。`FirestoreService` で集計してから return |
| D3 | `lib/features/home_widget/home_widget_data_sync.dart` | `widget_done_count_<group>_<list>` / `widget_total_count_<group>_<list>` を `HomeWidget.saveWidgetData` で書き込み |
| D4 | `android/app/src/main/res/layout/shopping_list_widget.xml` | bg を `#F6F0E2` 固定、count TextView を `@font/ibm_plex_mono`（要追加）または `android:fontFamily="monospace"` で実装、Material You 用 `@android:color/system_accent1_600` を accent 寄せに |
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
- [ ] `flutter test` 全件パス（新規 widget/unit test を追加）
- [ ] `flutter build ios --no-codesign` 成功
- [ ] `flutter build apk --debug` 成功
- [ ] 該当する `maestro/flows/*.yaml` 全件パス
- [ ] iOS Simulator iPhone 16 Plus で手動目視確認

## v2 チェックリスト

### 実装内容
- [ ] 4 PR それぞれに具体的なコード提案（コードブロック）が新ファイル `plans/design-handoff-shoppinglist-v2-redesign.md` に記載されている
- [ ] 既存コードのパターン・構成と整合している
- [ ] Plan mode 抜け直後の最初のステップとして新ファイル `plans/design-handoff-shoppinglist-v2-redesign.md` を作成し、本サマリを転記して詳細化

### Flutter（lib/ 変更がある場合）
- [ ] コード生成: `dart run build_runner build`（v2 では新規 provider なし、不要見込み）
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios` 成功
- [ ] Android ビルド: `flutter build apk` 成功
- [ ] 新規・変更機能に対するテストが存在する
- [ ] Maestro E2E: 該当 flow があれば実行、なければ新規作成
- [ ] Entity 命名: フィールド名省略なし
- [ ] DB 操作: Firestore 操作は `call` クラス Provider 経由
- [ ] 引数: 関数・コンストラクタ引数に `{required}` あり
- [ ] ref 使い分け: build 内 `ref.watch`、コールバック `ref.read`

### Firebase（firebase/ 変更がある場合）
- 今回スコープ外

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）

---

# v1 アーカイブ（参考用）

以下は v1 計画の本文。design_handoff_shopping_list（旧）時点で書かれたもの。実装時の参考にはなるが、新仕様との差分があるので v2 サマリを優先する。

---

## Context

`design_handoff_shopping_list/` に Anthropic Labs の Claude Design 経由で生成された High-fidelity デザインバンドルが入っている（issue #250 / #251 の指示書を経て生成された成果物）。これを Flutter 側で再現する。

- 参照 issue: #250 / #251
- 参照デザイン: `design_handoff_shopping_list/README.md`、`source/screens-*.jsx`、`source/tokens.jsx`、`source/styles.css`、`source/frame.jsx`、`source/widgets-and-micro.jsx`
- アプリは未リリース。UI/UX を大胆に作り直せる最後のタイミングという位置づけ
- ドメイン機能の追加・廃止はなし（認証 / グループ / カテゴリ / 店舗 / ホームウィジェット / AI / 課金は現状の境界を維持）。**今回は UI/UX 再構築のみ**

### ユーザー確定事項

| 項目 | 決定 |
|---|---|
| スコープ | 全 17 画面 + 共通基盤 + ホームウィジェットを 1 プランに統合（実装は段階 PR 推奨） |
| テーマカラー | 既存 10 色プリセットを廃止 → デザイン側 5 色（朱 / 抹茶 / 藍 / 墨 / 朽葉）に置換。既存値は朱に移行（読み取り時 fallback、書き戻しはしない） |
| ホームウィジェット | iOS WidgetKit / Android Glance とも今回スコープに含める |
| OnboardingPage | 新規追加。新規ユーザーのみ初回 1 回。SharedPreferences の `hasSeenOnboarding` で抑止 |

---

## 全体方針

### A. デザイントークンを ThemeExtension で SSOT 化

- `Theme.of(context).extension<AppTokens>()!` で `paper / surface / surface2 / card / ink / ink2 / ink3 / ink4 / divider / divider2 / accent / accentSoft / accentInk / ok / okSoft / warn / danger / dangerSoft / checked / cardShadow / brightness` を参照
- 既存の `ColorScheme` には Material 互換マッピングのみ載せ、`ColorScheme.primary = tokens.accent` で揃える（既存 `Theme.of(context).colorScheme.primary` 参照箇所が壊れない）
- `lib/style/color.dart` の `colorFromHex` は廃止せず、カテゴリ色など個別 HEX を扱う場面でそのまま使う

### B. 5 色プリセット移行は読み取り fallback のみ

- `users/{uid}.themeColorHex` の Firestore フィールドはそのまま（マイグレーション不要 / Rules 変更不要）
- 読み取り時に旧 10 色 HEX (`#673AB7` 等) や `null` は `AccentPreset.shu` (`#C2410C`) にフォールバック
- 書き戻しはしない（「テーマカラーが勝手に変わった」と感じさせないため）。次にユーザーが設定画面で色変更したタイミングで新 HEX が永続化される

### C. 段階的 PR 分割

このプランは 1 つの設計書だが、実装 PR は次の 5 段階に分けることを推奨する。

1. **PR1 — 基盤**: tokens / theme / google_fonts / `lib/components/frame/` 共通 Widget / `lib/app.dart` 接続
2. **PR2 — ShoppingListPage 中核**: ListTopBar / GroupChipsBar / FilterChipsBar / ProgressBlock / ItemRow / ExpandableFab / バナー類 / SnackBar 改修
3. **PR3 — 周辺画面 (前半)**: Onboarding / Auth / Home / ShoppingListSettingPage / FilterPage / SettingPage / ThemeColorSelectionPage / PaywallPage
4. **PR4 — 周辺画面 (後半)**: GroupList / GroupCreate / GroupSetting / GroupInvitationAccept / GroupCategory / CategoryEdit / ShoppingLocation / LocationPicker
5. **PR5 — ホームウィジェット**: iOS WidgetKit / Android Glance のスタイル更新 + テーマ色同期

各 PR は `flutter analyze`, `flutter test`, `flutter build ios`, `flutter build apk`, `maestro` を必ずパスさせる。

---

## 共通基盤（PR1）

### ファイル一覧

| 種別 | パス |
|---|---|
| 新規 | `lib/style/tokens.dart` |
| 新規 | `lib/style/theme.dart` |
| 改修 | `lib/provider/theme_color.dart`（5 色化、`AccentPreset` 解決） |
| 改修 | `lib/app.dart`（`buildAppTheme(brightness, accent)` 経由に） |
| 改修 | `pubspec.yaml`（`google_fonts: ^6.2.1` 追加） |
| 新規 | `lib/components/frame/app_pill.dart` |
| 新規 | `lib/components/frame/app_round_button.dart` |
| 新規 | `lib/components/frame/app_checkbox.dart` |
| 新規 | `lib/components/frame/app_chip.dart` |
| 新規 | `lib/components/frame/app_large_app_bar.dart` |
| 新規 | `lib/components/frame/app_bottom_tab_bar.dart` |
| 新規 | `lib/components/frame/app_section_card.dart` |

### `lib/style/tokens.dart`

`AppNeutralColors`（21 色 light/dark）、`AccentPreset` enum（5 色）、`AppTokens extends ThemeExtension<AppTokens>` を定義する。

```dart
// lib/style/tokens.dart
import 'package:flutter/material.dart';

@immutable
class AppNeutralColors {
  final Color paper, surface, surface2, card;
  final Color ink, ink2, ink3, ink4;
  final Color divider, divider2;
  final Color ok, okSoft, warn, danger, dangerSoft, checked;

  const AppNeutralColors({
    required this.paper, required this.surface, required this.surface2,
    required this.card, required this.ink, required this.ink2,
    required this.ink3, required this.ink4, required this.divider,
    required this.divider2, required this.ok, required this.okSoft,
    required this.warn, required this.danger, required this.dangerSoft,
    required this.checked,
  });

  static const light = AppNeutralColors(
    paper: Color(0xFFECE5D3), surface: Color(0xFFF8F2E2),
    surface2: Color(0xFFFFFCF3), card: Color(0xFFFFFFFF),
    ink: Color(0xFF1B1813), ink2: Color(0xFF5A5246),
    ink3: Color(0xFF948A77), ink4: Color(0xFFBDB39E),
    divider: Color(0xFFE0D5BC), divider2: Color(0xFFEBE2C9),
    ok: Color(0xFF2F6B43), okSoft: Color(0xFFDCEBDF),
    warn: Color(0xFFB47B1F), danger: Color(0xFFB53D3D),
    dangerSoft: Color(0xFFF4DEDB), checked: Color(0xFFA89E89),
  );
  static const dark = AppNeutralColors(
    paper: Color(0xFF13110D), surface: Color(0xFF1B1813),
    surface2: Color(0xFF221E18), card: Color(0xFF26221C),
    ink: Color(0xFFF2EDE2), ink2: Color(0xFFBFB6A3),
    ink3: Color(0xFF847C6B), ink4: Color(0xFF5A5246),
    divider: Color(0xFF2A251F), divider2: Color(0xFF332D26),
    ok: Color(0xFF6BB07F), okSoft: Color(0xFF1F3325),
    warn: Color(0xFFE1B05A), danger: Color(0xFFE47A7A),
    dangerSoft: Color(0xFF3A2020), checked: Color(0xFF5A5246),
  );

  AppNeutralColors lerp(AppNeutralColors other, double t) => AppNeutralColors(
    paper: Color.lerp(paper, other.paper, t)!, surface: Color.lerp(surface, other.surface, t)!,
    surface2: Color.lerp(surface2, other.surface2, t)!, card: Color.lerp(card, other.card, t)!,
    ink: Color.lerp(ink, other.ink, t)!, ink2: Color.lerp(ink2, other.ink2, t)!,
    ink3: Color.lerp(ink3, other.ink3, t)!, ink4: Color.lerp(ink4, other.ink4, t)!,
    divider: Color.lerp(divider, other.divider, t)!, divider2: Color.lerp(divider2, other.divider2, t)!,
    ok: Color.lerp(ok, other.ok, t)!, okSoft: Color.lerp(okSoft, other.okSoft, t)!,
    warn: Color.lerp(warn, other.warn, t)!, danger: Color.lerp(danger, other.danger, t)!,
    dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!, checked: Color.lerp(checked, other.checked, t)!,
  );
}

/// 5 色のアクセントプリセット。Firestore 永続化キーは LIGHT 値の `#RRGGBB`。
enum AccentPreset {
  shu(    light: Color(0xFFC2410C), dark: Color(0xFFE8743A), softLight: Color(0xFFFBE4D0), softDark: Color(0xFF3A2316), inkLight: Color(0xFF7C2A07), inkDark: Color(0xFFFCD7BB), label: '朱'),
  matcha( light: Color(0xFF1F6B4E), dark: Color(0xFF6BB07F), softLight: Color(0xFFDCEBDF), softDark: Color(0xFF1F3325), inkLight: Color(0xFF0F3D2A), inkDark: Color(0xFFB7D9C2), label: '抹茶'),
  ai(     light: Color(0xFF0F4C81), dark: Color(0xFF5FA0D6), softLight: Color(0xFFD8E4F0), softDark: Color(0xFF162B3E), inkLight: Color(0xFF0A2E50), inkDark: Color(0xFFC4DAEC), label: '藍'),
  sumi(   light: Color(0xFF1B1B1B), dark: Color(0xFFE8E5DD), softLight: Color(0xFFE8E5DD), softDark: Color(0xFF33302A), inkLight: Color(0xFF000000), inkDark: Color(0xFFF2EDE2), label: '墨'),
  kuchiba(light: Color(0xFFB45309), dark: Color(0xFFE0985A), softLight: Color(0xFFF6E1C9), softDark: Color(0xFF3A2812), inkLight: Color(0xFF6B2F05), inkDark: Color(0xFFF1D2A8), label: '朽葉');

  const AccentPreset({required this.light, required this.dark, required this.softLight, required this.softDark, required this.inkLight, required this.inkDark, required this.label});
  final Color light, dark, softLight, softDark, inkLight, inkDark;
  final String label;

  String get persistHex =>
      '#${light.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}

class AppTokens extends ThemeExtension<AppTokens> {
  final Brightness brightness;
  final AccentPreset accentPreset;
  final AppNeutralColors neutral;
  final List<BoxShadow> cardShadow;

  const AppTokens({required this.brightness, required this.accentPreset, required this.neutral, required this.cardShadow});

  bool get isDark => brightness == Brightness.dark;
  Color get accent     => isDark ? accentPreset.dark : accentPreset.light;
  Color get accentSoft => isDark ? accentPreset.softDark : accentPreset.softLight;
  Color get accentInk  => isDark ? accentPreset.inkDark : accentPreset.inkLight;

  static const s2 = 2.0; static const s4 = 4.0; static const s6 = 6.0;
  static const s8 = 8.0; static const s10 = 10.0; static const s12 = 12.0;
  static const s14 = 14.0; static const s16 = 16.0; static const s18 = 18.0;
  static const s20 = 20.0; static const s24 = 24.0; static const s32 = 32.0;

  static const radiusPill = 999.0; static const radiusButtonSm = 12.0;
  static const radiusButton = 14.0; static const radiusCta = 16.0;
  static const radiusCard = 14.0; static const radiusInput = 12.0;
  static const radiusSheet = 18.0;

  static const shadowLight = <BoxShadow>[
    BoxShadow(color: Color(0x0D1B1813), offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A1B1813), offset: Offset(0, 6), blurRadius: 18),
  ];
  static const shadowDark = <BoxShadow>[
    BoxShadow(color: Color(0x66000000), offset: Offset(0, 1)),
    BoxShadow(color: Color(0x4D000000), offset: Offset(0, 6), blurRadius: 18),
  ];

  factory AppTokens.of({required Brightness brightness, required AccentPreset accent}) {
    final isDark = brightness == Brightness.dark;
    return AppTokens(
      brightness: brightness, accentPreset: accent,
      neutral: isDark ? AppNeutralColors.dark : AppNeutralColors.light,
      cardShadow: isDark ? shadowDark : shadowLight,
    );
  }

  @override
  AppTokens copyWith({Brightness? brightness, AccentPreset? accentPreset}) =>
      AppTokens.of(brightness: brightness ?? this.brightness, accent: accentPreset ?? this.accentPreset);

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      brightness: t < 0.5 ? brightness : other.brightness,
      accentPreset: t < 0.5 ? accentPreset : other.accentPreset,
      neutral: neutral.lerp(other.neutral, t),
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
    );
  }
}

extension AppTokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
```

### `lib/style/theme.dart`

```dart
// lib/style/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoppinglist/style/tokens.dart';

ThemeData buildAppTheme({required Brightness brightness, required AccentPreset accent}) {
  final tokens = AppTokens.of(brightness: brightness, accent: accent);
  final neutral = tokens.neutral;
  final isDark = brightness == Brightness.dark;
  const features = <FontFeature>[FontFeature('palt')];

  TextStyle sans(double size, FontWeight w, {double height = 1.5, double ls = -0.005, Color? color}) =>
      GoogleFonts.notoSansJp(fontSize: size, fontWeight: w, height: height, letterSpacing: ls,
          fontFeatures: features, color: color ?? neutral.ink);
  TextStyle serif(double size, FontWeight w, {double height = 1.15, double ls = -0.02}) =>
      GoogleFonts.zenKakuGothicNew(fontSize: size, fontWeight: w, height: height, letterSpacing: ls,
          fontFeatures: features, color: neutral.ink);
  TextStyle mono(double size, FontWeight w) =>
      GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: w, height: 1.0,
          fontFeatures: const [FontFeature.tabularFigures()], color: neutral.ink);

  final base = GoogleFonts.notoSansJpTextTheme(
    isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
  ).apply(bodyColor: neutral.ink, displayColor: neutral.ink);

  final textTheme = base.copyWith(
    displayLarge:  serif(34, FontWeight.w800),
    displayMedium: serif(28, FontWeight.w800),
    headlineSmall: sans(22, FontWeight.w700, height: 1.25, ls: -0.015),
    titleLarge:    sans(17, FontWeight.w700, height: 1.3,  ls: -0.01),
    titleMedium:   sans(15, FontWeight.w600, height: 1.4,  ls: -0.005),
    bodyLarge:     sans(15, FontWeight.w400, height: 1.7),
    bodyMedium:    sans(14, FontWeight.w400, height: 1.6),
    bodySmall:     sans(12, FontWeight.w400, height: 1.4),
    labelLarge:    sans(13.5, FontWeight.w600, height: 1.0),
    labelSmall:    sans(11.5, FontWeight.w400, height: 1.4),
  );

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: tokens.accent, onPrimary: isDark ? neutral.ink : Colors.white,
    primaryContainer: tokens.accentSoft, onPrimaryContainer: tokens.accentInk,
    secondary: tokens.accent, onSecondary: isDark ? neutral.ink : Colors.white,
    error: neutral.danger, onError: Colors.white,
    errorContainer: neutral.dangerSoft, onErrorContainer: neutral.danger,
    surface: neutral.surface, onSurface: neutral.ink,
    surfaceContainerLowest: neutral.paper, surfaceContainerLow: neutral.surface,
    surfaceContainer: neutral.surface2, surfaceContainerHigh: neutral.card,
    surfaceContainerHighest: neutral.card,
    onSurfaceVariant: neutral.ink2,
    outline: neutral.divider, outlineVariant: neutral.divider2,
    shadow: const Color(0x141B1813),
    inverseSurface: neutral.ink, onInverseSurface: neutral.surface,
  );

  return ThemeData(
    useMaterial3: true, brightness: brightness, colorScheme: colorScheme,
    scaffoldBackgroundColor: neutral.surface, canvasColor: neutral.surface,
    textTheme: textTheme, extensions: [tokens],
    appBarTheme: AppBarTheme(
      backgroundColor: neutral.surface, foregroundColor: neutral.ink,
      elevation: 0, scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge, centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: neutral.surface, selectedItemColor: tokens.accent,
      unselectedItemColor: neutral.ink3, type: BottomNavigationBarType.fixed,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: neutral.surface, side: BorderSide(color: neutral.divider),
      labelStyle: sans(12.5, FontWeight.w500, height: 1.0),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: const StadiumBorder(),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      backgroundColor: tokens.accent, foregroundColor: Colors.white,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: sans(15, FontWeight.w600, height: 1.0),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
      foregroundColor: neutral.ink, side: BorderSide(color: neutral.divider),
      shape: const StadiumBorder(),
    )),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: tokens.accent)),
    dialogTheme: DialogThemeData(
      backgroundColor: neutral.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSheet)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: neutral.ink,
      contentTextStyle: sans(13, FontWeight.w500, color: neutral.surface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusButton)),
    ),
    dividerTheme: DividerThemeData(color: neutral.divider, thickness: 0.5, space: 0.5),
    splashFactory: NoSplash.splashFactory,
  );
}
```

### `lib/provider/theme_color.dart` 改修（5 色化＋fallback）

```dart
// lib/provider/theme_color.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/style/tokens.dart';

part 'theme_color.g.dart';

const defaultThemeColorHex = '#C2410C';

final themeColorPresets = AccentPreset.values
    .map((p) => (hex: p.persistHex, label: p.label, color: p.light, preset: p))
    .toList(growable: false);

bool isSupportedThemeColorHex(String themeColorHex) =>
    AccentPreset.values.any((p) => p.persistHex == themeColorHex);

AccentPreset resolveAccentPreset(String? themeColorHex) {
  for (final p in AccentPreset.values) {
    if (p.persistHex == themeColorHex) return p;
  }
  return AccentPreset.shu;
}

@Deprecated('Use resolveAccentPreset(...).light instead.')
Color resolveThemeColor(String? themeColorHex) =>
    resolveAccentPreset(themeColorHex).light;

class ThemeColorUpdate {
  final UserDatabase userDatabase;
  ThemeColorUpdate({required this.userDatabase});

  Future<void> call({required AccentPreset preset}) async {
    await userDatabase.userReference().update({
      'themeColorHex': preset.persistHex,
      'updatedDateTime': FieldValue.serverTimestamp(),
      'serverUpdatedDateTime': FieldValue.serverTimestamp(),
    });
  }
}

@Riverpod(dependencies: [userDatabase])
ThemeColorUpdate themeColorUpdate(Ref ref) =>
    ThemeColorUpdate(userDatabase: ref.read(userDatabaseProvider));
```

`dart run build_runner build --delete-conflicting-outputs` で `theme_color.g.dart` 再生成必須。

### `lib/app.dart` 改修（L39-58）

```dart
// Before: seedColor / ColorScheme.fromSeed
// After:
final accent = resolveAccentPreset(
  ref.watch(appUserProvider).asData?.value.themeColorHex,
);

return MaterialApp(
  navigatorKey: _navigatorKey,
  title: '買い物リスト',
  theme: buildAppTheme(brightness: Brightness.light, accent: accent),
  darkTheme: buildAppTheme(brightness: Brightness.dark, accent: accent),
  themeMode: ThemeMode.system,
  // ...（home, builder は既存維持）
);
```

import 追加: `package:shoppinglist/style/theme.dart`, `package:shoppinglist/style/tokens.dart`

### `pubspec.yaml`

```yaml
dependencies:
  google_fonts: ^6.2.1
```

`main.dart` の `runApp` 直前に `await GoogleFonts.pendingFonts([...])` を追加してフォントをプリロードする（オフライン耐性のため将来的に `assets/fonts/` 同梱も検討、但し本フェーズでは見送り）。

### 共通 frame コンポーネント

- `app_pill.dart`: `AppPill(label, onPressed, variant: neutral|accent|soft|ghost|danger, large: bool, icon)` — `StadiumBorder` + variant 色 + `large` で h=50/36
- `app_round_button.dart`: `AppRoundButton(icon, onPressed, size: 36, soft: bool, ring: bool)` — `CircleBorder`
- `app_checkbox.dart`: 円形 22px、`scale 1→1.2→1` の pop アニメ（`useAnimationController` + `TweenSequence`）
- `app_chip.dart`: 高さ 30、`active / soft / icon / dotColor` パラメータ、`StadiumBorder`
- `app_large_app_bar.dart`: `PreferredSizeWidget`、SafeArea + 上段 52px + 下段 大見出し 28pt + 任意 subtitle
- `app_bottom_tab_bar.dart`: 2 タブ固定 (`AppTab.list / settings`)、active accent + 600 weight
- `app_section_card.dart`: 設定画面の Section / Cell ラッパー、card 背景 + 角丸 14 + divider2

実装は別 Plan の付録参照（`feature-dev-code-architect-A` の 6.1〜6.7）。各 Widget のコード例はそこに完全形がある。

---

## ShoppingListPage 中核（PR2）

### 構造（Before / After）

**Before** (`lib/features/shopping_list/page.dart` L308-423):
- `Retry > Scaffold(appBar: ShoppingListAppBar, FAB(+), body: SafeArea > Column [_ProgressSection, Expanded(ShoppingListItems), 30日 footer])`

**After**:
- `Scaffold(appBar: null, FAB: ExpandableFab, body: SafeArea(top, bottom: false) > Column [ListTopBar(52), GroupChipsBar(46), FilterChipsBar(44), ProgressBlock(72) (totalCount > 0 のとき), RetentionBanner / AllDoneBanner / AIProcessingBanner (条件付き), Expanded(items.when(data: ShoppingListItems / EmptyShoppingListHint, error: ListErrorCard, loading: Loading))])`

外側 `ShoppingListPage` (L27-184) は `GroupSwitcher` を `GroupChipsBar` に置換。内側 `_Body` は `appBar: null` 化＋ Column に各バー。`AppBar` 廃止により `ShoppingListAppBar` は削除、PopupMenu 5 メニューは `ExpandableFab` に統合する。

### ファイル一覧

| 種別 | パス |
|---|---|
| 改修 | `lib/features/shopping_list/page.dart` |
| 削除 | `lib/features/shopping_list/components/app_bar.dart`（PopupMenu ロジックは ExpandableFab へ移動） |
| 削除 | `lib/features/shopping_list/components/group_switcher.dart`（`GroupChipsBar` に置換） |
| 新規 | `lib/features/shopping_list/components/list_top_bar.dart` |
| 新規 | `lib/features/shopping_list/components/group_chips_bar.dart` |
| 新規 | `lib/features/shopping_list/components/filter_chips_bar.dart` |
| 新規 | `lib/features/shopping_list/components/progress_block.dart` |
| 新規 | `lib/features/shopping_list/components/expandable_fab.dart` |
| 新規 | `lib/features/shopping_list/components/banners/retention_banner.dart` |
| 新規 | `lib/features/shopping_list/components/banners/all_done_banner.dart` |
| 新規 | `lib/features/shopping_list/components/banners/ai_processing_banner.dart` |
| 新規 | `lib/features/shopping_list/components/banners/list_error_card.dart` |
| 改修 | `lib/features/shopping_list/components/notification_member_bar.dart`（5 秒、card 背景） |
| 改修 | `lib/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart`（円形 Checkbox / focused 時左 2px accent / pop アニメ） |
| 改修 | `lib/features/shopping_list/components/shopping_list_items/empty_text_shopping_list_item.dart`（dashed hint box） |
| 改修 | `lib/features/shopping_list/components/shopping_list_items/shopping_list_items.dart`（CategorySectionHeader 差し替え） |
| 新規 | `lib/features/shopping_list/components/shopping_list_items/category_section_header.dart` |
| 新規 | `lib/features/shopping_list/components/shopping_list_items/ghost_item_row.dart` |
| 新規 | `lib/provider/ai_processing.dart`（AI 処理中の bool フラグ） |

### `progress_block.dart`

```dart
class ProgressBlock extends StatelessWidget {
  final int checkedCount;
  final int totalCount;
  const ProgressBlock({super.key, required this.checkedCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pct = totalCount == 0 ? 0.0 : checkedCount / totalCount;
    final allDone = checkedCount == totalCount && totalCount > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Text.rich(TextSpan(children: [
            TextSpan(text: '$checkedCount',
              style: GoogleFonts.ibmPlexMono(fontSize: 24, fontWeight: FontWeight.w600,
                  color: t.neutral.ink, fontFeatures: const [FontFeature.tabularFigures()])),
            TextSpan(text: '/$totalCount',
              style: GoogleFonts.ibmPlexMono(fontSize: 24, fontWeight: FontWeight.w400,
                  color: t.neutral.ink3, fontFeatures: const [FontFeature.tabularFigures()])),
          ])),
          const SizedBox(width: 8),
          Text(allDone ? '完了!' : 'チェック済み',
               style: TextStyle(fontSize: 12, color: t.neutral.ink2)),
          const Spacer(),
          if (allDone)
            Text('✓ おつかれさま',
                 style: TextStyle(fontSize: 12, color: t.neutral.ok, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct, minHeight: 4,
            backgroundColor: t.neutral.divider2,
            valueColor: AlwaysStoppedAnimation(allDone ? t.neutral.ok : t.accent),
          ),
        ),
      ]),
    );
  }
}
```

### `text_shopping_list_item.dart` 改修ポイント

連続入力 UX のロジック（`RawKeyboardListener` for Backspace L256-269 / `onSubmitted` で末尾空行追加 L293-334）は**完全保持**。装飾だけ差し替える。

1. 既存 `Transform.scale(scale: 1.5, child: Checkbox(shape: CircleBorder()))` (L72-95) を `_CircleCheckbox`（独自 Widget、22px、stroke 1.5px、pop アニメ込み）に置換。
2. Row 全体を `Container(decoration: BoxDecoration(border: Border(left: BorderSide(color: focused ? t.accent : Colors.transparent, width: 2)), color: focused ? t.accentSoft.withValues(alpha: 0.4) : null))` でラップ。
3. テキストスタイル: checked 時 `color: t.neutral.checked, decoration: TextDecoration.lineThrough, decorationColor: t.neutral.ink4`。
4. L309-317 の「最後の 1 件でも delete」が if/else 両方とも同じ実装になっているのを `if (value.isEmpty) { /* 一律 delete */ return; }` に整理。
5. `RawKeyboardListener` deprecated は `// ignore: deprecated_member_use` + 「ソフトキーボードの Backspace を拾うため意図して維持。Flutter SDK で代替が安定したら置換」とコメント。

```dart
class _CircleCheckbox extends StatefulWidget {
  final bool checked;
  final Color accent;
  final ValueChanged<bool> onChanged;
  const _CircleCheckbox({required this.checked, required this.accent, required this.onChanged});
  @override
  State<_CircleCheckbox> createState() => _CircleCheckboxState();
}
class _CircleCheckboxState extends State<_CircleCheckbox> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(duration: const Duration(milliseconds: 220), vsync: this);
  late final _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 60),
  ]).animate(_ctrl);
  @override
  void didUpdateWidget(_CircleCheckbox old) {
    super.didUpdateWidget(old);
    if (!old.checked && widget.checked) _ctrl.forward(from: 0);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ScaleTransition(scale: _scale, child: GestureDetector(
      onTap: () => widget.onChanged(!widget.checked),
      child: Container(width: 22, height: 22,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: widget.checked ? widget.accent : Colors.transparent,
          border: Border.all(color: widget.checked ? widget.accent : t.neutral.ink4, width: 1.5),
        ),
        alignment: Alignment.center,
        child: widget.checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
      ),
    ));
  }
}
```

### `expandable_fab.dart`

- 閉時 56×56、accent、plus アイコン
- 開時 4 アクション縦並び（写真 / URL / テキスト貼付 / 空行追加）+ ラベル pill (ink 背景 / surface 文字)
- AI バッジ: accent 背景 + 9px/700 で「AI」文字
- spring 280ms (`Curves.easeOutBack` / reverse: `Curves.easeIn`)
- 既存 PopupMenu のメニュー実装（`lib/features/shopping_list/components/app_bar.dart` L150-186 / `_showImagePicker` L285-, `_pasteFromClipboard` L406-428, URL ダイアログ L709- / `_AddShoppingListBottomSheet`）はこちらへ移植

### バナー類

```dart
// retention_banner.dart - 50 件超 / 30 日警告（無料時のみ）
class RetentionBanner extends StatelessWidget {
  const RetentionBanner({super.key});
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.accentSoft, borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(Icons.workspace_premium_outlined, size: 16, color: t.accent),
        const SizedBox(width: 10),
        Expanded(child: Text('無料プランは作成から30日でリストが整理されます',
              style: TextStyle(fontSize: 11.5, color: t.accentInk))),
        InkWell(onTap: () => showPaywall(context: context),
          child: Text('詳しく',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.accent))),
      ]),
    );
  }
}
```

`AllDoneBanner`（okSoft + 🌿 + 「全部チェック完了!」）、`AIProcessingBanner`（accentSoft + spinner + wand icon + 「画像から候補を抽出中...」+ shimmer 6 行）、`ListErrorCard`（dangerSoft + 再試行 / サポートに連絡）も同パターン。

### SnackBar 改修

`notification_member_bar.dart` L228-255 の `showNotificationSnackBar`:
- `duration: 5 seconds`（現状 10 秒）
- `backgroundColor: t.neutral.ink`、`shape: RoundedRectangleBorder(borderRadius: 14)`
- `margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16)`
- `dismissDirection: DismissDirection.startToEnd`
- メッセージは「『XXX』を追加 — 家族に通知しますか？」形式（最後に追加されたアイテム名を渡す）

### EmptyShoppingListHint（dashed hint box）

`empty_text_shopping_list_item.dart` を以下に書き換え:
- 上部: focused な ItemRowEmpty 1 行（タップで実アイテム追加）
- 中段: `GhostItemRow` × 5（opacity 0.5、italic 「例: 牛乳 1L」等）
- 下段: dashed border の Container（`CustomPainter` で破線実装、依存追加なし）に「return で次の行へ。空行で delete で行を消せます。」のヒント

### CategorySectionHeader

```dart
class CategorySectionHeader extends StatelessWidget {
  final GroupCategory category;
  final int doneCount;
  final int totalCount;
  const CategorySectionHeader({super.key, required this.category, required this.doneCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = category.color != null ? colorFromHex(category.color!) : t.neutral.ink3;
    return Container(
      color: t.neutral.surface,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(category.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: t.neutral.ink2, letterSpacing: 0.06)),
        const Spacer(),
        Text('$doneCount/$totalCount', style: GoogleFonts.ibmPlexMono(fontSize: 11,
          color: t.neutral.ink3, fontFeatures: const [FontFeature.tabularFigures()])),
      ]),
    );
  }
}
```

### AI 処理中フラグ

```dart
// lib/provider/ai_processing.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'ai_processing.g.dart';

enum AIProcessingType { image, url }

@riverpod
class AIProcessing extends _$AIProcessing {
  @override
  AIProcessingType? build() => null;
  void start(AIProcessingType type) => state = type;
  void end() => state = null;
}
```

`ExpandableFab` 内の画像 / URL 起動時に `start()`、結果到着 / エラー時に `end()`。`page.dart` 側で `ref.watch(aIProcessingProvider) != null` のとき `AIProcessingBanner` を表示。

### 移行リスク

| リスク | 対策 |
|---|---|
| `RawKeyboardListener` deprecated | コメント＋ ignore で意図的維持。後継 SDK API が安定したら置換タスク化 |
| `_Body` の `Scaffold(appBar: null)` 化で SafeArea を欠く | `ShoppingListPage` 外側 (page.dart L52) の `SafeArea(top: true, bottom: false)` で吸収済 |
| `GroupChipsBar` から groupID 切替伝搬 | `ShoppingListPage` 外側に置き、`_Body` には groupID を `ValueKey` 込みで渡す既存パターンを維持 |
| `themeColorPresets` の旧 hex とデザイン 5 色不一致 | `AccentPreset.fromHex` の fallback で `shu` に倒す（読み取りのみ） |
| `IBM Plex Mono` フォント | `google_fonts` のランタイム DL を使う（同梱は将来検討） |
| dashed border 用 `dotted_border` 依存 | `CustomPainter` で自作（依存最小化） |

---

## 周辺 16 画面 + Onboarding（PR3 / PR4）

各画面の改修ポリシーは「Material3 標準ウィジェットを `lib/components/frame/` の Widget で置き換え、トークンで配色」。ロジック（Provider / call クラス）は無改変。

各画面の inline style（padding / radius / 色）詳細は `design_handoff_shopping_list/source/screens-*.jsx` を都度参照する。

### 1. OnboardingPage（新規）

ファイル:
- 新規 `lib/features/onboarding/page.dart`
- 新規 `lib/features/resolver/onboarding_resolver.dart`
- 改修 `lib/root.dart`: resolver chain に `OnboardingResolver` を `AuthResolver` の前に追加

実装方針:
- `PageView.builder` 3 スライド + ドット + CTA（朱、56px、radius 14）+ skip
- スライド 1: 「家族と作る、買い物リスト」
- スライド 2: 「写真や URL から、まとめて追加」
- スライド 3: 「いつもの並び順で、店舗を回る」
- 完了時 `SharedPreferences.setBool('hasSeenOnboarding', true)` → `Navigator.pushReplacement(AuthPage)`
- 表示判定: `hasSeenOnboarding == false` かつ未認証ユーザー（既存ユーザーは出さない）

```dart
// lib/features/resolver/onboarding_resolver.dart 概要
class OnboardingResolver extends ConsumerWidget {
  final Widget child;
  const OnboardingResolver({super.key, required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final seen = prefs.getBool('hasSeenOnboarding') ?? false;
    final user = FirebaseAuth.instance.currentUser;
    if (!seen && user == null) {
      return const OnboardingPage();
    }
    return child;
  }
}
```

### 2. AuthPage

ファイル: `lib/features/auth/page.dart`

差分:
- AppBar 削除、`Scaffold(backgroundColor: surface)`、Column 全画面構造
- 中央に紙袋＋葉物の SVG イラスト（プレースホルダ）+ タイトル + 説明
- AppleSignInButton: 黒背景 / 高さ 52 / radius 14
- GoogleSignInButton: surface2 + divider / 高さ 52 / radius 14
- `loading-apple` 状態: ボタン内スピナー、他ボタン disabled
- error 状態: 上端に DismissibleBanner（dangerSoft + danger テキスト + radius 12）
- 規約・ポリシー: `.lk` style（下線 1px / underline-offset 3px）、`AppPill(variant: ghost)` 不可（テキストリンクのため `RichText` + `TapGestureRecognizer`）

### 3. HomePage

ファイル: `lib/features/home/page.dart`

差分:
- 既存 `NavigationBar` を `AppBottomTabBar(active: AppTab.list, onChanged: ...)` に置換
- `Scaffold(bottomNavigationBar: AppBottomTabBar(...))` + body は既存 TabBarView 維持
- `useTabController` のままアニメーション制御

### 4. ShoppingListSettingPage

ファイル: `lib/features/shopping_list_setting/page.dart`

差分:
- AppBar を `AppBar(title: Text('買い物リスト設定'), leading: AppRoundButton(icon: Icons.close, ...))` に
- body 全体を `paper` 背景に、`AppSectionCard` で Section / Cell の繰り返し
- リスト名 input、買い物する場所、保存期間（プレミアム CTA）、共有（招待 + グループ設定）、削除ボタン（`AppPill(variant: danger)`）
- `InviteCodeDialog`: 8 桁 mono + コピー / 共有 Pill
- `DeleteConfirmDialog`: AlertDialog ベース、削除ボタン `AppPill(variant: danger)`

### 5. ShoppingListItemFilterPage

ファイル: `lib/features/shopping_list_item_filter/page.dart`

差分:
- AppBar `x close`
- `AppSectionCard` 内に `SwitchListTile`（チェック済み表示 / カテゴリ順、後者はカテゴリ未定義時 disabled）
- ヒント box（`surface2` + radius 14）

### 6. GroupListPage

ファイル: `lib/features/group_list/page.dart`

差分:
- AppBar `chev-l`
- グループカード: `Card`（card 背景 + radius 14 + cardShadow）、内側にアバタースタック（28×28、-8 オーバーラップ、border 1.5px solid card）+ 名前 + メンバー数 + chev-r
- isDefault バッジ: `accentSoft + accent`
- free-limit 時 `AppSectionCard`（accentSoft 背景）に crown icon + 「最大3グループ」+ 解除リンク
- FAB: 通常時 accent + plus、上限時 surface2 + lock（既存実装維持）

### 7. GroupCreatePage

ファイル: `lib/features/group_create/page.dart`

差分:
- AppBar `chev-l`
- card 内に「グループ名」 input + 下線 1px accent
- 「作成する」`AppPill(variant: accent, large: true)` 全幅
- creating 時 内側 spinner、error 時 dangerSoft 帯

### 8. GroupSettingPage

ファイル: `lib/features/group_setting/page.dart`

差分:
- AppBar `chev-l` + trailing `AppRoundButton(more-h)`
- グループ名 input（オーナーのみ編集可）
- メンバーセクション: 36×36 アバター（自分=accent / オーナー=普通）+ `AppPill(soft, icon: person-add, label: '招待コードを発行')`
- リスト軸セクション: 買い物する場所 / カテゴリ Cell（`AppSectionCard` 内）
- 既存のロケーション / カテゴリの**インライン CRUD**は新デザインだと別ページ（`ShoppingLocationPage` / `GroupCategoryPage`）に分離されているので、Cell タップで該当ページに push する形に変更

### 9. GroupInvitationAcceptPage

ファイル: `lib/features/group_invitation/page.dart`

差分:
- AppBar `chev-l`
- 中央: 72×72 accentSoft 円 + person-add アイコン
- 8 桁コード入力 box: `mono 28/700, letterSpacing: 6, ink4 placeholder ·`
- 4 桁目で `marginRight: 12` の区切り
- valid 時 枠 accent、invalid 時 枠 danger + 下にエラー文
- 「参加する」`AppPill(accent)` + 「キャンセル」`AppPill(ghost)`

### 10. GroupCategoryPage

ファイル: `lib/features/group_category/page.dart`

差分:
- AppBar `chev-l`
- 並び順ピル（店舗ドロップダウン + `chev-d`）+ カテゴリ行（drag handle + 32×32 色付きアイコンタイル + 名前 + キーワード件数 + edit/trash）
- free-locked 時 crown バナー
- FAB（plus）

### 11. GroupCategoryEditPage

ファイル: `lib/features/group_category/category_edit_page.dart`

差分:
- 名前 input
- 色: 40×40 swatch 9 個 + 「なし」（X）、選択は outline 2px ink + 二重リング
- アイコン: 6 列グリッド、44×44、未設定タイル「先頭1文字」+ mono "未設定"、最後に「AI 生成」(dashed accent + crown badge、無料は disabled)
- キーワード CRUD: 部分一致 / 完全一致 + ×、「キーワードを追加」`AppPill(ghost)`

### 12. ShoppingLocationPage

ファイル: `lib/features/shopping_location/page.dart`

差分:
- AppBar `chev-l`
- 場所カード: 36×36 アイコンタイル（位置情報あり=accentSoft + accent pin-fill / なし=surface2 + ink3 store）+ 名前 + サブ + edit/trash
- empty 時: 破線 box + store アイコン + 案内
- add dialog: 名前 input + 「地図で場所を設定」破線ボタン + PRO バッジ

### 13. LocationPickerPage

ファイル: `lib/features/shopping_location/location_picker_page.dart`

差分:
- AppBar `chev-l`、bg `surface`
- GoogleMap 中央 + 大きい pin-fill 42 + drop-shadow
- 右下 crosshair 円ボタン 44×44
- 底のカード（left:16 right:16 bottom:36, padding 16, radius 18）
- loading 時: stripe-ph skeleton（CustomPainter で 45° 縞）+ LinearProgressIndicator 40%
- 「この場所を設定」`AppPill(accent, large: true)`

### 14. SettingPage

ファイル: `lib/features/settings/page.dart`

差分:
- 背景 `paper`、上端「設定」見出し（28/700）
- プロファイルカード（`AppSectionCard`）
- プレミアムカード:
  - 無料: surface2 + crown accentSoft + 「プレミアムにアップグレード」 CTA
  - プレミアム: linear-gradient(135deg, accent → #7C2A07) + 白文字 + crown
- グループ Section、外観 Section（テーマカラー Cell + 末尾 crown if 無料）、通知 Section、アプリについて Section、退会ボタン
- バージョン表示: `mono 11/400, ink3, 'v1.4.2 (build 248)'`
- bottom: `AppBottomTabBar(active: AppTab.settings)`

### 15. ThemeColorSelectionPage

ファイル: `lib/features/settings/theme_color_selection_page.dart`

差分:
- **5 色のみ表示**（既存 10 色 → 5 色）
- AppBar `chev-l`
- 説明文 + 5 列グリッド（gap 14）
- 各色: 52×52 円、選択時 border 3px solid surface + outline 2px solid ink + box-shadow + 中に check
- 下に `serif 12/700` で和の名（朱 / 抹茶 / 藍 / 朽葉 / 墨）
- 非プレミアムはタップで `showPaywall(context)` を呼ぶ
- `await ref.read(themeColorUpdateProvider).call(preset: preset);` に置換

### 16. PaywallPage

ファイル: `lib/features/paywall/paywall_page.dart`

差分:
- AppBar `x close`
- Hero: 64×64 グラデーション(accent → `#7C2A07`)タイル + crown + タイトル(22/800) + 説明
- Features カード: 6 項目（pin / image / wand / palette / export / doc）+ check OK
- Plans: 3 プラン横並び `_PaywallPackageTile` 改修。年額に「お得」 `AppPill(soft, label: 'お得')` バッジ（accent / serif）
- loading: 価格部分のみ shimmer
- error: dangerSoft + 再試行ボタン
- no-plans: 破線 box
- フッター: 規約 / ポリシー / 復元 リンク（`.lk` style）

### iOS / Android ホームウィジェット（PR5）

ホームウィジェットのネイティブファイルパスは PR 着手時に Glob で確定する（現時点で `ios/`, `android/` 配下を調査済みでない）。`lib/features/home_widget/home_widget_data_sync.dart` の `syncThemeColor` で渡す HEX を `AccentPreset` の light / dark 値に切り替える。

#### iOS (Swift / WidgetKit)

`ios/Widget/` あるいは `ios/Runner/Widget/` 想定:
- Small (158×158): リスト名 + 残数 (mono / 大) + 進捗バー、背景 paper
- Medium (338×158): 左 リスト名・残数 / 右 未チェック上位 3 件
- Large (338×354): 上位 6-8 件 + プログレス + メンバーアバター
- iOS 17+ Interactive Widget でチェック操作対応

App Group `group.com.bannzai.shoppinglist` の SharedDefaults に `themeColorHex`、ライト/ダーク判定用の値、リスト JSON を渡す（既存）。Swift 側で HEX → UIColor に変換する箇所が新 5 色 HEX のみを許容する形に変更。旧 HEX が来たら `#C2410C` にフォールバック（Flutter 側と同じセマンティクス）。

#### Android (Kotlin / Glance)

`android/app/src/main/kotlin/.../widget/` 想定:
- 4×2 cell, Material You 動的色取り（accent からトーン展開）
- Glance Composable + AppWidgetProvider

Android SharedPreferences `home_widget` 経由で同じ JSON / HEX を受け取る。

#### `lib/features/home_widget/home_widget_data_sync.dart`

L 内部の `_defaultThemeColorHex = '#673AB7'` を `'#C2410C'` に変更。`syncThemeColor` の渡し値も `AccentPreset` 経由で light/dark の HEX を別々に渡す（現状はライト 1 色のみ渡している場合は両方渡すよう拡張）。

---

## 検証方法

実装は段階 PR 分割を推奨だが、各 PR で以下を必ず通す。

### 共通

- `flutter analyze` → エラー 0、`deprecated_member_use` の `RawKeyboardListener` のみ ignore コメント付きで許容
- `flutter test` → 既存テスト全件パス + 新規テストが通る
- `flutter build ios --no-codesign` 成功
- `flutter build apk --debug` 成功
- `flutter pub get` 後 `dart run build_runner build --delete-conflicting-outputs` で `.g.dart` 再生成

### PR1（基盤）

- `test/theme_color_test.dart` を新仕様に書き換え:
  - `resolveAccentPreset(null) == AccentPreset.shu`
  - `resolveAccentPreset('#673AB7') == AccentPreset.shu`（旧 10 色フォールバック）
  - `resolveAccentPreset('#1F6B4E') == AccentPreset.matcha` 等 5 色の解決
  - `isSupportedThemeColorHex` の判定
- 新規 widget test: `AppPill / AppCheckbox / AppLargeAppBar`
- Maestro E2E: `maestro/flows/foundation_theme_smoke.yaml`（テーマカラー切替で primary が変わる確認）

### PR2（ShoppingListPage）

- 既存 Maestro flow が通る（連続入力 / スワイプ削除 / カテゴリ表示 / 空リスト / リスト切替）:
  - `maestro/flows/add_and_check_item.yaml`
  - `maestro/flows/swipe_delete_item.yaml`
  - `maestro/flows/category_matching_test.yaml`
  - `maestro/flows/empty_shopping_list_create.yaml`
- 新規 Widget Test:
  - `progress_block_test.dart`
  - `item_row_focus_test.dart`（focused 時に左 2px accent border が描画される）
  - `expandable_fab_test.dart`（4 メニューが展開する）
  - `all_done_banner_test.dart`（全完了時に表示）

### PR3 / PR4（周辺画面）

- 各画面に対して Maestro flow を追加 / 既存を確認:
  - Onboarding: `onboarding_first_launch.yaml`（新規ユーザーで 3 スライド + skip / 完走）
  - Auth: `auth_apple_signin.yaml` / `auth_error.yaml`
  - SettingPage: `theme_color_change.yaml`（5 色のいずれかを選択）
  - PaywallPage: 既存の Maestro flow 維持
- ThemeColorSelectionPage の `Key('theme_preset_${preset.name}')` を Maestro 用に付与

### PR5（ホームウィジェット）

- iOS / Android 両方で実機（or シミュレータ）にウィジェット追加 → 表示確認
- テーマカラー切替時に widget の accent が追従するか手動確認
- `lib/features/home_widget/home_widget_sync.dart` の `ref.listen` 経由で再同期されるか

### 手動チェックリスト（リリース前）

- [ ] 旧 10 色 (`#673AB7` 等) を保存済みのアカウントでログイン → アクセントが朱になっている
- [ ] 設定画面で抹茶 → 全画面の primary が緑系に切り替わる
- [ ] OS のダーク / ライト切替で `tokens.isDark` が反応する
- [ ] 初回起動で Noto Sans JP が描画される（フォールバックなし）
- [ ] OnboardingPage が新規ユーザーのみに表示され、既存ユーザーには表示されない
- [ ] ShoppingListPage の連続入力（Enter で末尾空行追加 / 空 Backspace で削除）が動作する
- [ ] ホームウィジェットの色がアプリのテーマと同期する

---

## 実装順序の推奨

1. PR1 をマージ → ベースが新トークンに乗る
2. PR2 をマージ → 中核 UX 完成、レビュー優先
3. PR3 / PR4 を並列で進める（互いに干渉しない画面群に分けて）
4. PR5（ウィジェット）はネイティブ側変更を含むので最後に集中レビュー

各 PR で issue 250 / 251 をリンクし、最終マージ時にこれらの issue を close する。

---

## 実装上の注意点

- **`palt`**: `TextStyle.fontFeatures: [FontFeature('palt')]` をテキストテーマ全体に適用。フォントが palt を持たなければ無視される（落ちない）
- **`tnum`**: 数値（mono）は `FontFeature.tabularFigures()` を別途指定。`palt` と同居可能
- **`ThemeExtension` の null チェック**: `Theme.of(context).extension<AppTokens>()!`。必ず `buildAppTheme` 経由でなければならない
- **`riverpod_generator`**: `provider/theme_color.dart` を編集したら必ず `dart run build_runner build --delete-conflicting-outputs`
- **`google_fonts` のオフライン挙動**: 初回起動時 Wi-Fi がないと Roboto フォールバック。`main.dart` で `GoogleFonts.pendingFonts(...)` プリロード推奨
- **無料 / プレミアム境界の文言**: README で「グループ最大3、保持期間30日」とあるが、実装は「グループ追加1、リスト5本、AI月5回 / 月50回」。**今回はビジネスロジック変更なし**で、表示文言だけ デザインに合わせる（30 日保持表記は新デザインのコピー、内部的なクリーンアップ Functions は別途要確認・必要なら別 issue で対応）
- **既存ユーザーの themeColor 保護**: 読み取り fallback のみ、書き戻ししない。設定画面で明示的に色変更したときだけ新 HEX が永続化される
- **削除予定ファイル**: `lib/features/shopping_list/components/app_bar.dart`、`group_switcher.dart` は PR2 で削除。中身のロジック（PopupMenu、URL ダイアログ、AddListBottomSheet）は `expandable_fab.dart` または個別ファイルに移植
- **`lib/components/toolbar/picker.dart`** の `CupertinoButton` は `AppPill` への置換を後続フェーズで検討（PR1 では触らない）

---

## チェックリスト

### 実装内容
- [x] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [x] 既存コードのパターン・構成を確認し、同じパターンで実装している

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

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
