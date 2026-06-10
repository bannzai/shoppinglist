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
- カテゴリ未作成（フラット表示）でも、カテゴリ表示が有効なら表示する（AIがカテゴリ自体を新規作成）。
- カテゴリ表示OFF（`sortByCategory == false`）のときは表示しない。

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

## 入力行と空行のライフサイクル
入力行は `message=''` の `GroupShoppingListItem` ドキュメント。テキストはローカルの
`TextEditingController` に保持し、Enter（改行）で確定して別アイテムに保存する。

- 空行はフォーカスが外れた時に削除する（`text_shopping_list_item.dart` の FocusNode listener）。
  常駐する空入力行は残さない。
- フォーカス喪失時、入力途中のテキストがあれば確定保存する（空なら行を削除）。
- 連続入力（Enter連打）中は入力行にフォーカスが残るためキーボードは閉じず、空行も消えない
  （キーボード維持は fix-350 の設計を踏襲）。
- 再入力は FAB（`expandable_fab.dart`：タップで空行追加→auto-focus）または空状態のスターター行から。

## チェック済みフィルター
`FilterChipsBar` の「チェック済み表示/非表示」は `showChecked`（bool）を
`ShoppingListBodyContent → ShoppingListItems` と渡し、`textShoppingListItemsProvider` の
クエリ（`status==unchecked` 絞り込み）に反映する。

## アイテム詳細からのカテゴリ確認・編集
アイテム詳細シート（`text_shopping_list_item_detail_bottom_sheet.dart`）に、先頭軸
（`groupCategoryAxes.first`）で `findMatchingCategoryID`（`category_matcher.dart`）により判定した
現在の分類カテゴリを表示する。

- マッチ時:「カテゴリを編集」→ そのカテゴリの `GroupCategoryEditPage` へ遷移。
- 未分類時:「カテゴリを管理」→ `GroupCategoryPage`（一覧）へ遷移（キーワード追加で分類されるようになる）。
- 軸が無い（カテゴリ機能未使用）ときはカテゴリ行を表示しない。
