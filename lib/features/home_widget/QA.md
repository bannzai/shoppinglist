---
feature: home_widget
verification: mobile-mcp
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# home_widget QA

iOSホーム画面ウィジェット（WidgetKit, `ShoppingListWidget`）とアプリ間のデータ同期・操作を検証する。
ウィジェットの追加・操作はOSのホーム画面UIを介するため、アプリ内で完結するMaestroフローは無く
mobile-mcp（`/verify-ui-mobile-mcp` の手順）でのみ検証する。

## 1. ウィジェットの追加・表示

- [ ] **ホーム画面へのウィジェット追加**: iOS標準のウィジェットギャラリーから「ShoppingListWidget」を検索してホーム画面に追加すると、現在のグループの買い物リスト名とアイテム一覧、done/total件数が表示される。
  - ❌ 失敗: ウィジェット追加は成功し体裁（リスト名・アイテム一覧・done/total）は表示されるが、内容が現在のアカウントの実際のグループ/リストではなく、まったく無関係な古いリスト（"2026-06-10"）になっていた。`widget_current_group_id`/`widget_shopping_lists` が一度もアプリから同期されないことが原因（詳細はissue参照）。issue: https://github.com/bannzai/shoppinglist/issues/475
- [ ] **リスト・アイテム変更の同期**: アプリでアイテムを追加/チェック/削除すると、`HomeWidgetSync` によりウィジェットストレージが更新され、ウィジェットの表示内容とdone/total件数に反映される（タイムラインは最大15分毎の更新のため、即時反映されない場合はアプリ再起動やしばらく待っての確認が必要）。
  - ❌ 失敗: `flutter run` のログで `HomeWidgetDataSync.syncCurrentShoppingListItems` が正しいgroupID/shoppingListID/件数で呼ばれることを確認したが、アプリを再起動し数十秒待ってもホーム画面のウィジェットは一切再描画されなかった。issue: https://github.com/bannzai/shoppinglist/issues/475

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ホーム画面へのウィジェット追加**: iOS標準のウィジェットギャラリーから「ShoppingListWidget」を検索してホーム画面に追加すると、現在のグループの買い物リスト名とアイテム一覧、done/total件数が表示される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

ウィジェット追加直後。体裁は正しいが内容は現在のアカウントと無関係な古いリスト。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/03522bc5-4508-493f-9bae-15835254d6dc.png" width="320">

</details>

### **リスト・アイテム変更の同期**: アプリでアイテムを追加/チェック/削除すると、`HomeWidgetSync` によりウィジェットストレージが更新され、ウィジェットの表示内容とdone/total件数に反映される（タイムラインは最大15分毎の更新のため、即時反映されない場合はアプリ再起動やしばらく待っての確認が必要）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

アプリでリスト切替・アイテムを2/2までチェックした直後（ログ上は同期成功）。ウィジェットは変化なし。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/849fef31-77a9-488f-ad98-c3fa61f26fe8.png" width="320">

</details>

</details>

---

## 2. ウィジェットからの操作

- [ ] **ウィジェット上でのチェック切替とアプリへの同期**: ウィジェット内のアイテムをタップしてチェック状態を切り替えると（`homeWidgetBackgroundCallback`）、Firestore上のstatusが更新され、アプリを開いた際にも同じチェック状態が反映されている。
  - ❌ 失敗: ウィジェットをタップしたチェック切替自体（`ToggleItemIntent`経由）は即座に反映され動作した。ただし上記の同期不具合(#475)によりウィジェットが現在のアカウントと無関係な古いリストを表示しているため、「アプリを開いた際に同じチェック状態が反映される」対象データが現在のアカウントに存在せず、この観点の検証はブロックされている。issue: https://github.com/bannzai/shoppinglist/issues/475

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ウィジェット上でのチェック切替とアプリへの同期**: ウィジェット内のアイテムをタップしてチェック状態を切り替えると（`homeWidgetBackgroundCallback`）、Firestore上のstatusが更新され、アプリを開いた際にも同じチェック状態が反映されている。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

ウィジェット上の「milk」をタップ→即座にチェック済み表示・進捗バー反映（Firestore書き込み自体は成功）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/3a0dde91-e250-49e8-b516-858e8947f4e5.png" width="320">

</details>

</details>

---

## 3. ウィジェット設定（長押し編集）

- [ ] **表示リストの選択（プレミアム限定）**: プレミアムユーザーはウィジェットを長押し→編集で任意の買い物リストを選んで固定表示できる。非プレミアムでは選択肢が使えず、常にアプリで現在表示中のリストが使われる。
  - ❌ 失敗: プレミアム状態でウィジェット長押し→編集→「買い物リスト」を開いたところ、選択肢が現在のアカウントの実際のリスト（2件）ではなく、無関係な古いリスト「2026-06-10」1件のみだった。`widget_shopping_lists` が同期されない不具合(#475)が原因。issue: https://github.com/bannzai/shoppinglist/issues/475
- [x] **チェック済みアイテムの表示切替**: ウィジェット編集の「チェック済みアイテムを表示」設定をオフにすると、ウィジェットには未チェックのアイテムのみが表示される（done/totalの件数表示は全件基準のまま変わらない）。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **表示リストの選択（プレミアム限定）**: プレミアムユーザーはウィジェットを長押し→編集で任意の買い物リストを選んで固定表示できる。非プレミアムでは選択肢が使えず、常にアプリで現在表示中のリストが使われる。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

ウィジェット編集の「買い物リスト」選択肢。現在のアカウントの実際のリストが出てこず、無関係な古いリスト1件のみ表示。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/3d57d243-a551-4a8d-bd14-2950d8e9a287.png" width="320">

</details>

### **チェック済みアイテムの表示切替**: ウィジェット編集の「チェック済みアイテムを表示」設定をオフにすると、ウィジェットには未チェックのアイテムのみが表示される（done/totalの件数表示は全件基準のまま変わらない）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

「チェック済みを表示」をオフにすると、チェック済みの「milk」が非表示になり「carrot」のみ表示。done/total(1/2)の件数表示は変わらないことを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/b89a2504-6b68-493d-881a-d24adb8813ee.png" width="320">

</details>

</details>

---

## 4. テーマカラー・プレミアム状態の反映

- [ ] **テーマカラーの反映はプレミアム限定**: プレミアムでアプリのテーマカラー（5色プリセット）を変更するとウィジェットの配色にも反映される。非プレミアムでは変更してもウィジェットは常にデフォルトカラー（朱 #C2410C）で表示される。
  - ❌ 失敗: プレミアム状態でテーマカラーを「朱」→「藍」に変更。`flutter run`のログで`HomeWidgetDataSync.syncThemeColor`の実行を確認したが、ウィジェットのアクセントカラーは朱のまま変化しなかった。#475と同根（アプリ側からの`HomeWidget.updateWidget()`がウィジェットの再描画を起こせていない）。issue: https://github.com/bannzai/shoppinglist/issues/475

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **テーマカラーの反映はプレミアム限定**: プレミアムでアプリのテーマカラー（5色プリセット）を変更するとウィジェットの配色にも反映される。非プレミアムでは変更してもウィジェットは常にデフォルトカラー（朱 #C2410C）で表示される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

アプリのテーマカラーを「藍」に変更した後もウィジェットは朱のまま（ログ上はsyncThemeColor実行済み）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/0ac99fce-0fb7-45cf-b3aa-8c9db4ce4760.png" width="320">

</details>

</details>

---
