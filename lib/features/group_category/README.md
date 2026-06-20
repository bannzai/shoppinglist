# カテゴリ（GroupCategory）

## 概要

買い物アイテムを「野菜」「肉」などのカテゴリへ自動分類し、買い物リストをグループ分け表示するための機能。
カテゴリは **キーワード** を持ち、アイテム名（`item.message`）とキーワードを突き合わせて自動分類する。
さらに **買い物場所ごとにカテゴリの並び順を変えられる**（売り場の動線に合わせられる。プレミアム機能）。

本アプリのキラー機能であり、`GroupCategoryPage` がカテゴリの一覧・管理画面にあたる。

## 画面

| 画面 | 表示条件 | 操作内容 |
|---|---|---|
| カテゴリ一覧（`GroupCategoryPage`） | 通常 | カテゴリの追加・並び替え・編集・削除。買い物場所ごとの並び順切替（プレミアム） |
| カテゴリ選択モード（同上 / `selectionForItem != null`） | アイテム詳細から「カテゴリを変更/選択」で開いた時 | 行タップでアイテムを当該カテゴリへ移して pop（`MoveItemCategoryKeyword` による完全一致キーワードの付け替え）。新規カテゴリを追加してそのまま選ぶことも可能 |

## 空状態

カテゴリの価値（自動グループ分け・店ごとの並び替え）を初見ユーザーへ伝えるため、空状態では
`CategoryEmptyState`（`category_empty_state.dart`）で見出し・具体的ユースケースを表示する。
以下の2種類があり、両方で同じ `CategoryEmptyState` を使い回す。

| 空状態 | 条件 | 追加導線 |
|---|---|---|
| 初回空状態 | カテゴリ軸（`axes`）が0件 | `CategoryEmptyState` のカード内「＋ カテゴリを追加」ボタン（`onAddCategory` 非null） |
| カテゴリ0件 | 軸はあるがカテゴリが0件 | Scaffold の FloatingActionButton（`onAddCategory` は null でカード内ボタンは省略） |

## フロー（カテゴリ追加）

1. 空状態または FloatingActionButton から「カテゴリを追加」をタップ
2. 軸が無ければ「デフォルト」軸を自動作成（`_addCategoryWithAutoAxis`）
3. 空名のカテゴリを即座に作成し、`GroupCategoryEditPage` へ遷移（名前・色・アイコン・キーワードをまとめて設定）

## 関連ファイル

- `page.dart` — カテゴリ一覧・空状態・追加/並び替え/削除
- `category_empty_state.dart` — 空状態の価値訴求カード（`CategoryEmptyState`）
- `../group_category_edit/page.dart` — カテゴリ編集画面
- `../shopping_list/components/shopping_list_items/category_matcher.dart` — 自動分類（`findMatchingCategoryID`）・並び替え（`sortCategoriesByLocation`）
- `../../entity/group_category.dart` / `group_category_keyword.dart` / `group_category_axis.dart` — エンティティ
