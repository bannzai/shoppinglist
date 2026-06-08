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
  リスト上部に表示する「AIでカテゴリ分け（N件）」ボタン。
- `components/ai_categorize_preview_sheet.dart` (`showAICategorizePreviewSheet`): 分類結果を
  カテゴリ別に表示し、各候補のカテゴリ変更・除外ができる確認シート。

### 表示条件
`shopping_list_items.dart` で、未分類アイテムが1件以上あるときボタンを表示する。
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
