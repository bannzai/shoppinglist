# home_widget（iOSホームウィジェット同期）

## 概要
アプリの状態（テーマカラー・プレミアム状態・買い物リスト一覧・現在の買い物リストのアイテム）を
iOS/Android のホームウィジェット（`ShoppingListWidget`）が参照する共有ストレージ
（`home_widget` パッケージ経由の App Group UserDefaults）へ同期する機能。

## 画面
表示画面は持たない。`RootPage`（`lib/root.dart`）の Resolver chain に
`HomeWidgetSync` を配置し、表示ツリーの深さに依存せず全画面でバックグラウンド同期を行う。

## フロー
1. `AppEntityPrepareResolver` → `CurrentGroupResolver` を経て `HomeWidgetSync` がマウントされる。
2. 初回マウント時、`useEffect(const [])` で以下を無条件に一度だけ同期する:
   - `syncThemeColor`（テーマカラー）
   - `syncPremiumStatus`（プレミアム状態）
   - `syncShoppingLists`（買い物リスト一覧・現在のグループID）
   - 祖先の Resolver（`AppEntityPrepareResolver` など）が同じ Provider を先に
     `ref.watch` して既に `AsyncData` に解決済みの場合、`ref.listen` だけでは
     初回の Loading→Data 遷移を検知できないため、この初回同期が必須（Issue #475）。
3. 以降の変更は各 Provider への `ref.listen` で検知し、変更のたびに再同期する。
4. 現在の買い物リストのアイテム一覧（`syncCurrentShoppingListItems`）は
   `_HomeWidgetItemSync`（`resolvedShoppingListID` が確定した時のみマウント）が
   `textShoppingListItemsProvider` を `ref.listen` して同期する。
   このProviderは resolver chain 内で事前に watch されないため、`ref.listen` のみで
   初回分も正しく検知できる。

## データ形式
`HomeWidgetDataSync`（`home_widget_data_sync.dart`）が書き込むキー:
- `widget_theme_color_hex` / `widget_is_premium`
- `widget_shopping_lists`（JSON配列） / `widget_current_group_id`
- `widget_current_shopping_list_id` / `widget_current_shopping_list_name`
- `widget_items_{groupID}_{shoppingListID}`（JSON配列）
- `widget_total_count_{groupID}_{shoppingListID}` / `widget_done_count_{groupID}_{shoppingListID}`

## ウィジェット再描画（Issue #475 Root Cause 2）
`home_widget` の `updateWidget()` は iOS で `WidgetCenter.reloadTimelines(ofKind:)` しか呼ばず、
正しい kind を渡しても既に追加済みのウィジェットが再描画されないことがある。
一方、ウィジェット拡張自身が呼ぶ `WidgetCenter.shared.reloadAllTimelines()`
（`ToggleItemIntent.swift`）は確実に反映される。

このため `HomeWidgetDataSync.updateWidget()` は iOS のとき、`HomeWidget.updateWidget()` に加えて
`AppDelegate` に登録した MethodChannel（`com.bannzai.shoppinglist/home_widget_reload`）経由で
`reloadAllTimelines()` を追加で呼ぶ。バックグラウンド isolate 等チャンネル未登録のエンジンから
呼ばれた場合は `MissingPluginException` を無視し、`HomeWidget.updateWidget()` のみで続行する。
