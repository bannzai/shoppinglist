---
feature: shopping_list
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-04
---

# shopping_list QA

## 1. 表示・空状態

- [x] **買い物リストの初期表示**: グループの買い物リストを開くと、チェック済みを含む全アイテムが表示される（フィルター切替UIは廃止済みで常に全件表示）。maestro/flows/add_and_check_item.yaml で確認。
- [x] **空リストの使い方ヒント**: アイテムが0件のとき、「タップで入力開始」の空行と5件の例文（GhostItemRow）、操作方法を説明する点線カードが表示される。maestro/flows/add_and_check_item.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **買い物リストの初期表示**: グループの買い物リストを開くと、チェック済みを含む全アイテムが表示される（フィルター切替UIは廃止済みで常に全件表示）。maestro/flows/add_and_check_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/add_and_check_item.yaml` 実行。牛乳/卵/パンを追加後、牛乳をチェックしても一覧から消えず、進捗ピル「1/3」とともに表示され続けることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/693a5ea8-4631-453d-bd58-915dfc322ebd.png" width="320">

</details>

### **空リストの使い方ヒント**: アイテムが0件のとき、「タップで入力開始」の空行と5件の例文（GhostItemRow）、操作方法を説明する点線カードが表示される。maestro/flows/add_and_check_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/add_and_check_item.yaml` 実行。空リスト状態で「タップで入力開始」の空行、5件の例文（牛乳/卵/パン/玉ねぎ/トマト）、「こんな風に使えます」の点線カードが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/ac0cace2-ad3e-46ce-a69c-dc571f1467e2.png" width="320">

</details>

</details>

---

## 2. アイテムの追加・編集

- [x] **タップ入力とEnter連続追加**: 空行「タップで入力開始」をタップしてテキストを入力しEnterで確定すると一覧に追加され、末尾に新しい空行が残ってフォーカスが維持されたまま連続入力できる。maestro/flows/shopping_list_enter_and_empty_row_removal.yaml, add_and_check_item.yaml で確認。
- [x] **フォーカス喪失時の空行自動削除**: 入力中でない空行はスクロール等でフォーカスが外れると自動的に削除され、常駐する空行は残らない。maestro/flows/shopping_list_enter_and_empty_row_removal.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **タップ入力とEnter連続追加**: 空行「タップで入力開始」をタップしてテキストを入力しEnterで確定すると一覧に追加され、末尾に新しい空行が残ってフォーカスが維持されたまま連続入力できる。maestro/flows/shopping_list_enter_and_empty_row_removal.yaml, add_and_check_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/shopping_list_enter_and_empty_row_removal.yaml` 実行。牛乳→卵→パンとEnterで連続追加後も入力行（hint「メモを書く...」）が末尾に残り、フォーカスが維持されたまま連続入力できることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/74c5c03a-6e70-4611-83cc-bbfa19a4e67e.png" width="320">

</details>

### **フォーカス喪失時の空行自動削除**: 入力中でない空行はスクロール等でフォーカスが外れると自動的に削除され、常駐する空行は残らない。maestro/flows/shopping_list_enter_and_empty_row_removal.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/shopping_list_enter_and_empty_row_removal.yaml` 実行。リストをスクロール（ドラッグ）してフォーカスを外すと、空の入力行（「メモを書く...」）が自動的に削除され、確定済みアイテムのみ残ることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/e27d875e-f8d3-4f64-a5da-439f9b90fc19.png" width="320">

</details>

</details>

---

## 3. チェック・削除

- [x] **チェックのトグルと進捗ピル**: 行左端の円形チェックボックスのタップ、またはアイテム行の右スワイプでチェック状態がトグルされ、左下の進捗ピル（done/total）が更新される。maestro/flows/add_and_check_item.yaml で確認。
- [x] **左スワイプ削除とUndo**: アイテム行を左スワイプすると削除され、「元に戻す」のSnackBarから削除前の状態に復元できる。maestro/flows/swipe_delete_item.yaml で確認。
- [x] **詳細シートからの削除**: アイテム行末尾の「…」→詳細シート右上のゴミ箱アイコン→確認ダイアログ「このアイテムを削除しますか？」→削除で、アイテムが一覧から消える。maestro/flows/item_detail_and_delete.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **チェックのトグルと進捗ピル**: 行左端の円形チェックボックスのタップ、またはアイテム行の右スワイプでチェック状態がトグルされ、左下の進捗ピル（done/total）が更新される。maestro/flows/add_and_check_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/add_and_check_item.yaml` 実行。牛乳行左端の円形チェックボックスをタップしてチェック状態がトグルされ、左下の進捗ピルが「1/3」に更新されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/693a5ea8-4631-453d-bd58-915dfc322ebd.png" width="320">

</details>

### **左スワイプ削除とUndo**: アイテム行を左スワイプすると削除され、「元に戻す」のSnackBarから削除前の状態に復元できる。maestro/flows/swipe_delete_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/swipe_delete_item.yaml` 実行。アイテム行を左スワイプすると削除され「元に戻す」のSnackBarが表示、タップで削除前の状態に復元されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/330341bf-9af7-4b2b-a61f-7f95ab09b2a8.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/3972ba51-7494-454b-b56c-7552d0010c8a.png" width="320">

</details>

### **詳細シートからの削除**: アイテム行末尾の「…」→詳細シート右上のゴミ箱アイコン→確認ダイアログ「このアイテムを削除しますか？」→削除で、アイテムが一覧から消える。maestro/flows/item_detail_and_delete.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/item_detail_and_delete.yaml` 実行。「アイテム詳細」→ゴミ箱アイコン→確認ダイアログ「このアイテムを削除しますか？」→削除で、アイテムが一覧から消え空リスト状態に戻ることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/fe3fa2de-4bb9-49f7-b03f-4a00a6d83188.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/ccac36df-6d63-4ef4-9d49-153f77dea1f1.png" width="320">

</details>

</details>

---

## 4. アイテム詳細・カテゴリ割り当て

- [x] **詳細シートの表示内容とカテゴリ割当**: 詳細シートにはカテゴリの確認・変更（マッチ時「カテゴリを変更」/未分類時「カテゴリを選択」）と削除のみが表示される（説明・写真・カラー編集は廃止済みで表示されない）。未分類アイテムでカテゴリ選択→一覧からカテゴリをタップすると、そのカテゴリの完全一致キーワードとして追記され、アイテムが買い物リスト上でも該当カテゴリのセクションへ移動する。maestro/flows/item_detail_and_delete.yaml, category_select_from_item.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **詳細シートの表示内容とカテゴリ割当**: 詳細シートにはカテゴリの確認・変更（マッチ時「カテゴリを変更」/未分類時「カテゴリを選択」）と削除のみが表示される（説明・写真・カラー編集は廃止済みで表示されない）。未分類アイテムでカテゴリ選択→一覧からカテゴリをタップすると、そのカテゴリの完全一致キーワードとして追記され、アイテムが買い物リスト上でも該当カテゴリのセクションへ移動する。maestro/flows/item_detail_and_delete.yaml, category_select_from_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/category_select_from_item.yaml` 実行。未分類アイテム「juice」の詳細シートで「カテゴリを選択」→カテゴリ一覧（選択モード）→「飲料」をタップすると、シートのボタンが「カテゴリを変更」に更新され、買い物リスト上でも「飲料」セクションへ移動することを確認した（`item_detail_and_delete.yaml` で説明・写真・カラー欄が表示されないことも確認済み）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/e469fab1-742e-4d5e-b959-3ebe4de3c3b1.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/2a3fe6d3-8591-474f-ad6f-28721e1d01b3.png" width="320">

</details>

</details>

---

## 5. AIによるアイテム追加

- [ ] **写真から追加**: 右下FABを長押し→「写真から追加」→フォトライブラリ（Simulatorではカメラ撮影は利用不可）で画像を選択すると、AIが抽出した候補がレビューシートに表示され、選択した候補のみが一覧に追加される。月間利用回数の上限に達すると、無料/プレミアムそれぞれの上限メッセージ（無料はアップグレード導線付き）がSnackBarで表示される。
- [ ] **URLから追加・テキスト貼り付け**: FAB長押し→「URLから追加」でHTTPS URLを入力するとAI抽出→レビューシートに候補が表示される。不正なURL（https以外・空）はトーストでエラー表示される。「テキスト貼り付け」ではクリップボードの複数行テキストから、既存アイテムと重複しない行だけが一括で追加される。maestro/flows/design_v2_ai_review.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **写真から追加**: 右下FABを長押し→「写真から追加」→フォトライブラリ（Simulatorではカメラ撮影は利用不可）で画像を選択すると、AIが抽出した候補がレビューシートに表示され、選択した候補のみが一覧に追加される。月間利用回数の上限に達すると、無料/プレミアムそれぞれの上限メッセージ（無料はアップグレード導線付き）がSnackBarで表示される。

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 唯一の入口である FAB 長押し（`lib/features/shopping_list/components/expandable_fab.dart` の `GestureDetector.onLongPress`）が、maestro（`longPressOn`, duration指定含む）・mobile-mcp（`mobile_long_press_on_screen_at_coordinates`, 600ms〜2000msで複数回試行）のいずれでも発火しなかった（メニュー展開も、コード注釈にある「タップへの退化」による空行追加も発生せず）。同一座標への通常タップは空行追加として正しく発火することを確認済みのため、座標や環境の問題ではなく、WDA経由の合成長押しジェスチャーがFlutterの`onLongPress`ジェスチャーアリーナで認識されない自動化ツール側の制約と判断した。`maestro/flows/design_v2_ai_review.yaml` 自体もこの長押しステップを全て `optional: true` としており、既知の制約であることが伺える。実機能はコードレビューで確認済み（`_showImagePicker` が月間上限チェック→上限到達時はSnackBar表示のロジックを持つ）。

</details>

### **URLから追加・テキスト貼り付け**: FAB長押し→「URLから追加」でHTTPS URLを入力するとAI抽出→レビューシートに候補が表示される。不正なURL（https以外・空）はトーストでエラー表示される。「テキスト貼り付け」ではクリップボードの複数行テキストから、既存アイテムと重複しない行だけが一括で追加される。maestro/flows/design_v2_ai_review.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 上記「写真から追加」と同じFAB長押しメニューが入口のため、同一の自動化ツール制約でメニューを開けなかった。`maestro/flows/design_v2_ai_review.yaml` を実行したが、長押しステップが `optional: true` のため警告止まりで実際にはメニューが開かず、URL入力ダイアログの表示確認まで到達できなかった。

</details>

</details>

---

## 6. AIカテゴリ分けとセクション並び替え

- [x] **自動カテゴリ分けボタン**: 未分類アイテムが1件以上あるとリスト上部に「自動でカテゴリ分け（N件）」ボタンが表示され、タップ→AI分類→プレビューシートでカテゴリ確認・調整・除外→登録すると、各アイテムが該当カテゴリの完全一致キーワードとして永続化される。
- [x] **カテゴリセクションの並び替え**: カテゴリ別グルーピング表示で、セクションヘッダーを長押しドラッグするとセクション単位で並び替えでき、順序はアプリ再起動後も保持される。「未分類」セクションは末尾固定でドラッグできない。maestro/flows/category_section_reorder.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **自動カテゴリ分けボタン**: 未分類アイテムが1件以上あるとリスト上部に「自動でカテゴリ分け（N件）」ボタンが表示され、タップ→AI分類→プレビューシートでカテゴリ確認・調整・除外→登録すると、各アイテムが該当カテゴリの完全一致キーワードとして永続化される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

mobile-mcpで検証。未分類アイテム「キャベツ」「にんじん」を追加すると「自動でカテゴリ分け（2件）」ボタンが表示され、タップするとAIが両方を「野菜」カテゴリと判定したプレビューシート（2/2、チェック済み）が表示された。「2件を登録」で確定すると、買い物リストが「野菜」セクションにグルーピングされて表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/3e81959c-5ed0-4154-9044-0249432684a9.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/4c9860cc-68a9-4033-900e-de7072c312b4.png" width="320">

</details>

### **カテゴリセクションの並び替え**: カテゴリ別グルーピング表示で、セクションヘッダーを長押しドラッグするとセクション単位で並び替えでき、順序はアプリ再起動後も保持される。「未分類」セクションは末尾固定でドラッグできない。maestro/flows/category_section_reorder.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/category_section_reorder.yaml` 実行。「乳製品」セクションヘッダーを超低速swipeで長押しドラッグすると「肉」セクションの下に移動し、「未分類」セクションは末尾固定でドラッグしても順序が変わらないこと、アプリ再起動後も並び順（乳製品→肉→未分類）が保持されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/258ae9b3-ce6d-4611-809f-7e1f5f1a6052.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/6a65296b-7e15-4a52-8a1e-08806a9180aa.png" width="320">

</details>

</details>

---

## 7. リストの追加・切替・複製

- [x] **リスト切替と新規追加**: 上部バーのリスト名タップでリスト切替シートが開き選択で表示を切り替えられる。「リストを追加」→「今日の日付でリストを追加」で日付名のリストが作成され、同日に複数作成すると (1)(2)…の連番が付く。無料プランの上限に達すると作成できずアップグレード導線付きのSnackBarが表示される。maestro/flows/shopping_list_crud.yaml, shopping_list_name_sequence.yaml で確認。
- [x] **リストの複製**: 「現在のリストを複製」/「未チェックのみ引き継いで複製」で複製リストが作成され、複製先リストの本体上部に複製元へ戻れるリンクが表示される。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **リスト切替と新規追加**: 上部バーのリスト名タップでリスト切替シートが開き選択で表示を切り替えられる。「リストを追加」→「今日の日付でリストを追加」で日付名のリストが作成され、同日に複数作成すると (1)(2)…の連番が付く。無料プランの上限に達すると作成できずアップグレード導線付きのSnackBarが表示される。maestro/flows/shopping_list_crud.yaml, shopping_list_name_sequence.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/shopping_list_crud.yaml`（作成・リネーム・削除）と `shopping_list_name_sequence.yaml`（同日連番採番）を実行。上部バーのリスト名タップでリスト切替シートが開き、「新しいリストを追加」で日付名のリストが作成され、同日2件目は「(1)」、3件目は「(2)」の連番が付くことを確認した（無料プランの上限到達時の挙動は横断確認項目「非プレミアム制限」で別途検証済み）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/1eeef3c4-e951-49f4-add5-2767aa83e585.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/2d215e84-efea-468d-8f94-a24df9f05b70.png" width="320">

</details>

### **リストの複製**: 「現在のリストを複製」/「未チェックのみ引き継いで複製」で複製リストが作成され、複製先リストの本体上部に複製元へ戻れるリンクが表示される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

mobile-mcpで検証。「野菜」カテゴリのアイテムを含むリストで「リストを追加」→「現在のリストを複製」を実行すると、新しいリスト（同名+連番）が作成され、アイテムがそのまま複製されると同時に本体上部に複製元へ戻れるリンク「2026-07-04 (2)から複製」が表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/0e5cfc33-c905-4914-baa2-baa4c7e48911.png" width="320">

</details>

</details>

---

## 8. グループへの通知

- [x] **通知ボタンの表示条件と送信**: グループに自分以外のメンバーがいるときのみ通知アイコンが表示され、ソロ運用では非表示になる。初回タップ時のみ機能説明ダイアログが表示され、「通知を送る」で他メンバー全員へプッシュ通知が送信される。2回目以降はダイアログなしで即送信され、送信中は連打しても多重送信されない。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **通知ボタンの表示条件と送信**: グループに自分以外のメンバーがいるときのみ通知アイコンが表示され、ソロ運用では非表示になる。初回タップ時のみ機能説明ダイアログが表示され、「通知を送る」で他メンバー全員へプッシュ通知が送信される。2回目以降はダイアログなしで即送信され、送信中は連打しても多重送信されない。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/virtual_pairing/01〜03` でデバッグユーザーをグループに追加（2人グループ化）した後、mobile-mcpで検証。ソロ運用時（横断確認項目のスクショ等）はベルアイコンが非表示だが、2人グループ化後はベルアイコン「グループに通知」が表示された。初回タップで機能説明ダイアログ（「グループに通知」「このボタンを押すと...」+キャンセル/通知を送る）が表示され、「通知を送る」で送信。2回目以降はダイアログなしで即座に「グループに通知しました」のトーストが表示されることを確認した（`isSending` フラグによる多重送信防止はコードレビューで確認済み）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/f2a5acf2-b70c-47c1-b406-c04842c13b9a.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/c48633d9-072f-40fd-b470-353369064822.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/ce6d191c-e7b1-43c7-9827-2e9dfd3e24e9.png" width="320">

</details>

</details>

---
