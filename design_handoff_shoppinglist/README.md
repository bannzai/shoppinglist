# 買い物リストアプリ UI 実装 — 引き継ぎ書

## 1. 概要

家族・ルームシェア向けの共有買い物リストアプリの UI フル再設計です。中核となる ShoppingListPage は「リスト行そのものが TextField」というメモアプリ的な連続入力 UX を採用し、買い物中に毎回 FAB から追加モーダルを開かせない、軽い道具のような体験を目指しています。iOS / Android 両対応、ホーム画面ウィジェット、AI による写真・URL からのアイテム抽出、グループ共有、カテゴリ管理、店舗別並び順、プレミアム課金まで含む全 17 画面の完全な設計です。

## 2. 引き継ぎ物の取り扱いについて

このバンドルに含まれるファイル（特に `preview/` 配下）は **HTML/React で作成されたデザインリファレンス** です。見た目と挙動を示すプロトタイプであり、本番コードとしてそのまま使う想定ではありません。**対象アプリのコードベース（React Native / Flutter / SwiftUI / Jetpack Compose 等）の既存パターン・ライブラリで再現** してください。コードベースが未確定の場合は、家族で共有するモバイルアプリとして適切なフレームワークを選んで実装してください。

`preview/買い物リスト UI再設計.html` をブラウザで開くと、全 17 画面 + 状態 + ウィジェット + マイクロインタラクションが横にスクロールできるデザインキャンバスとして閲覧できます。

## 3. 制作精度

**High-fidelity (hifi)** — 配色・タイポグラフィ・余白・アイコン・コピー・状態を最終決定したピクセルパーフェクトのモックアップです。下記のトークンとレイアウト指示をそのまま実装してください。

論理サイズの基準は iPhone 14（390 × 844）です。Safe Area / Status Bar の高さは実機 OS から取得してください（モックでは固定値）。

---

## 4. ブランド原則とサーフェスの使い分け（重要）

このアプリには **2 種類の画面サーフェス** があります。**この使い分けが UI の核です**：

### 4-1. ShoppingListPage（中核画面・特殊な構造）

**NavBar / TabBar は紙色（`paper` / `surface`）、コンテンツ部（グループチップ・進捗・リスト）は白（`card`）** という **ハイブリッド構造** を採用します。

```
┌─────────────────────────────┐
│ NavBar  (status + title)    │ ← 紙色 #ECE5D3 系
├─────────────────────────────┤
│ Group chips (家族/じぶん用) │ ← 白 #FFFFFF
│ Filter chips                │ ← 白
│ Progress bar (3/8)          │ ← 白
│ ───────────────────────     │ ← 白（罫線で区切る）
│ ☐ 牛乳 1L                   │
│ ☑ 卵 10個入り (取消線)      │
│ ☐ トマト 4個                │
│ ...                         │
│ ☐ ＿＿＿＿＿ (空行・フォーカス) │
├─────────────────────────────┤
│ TabBar  (買い物リスト/設定) │ ← 紙色
└─────────────────────────────┘
```

**理由**：
- 買い物中に視線が集中するアイテムリストは白で視認性最優先
- 上下の chrome を紙色にすることで、ブランドカラーが画面外周に残り続け、「白い紙が温かい机の上に置かれている」イメージ
- StatusBar / Home Indicator 周辺も紙色のため、画面遷移時もブランドが消えない

### 4-2. その他すべての画面

**紙色を中心とした背景**（`paper` = #ECE5D3）で、カード・リスト要素のみ白（`card`）で浮かせます。これは iOS のグループ化リスト風の表現です。

対象：HomePage、SettingPage、OnboardingPage、AuthPage、GroupListPage / Create / Setting / InvitationAccept、CategoryPage / Edit、ShoppingLocationPage / Picker、ShoppingListSettingPage、FilterPage、PaywallPage、ThemeColorSelectionPage、すべての Dialog。

---

## 5. デザイントークン

### 5-1. Colors — Light

```
paper       #ECE5D3   アプリ全体の背景（暖色ベージュ／和紙）
surface     #F8F2E2   ShoppingListPage の NavBar / TabBar
surface2    #FFFCF3   入れ子の面・チップ背景
card        #FFFFFF   カード・ダイアログ・ShoppingListPage のコンテンツ部
ink         #1B1813   主要テキスト（墨）
ink2        #5A5246   副次テキスト
ink3        #948A77   キャプション・プレースホルダ
ink4        #BDB39E   非アクティブ・矢印アイコン
divider     #E0D5BC   1px 罫線
divider2    #EBE2C9   薄めの罫線
accent      #C2410C   朱（デフォルトアクセント）
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

### 5-2. Colors — Dark

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
accent      #E8743A
accentSoft  #3A2316
accentInk   #FCD7BB
```

### 5-3. Accent Presets — 和の伝統色 5 種

| キー       | Light    | Dark     | 名称（表示用） |
|-----------|----------|----------|---------------|
| `shu`     | `#C2410C`| `#E8743A`| 朱（**デフォルト**） |
| `matcha`  | `#1F6B4E`| `#6BB07F`| 抹茶 |
| `ai`      | `#0F4C81`| `#5FA0D6`| 藍 |
| `sumi`    | `#1B1B1B`| `#E8E5DD`| 墨 |
| `kuchiba` | `#B45309`| `#E0985A`| 朽葉 |

無料プランは `shu` 固定。プレミアムで切替可能。アクセント色は `accent` トークンとして全 UI（リスト・ボタン・進捗バー・チップ・カーソル・FAB）に伝搬します。

### 5-4. Typography

```
UI body          Noto Sans JP    400 / 500 / 600 / 700 / 800
Display 見出し   Zen Kaku Gothic New  700 / 800 / 900（class="serif"）
数値・コード      IBM Plex Mono   400 / 500 / 600（class="mono"、tnum 有効）

font-feature-settings: 'palt' 1   全文（和文ツメ）
```

| ロール | size | weight | line-height | letter-spacing |
|---|---|---|---|---|
| Display H1 | 28–38 | 800 | 1.15 | -0.02em |
| Page Title | 22–24 | 700 | 1.25 | -0.015em |
| Section heading | 17 | 700 | 1.3 | -0.01em |
| Body | 14–15 | 400–500 | 1.5–1.7 | 0 |
| Caption | 11.5–12 | 400 | 1.4 | 0 |
| Mono numeric | 11–14 | 500 | 1 | 0 (tnum) |

### 5-5. Spacing & Radius

```
Padding scale    2 / 4 / 6 / 8 / 10 / 12 / 14 / 16 / 18 / 20 / 24 / 32

border-radius
  pill / chip    999
  button         12 (small) / 14 (default) / 16 (CTA)
  card           14
  input field    12
  sheet / dialog 18
  Section card   14
```

### 5-6. Shadows

控えめ。FAB / ダイアログ / SnackBar 以外には基本的に影を載せません。

```
Light: 0 1px 0 rgba(27,24,19,0.05), 0 6px 18px rgba(27,24,19,0.04)
Dark:  0 1px 0 rgba(0,0,0,0.4),     0 6px 18px rgba(0,0,0,0.3)
```

---

## 6. デザイン原則（実装時に絶対に守ること）

1. **行 = TextField**。ShoppingList の各行をタップしたら即編集モード。フォーカスリングは出さない、カーソルだけ立つ。
2. **return で次行、空行 backspace で削除**。連続入力できることが核。
3. **共有はあるが監視しない**。メンバー通知は SnackBar で「全員 / 個別アバター」を能動選択。自動通知は設定で ON/OFF（既定 OFF）。
4. **AI は写真・URL のみ**。テキストの貼り付けは AI を介さず、改行で分割して即追加。AI バナーは写真・URL 系シートのみ。
5. **暮らしの色 · 朱**。紫グラデや業務 SaaS 風の配色を使わない。
6. **プレミアム導線は王冠（crown）アイコン + accent 色**。鍵（lock）は使わない。
7. **placeholder は道具的に**。「うちの買い物」「メモを書く...」のような家庭言葉。マーケ文言は使わない。
8. **役立たないアイコン・数値を出さない**。ダッシュボード化しない。

---

## 7. 画面一覧（全 17 画面 + 状態）

各画面は `preview/screens-*.jsx` に React コンポーネントとして実装されています。レイアウト・余白・コピー・状態の参照に使ってください。

### 7-1. OnboardingPage（3 スライド）

**サーフェス**：紙色（4-2）。
**構造**：上部に「スキップ」（右上 / `ink3` / 12px）→ 中央にイラストエリア（180×180 角丸 24 / `surface2` 背景 / 中央に大絵文字または抽象シェイプ）→ 下に H1（`serif` 28px / 800）+ 本文（`ink2` / 14px / line-height 1.7）→ 下端に 3 ドットページネーション + 「次へ」CTA（朱 / 56px / radius 14）。
**コピー**：
1. 「家族と作る、買い物リスト」 — メンバー全員でリアルタイムに共有・編集できる。
2. 「写真や URL から、まとめて追加」 — レシピ画像やネット記事を放り込むだけ。
3. 「いつもの並び順で、店舗を回る」 — カテゴリと店舗ごとに最適な順序で表示。最終スライドの CTA は「はじめる」。

### 7-2. AuthPage（通常 / loading-apple / error）

**サーフェス**：紙色。
- Apple / Google サインインボタン × 2、下に「ゲストとして使う」薄リンク。
- loading: ボタンの中身がスピナーに置き換わる、他は disabled。
- error: 上に DismissibleBanner（`dangerSoft` 背景 / `danger` テキスト / radius 12）。

### 7-3. HomePage（タブルート: list / settings）

- 下タブ 2 つだけ：「買い物リスト」「設定」。タブバーは紙色面 + 上罫線、12px ラベル。
- アクティブは accent 色のアイコン + 太字ラベル。

### 7-4. ShoppingListPage（中核 UX）★最重要

**サーフェス**：4-1 のハイブリッド構造。

**縦方向の構造**：

1. **NavBar**（紙色・h=48） — 左にリスト名（17px / 700 + ▼ ドロップダウン）、右にフィルタアイコン・︙メニュー
2. **境界線**（NavBar 下に 0.5px / `divider`）
3. **GroupChipsRow**（白・h=46） — 「家族」「じぶん用」「ルームシェア」「+ 追加」の横スクロールチップ群。アクティブチップは `accentSoft` 背景 + `accent` テキスト。
4. **FilterChips**（白・h=40） — 「チェック済み 表示/非表示」「リスト順/カテゴリ順」
5. **ProgressBlock**（白・h=72） — `mono` で `3/8` 大表示 + キャプション「チェック済み」+ プログレスバー（高さ 4 / `accent` / 240ms 補間）
6. **List body**（白・縦スクロール） — 各行は ItemRow（h=52）
7. **TabBar**（紙色・h=83 含む SafeArea）

**ItemRow（最重要コンポーネント）**

- 高さ 52px、左右 padding 20px。
- 左→右：チェックボックス（22×22 / radius 22 / 1.5px stroke）→ アイテム名 TextField（flex:1）→ 写真サムネ（オプション、40×40）→ ︙メニュー
- **行そのものが TextField**：タップで編集モード、フォーカス枠は出さず placeholder の `ink3` がインライン編集に切り替わる。
- **フォーカス時**：行背景に `accentSoft` を 40% 不透明で重ね、左端に 2px の `accent` ボーダー、カーソル `accent` 色（1.5px 幅、blink）
- **チェック済み**：テキスト `checked` 色 + 取り消し線（`ink4`）、チェックボックス内に `cat.color` で塗り + 白チェックマーク、200ms `pop` キーフレーム（scale 1 → 1.2 → 1）
- **末尾の空行**：常に 1 行用意。`return` で確定 + 新空行追加（自動スクロール）、空行 `backspace` で削除 + 前行末にフォーカス
- **ノート**：あれば 12px / `ink3` でアイテム名の下に折り返し表示
- **長押し**：複製 / メモ / 担当者割当 / 削除のコンテキストメニュー
- **左スワイプ**：削除（赤背景）
- **右スワイプ**：チェック切替

**FAB**

右下、56×56 円、`accent` 背景、`+` アイコン 26px。タップでボトムシート展開（spring 280ms）、4 アクション：
1. 「写真から追加」（AI バッジ）
2. 「URL から追加」（AI バッジ）
3. 「テキスト貼り付け」（AI 無）
4. 「空行を追加」（プライマリ）

**SnackBar（メンバー通知）**

下から 16px 上にフロート、左右 16px。`ink` 背景 + `surface` テキスト、radius 14。
- 「『牛乳』を追加 — 家族に通知しますか？」
- 右に個別メンバーアバター（最大 3、26×26、accent 色のリング） + 「全員に通知」ボタン（accent 背景）
- 5 秒タイマーで自動消滅、左スワイプで dismiss

**状態バリエーション**

| 状態 | 表示 |
|---|---|
| フラット表示 | 上記の基本構造 |
| カテゴリ順 | 「野菜・果物 (3)」のセクションヘッダ（`mono` 11px / `ink2` / 色ドット）を挟む |
| 0 件初期 | 空行 1 つフォーカス + 5 つの ghost 行 + ヒント box（surface2 + dashed border）|
| 全チェック済み | progress バー上に「✓ おつかれさま」、上部に緑のアーカイブ提案バナー（okSoft / 「お会計のあと、リストをアーカイブしますか?」）|
| AI 処理中 | progress 下に accentSoft バナー（wand アイコン + 「写真からアイテムを生成中」+ ストライプスピナー + キャンセル）、リスト末尾に shimmer 3 行 |
| エラー | 中央に dangerSoft カード（📡 + 「読み込めませんでした」+ 再試行ボタン）|
| 50 件超 + 無料 | progress 直下に薄いバナー（surface2 + 1px divider + crown + 「無料プランは作成から30日でリストが整理されます」+ 「詳しく」accent リンク）|

### 7-5. ShoppingListSettingPage（通常 / invite / delete dialog）

**サーフェス**：紙色。
- リスト名・アイコン編集
- メンバー管理（アバター + ロール）
- 自動通知 ON/OFF
- 並び順設定
- リスト削除（danger）

**招待コード dialog**：`mono` 8 桁コード（例 `X9KP-2H4M`）+ コピー / QR / 共有ボタン + 「7 日有効」キャプション。
**削除確認 dialog**：「リストを削除しますか？」+ 内容明記 + キャンセル / 削除（danger）。

### 7-6. FilterPage（通常 / カテゴリなし）

**サーフェス**：紙色。
- チェック済み非表示トグル
- カテゴリ複数選択（色ドット + 名前）
- 期日範囲
- 担当者
- カテゴリなし状態：「カテゴリが未登録です」+ カテゴリ作成への導線

### 7-7. GroupListPage（複数 / 無料上限）

**サーフェス**：紙色。
- グループカード一覧（アイコン + 名前 + メンバーアバター + リスト数）
- 末尾に「+ 新規グループ」CTA
- 無料 3 グループ超過時：crown + accent の「無料プランは最大 3 グループまで」バナー

### 7-8. GroupCreatePage

**サーフェス**：紙色。
- 名前入力 + アイコン選択（プリセット + AI 生成バッジ・プレミアム）
- 最初のメンバー招待（オプション）

### 7-9. GroupSettingPage（オーナー / メンバー）

**サーフェス**：紙色。
- メンバー一覧（オーナーには crown バッジ、自分には「自分」バッジ）
- 招待コード再生成
- グループ内リスト一覧
- グループ削除（オーナーのみ）

### 7-10. GroupInvitationAcceptPage（valid / invalid）

**サーフェス**：紙色。
- 招待コード入力（8 桁、`mono` 大表示、4-4 区切り）
- プレビュー（グループ名・メンバー数）
- 「参加する」CTA / 「不正コード」エラー表示

### 7-11. GroupCategoryPage

**サーフェス**：紙色。
- カテゴリ一覧（色ドット + アイコン + 名前 + キーワード件数）
- ドラッグハンドルで並び替え
- 「店舗ごとの並び順」プレミアムバナー（crown + accent）

### 7-12. GroupCategoryEditPage

**サーフェス**：紙色。
- 名前入力
- 色選択（9 色 + 「なし」）
- **アイコン選択**：プリセット 12 個 + 「未設定」タイル（カテゴリ名の先頭 1 文字を表示）+ 「AI 生成」タイル（accent / crown バッジ・プレミアム）。下に補足テキスト「未設定の場合はカテゴリ名の先頭1文字が表示されます。AI 生成はプレミアム機能です。」
- キーワード CRUD（部分一致 / 完全一致 / 正規表現）

### 7-13. ShoppingLocationPage（一覧 / 空 / 追加 dialog）

**サーフェス**：紙色。
- 店舗カード（名前 + 住所 + 距離）
- 右下 FAB で追加
- 追加 dialog：名前 + 住所検索 + 「現在地から選ぶ」

### 7-14. LocationPickerPage（通常 / loading）

**サーフェス**：紙色（地図エリアを除く）。
- 地図表示
- 住所検索バー
- 現在地ボタン
- 半透明オーバーレイで loading

### 7-15. SettingPage（無料 / プレミアム）

**サーフェス**：紙色。
- アカウント情報（アバター + 名前 + メール）
- テーマカラー行（行末に crown if 無料）
- 通知設定
- データエクスポート
- プラン（無料 / プレミアム）
- サインアウト
- アカウント削除（danger）

### 7-16. ThemeColorSelectionPage

**サーフェス**：紙色。
- 5 色のスウォッチを大きく並べる（円形、tap でプレビュー）
- 各スウォッチの下に和の伝統色名（`serif`）
- 無料ユーザーは `shu` 以外がロック表示（crown + accent）

### 7-17. PaywallPage（plans / loading / error）

**サーフェス**：紙色。
- 月額 / 年額 / 買い切りの 3 プラン横並び（実装時は縦の場合あり）
- 年額カードに「お得」バッジ（accent / serif）
- 機能比較表
- loading は価格部分のみシマー、その他は表示

---

## 8. インタラクション仕様

| 操作 | 効果 |
|---|---|
| ItemRow テキスト部タップ | TextField 編集モード（カーソルだけ立つ） |
| ItemRow チェックボックスタップ | 即チェック / 200ms ease-out で `scale 1 → 1.2 → 1`、テキスト取り消し線 120ms フェード |
| TextField `return` | 末尾に空行追加 + 自動スクロール + フォーカス移動 |
| 空行 `backspace` | 行削除 + 前行末にフォーカス |
| アイテム長押し | コンテキストメニュー（複製 / メモ / 担当者 / 削除） |
| 左スワイプ | 削除（赤背景） |
| 右スワイプ | チェック切替 |
| ヘッダー名タップ | リスト切替シート |
| FAB タップ | 4 メニューボトムシート（spring 280ms） |
| 写真・URL 選択 | AI 処理（リスト shimmer）→ 結果レビューシート（候補 ☑、編集可） |
| アイテム追加完了 | SnackBar フェードイン 180ms ease-out、5 秒自動消滅 |
| プレミアム機能タップ（無料） | PaywallPage を full-screen modal で push（300ms slide-up） |
| ダーク切替 | テーマ全体 200ms cross-fade |
| グループチップ切替 | リスト本体を 240ms slide-fade で差し替え |

### 8-1. 連続入力フロー（核）

1. ユーザがリストを開く → 末尾に必ず空行 1 つ（placeholder「メモを書く...」）
2. 空行タップ → カーソル（accent 色）が立つ。フォーカス枠なし
3. 「牛乳」と入力
4. `return` → 「牛乳」確定保存（debounce 300ms）、その下に新空行生成・即フォーカス
5. 「卵」「パン」と続けて入力
6. 空行で `backspace` → その空行が消え、前行末にカーソル移動

60fps 維持、保存は debounce で都度同期。

### 8-2. AI 処理フロー（写真 / URL）

1. FAB → 「写真から追加」→ カメラ or ライブラリ
2. 送信中：ListBody 上に accentSoft バナー（wand アイコン + 「画像から候補を抽出中…」）、shimmer 3 行が 1.6s loop
3. 結果到着：ボトム 60% にレビューシート（候補に ☑、カテゴリ自動判定、編集可）
4. 「追加する」で全候補をリストに即時追加 + SnackBar で件数表示

---

## 9. ドメインモデル

```typescript
type User = {
  id: string;
  displayName: string;
  email: string;
  avatarUrl?: string;
  plan: 'free' | 'premium';
};

type Group = {
  id: string;
  name: string;
  iconKey: string;
  ownerId: string;
  members: User[];
  inviteCode: string;       // 8 文字英数
  inviteCodeExpiresAt: Date;
  autoNotify: boolean;
  shoppingListIds: string[];
  categories: Category[];
  locations: Location[];
};

type ShoppingList = {
  id: string;
  groupId: string;
  name: string;
  sortOrder: 'manual' | 'category' | 'location';
  items: Item[];
  createdAt: Date;
  updatedAt: Date;
  archivedAt?: Date;
};

type Item = {
  id: string;
  listId: string;
  name: string;
  checked: boolean;
  categoryId?: string;
  assigneeId?: string;
  note?: string;
  photoUrl?: string;
  dueDate?: Date;
  position: number;
  createdBy: string;
  createdAt: Date;
};

type Category = {
  id: string;
  groupId: string;
  name: string;
  color: string;            // hex (CAT_PRESETS のいずれか + カスタム)
  iconKey: string | 'auto' | 'ai';   // 'auto' = 先頭1文字、'ai' = AI 生成画像
  keywords: { kw: string; mode: 'partial' | 'exact' | 'regex' }[];
  position: number;
};

type Location = {
  id: string;
  groupId: string;
  name: string;
  address: string;
  lat: number;
  lng: number;
  categoryOrder: string[];  // 店舗別カテゴリ並び順（プレミアム）
};

type Settings = {
  userId: string;
  theme: 'light' | 'dark' | 'system';
  accent: 'shu' | 'matcha' | 'ai' | 'sumi' | 'kuchiba';
  autoNotify: boolean;
  language: 'ja' | 'en';
};
```

### 9-1. リアルタイム同期

メンバー間の同期は必須です。Firestore / Supabase Realtime / Liveblocks のような高レベル抽象を推奨。アイテムの追加・編集・チェック・並び替えはすべてメンバーに即時反映されます。

### 9-2. 無料 / プレミアム制限

| 機能 | 無料 | プレミアム |
|---|---|---|
| グループ数 | 最大 3 | 無制限 |
| リスト保持期間 | 30 日 | 無期限 |
| テーマ色 | 朱固定 | 5 色から選択 |
| 位置情報リマインダー | × | ◯ |
| アイテム写真添付 | × | ◯ |
| AI 認識（写真/URL） | 月 5 回 | 無制限 |
| AI アイコン生成 | × | ◯ |
| 店舗別カテゴリ並び順 | × | ◯ |
| データエクスポート | × | ◯ |

---

## 10. ホーム画面ウィジェット

`preview/widgets-and-micro.jsx` 参照。

- **iOS Small (158×158)**：リスト名 + 残り件数（`mono` 大）+ 進捗バー。`paper` 背景。
- **iOS Medium (338×158)**：左サイドにリスト名・残数、右に未チェックアイテム上位 3 件（チェックボックス + アイテム名）。
- **iOS Large (338×354)**：medium の延長 + 上位 6–8 件 + プログレス + メンバーアバター。
- **Android (4×2 cell)**：Material You で動的色取り（accent からトーン展開）。

iOS 17+ Interactive Widget でウィジェットから直接チェック操作可能にしてください。

---

## 11. ファイル構成

```
design_handoff_shoppinglist/
├── README.md                              ← このファイル
└── preview/
    ├── 買い物リスト UI再設計.html         ← ブラウザで開ける全画面プレビュー
    ├── styles.css                         ← Web フォント・グローバル・class ユーティリティ
    ├── tokens.jsx                         ← LIGHT / DARK / ACCENT_PRESETS / mkTheme()
    ├── icons.jsx                          ← SVG アイコン辞書
    ├── frame.jsx                          ← Phone / AppBar / TabBar / Pill / RoundBtn / Checkbox / Chip / StatusBar
    ├── app.jsx                            ← デザインキャンバスの構成（実装する画面リストの目次として読める）
    ├── screens-onboarding.jsx             ← Onboarding / Auth / HomeRoot
    ├── screens-list.jsx                   ← ShoppingListPage 全状態 + ItemRow + FAB + SnackBar + ListShell
    ├── screens-list-settings.jsx          ← ShoppingListSettingPage + Filter
    ├── screens-groups.jsx                 ← Group 4 画面
    ├── screens-categories.jsx             ← Category 一覧 + 編集
    ├── screens-locations.jsx              ← Location 一覧 + Picker
    ├── screens-settings.jsx               ← Setting / Theme / Paywall
    ├── widgets-and-micro.jsx              ← iOS / Android ウィジェット + マイクロインタラクション
    ├── ios-frame.jsx, android-frame.jsx   ← デバイスフレーム（モック専用）
    ├── design-canvas.jsx                  ← デザインキャンバス（モック専用）
    └── tweaks-panel.jsx                   ← Tweaks パネル（モック専用）
```

`preview/screens-*.jsx` を **見た目のリファレンス** として読み、レイアウト・配色・余白・コピーを参照してください。`tokens.jsx` と `styles.css` の値は出典として優先使用してください。

## 12. アセット

このバンドルには本番用画像・写真は含まれません（プレースホルダのみ）。実装時に必要：

- アプリアイコン（`accent` 背景 + 「買」または抽象的な紙袋シェイプ）
- Onboarding 用イラスト × 3（別途用意）
- カテゴリプリセットアイコン（絵文字 / SF Symbols / Material Symbols いずれでも可）

Web フォントは Google Fonts から：`Noto Sans JP`、`Zen Kaku Gothic New`、`IBM Plex Mono`。

---

## 13. 実装の優先順位（推奨）

1. デザイントークン（colors / type / spacing / radius）を対象環境に移植
2. 共通コンポーネント：NavBar / TabBar / Chip / Pill / Checkbox / Icon / ListShell
3. **ShoppingListPage（中核）+ ItemRow + 連続入力フロー + リアルタイム同期**
4. Auth / Onboarding / HomePage
5. Group 系 4 画面 + 招待フロー
6. Category / Location 編集
7. AI 写真スキャン / URL 抽出
8. Setting / Theme / Paywall
9. ホーム画面ウィジェット（iOS / Android）
10. プッシュ通知 / バックグラウンド同期 / オフライン対応
