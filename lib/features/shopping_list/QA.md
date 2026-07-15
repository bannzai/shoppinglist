---
feature: shopping_list
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-15
---

# shopping_list QA

## 1. 表示状態・グループ切替

- [ ] **リストなし状態**: 買い物リストが 0 件のとき「買い物リストがありません」「新しい買い物リストを作成しましょう」と案内し、「買い物リストを作成」ボタンで空リストを 1 件作成する。無料上限超過時は上限 SnackBar（アップグレード導線付き）を出す
  - ⏭️ スキップ: `_NoListYet`（lib/features/shopping_list/page.dart:71-79）は `shoppingLists.isEmpty` の時に表示されるが、UI 上にリスト全体を削除する導線が無く（アイテム削除のみ）、グループ作成・招待参加は必ず 1 件目のリストを自動作成する（empty_shopping_list_create.yaml で確認済み）ため、通常操作では 0 件状態に到達できない。Firestore への直接ドキュメント削除は破壊的操作のため今回は実施せず、コードレビューでの表示ロジック確認に留めた
- [x] **空リスト状態のスターター行・ヒント**: アイテム 0 件のリストで「タップで入力開始」の空行、例文ゴースト行 5 件、「こんな風に使えます」ヒントカード（タップで入力 / return で次の行 / 空行で delete / 右下 FAB 長押しで写真・URL）を表示する（既存 E2E: maestro/flows/add_and_check_item.yaml）
- [x] **グループ切替チップ**: グループが 2 つ以上あるとき上部に横スクロールチップを表示し、タップで表示グループを切り替える（選択中はチェック付き）。グループが 1 つのときは非表示（既存 E2E: maestro/flows/empty_shopping_list_create.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **リストなし状態**: 買い物リストが 0 件のとき「買い物リストがありません」「新しい買い物リストを作成しましょう」と案内し、「買い物リストを作成」ボタンで空リストを 1 件作成する。無料上限超過時は上限 SnackBar（アップグレード導線付き）を出す

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: `_NoListYet`（lib/features/shopping_list/page.dart:71-79）は `shoppingLists.isEmpty` の時に表示されるが、UI 上にリスト全体を削除する導線が無く（アイテム削除のみ）、グループ作成・招待参加は必ず 1 件目のリストを自動作成する（empty_shopping_list_create.yaml で確認済み）ため、通常操作では 0 件状態に到達できない。Firestore への直接ドキュメント削除は破壊的操作のため今回は実施せず、コードレビューでの表示ロジック確認に留めた

</details>

### **空リスト状態のスターター行・ヒント**: アイテム 0 件のリストで「タップで入力開始」の空行、例文ゴースト行 5 件、「こんな風に使えます」ヒントカード（タップで入力 / return で次の行 / 空行で delete / 右下 FAB 長押しで写真・URL）を表示する（既存 E2E: maestro/flows/add_and_check_item.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/98b29954-e69e-445c-9003-0f60e566e2d0.png" width="320">

</details>

### **グループ切替チップ**: グループが 2 つ以上あるとき上部に横スクロールチップを表示し、タップで表示グループを切り替える（選択中はチェック付き）。グループが 1 つのときは非表示（既存 E2E: maestro/flows/empty_shopping_list_create.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/98b29954-e69e-445c-9003-0f60e566e2d0.png" width="320">

</details>

</details>

---

## 2. アイテムの追加・入力

- [x] **FAB タップで空行追加**: 右下 FAB（add_task アイコン）タップで空の入力行を 1 件追加し、自動フォーカスしてキーボードを開く（既存 E2E: maestro/flows/design_v2_list_core.yaml）
- [x] **Enter 連続入力**: 入力行で文字を入力し Enter（改行）で確定すると、確定アイテムが上に積まれ、入力行は空のまま末尾に残ってフォーカス・キーボードを維持し連続入力できる（既存 E2E: maestro/flows/shopping_list_enter_and_empty_row_removal.yaml）
- [x] **空行の自動削除**: 空の入力行からフォーカスが外れる、または空欄で Backspace を押すとその行を削除する。入力途中のテキストがあればフォーカス喪失時に確定保存する（既存 E2E: maestro/flows/add_and_check_item.yaml）
- [x] **キーボード閉じるツールバー**: アイテム入力でキーボード表示中、キーボード直上に「閉じる」ツールバーを出し、タップでフォーカスを外してキーボードを閉じる。キーボード表示中も FAB は表示し続け、タップ・長押しでキーボードを閉じる（空行追加はしない）（既存 E2E: maestro/flows/keyboard_close_toolbar.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **FAB タップで空行追加**: 右下 FAB（add_task アイコン）タップで空の入力行を 1 件追加し、自動フォーカスしてキーボードを開く（既存 E2E: maestro/flows/design_v2_list_core.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

design_v2_list_core.yaml は空リストの「タップで入力開始」起点で Enter 連続入力・スワイプを検証するのみで右下丸型 FAB（add_task アイコン）タップは検証していないため、mobile-mcp で個別に確認した（アイテム有りの状態で FAB タップ→新規空行「メモを書く…」が追加され自動フォーカス＋キーボード表示）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/6d657e90-4d9b-46c8-b62e-703ceb2f822e.png" width="320">

</details>

### **Enter 連続入力**: 入力行で文字を入力し Enter（改行）で確定すると、確定アイテムが上に積まれ、入力行は空のまま末尾に残ってフォーカス・キーボードを維持し連続入力できる（既存 E2E: maestro/flows/shopping_list_enter_and_empty_row_removal.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/596aae35-ab4e-4665-89e7-81db7f93f986.png" width="320">

</details>

### **空行の自動削除**: 空の入力行からフォーカスが外れる、または空欄で Backspace を押すとその行を削除する。入力途中のテキストがあればフォーカス喪失時に確定保存する（既存 E2E: maestro/flows/add_and_check_item.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

shopping_list_enter_and_empty_row_removal.yaml でフォーカス喪失時（スワイプでキーボードを閉じる）に空行「メモを書く…」が自動削除されることを確認（確定済みアイテムは残る）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/ecc92b19-e1ee-45f1-9ba0-e8dd09ed81c0.png" width="320">

</details>

### **キーボード閉じるツールバー**: アイテム入力でキーボード表示中、キーボード直上に「閉じる」ツールバーを出し、タップでフォーカスを外してキーボードを閉じる。キーボード表示中も FAB は表示し続け、タップ・長押しでキーボードを閉じる（空行追加はしない）（既存 E2E: maestro/flows/keyboard_close_toolbar.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

閉じる前:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/e02d3e30-1347-4fa1-ba04-f1c1574d31b6.png" width="320">

「閉じる」タップ後（キーボード閉・空行は残らず確定済みアイテムのみ）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/97d978d2-406a-4677-9e4a-61871ba7313d.png" width="320">

</details>

</details>

---

## 3. アイテムのチェック

- [x] **チェックボックスでチェック切替**: 行頭の円形チェックボックスをタップするとチェック / 解除が切り替わり、チェック時はポップアニメ + テキストに取り消し線 + checked 色になる。メッセージが空の行はタップ不可（既存 E2E: maestro/flows/add_and_check_item.yaml）
- [x] **右スワイプでチェック切替**: アイテムを右スワイプするとチェック状態がトグルし、行は残る。空行は右スワイプ無効（既存 E2E: maestro/flows/design_v2_list_core.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **チェックボックスでチェック切替**: 行頭の円形チェックボックスをタップするとチェック / 解除が切り替わり、チェック時はポップアニメ + テキストに取り消し線 + checked 色になる。メッセージが空の行はタップ不可（既存 E2E: maestro/flows/add_and_check_item.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/57a79d89-9edd-4419-b701-6e97c296f7d3.png" width="320">

</details>

### **右スワイプでチェック切替**: アイテムを右スワイプするとチェック状態がトグルし、行は残る。空行は右スワイプ無効（既存 E2E: maestro/flows/design_v2_list_core.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

design_v2_list_core.yaml のスワイプは通過確認のみだったため、mobile-mcp で「卵」行を右スワイプしチェック状態が 2/3 にトグルすることを個別に確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/ade0a238-1fcc-4859-a545-228646a5e108.png" width="320">

</details>

</details>

---

## 4. アイテムの編集・削除

- [x] **既存アイテムの編集確定**: 既存アイテムのテキストを編集し Enter で確定すると内容を更新し、末尾の入力行へフォーカスを移す（入力行が無ければ新規作成）。空にして Enter するとその既存アイテムを削除する
- [x] **左スワイプ削除 + Undo**: アイテムを左スワイプすると削除し、「アイテムを削除しました」SnackBar の「元に戻す」で復元できる（既存 E2E: maestro/flows/swipe_delete_item.yaml）
- [x] **詳細シートからの削除**: 詳細シート右上のゴミ箱アイコン →「このアイテムを削除しますか？」の確認 →「削除」でアイテムを削除しシートを閉じる（「キャンセル」で閉じる）（既存 E2E: maestro/flows/item_detail_and_delete.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **既存アイテムの編集確定**: 既存アイテムのテキストを編集し Enter で確定すると内容を更新し、末尾の入力行へフォーカスを移す（入力行が無ければ新規作成）。空にして Enter するとその既存アイテムを削除する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

編集確定（「牛乳」→「牛乳2本」、末尾の空行へフォーカス移動）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/b97382de-7f9d-4a17-9a26-58331fc872df.png" width="320">

空にして Enter → アイテム削除:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/acc8aef8-e87b-494d-a3aa-1db9a8949a8a.png" width="320">

</details>

### **左スワイプ削除 + Undo**: アイテムを左スワイプすると削除し、「アイテムを削除しました」SnackBar の「元に戻す」で復元できる（既存 E2E: maestro/flows/swipe_delete_item.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/819df1c3-7999-4072-af5b-ac889ac33178.png" width="320">

</details>

### **詳細シートからの削除**: 詳細シート右上のゴミ箱アイコン →「このアイテムを削除しますか？」の確認 →「削除」でアイテムを削除しシートを閉じる（「キャンセル」で閉じる）（既存 E2E: maestro/flows/item_detail_and_delete.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/a6af27bd-28d9-4316-b182-7c2d746d29af.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/d71e3527-1f6d-42b4-a152-3d8e553fe51a.png" width="320">

</details>

</details>

---

## 5. アイテム詳細・カテゴリ割り当て

- [x] **詳細シート表示**: 行末尾の詳細アイコン（more_horiz）でアイテム名・カテゴリ・削除のシートを開く。説明・写真・カラーの編集項目は表示しない（既存 E2E: maestro/flows/item_detail_and_delete.yaml）
- [x] **カテゴリの確認・変更**: カテゴリ軸があるとき、現在の分類カテゴリ（未分類含む）を表示し「カテゴリを選択 / 変更」でカテゴリ選択画面へ遷移してアイテムを割り当てる。未分類の確定済み行に出る「カテゴリ +」チップからも割り当てられる。軸が無いときはカテゴリ行を表示しない（既存 E2E: maestro/flows/category_select_from_item.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **詳細シート表示**: 行末尾の詳細アイコン（more_horiz）でアイテム名・カテゴリ・削除のシートを開く。説明・写真・カラーの編集項目は表示しない（既存 E2E: maestro/flows/item_detail_and_delete.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

カテゴリ軸が無いグループでの詳細シート（説明・写真・カラーなし、カテゴリ行も非表示）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/a6af27bd-28d9-4316-b182-7c2d746d29af.png" width="320">

カテゴリ軸があるグループでの詳細シート（カテゴリ行「飲料」+「カテゴリを変更」表示）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/2ad408e9-3f4f-4fad-b267-d4f20f5b9f4e.png" width="320">

</details>

### **カテゴリの確認・変更**: カテゴリ軸があるとき、現在の分類カテゴリ（未分類含む）を表示し「カテゴリを選択 / 変更」でカテゴリ選択画面へ遷移してアイテムを割り当てる。未分類の確定済み行に出る「カテゴリ +」チップからも割り当てられる。軸が無いときはカテゴリ行を表示しない（既存 E2E: maestro/flows/category_select_from_item.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

未分類 → 「カテゴリを選択」→ 「飲料」選択 → 割り当て後は「カテゴリを変更」表示、リストは「飲料」セクションに移動:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/2ad408e9-3f4f-4fad-b267-d4f20f5b9f4e.png" width="320">

</details>

</details>

---

## 6. 並び替え・カテゴリ間移動

- [ ] **アイテムの並び替え**: 確定アイテム行を長押しドラッグで並び替えでき、順序が保存される。入力行（空行）はドラッグ対象外
  - ⏭️ スキップ: maestro の低速 swipe（duration 10000ms、category_section_reorder.yaml と同じ技法）をアイテム行に対して x=1%/6%/30% の複数位置・selector 指定 swipe・flat 表示/カテゴリ表示の両方で試したが、いずれも並び替えが一切発火しなかった（表示順が完全に不変）。同じ技法でセクションヘッダーの並び替えは成立する（下記セクション並び替え参照）ため、ツール側の技法自体は有効。コード上、アイテム行は `Dismissible`（横方向ドラッグ判定）が `ReorderableDelayedDragStartListener`（長押し並び替え）の外側にラップされており（text_shopping_list_item.dart:319-327,425）、ヘッダー行にはこの `Dismissible` ラップが無い（category_section_header.dart 相当箇所）。ジェスチャ競合が自動化タップで長押し判定を阻害している可能性があるが、実機・実指での挙動は未検証のためアプリのバグと断定はできない。実機での長押しドラッグ動作を手動確認するか、mobile-mcp/maestro 以外の手段での再検証を推奨する
- [ ] **カテゴリ間移動**: カテゴリ表示時、アイテムを別カテゴリのセクションへドラッグすると移動先カテゴリへ分類が変わり（完全一致キーワードの付け替え）、順序も保存される
  - ⏭️ スキップ: 上記「アイテムの並び替え」と同じ理由（アイテム行の長押しドラッグが自動化操作で発火しない）により検証できなかった
- [x] **セクション並び替え**: カテゴリのセクションヘッダーを長押しドラッグでセクション単位に並び替えできる。「未分類」セクションは常に末尾でドラッグ不可（既存 E2E: maestro/flows/category_section_reorder.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **アイテムの並び替え**: 確定アイテム行を長押しドラッグで並び替えでき、順序が保存される。入力行（空行）はドラッグ対象外

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 上記チェック項目欄に理由を記載

</details>

### **カテゴリ間移動**: カテゴリ表示時、アイテムを別カテゴリのセクションへドラッグすると移動先カテゴリへ分類が変わり（完全一致キーワードの付け替え）、順序も保存される

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 上記チェック項目欄に理由を記載

</details>

### **セクション並び替え**: カテゴリのセクションヘッダーを長押しドラッグでセクション単位に並び替えできる。「未分類」セクションは常に末尾でドラッグ不可（既存 E2E: maestro/flows/category_section_reorder.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

肉/乳製品/未分類の順から、肉セクションを長押しドラッグして乳製品と入れ替え、さらに未分類を先頭へドラッグしても末尾に固定されたままであることを確認:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/2438516a-59ee-41a4-94e5-400a8ecd2042.png" width="320">

</details>

</details>

---

## 7. AI 自動カテゴリ分け

- [x] **ボタン表示・分類プレビュー・登録**: 未分類アイテムが 1 件以上あるときリスト上部に「自動でカテゴリ分け（N 件）」ボタンを表示（入力中の空行は件数から除外）。タップ → AI 処理（処理中バナー）→ プレビューシートでカテゴリ変更・除外 →「N 件を登録」で分類を永続化しアイテムが各カテゴリへ移動、「N 件をカテゴリに登録しました」SnackBar を出す
- [ ] **利用上限**: 当月の残回数が 0 のとき「自動カテゴリ分けの月間利用回数（N 回）に達しました」SnackBar を出す（無料はアップグレード導線付き。プレミアムは開発者オプション →「プレミアム付与（1 日）」で付与して確認）
  - ⏭️ スキップ: 無料上限（5回/月、firebase/functions/src/functions/categorizeShoppingListItems/function.ts:31）に達するまで実際に5回連続でボタンを実行し全て成功（りんご→果物、キャベツ→野菜(新規)、にんじん→野菜、ティッシュ→日用品(新規)、歯ブラシ→日用品）、6回目（シャンプー）をタップしたが SnackBar・処理中バナー・エラーいずれも一切表示されず、アイテムも未分類のまま変化しなかった。座標変更・アプリ再起動・ログストリーム確認を行ったが原因を特定できず、自動化タップが届いていないのか実際に無反応なのか切り分けできなかった。手動での実機確認を推奨する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ボタン表示・分類プレビュー・登録**: 未分類アイテムが 1 件以上あるときリスト上部に「自動でカテゴリ分け（N 件）」ボタンを表示（入力中の空行は件数から除外）。タップ → AI 処理（処理中バナー）→ プレビューシートでカテゴリ変更・除外 →「N 件を登録」で分類を永続化しアイテムが各カテゴリへ移動、「N 件をカテゴリに登録しました」SnackBar を出す

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

未分類「みかん」→「自動でカテゴリ分け」タップ→AI が既存カテゴリ「果物」を提案→登録後 果物 セクションへ移動:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/d546f2bd-e672-40ac-90a5-887e0c0ac4bb.png" width="320">

未分類「キャベツ」→AI が新規カテゴリ「野菜」を提案するプレビューシート:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/5845714c-11f0-47b6-98b1-8e20a973c312.png" width="320">

</details>

### **利用上限**: 当月の残回数が 0 のとき「自動カテゴリ分けの月間利用回数（N 回）に達しました」SnackBar を出す（無料はアップグレード導線付き。プレミアムは開発者オプション →「プレミアム付与（1 日）」で付与して確認）

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 上記チェック項目欄に理由を記載

</details>

</details>

---

## 8. 写真・URL からの追加（AI 抽出）

- [ ] **FAB 長押しメニュー**: FAB 長押しで「写真から追加 / URL から追加 / テキスト貼り付け」メニューを上方向に展開する。AI 処理中は写真・URL 項目を無効化する。「テキスト貼り付け」はクリップボードの複数行を行ごとに追加（空行・既存と同名はスキップ）
  - ⏭️ スキップ: FAB（右下丸ボタン）の通常タップは正常に空行追加が発火する（座標検証済み）が、長押しではメニューが一切開かなかった。mobile-mcp の長押し（500ms/1500ms）、maestro `longPressOn`（既定 duration）、maestro の低速 swipe（開始・終了をほぼ同座標にして duration 3000ms、category_section_reorder.yaml で有効実績のある技法）の3手法すべてで再現せず。コード上は `GestureDetector(onLongPress: ...)` で FloatingActionButton をラップするだけのシンプルな実装（lib/features/shopping_list/components/expandable_fab.dart:165-193）で、他の長押しドラッグ系（セクション6参照）と異なり競合するジェスチャも無い。自動化ツール側の既知の制限か実際の不具合かを切り分けられなかった。実機・実指での長押し動作を手動確認することを推奨する
- [ ] **写真 / URL から追加**: 「写真から追加」→ カメラ / フォトライブラリ選択、「URL から追加」→ HTTPS URL 入力 →「生成」で、いずれも AI 抽出（処理中バナー）→ review sheet で候補を選んで追加する。候補が空でも review sheet に「候補がありませんでした」を表示する。空・非 HTTPS の URL はトーストで弾く（既存 E2E: maestro/flows/design_v2_ai_review.yaml）
  - ⏭️ スキップ: 上記「FAB 長押しメニュー」が開けないため、写真/URL 追加フローの入口に到達できず検証不能。既存 E2E（design_v2_ai_review.yaml）も同じ長押しステップが `optional: true` で警告のみ（Warning: Element not found）となり、実質的に URL 入力ダイアログ到達を検証できていない
- [ ] **AI 利用上限（画像 / URL）**: 画像 / URL 読み取りの月間上限に達すると「〇〇読み取りの月間利用回数（N 回）に達しました」SnackBar を出す（無料はアップグレード導線付き）（既存 E2E: maestro/flows/ai_image_recognition_limit.yaml, maestro/flows/ai_url_recognition_limit.yaml）
  - ⏭️ スキップ: 上記と同じ理由（FAB 長押しメニューに到達できない）に加え、既存 E2E 2本は design v2 移行前の UI（`id: "popup_menu_button"`）を参照する stale flow だった（全ステップ `optional: true` のため警告のみで見かけ上パスする）。`grep -rn "popup_menu_button" lib/` は 0 件で、現行コードに同 id の要素は存在しない。同じパターンの stale flow が他に premium_ai_image_recognition.yaml, premium_ai_url_recognition.yaml, design_v2_groups.yaml, design_v2_list_settings.yaml, design_v2_category_location.yaml にもあり（詳細は root QA.md 参照）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **FAB 長押しメニュー**: FAB 長押しで「写真から追加 / URL から追加 / テキスト貼り付け」メニューを上方向に展開する。AI 処理中は写真・URL 項目を無効化する。「テキスト貼り付け」はクリップボードの複数行を行ごとに追加（空行・既存と同名はスキップ）

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 上記チェック項目欄に理由を記載

</details>

### **写真 / URL から追加**: 「写真から追加」→ カメラ / フォトライブラリ選択、「URL から追加」→ HTTPS URL 入力 →「生成」で、いずれも AI 抽出（処理中バナー）→ review sheet で候補を選んで追加する。候補が空でも review sheet に「候補がありませんでした」を表示する。空・非 HTTPS の URL はトーストで弾く（既存 E2E: maestro/flows/design_v2_ai_review.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 上記チェック項目欄に理由を記載

</details>

### **AI 利用上限（画像 / URL）**: 画像 / URL 読み取りの月間上限に達すると「〇〇読み取りの月間利用回数（N 回）に達しました」SnackBar を出す（無料はアップグレード導線付き）（既存 E2E: maestro/flows/ai_image_recognition_limit.yaml, maestro/flows/ai_url_recognition_limit.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 上記チェック項目欄に理由を記載

</details>

</details>

---

## 9. リストの作成・複製・切替

- [x] **リスト追加メニュー**: 上部バー右の「リストを追加」ボタンで「今日の日付でリストを追加 / 現在のリストを複製 / 未チェックのみ引き継いで複製」メニューを開く。「今日の日付でリストを追加」は日付名リスト作成 → 切替 → 空アイテム追加 → フォーカスまで連鎖する。複製は各アイテム（未チェックのみ含む）を引き継いだリストを作成し複製先へ表示を切り替える（既存 E2E: maestro/flows/shopping_list_crud.yaml, maestro/flows/shopping_list_name_sequence.yaml）
- [x] **リスト切替シート**: 上部バーのリスト名（▼）タップで切替シートを開き、選択中リストにチェックマーク、末尾の「+ 新しいリストを追加」で新規作成して切り替える

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **リスト追加メニュー**: 上部バー右の「リストを追加」ボタンで「今日の日付でリストを追加 / 現在のリストを複製 / 未チェックのみ引き継いで複製」メニューを開く。「今日の日付でリストを追加」は日付名リスト作成 → 切替 → 空アイテム追加 → フォーカスまで連鎖する。複製は各アイテム（未チェックのみ含む）を引き継いだリストを作成し複製先へ表示を切り替える（既存 E2E: maestro/flows/shopping_list_crud.yaml, maestro/flows/shopping_list_name_sequence.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

メニュー（3項目）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/55f9d524-dc1e-407b-af12-3403babd9b5f.png" width="320">

「現在のリストを複製」実行後（アイテム引き継ぎ + 複製元リンク表示 + 複製先へ切替）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/0d8a836d-89d4-45b3-b250-ef9caae86e51.png" width="320">

</details>

### **リスト切替シート**: 上部バーのリスト名（▼）タップで切替シートを開き、選択中リストにチェックマーク、末尾の「+ 新しいリストを追加」で新規作成して切り替える

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/40b6b0f0-b2d2-4f39-9f24-d6b3cb652dd9.png" width="320">

</details>

</details>

---

## 10. グループ通知・プレミアム制限

- [x] **グループへの更新通知**: グループに自分以外のメンバーが居るときだけ上部バーに通知ボタン（ベルアイコン）を表示（ソロでは非表示）。初回タップ時のみ説明ダイアログを出し「通知を送る」で送信 + 説明済みフラグ保存、2 回目以降は確認なしで他メンバー全員へ送信し「グループに通知しました」トーストを出す（開発者オプション →「グループにデバッグユーザーを追加」で他メンバーを用意して確認。既存 E2E: maestro/flows/notify_group_button_test.yaml 新規作成）
- [x] **リスト数上限**: 無料プランで 1 グループのアクティブリストが上限（20 件）に達した状態で追加・複製すると上限 SnackBar（アップグレード導線）を出す。プレミアムでは上限を超えて作成できる（既存 E2E: maestro/flows/shopping_list_limit_non_premium.yaml, maestro/flows/premium_shopping_list_limit.yaml）
- [x] **リテンションバナー・AI 上限のプレミアム拡張**: 無料プランでアイテムが 50 件超のとき最下部に「無料プランは作成から30日でリストが整理されます」バナーを出し「詳しく」でペイウォールを開く。プレミアムでは AI 画像 / URL / カテゴリ分けの月間上限が拡張される（バナーは maestro/flows/retention_banner_test.yaml 新規作成で確認。AI 上限拡張はカテゴリ分けを新規作成 maestro/flows/premium_ai_categorize_limit_extension.yaml で無料上限 5 回を超えて 6 回連続成功を確認。既存 E2E premium_ai_image_recognition.yaml / premium_ai_url_recognition.yaml は root QA.md 記載の通り popup_menu_button 参照の stale flow のため使用不可）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **グループへの更新通知**: グループに自分以外のメンバーが居るときだけ上部バーに通知ボタン（ベルアイコン）を表示（ソロでは非表示）。初回タップ時のみ説明ダイアログを出し「通知を送る」で送信 + 説明済みフラグ保存、2 回目以降は確認なしで他メンバー全員へ送信し「グループに通知しました」トーストを出す（開発者オプション →「グループにデバッグユーザーを追加」で他メンバーを用意して確認）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

ソログループでは非表示 → デバッグユーザー作成 + グループ追加後に表示:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/8f48d389-a5ac-4e48-ad44-1664d979863f.png" width="320">

初回タップの説明ダイアログ →「通知を送る」→「グループに通知しました」トースト:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/723d9c79-498c-45e4-893f-1c62517d19b5.png" width="320">

2 回目タップも確認なしで即トースト表示することを maestro/flows/notify_group_button_test.yaml で確認（新規作成フロー）。

</details>

### **リスト数上限**: 無料プランで 1 グループのアクティブリストが上限（20 件）に達した状態で追加・複製すると上限 SnackBar（アップグレード導線）を出す。プレミアムでは上限を超えて作成できる（既存 E2E: maestro/flows/shopping_list_limit_non_premium.yaml, maestro/flows/premium_shopping_list_limit.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

無料プランで 21 個目のリスト作成時に上限 SnackBar（「アップグレード」導線付き）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/191e096f-3844-4f06-b65a-ad012ed1431f.png" width="320">

プレミアムでは 21 個目作成後も上限 SnackBar が出ず無制限に作成できる:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/dcb35225-929b-4e93-b679-3052ab120c16.png" width="320">

</details>

### **リテンションバナー・AI 上限のプレミアム拡張**: 無料プランでアイテムが 50 件超のとき最下部に「無料プランは作成から30日でリストが整理されます」バナーを出し「詳しく」でペイウォールを開く。プレミアムでは AI 画像 / URL / カテゴリ分けの月間上限が拡張される（既存 E2E: maestro/flows/premium_ai_image_recognition.yaml, maestro/flows/premium_ai_url_recognition.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

無料プランで 51 件アイテム入力後、最下部にリテンションバナー表示（maestro/flows/retention_banner_test.yaml 新規作成）:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/a22705a6-f1a2-46ce-93ef-493195564f69.png" width="320">

「詳しく」タップでペイウォールに遷移:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/d263ea30-2fb0-48d3-9e7b-4abe072eb297.png" width="320">

AI カテゴリ分けの月間上限拡張: コード確認で free=5 回・premium=50 回
（firebase/functions/src/functions/categorizeShoppingListItems/function.ts:31,34。generateShoppingListItemsFromImage:45,48・generateShoppingListItemsFromURL:53,56 も同様の free=5/premium=50）。
プレミアム付与状態で無料上限(5回)を超えて6回連続でAIカテゴリ分けを実行し、上限SnackBarを出さず正常完了することを maestro/flows/premium_ai_categorize_limit_extension.yaml（新規作成）で確認:
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/269066db-f32f-43c6-9c45-45f275b991cb.png" width="320">

画像 / URL 認識の premium 拡張（各50回）は、セクション8に記載の通り FAB 長押しメニューが自動化操作で開けない既知の制約により自動検証できなかった。上限値がコード上 free=5/premium=50 であることのみ確認済み。

</details>

</details>
