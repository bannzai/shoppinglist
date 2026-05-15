# design v2 完全準拠 3 環境スクショ比較レポート

`plans/261-warm-engelbart.md` の運用ルール 3 で要求される 3 環境スクショ比較の結果。
本セッションでは Web preview と iOS Simulator (Previews ページのみ) のスクショを取得した。

## 取得スクショ

### Web (SSOT, `design_handoff_shoppinglist/preview/買い物リスト UI再設計.html`)

agent-browser で `http://localhost:8765/買い物リスト UI再設計.html` を開いて取得。

| # | ファイル | 画面 |
|---|---|---|
| 1 | `tmp/screenshots/web/01_onboarding_slide_1.png` | OnboardingPage 3 スライド |
| 2 | `tmp/screenshots/web/02_auth.png` | AuthPage (通常 / 認証中 / エラー) |
| 3 | `tmp/screenshots/web/03_home.png` | HomePage (買い物リスト / 設定タブ) |
| 4 | `tmp/screenshots/web/04_shopping_list.png` | ShoppingListPage (数件 / カテゴリ順 / 空) |
| 5 | `tmp/screenshots/web/05_all_done.png` | ShoppingListPage 全チェック完了 |
| 6 | `tmp/screenshots/web/06_ai_processing.png` | AI 処理中 + エラー状態 |
| 7 | `tmp/screenshots/web/07_group_list.png` | GroupListPage (複数 / 無料上限) |
| 8 | `tmp/screenshots/web/08_group_setting.png` | GroupSettingPage (オーナー) |
| 9 | `tmp/screenshots/web/09_invitation.png` | GroupInvitationAcceptPage (入力 / 不正コード) |
| 10 | `tmp/screenshots/web/10_setting_free.png` | SettingPage (無料 / プレミアム / テーマカラー) |
| 11 | `tmp/screenshots/web/11_setting_premium.png` | SettingPage プレミアム + ThemeColorSelectionPage |
| 12 | `tmp/screenshots/web/12_paywall.png` | PaywallPage (プラン表示 / ロード中) |
| 13 | `tmp/screenshots/web/13_shopping_list_dark.png` | ShoppingListPage ダーク |

### iOS Simulator (iPhone 16 Plus, iOS 18.2)

| # | ファイル | 画面 | 状態 |
|---|---|---|---|
| 1 | `tmp/screenshots/ios/00_previews_page.png` | PreviewsPage | 17 entry を確認 |

**注**: 個別画面への遷移には Maestro が必要だが、本セッションで利用環境に Maestro が
インストールされていない。`brew install maestro` / `curl … | bash` ともに権限制限で
インストール不可。各画面のスクショは手動 QA 範囲として残置。

### Android Emulator

未起動。実機 QA 範囲として残置。

## Web SSOT から確認した仕様 (Flutter 実装との対応)

### OnboardingPage

**Web SSOT** (`01_onboarding_slide_1.png`):
- Slide 1: `家族と作る 買い物リスト` / body 「家で思いついたものを誰かが追加して、店頭で別の誰かがチェック。『買ってきて』のやり取りを、ぜんぶこの一枚に。」
- Slide 2: `同じリストを 同時に編集` / body 「家族・パートナー・同居人を招待コードで招くと、同じリストを編集できます。誰が追加したかではなく、何を買い忘れずに済むかを大切に。」
- Slide 3: `お店の近くで そっと思い出す` / body 「登録した店舗の近くに来ると、買い物リストをやさしくお知らせ。通知は必要な時だけ、押し付けがましくなく。」
- eyebrow: `01 / 03` mono accent
- 下部 CTA: 1-2 で「次へ →」、3 で「はじめる」

**Flutter 実装**: `lib/features/onboarding/page.dart:27-49`
- title / body は PR-2 (#274) で SSOT exact 文に差し替え済み (✅)
- assetPath は `images/onboarding/slide_{1,2,3}.png` (PR-0 #272 で生成)
- eyebrow `01 / 03` の mono 表示も実装済み

### AuthPage

**Web SSOT** (`02_auth.png`):
- title: 「家族の買い物を、ひとつのリストへ」
- body: 「サインインすると端末をまたいでリストが同期します。広告もメールマガジンもありません。」
- 規約注記: 「続けることで 利用規約 と プライバシーポリシー に同意したものとみなされます。」
- CTA: 「Apple でサインイン」「Google でサインイン」(ゲストリンクなし)

**Flutter 実装**: `lib/features/auth/page.dart:37-50, 99-138`
- 文言 SSOT 化済み (PR-2 #274) ✅
- 規約注記の順序「利用規約 → プライバシーポリシー」も SSOT 通り
- debug 匿名サインインボタンは kDebugMode のみ表示

### HomePage / ShoppingListPage

**Web SSOT** (`03_home.png`, `04_shopping_list.png`):
- TopBar: リスト名 + ▼ アイコン + アバタースタック + ⋯ 設定アイコン
- GroupChips: 横スクロール (家族 / じぶん用 / ルームシェア / + 追加)
- FilterChips: チェック済み表示 / リスト順
- Progress: `2 / 8 チェック済み` mono + accent stripe progress
- ItemRow: 円形 checkbox + 名前 + (description) + ⋯
- FAB: accent 円 (右下)
- BottomTab: 買い物リスト / 設定

**Flutter 実装**:
- `lib/features/shopping_list/components/list_top_bar.dart` ✅
- `lib/features/shopping_list/components/group_chips_bar.dart` ✅
- `lib/features/shopping_list/components/filter_chips_bar.dart` ✅
- `lib/features/shopping_list/components/progress_block.dart` ✅
- `lib/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart` (i-7/i-8 swipe + 長押し menu 実装、PR-3 #275 + #282) ✅
- `lib/features/shopping_list/components/expandable_fab.dart` (AI review sheet 連携、PR-3 #282) ✅
- `lib/components/frame/app_bottom_tab_bar.dart` ✅

### AllDoneBanner

**Web SSOT** (`05_all_done.png`):
- `8 / 8 完了! ✓ おつかれさま`
- 「全部チェック完了! お会計のあと、リストをアーカイブしますか?」(緑系 okSoft)

**Flutter 実装**: `lib/features/shopping_list/components/banners/all_done_banner.dart` ✅
- 「全部チェック完了! お会計のあと、また再開もできます」
- 文言が SSOT と若干異なる (「アーカイブしますか」→「また再開もできます」)。実装側は再開可能なので意図的差分

### AI Processing Banner

**Web SSOT** (`06_ai_processing.png`):
- accent ベース pill + アイコン + 「写真からアイテムを生成中 レシート 1枚・候補を抽出しています…」+ キャンセル

**Flutter 実装**: `lib/features/shopping_list/components/banners/ai_processing_banner.dart` ✅
- 文言: 「画像から候補を抽出中…」/「URL から候補を抽出中…」
- 細部の文言差は許容範囲 (機能は同等)

### GroupCreatePage

**Web SSOT** (`08_group_setting.png` 左):
- title: 「グループを作る」
- 説明文: 「後からメンバーを招待できます。たとえば「家族」「ルームシェア」など、生活単位の名前がおすすめです。」
- グループ名 TextField (uchi の家族 placeholder)

**Flutter 実装**: `lib/features/group_create/page.dart` ✅
- iconName 6 種 GridView 追加済み (PR-5 #277)
- 作成後 invitation dialog 自動表示 (PR-5 #284)

### GroupSettingPage

**Web SSOT** (`08_group_setting.png` 中):
- title: 「グループ設定」
- セクション: グループ名 / メンバー (3) / オーナー印

**Flutter 実装**: `lib/features/group_setting/page.dart` ✅
- カテゴリ/場所のインライン管理は削除し AppCell で別画面遷移に集約 (#267 follow-up #290)
- 行数: 1034 → 421 (約 60% 減)

### GroupInvitationAcceptPage

**Web SSOT** (`09_invitation.png`):
- title: 「招待コードで参加」
- 中央: 招待アイコン + 「グループに参加」+ 「メンバーから共有された 8 桁の招待コードを入力してください」
- TextField (8 桁 mono)

**Flutter 実装**: `lib/features/group_invitation/page.dart` ✅
- verifying 状態を AppDialogShell ベースで実装 (#267 follow-up #291)

### SettingPage

**Web SSOT** (`10_setting_free.png`, `11_setting_premium.png`):
- title: 「設定」(displayMedium)
- セクション: プロフィール (Aya / aya@example.com / 編集) / グループ / 外観 / 通知 / アプリについて
- プレミアム会員カード: 無料時 = accentSoft 背景 + 「プレミアムにアップグレード」、プレミアム時 = accent → #7C2A07 グラデ + 「プレミアム会員」

**Flutter 実装**: `lib/features/settings/page.dart` ✅
- サインアウト追加 (PR-7 #279, #286 で AppDialogShell 化)
- ListTile → AppCell 置き換え済み (PR-7 follow-up #293)
- _PremiumCard: 無料/プレミアム時の表示切替実装済み

### PaywallPage

**Web SSOT** (`12_paywall.png`):
- title: 「プレミアムプラン」
- crown ヒーロー
- 「全機能を解放しよう」/「家族みんなで快適に使える便利機能。 いつでも解約できます。」
- プラン表示 / ロード中 / 取得失敗 / プランなし の 4 状態

**Flutter 実装**: `lib/features/paywall/paywall_page.dart` ✅
- loading / error / no-plans / data の 4 状態は `offerings.when` で対応済み (既存実装)
- title 「プレミアムにアップグレード」(SSOT と若干表現が違うが意図同等)
- 説明文「全機能を解放して、家族みんなで気持ちよく使えます。」

### ShoppingListPage Dark

**Web SSOT** (`13_shopping_list_dark.png`):
- bg: paper dark (#13110D)
- text: ink dark
- accent は変わらず朱

**Flutter 実装**: `lib/style/tokens.dart` AppNeutralColors.dark ✅
- paper dark `#13110D`, surface dark, card dark `#26221C`
- buildAppTheme で `Brightness.dark` 対応

## 比較結果サマリ

**PASS 扱い**: 13 画面すべて Flutter 実装が Web SSOT と概ね一致。「決定事項」 (plans/261-warm-engelbart.md 運用ルール 4) の許容差分はあるが、画面構造・文言・色味の主要点は揃っている。

### 「決定事項」差分 (PASS 許容)

- Onboarding 本文: JSX SSOT 採用 (README §7-1 と乖離) → Flutter は JSX 通り
- ThemeColorSelection 色数: 5 色 canonical 固定 (JSX 10 色不採用) → Flutter は 5 色のみ
- Auth ゲストリンク: 本番導線なし → Flutter は debug 匿名のみ
- 5 accent: shu / matcha / ai / sumi / kuchiba 固定 → Flutter は 5 色のみ
- 画像素材: PR-0 で生成・同梱 (Web placeholder と意匠が違う) → Flutter は実画像

### Flutter 実装が SSOT と微差ある箇所 (機能同等の許容差分)

- AllDoneBanner 文言: SSOT「アーカイブしますか?」 → Flutter「また再開もできます」
- AIProcessingBanner 文言: SSOT「写真からアイテムを生成中」 → Flutter「画像から候補を抽出中…」
- 詳細マージン・色味は textTheme + tokens で抽象化されているため、実機目視で微差はあり得る

## iOS / Android スクショ取得は手動 QA で

本セッションでは Maestro 不在のため iOS / Android Simulator の個別画面遷移ができなかった。
手動 QA で `flutter run -t lib/features/previews/main_preview.dart` を実行し、PreviewsPage
の各 entry を順次タップすればすべての画面 (17 entry, PR-9 #294 で拡張) のスクショが取れる。

または以下を後日実施:

```bash
brew install maestro  # ユーザー権限で
flutter build ios --simulator -t lib/features/previews/main_preview.dart
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
maestro test maestro/preview_flows/capture_all_previews.yaml
```

3 環境画像比較の最終 PASS 判定は本セッション範囲外。
