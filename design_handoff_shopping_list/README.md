# Handoff: 買い物リスト UI 再設計（Shopping List App）

## Overview

家族・ルームシェア向けの共有買い物リストアプリの UI 全面再設計です。中核となる ShoppingListPage は「リスト行そのものが TextField」というメモアプリ的な連続入力 UX を採用し、FAB を毎回開かず素早くアイテムを追加できる、軽い「道具のような」体験を目指しています。iOS / Android 両対応、ホーム画面ウィジェット、AI による写真・URL からのアイテム抽出、グループ共有、カテゴリ管理、店舗別並び順、プレミアム課金まで含む完全なアプリ設計です。

全 17 画面 + 主要状態（loading / empty / error / all-done / 50件超 / SnackBar 表示など）+ iOS small/medium/large + Android のウィジェット + 主要マイクロインタラクションを 1 つのデザインキャンバスに並べています。

## About the Design Files

このバンドルに含まれるファイルは **HTML で作成されたデザインリファレンス** です。意図する見た目と挙動を示すプロトタイプであり、本番コードとしてそのままコピーする想定ではありません。タスクは、これらの HTML デザインを **対象コードベースの既存環境（React Native / Flutter / SwiftUI / Jetpack Compose 等）で、その確立されたパターンとライブラリを使って再現する** ことです。まだコードベースが存在しない場合は、プロジェクトに最も適したフレームワーク（家族で共有するモバイルアプリなので React Native / Flutter / 各ネイティブのいずれか）を選択して実装してください。

## Fidelity

**High-fidelity (hifi)** — 最終的な配色・タイポグラフィ・余白・アイコン・コピーまで決め込んだピクセルパーフェクトのモックアップです。配色（朱 #C2410C / 紙 #ECE5D3）、Noto Sans JP + Zen Kaku Gothic New + IBM Plex Mono のタイポ、各コンポーネントの border-radius・shadow・余白は意図したまま実装してください。ダークモード、5 色のシードカラー切替、Tweaks パネルでの動作も含みます。

iPhone のフレーム表現は 390 × 844（iPhone 14 程度）の論理サイズを基準にしています。SafeArea や StatusBar の高さは実機 OS から取得してください（モックでは固定値 47px / home indicator 34px）。

---

## Design Tokens

すべて `source/tokens.jsx` および `source/styles.css` に正規定義があります。実装時は対象環境のトークンシステム（CSS 変数 / Tailwind config / Flutter ThemeData / SwiftUI Color set）に移し替えてください。

### Colors — Light

```
paper       #ECE5D3   アプリ全体の背景（暖色ベージュ／和紙イメージ）
surface     #F8F2E2   画面ベース面
surface2    #FFFCF3   入れ子の面・チップ背景
card        #FFFFFF   カード・ダイアログ
ink         #1B1813   主要テキスト（墨色）
ink2        #5A5246   副次テキスト
ink3        #948A77   キャプション・プレースホルダ
ink4        #BDB39E   非アクティブ・矢印アイコン
divider     #E0D5BC   1px 罫線
divider2    #EBE2C9   薄めの罫線

accent      #C2410C   朱（デフォルト）
accentSoft  #FBE4D0   accent の背景帯
accentInk   #7C2A07   accent 上の濃いテキスト

ok          #2F6B43   成功・チェック済みインジ
okSoft      #DCEBDF
warn        #B47B1F
danger      #B53D3D
dangerSoft  #F4DEDB
checked     #A89E89   チェック済みアイテムのテキスト
shadow      0 1px 0 rgba(27,24,19,0.05), 0 6px 18px rgba(27,24,19,0.04)
```

### Colors — Dark

```
paper       #13110D
surface     #1B1813
surface2    #221E18
card        #26221C
ink         #F2EDE2
ink2        #BFB6A3
ink3        #847C6B
ink4        #5A5246
divider     #2A251F
divider2    #332D26

accent      #E8743A   ダークモードでは少し明るい朱
accentSoft  #3A2316   accent の暗背景帯
accentInk   #FCD7BB
```

### Accent Presets — 5 種（Tweaks / 設定で切替可能）

| Key       | Light    | Dark     | Soft (light) | Soft (dark) | 名称 |
|-----------|----------|----------|--------------|-------------|------|
| `shu`     | `#C2410C`| `#E8743A`| `#FBE4D0`    | `#3A2316`   | 朱（デフォルト） |
| `matcha`  | `#1F6B4E`| `#6BB07F`| `#DCEBDF`    | `#1F3325`   | 抹茶 |
| `ai`      | `#0F4C81`| `#5FA0D6`| `#D8E4F0`    | `#162B3E`   | 藍 |
| `sumi`    | `#1B1B1B`| `#E8E5DD`| `#E8E5DD`    | `#33302A`   | 墨 |
| `kuchiba` | `#B45309`| `#E0985A`| `#F6E1C9`    | `#3A2812`   | 朽葉 |

> プレミアム機能。無料は `shu` 固定。

### Typography

```
UI body          Noto Sans JP    400 / 500 / 600 / 700 / 800
Display 見出し   Zen Kaku Gothic New 700 / 900（class="serif"）
数値・コード     IBM Plex Mono   400 / 500 / 600（class="mono"、tnum 有効）

font-feature-settings: 'palt' 1   全文に適用（和文ツメ）
letter-spacing: -0.005 ~ -0.02    日本語表示時に強めに詰める（j-tight クラス）
```

タイポスケール（モバイル基準 / 1pt = 1px）

| ロール | size | weight | line-height | letter-spacing |
|---|---|---|---|---|
| Display H1 | 28–38 | 800 | 1.15 | -0.02em |
| Page Title | 22–24 | 700 | 1.25 | -0.015em |
| Section heading | 17 | 700 | 1.3 | -0.01em |
| Body | 14–15 | 400–500 | 1.5–1.7 | 0 |
| Caption | 11.5–12 | 400 | 1.4 | 0 |
| Mono numeric | 11–14 | 500 | 1 | 0 (tnum) |

### Spacing & Radius

```
Padding scale     2 / 4 / 6 / 8 / 10 / 12 / 14 / 16 / 18 / 20 / 24 / 32

border-radius
  pill / chip     999
  button          12 (small) / 14 (default) / 16 (CTA)
  card            14
  input field     12
  sheet / dialog  18
  Section card    14
```

### Shadows

ライト: `0 1px 0 rgba(27,24,19,0.05), 0 6px 18px rgba(27,24,19,0.04)`
ダーク: `0 1px 0 rgba(0,0,0,0.4), 0 6px 18px rgba(0,0,0,0.3)`

控えめ。フローティングしているもの（FAB / ダイアログ / SnackBar）以外には影を載せません。

---

## Design Principles（実装時に絶対に守るべきこと）

1. **買い物中の「見る・追加する・チェック」を最短に。** リスト行そのものが TextField。タップで即編集、return で次の空行へ移動しながら連続入力でき、空行で delete を押すとその行が消える（メモアプリ的）。
2. **片手・親指で届く UI。** 操作要素は AppBar 直下のチップと末尾の FAB に集約。スクロール中央に重要操作を置かない。
3. **共有はあるが監視しない。** メンバー通知は SnackBar で「家族に通知しますか？ 全員 / 個別アバター」の能動的な選択。自動通知は設定で ON/OFF 可能（既定 OFF）。
4. **AI は「写真・URL」のみ。** テキストの貼り付けや手入力は AI を介さず、改行で分割して即追加するシンプルな経路にする。AI バナーは写真・URL シートのみに表示。
5. **暮らしの色 · 朱。** デフォルトはあたたかい朱（#C2410C）。プレミアムで 5 色から選択可能。紫グラデや業務 SaaS 風の配色は使わない。
6. **placeholder text は道具的に。** 「うちの買い物」「メモを書く...」のような家庭言葉。マーケティング言葉や機能説明は使わない。
7. **役立たないアイコンや数値は出さない。** ダッシュボード化しない。

---

## 画面一覧（17 画面 + 状態）

`source/screens-*.jsx` にすべての画面が React コンポーネントとして定義されています。以下の各セクションは「source/app.jsx」で `<DesignCanvas>` 内に並べられている順です。

### 00 — Onboarding / Auth / Home

#### OnboardingPage（3 スライド）
- **目的**: 初回起動時にアプリの 3 つの価値を伝える。
- **構造**: 上部にスキップボタン（右上 / `ink3` / 12px）→ 中央にイラストプレースホルダ（180×180 角丸 24 / `surface2` 背景 / 中央に大絵文字または抽象シェイプ）→ 下に H1（`serif` 28px / 700）+ 本文（`ink2` / 14px / line-height 1.7）→ 下端に 3 ドットページネーション + 「次へ」CTA（朱 / 56px / radius 14）。
- **コピー**:
  1. 「家族と作る、買い物リスト」 — メンバー全員でリアルタイムに共有・編集できる。
  2. 「写真や URL から、まとめて追加」 — レシピ画像やネット記事を放り込むだけ。
  3. 「いつもの並び順で、店舗を回る」 — カテゴリと店舗ごとに最適な順序で表示。
- 最終スライドの CTA は「はじめる」。

#### AuthPage（通常 / loading-apple / error）
- Apple / Google サインインボタン × 2、下にメール（プレミアム表記なし、平等）。「ゲストとして使う」の薄いリンクを下端に。
- loading 状態: ボタンの中身がスピナーに置き換わる、他のボタン全体は disabled。
- error 状態: 上に DismissibleBanner（`dangerSoft` 背景 / `danger` テキスト / radius 12）でエラー文言。

#### HomePage（タブルート: list / settings）
- 下タブ 2 つだけ:「買い物リスト」「設定」。タブバーは紙色面 + 上罫線。アイコン + 12px ラベル。
- アクティブはアクセント色のアイコン + ラベル太字。

### 04 — ShoppingListPage（中核 UX）

これがアプリの心臓。状態と各サブコンポーネントを正確に再現してください。

**全状態共通の構造（縦方向）**
1. **ListTopBar** (h=52) — 左にリスト名（17px 700 + ▼）、右にアバタースタック（最大 3 + +N）+ 設定アイコン
2. **GroupChips horizontal scroll** (h=46) — 「家族」「じぶん用」「ルームシェア」等のグループ切替チップ
3. **FilterChips** (h=44) — 「並び替え」「カテゴリ順」「フィルター」「全選択」のチップ群
4. **ProgressBlock** (h=72) — `done / total` のタイポ + プログレスバー（朱 / 高さ 3）+ 残り件数キャプション
5. **List body** — 縦スクロール、各行 ItemRow
6. **FAB** — 右下 56px、写真・URL・スキャン・テキスト貼付の 4 メニュー

**ItemRow**（最重要コンポーネント）
- 高さ 52px、横余白 16px。
- 構成（左→右）: チェックボックス（24×24 / radius 6 / 1.5px stroke）→ アイテム名 TextField（flex:1、placeholder「メモを書く...」）→ カテゴリチップ（極小 / 最右）→ ドラッグハンドル（オプション）。
- 「行そのものが TextField」: タップで編集モード、フォーカス枠は出さない（無音）、placeholder の `ink3` がそのままインライン編集に切り替わる。
- チェック済み: テキスト `checked` 色 + 取り消し線、チェックボックス内 `accent` 塗りつぶし + 白チェック、`pop` キーフレーム（`scale 1 → 1.2 → 1`）でフィードバック。
- 末尾の空行（placeholder のみ）は常に 1 行用意。`return` キーで新しい空行が末尾に追加される。`backspace` で空行が削除される。
- カテゴリ別ビューでは「野菜・果物 (3)」のセクションヘッダ（`mono` 11px / `ink3`）が間に挿入される。

**FAB のメニュー**: タップでボトムシート展開。4 メニュー（写真からスキャン / URL から / テキスト貼付 / 既存リストから複製）。AI 動作する 2 つにのみ accent badge を付ける。

**SnackBar（メンバー通知）**
- 下から 16px 上にフロート、左右余白 16px。`card` 背景 + 角丸 14。
- 「『牛乳』を追加 — 家族に通知しますか？」+ 全員 / 個別アバターアイコンのトグル。
- 5 秒タイマーで自動消滅。手動 dismiss は左へのスワイプ。

**状態バリエーション**
- フラット表示 / カテゴリ順 / 全チェック済み（"完了!"の控えめテキスト + 全消去/再開ボタン）/ 0 件初期 / AI 処理中（行プレースホルダがシマー）/ エラー（インラインメッセージ）/ 50 件超（無料プラン保持期間バナー）。

**「無料プラン保持期間」バナー** （リスト最下部）
- `accentSoft` 背景 + 12px padding + radius 12。クラウン（王冠）アイコン（accent 色）+ 「無料プランは作成から 30 日でリストが整理されます」+ 「詳しく」（accent / 太字）。
- 「鍵」アイコンではなく **必ず crown** を使う（`source/icons.jsx` の `case 'crown'` 参照）。プレミアム導線はすべて crown + accent。

### 05 — ShoppingListSettingPage / Filter / Invite / Delete dialog

- リスト名・アイコン編集・メンバー管理・自動通知 ON/OFF・並び順設定・削除。
- 招待コード dialog: `mono` で 8 桁コード（例 `X9KP-2H4M`）+ コピーボタン + QR + 7 日有効。
- 削除確認 dialog: タイトル「リストを削除しますか？」+ 内容明記 + キャンセル / 削除（danger）。
- フィルターページ: チェック済み非表示・カテゴリ複数選択・期日範囲・担当者。

### 07 — Groups（4 画面）

- GroupListPage（複数 / 無料上限）: グループカード一覧、最後に「新規グループ」+ 「無料プランは最大3グループまで」バナー（crown / accent）。
- GroupCreatePage: 名前 + アイコン + 最初のメンバー招待。
- GroupSettingPage（オーナー / メンバー）: メンバー一覧（オーナー王冠バッジ）、招待コード再生成、リスト一覧、削除。
- GroupInvitationAcceptPage（valid / invalid）: コード入力 / プレビュー → 参加。

### 11 — Categories & Locations

- GroupCategoryPage: カテゴリ一覧（色ドット + アイコン + 名前 + キーワード件数）+ ドラッグ並び替え。「店舗ごとの並び順」プレミアムバナー（crown / accent）。
- GroupCategoryEditPage: 色（9 色 + 「なし」）+ アイコン（プリセット 12 個 + 「未設定」（先頭 1 文字表示）+ 「AI 生成」（accent / crown バッジ・プレミアム））+ キーワード CRUD（部分一致 / 完全一致 / 正規表現）。
- ShoppingLocationPage（複数 / 空 / 追加 dialog）: 店舗カード（名前 + 住所 + 距離）+ FAB で追加。
- LocationPickerPage（通常 / loading）: 地図表示 + 住所検索 + 現在地ボタン。

### 15 — Settings & Premium

- SettingPage（無料 / プレミアム）: アカウント、テーマカラー（行末に crown if 無料）、通知、データエクスポート、プラン、サインアウト、削除。
- ThemeColorSelectionPage: 5 色のスウォッチを大きく並べる。和の伝統色名表示。プレミアム以外はチェック不可。
- PaywallPage（plans / loading / error）: 月額 / 年額 / 買い切りの 3 プラン横並び。年額に「お得」バッジ（accent / serif）。loading は価格部分のみシマー。

---

## アイコン

`source/icons.jsx` の `Icon` コンポーネントが SVG を返します。実装時は対象プラットフォームのアイコンライブラリ（SF Symbols / Material Symbols / lucide / heroicons など）にマップしてください。stroke-width 1.7、24×24 viewBox。

主要アイコン: `chev-l/r/d/u`, `plus`, `x`, `check`, `more`, `search`, `bell`, `share`, `settings`, `trash`, `pencil`, `camera`, `link`, `clip`, `drag`, `wand`（AI / 4 角の輝き）, `qr`, `people`, `person`, `crown`（プレミアム / 王冠）, `info`, `arrow-r`, `eye`, `filter`, `sort`, `cart`, `marker`, `map`, `clock`, `calendar`, `bag`, `star`, `chefhat`, `sparkle`.

> **Important**: プレミアム導線は **必ず crown + accent 色**。`lock`（鍵）は使わない。

---

## Interactions & Behavior

| 操作 | 効果 |
|---|---|
| ItemRow タップ（テキスト部） | TextField 編集モード（フォーカスリングなし、cursor が立つ） |
| ItemRow チェックボックスタップ | 即座にチェック、`scale 1 → 1.2 → 1` 200ms ease-out、テキスト取り消し線フェード（120ms） |
| TextField で `return` | 末尾に空行追加 → そこへフォーカス移動（自動スクロール） |
| 空行で `backspace` | その行を削除し、前の行末にフォーカス |
| 空行で `tab` | カテゴリチップにフォーカス（任意） |
| アイテム長押し | コンテキストメニュー（複製 / メモ / 担当者割当 / 削除） |
| 横スワイプ（左） | 削除（赤背景） |
| 横スワイプ（右） | チェック切替 |
| ヘッダー名タップ | リスト切替シート |
| FAB タップ | 4 メニュー bottom sheet（spring 280ms） |
| 写真・URL 選択 | AI 処理画面（行のシマー）→ 結果のレビューシート |
| アイテム追加完了 | SnackBar フェードイン（180ms ease-out）、5 秒で自動消滅 |
| プレミアム機能タップ（無料） | PaywallPage を full-screen modal で push（300ms slide-up） |
| ダーク切替 | テーマ全体 200ms cross-fade |
| グループチップ切替 | リストを 240ms slide-fade で差し替え |

### 連続入力フロー（ShoppingListPage の核）

1. ユーザがリストを開く。末尾に必ず空の `placeholder="メモを書く..."` 行が 1 つある。
2. その行をタップ → cursor が立つ（フォーカスリングなし、UI 変化は cursor のみ）。
3. 「牛乳」と打つ。
4. `return` を押す → 「牛乳」の行が確定して保存、その下に新しい空行が生成・即フォーカス。
5. 「卵」「パン」と続けて入力。
6. 空行で `backspace` を押す → その空行が消え、前の「パン」の行末にカーソルが移動。

この流れを 60fps 維持、保存はデバウンス（300ms）で都度同期。

### AI 処理フロー（写真 / URL）

1. FAB → 「写真からスキャン」選択 → カメラ or ライブラリ。
2. 画像送信中: ListBody の上に占有 banner（accent / serif / wand アイコン）「画像から候補を抽出中...」、行プレースホルダ 6 行が `shimmer` 1.6s loop。
3. 結果到着: 候補レビューシート（ボトム 60% / 候補に ☑ / カテゴリ自動判定済み / 編集可）。
4. 「追加する」で全候補をリストに即時追加、SnackBar で件数表示。

---

## State Management

各画面コンポーネントは現状 props で状態を受けるピュア React です。実装時は次のドメイン状態が必要です:

```typescript
// User
type User = { id, displayName, email, avatarUrl, plan: 'free' | 'premium' };

// Group
type Group = {
  id, name, icon, ownerId, members: User[],
  inviteCode, autoNotify: boolean,
  shoppingListIds: string[], categories: Category[], locations: Location[],
};

// ShoppingList
type ShoppingList = {
  id, groupId, name, sortOrder: 'manual'|'category'|'location',
  items: Item[], createdAt, updatedAt,
};

type Item = {
  id, listId, name, checked: boolean, categoryId?, assigneeId?,
  note?, dueDate?, position: number, createdBy, createdAt,
};

type Category = {
  id, groupId, name, color: string, icon: string|'auto'|'ai',
  keywords: { kw: string, mode: 'partial'|'exact'|'regex' }[],
  position: number,
};

type Location = { id, groupId, name, address, lat, lng, categoryOrder: string[] };

// Settings
type Settings = {
  userId, theme: 'light'|'dark'|'system',
  accent: 'shu'|'matcha'|'ai'|'sumi'|'kuchiba',
  autoNotify: boolean, language: 'ja'|'en',
};
```

リアルタイム同期はメンバー間で必須（CRDT or operational transform、または Firestore / Supabase Realtime のような高レベル抽象を推奨）。

### 無料 / プレミアム制限
- 無料: グループ最大 3、リスト保持期間 30 日、テーマ色 = 朱固定、AI アイコン生成 不可。
- プレミアム: 全解放。

---

## ホーム画面ウィジェット

`source/widgets-and-micro.jsx` の `IOSWidget` / `AndroidWidget` を参照。

- **iOS Small (158×158)**: リスト名 + 残り件数（mono / 大）+ 進捗バー。背景 `paper`。
- **iOS Medium (338×158)**: 左サイドにリスト名・残数、右に未チェックアイテム上位 3 件（チェックボックス + アイテム名）。
- **iOS Large (338×354)**: medium の延長 + 上位 6–8 件 + プログレス + メンバーアバター。
- **Android (4×2 cell)**: Material You で動的色取り（accent からトーン展開）。

ウィジェットからのチェック操作は iOS 17+ 対応の Interactive Widget で。

---

## ファイル構成

```
design_handoff_shopping_list/
├── README.md                              ← このファイル
├── 買い物リスト UI再設計.html              ← 全画面プレビュー（ブラウザで開く）
└── source/
    ├── app.jsx                            ← デザインキャンバスの構成。実装する画面リストの目次として読める
    ├── tokens.jsx                         ← LIGHT / DARK / ACCENT_PRESETS / mkTheme()
    ├── styles.css                         ← フォント・グローバル・class ユーティリティ
    ├── icons.jsx                          ← SVG アイコン辞書
    ├── frame.jsx                          ← Phone / AppBar / TabBar / Pill / RoundBtn / Checkbox / Chip / StatusBar
    ├── screens-onboarding.jsx             ← Onboarding / Auth / HomeRoot
    ├── screens-list.jsx                   ← ShoppingListPage 全状態 + ItemRow + FAB + SnackBar
    ├── screens-list-settings.jsx          ← ShoppingListSettingPage + Filter
    ├── screens-groups.jsx                 ← Group 4 画面
    ├── screens-categories.jsx             ← Category 一覧 + 編集
    ├── screens-locations.jsx              ← Location 一覧 + Picker
    ├── screens-settings.jsx               ← Setting / Theme / Paywall
    ├── widgets-and-micro.jsx              ← iOS / Android ウィジェット + マイクロインタラクション図解
    ├── ios-frame.jsx                      ← iOS デバイスフレーム（モック用、実装には不要）
    ├── android-frame.jsx                  ← Android デバイスフレーム（同上）
    ├── design-canvas.jsx                  ← デザインキャンバス（同上）
    └── tweaks-panel.jsx                   ← Tweaks パネル（同上）
```

実装時は `source/screens-*.jsx` を **見た目のリファレンス** として読み、各画面のレイアウト・配色・余白・コピーを参照してください。`tokens.jsx` と `styles.css` は値の出典として優先使用してください。

## Assets

このバンドルには画像・写真アセットは含まれていません（プレースホルダのみ）。本番実装時に必要となるもの:

- アプリアイコン（朱 #C2410C 背景 + 「買」または抽象的な紙袋シェイプ）
- Onboarding 用イラスト × 3（ユーザ側で用意 or 外注）
- カテゴリプリセットアイコン（絵文字でもよい / SF Symbols / Material Symbols でも可）

フォントは Google Fonts から: `Noto Sans JP`, `Zen Kaku Gothic New`, `IBM Plex Mono`。

---

## 実装の優先順位（おすすめ）

1. デザイントークン（colors / type / spacing / radius）を対象環境に移植
2. 共通コンポーネント: AppBar / TabBar / Chip / Pill / Checkbox / Icon
3. ShoppingListPage（中核）+ ItemRow + 連続入力フロー + リアルタイム同期
4. Auth / Onboarding / HomePage
5. Group 系 4 画面 + 招待フロー
6. Category / Location 編集
7. AI 写真スキャン / URL 抽出
8. Setting / Theme / Paywall
9. ホーム画面ウィジェット（iOS / Android）
10. プッシュ通知 / バックグラウンド同期 / オフライン対応
