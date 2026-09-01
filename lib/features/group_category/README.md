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

## グループメンバーからの取り込み

カテゴリはユーザーごとの所有を維持しつつ、カテゴリ一覧右上の取り込みボタンから、
同じグループに所属する別メンバーのカテゴリ軸を自分の設定へコピーできる。

- 他メンバーのカテゴリは読み取り専用で、元データを直接編集しない
- 取り込んだカテゴリは自分のカテゴリ軸に保存され、自分だけが編集・削除できる
- 元ユーザーID・元軸ID・元カテゴリIDから決定したDocument IDを使うため、同じ軸を再度取り込むと以前のコピーが更新される
- 元カテゴリの先頭順序が0でなくても、初回取り込みでは自分の既存カテゴリの直後から連続配置する
- 複数メンバーから取り込んだ後も、再取り込み対象のカテゴリブロックは現在位置を維持する
- 元側で削除されたカテゴリは再取り込み時に取込先からも削除される
- `locationOrders` もコピーする。参照先の買い物場所は元からグループ共有のため、位置情報機能を再度有効化した際も同じ並び順を利用できる

## 関連ファイル

- `page.dart` — カテゴリ一覧・空状態・追加/並び替え/削除
- `import_action.dart` — 別メンバーのカテゴリ設定を選択・取り込むダイアログ
- `category_empty_state.dart` — 空状態の価値訴求カード（`CategoryEmptyState`）
- `../group_category_edit/page.dart` — カテゴリ編集画面
- `../shopping_list/components/shopping_list_items/category_matcher.dart` — 自動分類（`findMatchingCategoryID`）・並び替え（`sortCategoriesByLocation`）
- `../../entity/group_category.dart` / `group_category_keyword.dart` / `group_category_axis.dart` — エンティティ
