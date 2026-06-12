# shopping_list 機能

買い物リストのメイン画面（`page.dart`）と、アイテム表示・追加・AI連携の各コンポーネント。

## カテゴリ分類の仕組み（前提）
アイテム（`GroupShoppingListItem`）は **カテゴリIDを持たない**。表示時に各アイテムの `message` と
カテゴリ（`GroupCategory`）の `keywords` を `category_matcher.dart` の `groupItemsByCategory` で
マッチングし、グルーピングして表示する。どのキーワードにもマッチしないアイテムは「未分類」になる。

## AIによるカテゴリ分け

未分類アイテムを AI が「野菜」「肉」などのコーナーに分類し、プレビューで確認・調整して一括登録する機能。

### 画面・コンポーネント
- `components/ai_categorize_button.dart` (`AICategorizeButton`): 未分類アイテムがあるとき
  リスト上部に表示する「自動でカテゴリ分け（N件）」ボタン。
- `components/ai_categorize_preview_sheet.dart` (`showAICategorizePreviewSheet`): 分類結果を
  カテゴリ別に表示し、各候補のカテゴリ変更・除外ができる確認シート。

### 表示条件
`shopping_list_items.dart` で、未分類アイテムが1件以上あるときボタンを表示する。
- 入力中の空行（`message` が空のアイテム）は表示条件・件数カウントから除外する。
- カテゴリ未作成（フラット表示）でも表示する（AIがカテゴリ自体を新規作成）。

### フロー
1. ボタンをタップ。当月の残回数が0なら SnackBar（無料ユーザーはアップグレード導線）を出して終了。
2. `functions.categorizeShoppingListItems(itemNames, existingCategoryNames)` を呼ぶ
   （AI処理中バナーを表示）。サーバーは「アイテム名→カテゴリ名」の対応のみ返す。
3. プレビューシートで確認・調整（カテゴリ変更／除外）し「N件を登録」。
4. `aiCategorizeApplyProvider`（`AICategorizeApply`）で永続化:
   - 軸（`GroupCategoryAxis`）が無ければ「デフォルト」軸を作成
   - カテゴリ名に一致する既存カテゴリが無ければ作成
   - 各アイテム名を該当カテゴリの **完全一致キーワード** として追記（重複は無視）
5. Firestore のストリーム更新で、未分類アイテムが各カテゴリに移動して表示される。

### 登録方式
分類結果はアイテム名を **完全一致（`GroupCategoryKeywordMatchingType.exact`）キーワード** として
カテゴリに追記して永続化する。これにより既存のキーワード分類エンジンにそのまま乗り、今後同じ品名も
自動分類される。カテゴリ軸はユーザーごと（`groupCategoryAxes` が `userID` で絞り込み）のため、
登録結果は実行ユーザーのカテゴリ表示に反映される。

### 制約
- 認証必須。
- 月次利用上限: 無料5回 / プレミアム50回（UTC基準）。`aiUsage.categorizeCount` でカウント。
- 1リクエスト最大100アイテム、各100文字以下（サーバー側で制限）。

### 関連
- バックエンド: `firebase/functions/src/functions/categorizeShoppingListItems/`
- 利用回数: `lib/entity/ai_usage.dart` / `lib/provider/ai_usage.dart`（`remainingCategorizeCount`）
- プレビュー（UI検証）: `lib/features/previews/screens/ai_categorize_preview_sheet_preview.dart`

## 右下のダブル FAB
右下には 2 つのボタンを縦に並べる。

- 下（メイン・accent 塗り・鉛筆アイコン）: `expandable_fab.dart`（`ExpandableFab`）。
  タップで空行追加→auto-focus。長押しで写真 / URL / テキスト貼り付けメニューを展開。
- 上（白地・リスト+バッジの合成アイコン）: `create_list_fab.dart`（`CreateListFab`）。
  タップで「今日の日付でリストを追加 / 現在のリストを複製 / 未チェックのみ引き継いで複製」の
  3 メニューを上方向に展開する（展開中にもう一度タップで閉じる）。
  「今日の日付でリストを追加」は「リスト作成（日付名で自動命名）→ 作成リストへ切替 →
  空アイテム追加→auto-focus」まで連鎖し、新しい買い物の開始につなげる。無料プランの上限超過時は
  SnackBar（アップグレード導線付き）を表示する。複製は `ShoppingListDuplicate` に委譲し、
  完了後は複製先リストへ表示を切り替える。

両 FAB の展開メニュー（ラベルピル + 円形アイコンの行）は `fab_action_menu.dart`
（`FabActionMenu` / `FabMenuAction`）で共用する。

## 入力行と空行のライフサイクル
入力行は `message=''` の `GroupShoppingListItem` ドキュメント。テキストはローカルの
`TextEditingController` に保持し、Enter（改行）で確定して別アイテムに保存する。

- 空行はフォーカスが外れた時に削除する（`text_shopping_list_item.dart` の FocusNode listener）。
  常駐する空入力行は残さない。
- フォーカス喪失時、入力途中のテキストがあれば確定保存する（空なら行を削除）。
- 連続入力（Enter連打）中は入力行にフォーカスが残るためキーボードは閉じず、空行も消えない
  （キーボード維持は fix-350 の設計を踏襲）。
- 再入力は FAB（`expandable_fab.dart`：タップで空行追加→auto-focus）または空状態のスターター行から。

## チェック済み・カテゴリ表示の固定（Issue #373）
チェック済みアイテムは常に表示し、カテゴリ軸があれば常にカテゴリ順で表示する。
切り替えUI（`FilterChipsBar` / フィルター画面）は Issue #373 で廃止した。
`textShoppingListItemsProvider` は常に全件（チェック済み含む）を返す。

## カテゴリ表示の並び替え・カテゴリ間移動
カテゴリ表示時は、ヘッダーとアイテムを 1 つの `ReorderableListView`（`buildDefaultDragHandles: false`、
アイテム行のみ `ReorderableDelayedDragStartListener` でラップ）にフラットに並べ、長押しドラッグで
**同一カテゴリ内の並び替え** と **別カテゴリへの移動** の両方を行える。ヘッダーはドラッグ対象外、
入力行（空行）もドラッグ対象外。行モデル・ドロップ先カテゴリ判定・order 正規化は
`category_matcher.dart` の `buildGroupedRows` / `categoryIDForDropPosition` / `dropIndexInTarget` /
`itemsAfterMove` に切り出している。

- **order**: 移動のたびに、移動後の表示順（カテゴリ順 → カテゴリ内順）で全アイテムの `order` を
  0..N-1 に正規化し、`shoppingListItemBatchUpdateProvider` で永続化する。
- **カテゴリ間移動の永続化**: アイテムはカテゴリIDを持たない（`message` × キーワードで分類）ため、
  別カテゴリへ移したら `MoveItemCategoryKeyword`（`provider/group_category.dart`）で移動先カテゴリに
  `message` を完全一致(exact)キーワードとして追加し、移動先以外のカテゴリから同 exact を削除する
  （`keywordsAfterItemMove` が 1 カテゴリ分の付け替えを担う、transaction で read-modify-write）。
- **楽観的ローカル状態（ドロップ後のチラつき防止）**: `ReorderableListView` は `onReorder` 内で表示元
  データを同期更新する前提だが、本実装は永続化を Firestore stream 反映に委ねるため、そのままだと
  ドロップ後に一旦古い並びへ戻り（さらにカテゴリ間移動では order=batch とキーワード=transaction が
  二段で反映され）チラつく。これを防ぐため `_GroupedListView`（`HookConsumerWidget`）が `onReorder`
  時に楽観状態（`_OptimisticReorder`: 全アイテムの新 order と移動アイテムの分類上書き）を同期セットして
  即座に新しい並び・分類で描画し、stream が同じ状態に追いついたら（`_optimisticReflected`）破棄する。
  書き込み失敗時は破棄して永続化された実状態を表示する（ロールバック）。

### 既知の限界・副作用
- 同名（`message` が同じ）アイテムは一緒に移動する（キーワードは message 単位）。
- 手動の部分一致/正規表現でマッチしているアイテムは、移動先に exact を足しても元カテゴリの order が
  小さいと残るため、移動が効かない場合がある（分類エンジン `findMatchingCategoryID` は変更しない方針）。
- 表示されていない（アイテム 0 件の）カテゴリへはドラッグで移動できない（ヘッダーが無いため）。

フラット表示（`_FlatShoppingListItems`、カテゴリ軸なし）は従来どおり全体を `ReorderableList`
で並び替える（`reorderedSectionItems` を使用）。

### 検証
カテゴリ間ドラッグは widget test（`shopping_list_items_cross_category_test.dart`）で、実際に長押し
ドラッグを駆動して `onReorder` → カテゴリ判定 → `MoveItemCategoryKeyword` 呼び出しまでを検証する
（行中央は TextField のため、ドラッグ開始は行の左端を掴む）。判定・order・キーワード付け替えの各純粋
関数は単体テストで担保する。

## セクション（カテゴリ）単位の並び替え（Issue #386）
カテゴリ別グルーピング表示では、セクションヘッダー（`CategorySectionHeader`）を **長押しドラッグ**
するとセクション単位で並び替えできる。アイテム単位の D&D と同じ統合 `ReorderableListView` 上で、
掴んだ行がヘッダーならセクション並び替え、アイテムならアイテム移動として扱う。

- 並び順は `GroupCategory.order`（買い物場所選択時は `locationOrders`、プレミアム限定）へ
  `groupCategoryBatchUpdateProvider` で永続化され、カテゴリ管理画面（`group_category/page.dart`）の
  並び順と共有される。
- アイテムが0件で非表示のカテゴリは、元の相対順序を保ったまま並び直す
  （`category_matcher.dart` の `reorderCategorySections`。ヘッダーのドロップ位置→挿入先 index の
  変換は `sectionInsertIndexForHeaderDrop`）。
- 「未分類」セクションはカテゴリ実体が無いため常に末尾固定でドラッグ不可。カテゴリを未分類の
  下へドロップしても未分類の直前に収まる。
- ドロップ直後はアイテム移動と同様に楽観の表示順（カテゴリID列）を同期適用し、stream が
  追いついたら破棄する（チラつき防止）。失敗時は破棄してロールバック。
- ドラッグ中の proxy はヘッダー + 先頭アイテム（最大2件、`IgnorePointer` の表示専用プレビュー）で
  「セクションごと持ち上げた」見た目にする（`proxyDecorator`）。掴んだ瞬間（`onReorderStart`）に
  そのセクションのアイテム行はリストから畳み、proxy との二重表示を防ぐ。畳みの解除は、移動を
  伴うドロップは `onReorder` で楽観順の適用と同一フレーム、同位置ドロップ（`onReorder` が
  呼ばれない）は `onReorderEnd`、ポインタキャンセル（どちらも呼ばれない）は外側の
  `Listener(onPointerCancel)` が保険として行う。proxy のプレビューは別インスタンスのため、
  入力行の GlobalKey（fix-350）はセクションドラッグ中も二重化しない。
- E2E: `maestro/flows/category_section_reorder.yaml`（長押しドラッグは超低速 swipe で再現）。

## アイテムの説明 (description) と商品写真の一覧表示
アイテム詳細シートで「説明」（`description`・80文字以内）と商品写真（`imageURL`・プレミアム機能）を
設定できる。設定されている場合は一覧のアイテム行にも表示する。

- 説明: message の下に 1 行で省略表示（`ShoppingListItemDescriptionText`）。
  80文字制限は詳細シートの入力時のみ（既存の80文字超データは切り詰めない）。
- 商品写真: 行末の詳細アイコン（3点リーダー）の左に 36px のサムネイルで表示
  （`ShoppingListItemThumbnail`）。

## アイテム詳細からのカテゴリ確認・編集
アイテム詳細シート（`text_shopping_list_item_detail_bottom_sheet.dart`）に、先頭軸
（`groupCategoryAxes.first`）で `findMatchingCategoryID`（`category_matcher.dart`）により判定した
現在の分類カテゴリを表示する。

- マッチ時:「カテゴリを編集」→ そのカテゴリの `GroupCategoryEditPage` へ遷移。
- 未分類時:「カテゴリを管理」→ `GroupCategoryPage`（一覧）へ遷移（キーワード追加で分類されるようになる）。
- 軸が無い（カテゴリ機能未使用）ときはカテゴリ行を表示しない。
