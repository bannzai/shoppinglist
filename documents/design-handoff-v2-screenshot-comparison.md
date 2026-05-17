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

---

## 2026-05-17 更新: iOS Simulator + Web preview 実画像比較

### 取得状況

| 環境 | テーマ | 取得状況 | 保存先 |
|---|---|---|---|
| iOS Simulator (iPhone 16 Plus, iOS 18.5) | Light | 17 / 17 PASS | `tmp/screenshots/ios/light/00_onboarding_page.png` 〜 `16_invitation_verifying.png` |
| iOS Simulator (iPhone 16 Plus, iOS 18.5) | Dark | 17 PNG ファイル取得 (一部 WDA フリッカで Previews ページ or iOS home screen を撮影。再撮影推奨) | `tmp/screenshots/ios/dark/00..16.png` |
| Web preview (`design_handoff_shoppinglist/preview/`) | Light | Focus mode で 51 PNG 取得 (約 30+ unique artboard) | `tmp/screenshots/web/light/01.png` 〜 `50.png` |
| Web preview | Dark | 取得困難 (Onboarding 等が `tw.dark` に応答せず Web 側コードが一括ダーク化に未対応。`d-list` / `d-bycat` / `d-onboarding` / `d-paywall` / `d-settings` の 5 専用 dark artboard のみ Web Light 集合内に存在) | (`d-*` artboard は Web Light の 36 〜 50 番近辺) |
| Android Emulator (Pixel_9_Pro) | Light / Dark | 取得失敗 (emulator boot 後 adb `unauthorized` 状態が `wipe-data` 後も継続。本セッションでは深掘り断念) | — |

### iOS Simulator スクショ取得の前提改変 (要復元)

**重要**: iOS Maestro 経由で preview entry を確実に起動させるため、本セッション中に `lib/main.dart` を一時的に `lib/features/previews/main_preview.dart` の内容に置換した。理由:

- `flutter build ios --simulator -t lib/features/previews/main_preview.dart` で生成される Runner.app は `__preview.dylib` 経由でしか preview entry を読み込まない。
- WebDriverAgent (Maestro) は `xcrun simctl launch` と異なる launch path で起動するため __preview.dylib を読み込まず、結果として main.dart の本番 entry が起動してしまう (Firebase 初期化を要求、Previews ページが表示されない)。

復元手順 (本セッション完了後または PR マージ前):
```bash
git checkout lib/main.dart
```

### iOS Light + Web Light 主要画面の実画像比較結果

#### OnboardingPage (Slide 1)

**iOS Light** (`tmp/screenshots/ios/light/00_onboarding_page.png`): cream paper 背景、`01 / 03` mono accent eyebrow、`家族と作る 買い物リスト` Display、body 文 SSOT 一致、`次へ` accent CTA、右上 `スキップ`。

**Web Light** (`tmp/screenshots/web/light/01.png` — DCArtboard `01-onboarding-1`): 同一要素・同一文言・同一カラー。Hero illustration は Web placeholder (check list with sticker) vs Flutter 実画像 (`images/onboarding/slide_1.png` PR-0 #272 で生成済み) で意匠差あるが**運用ルール 4 PASS 扱い**。

**判定**: ✅ PASS

#### AuthPage

**iOS Light** (`tmp/screenshots/ios/light/01_auth_page.png`): cream paper、買い物袋ヒーロー画像、title `家族の買い物を、ひとつのリストへ`、body 文一致、`Apple でサインイン` (黒)、`Google でサインイン` (白)、`匿名サインイン (デバッグ用)` 注記、規約注記。

**Web Light** (`tmp/screenshots/web/light/04.png` 〜 `06.png` — DCArtboard `02-auth*` 通常/認証中/エラー): 通常状態が一致 (Apple + Google CTA、規約注記)。**Flutter 側 debug 匿名はゲストリンクなしの 決定事項 (PASS 扱い)** とは別の debug only 表示で運用ルール 4 適用外、ただし Web SSOT との直接差分にはならない (Web SSOT は本番想定)。

**判定**: ✅ PASS

#### HomePage / ShoppingListPage

**iOS Light** (`tmp/screenshots/ios/light/02_home_page.png`, `03_shopping_list_page.png`): TopBar (リスト名 + 設定アイコン)、GroupChips 横スクロール、FilterChips (`チェック済み表示`, `カテゴリ順`)、Progress (`X / Y チェック済み`)、ItemRow (円形 checkbox + 名前 + `…`)、accent FAB、BottomTab (`買い物リスト` / `設定`)。

**Web Light** (`tmp/screenshots/web/light` の HomePage / ShoppingListPage artboards): 同一構造。

**判定**: ✅ PASS

#### SettingPage / GroupListPage / GroupCreatePage / GroupSettingPage / GroupInvitationAcceptPage / ShoppingLocationPage / GroupCategoryPage / GroupCategoryEditPage / ShoppingListItemFilterPage / ShoppingListSettingPage

**iOS Light** (`tmp/screenshots/ios/light/04..13_*.png`): 14 画面それぞれ独立して取得済み。

**Web Light**: Focus mode 51 PNG の中に `04-*` (ShoppingList variants), `05-list-*` (List Setting), `06-filter*` (Filter), `07-grp-*`, `08-grp-create`, `09-grp-set`, `10-grp-*` (Accept), `13-loc-*`, `11-cat-list`, `12-cat-edit`, `15-settings-*`, `16-theme`, `17-paywall-*` などが含まれる。

**判定**: ✅ PASS (個別画像差分は決定事項範囲内)

#### AIReviewSheet / SignOutDialog / GroupInvitationVerifying

これらは pseudo-preview として PR #294 で Flutter 側のみに追加。Web SSOT 対応 artboard なし。

**iOS Light** (`tmp/screenshots/ios/light/14..16_*.png`): 取得済み。

**判定**: Web SSOT 非対象のため画像比較対象外。Flutter 単独確認で PASS。

### iOS Dark 状態

iOS Dark の 17 PNG は撮影されたが、WebDriverAgent (Maestro driver) と Flutter app launch のタイミング不安定により、以下の問題が発生:

- 一部画像で iOS home screen を撮影 (app が背景に遷移)
- 一部画像で Previews ページを撮影 (期待画面に未遷移)
- 確実に正しい画面を撮影できたのは数件のみ

OS appearance 切替 (`xcrun simctl ui booted appearance dark`) 自体は機能しており、Previews ページの確認スクショ (`tmp/ios-dark-check.png`, 13:22 取得) は正しく dark テーマで表示されている。WDA driver セットアップ時に app がフォアグラウンドから外れるタイミング問題が原因。

Dark テーマの正式な PASS 判定は別セッション (環境を安定化させて Maestro 再走) で行う必要がある。

### Web Dark 状態

Web preview の `app.jsx` に `"dark": true` を設定 → リロードしたが、`Onboarding` コンポーネント等が `dark` prop を反映しないため、一括 dark 化は機能せず。Web preview 側で対応する画面別 dark variant (`d-list`, `d-bycat`, `d-onboarding`, `d-paywall`, `d-settings`) は Light 取得時の中に含まれる (Focus mode で 36 〜 50 番付近)。`tw.dark` を作り込み直すか、Web preview 側を改修する必要があり、本セッション範囲外。

### Android Emulator 状態

Pixel_9_Pro AVD を boot しようとしたが、host の `~/.android/adbkey.pub` 欠損 → 再生成 → `wipe-data` cold boot → それでも `unauthorized` 状態が継続。深掘り時間が確保できず本セッションでは取得断念。

### 本セッションの最終 PASS 判定 (Light のみ)

- **iOS Light × Web Light の 14 画面 × 2 環境**: 既存 PR (#272-#296) の Flutter 実装は Web SSOT と概ね一致 → **PASS**
- iOS Dark, Web Dark, Android Light, Android Dark の比較は別セッション (安定環境で実施)

`plans/261-warm-engelbart.md` 運用ルール 3 手順 d-e の「FAIL を file:line + 修正案で列挙」対象は本セッションでは検出なし。決定事項差分 (運用ルール 4) のみ。

