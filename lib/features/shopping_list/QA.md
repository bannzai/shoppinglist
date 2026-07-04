---
feature: shopping_list
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# shopping_list QA

## 1. 表示・空状態

- [ ] **買い物リストの初期表示**: グループの買い物リストを開くと、チェック済みを含む全アイテムが表示される（フィルター切替UIは廃止済みで常に全件表示）。maestro/flows/add_and_check_item.yaml で確認。
- [ ] **空リストの使い方ヒント**: アイテムが0件のとき、「タップで入力開始」の空行と5件の例文（GhostItemRow）、操作方法を説明する点線カードが表示される。maestro/flows/add_and_check_item.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **買い物リストの初期表示**: グループの買い物リストを開くと、チェック済みを含む全アイテムが表示される（フィルター切替UIは廃止済みで常に全件表示）。maestro/flows/add_and_check_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **空リストの使い方ヒント**: アイテムが0件のとき、「タップで入力開始」の空行と5件の例文（GhostItemRow）、操作方法を説明する点線カードが表示される。maestro/flows/add_and_check_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. アイテムの追加・編集

- [ ] **タップ入力とEnter連続追加**: 空行「タップで入力開始」をタップしてテキストを入力しEnterで確定すると一覧に追加され、末尾に新しい空行が残ってフォーカスが維持されたまま連続入力できる。maestro/flows/shopping_list_enter_and_empty_row_removal.yaml, add_and_check_item.yaml で確認。
- [ ] **フォーカス喪失時の空行自動削除**: 入力中でない空行はスクロール等でフォーカスが外れると自動的に削除され、常駐する空行は残らない。maestro/flows/shopping_list_enter_and_empty_row_removal.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **タップ入力とEnter連続追加**: 空行「タップで入力開始」をタップしてテキストを入力しEnterで確定すると一覧に追加され、末尾に新しい空行が残ってフォーカスが維持されたまま連続入力できる。maestro/flows/shopping_list_enter_and_empty_row_removal.yaml, add_and_check_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **フォーカス喪失時の空行自動削除**: 入力中でない空行はスクロール等でフォーカスが外れると自動的に削除され、常駐する空行は残らない。maestro/flows/shopping_list_enter_and_empty_row_removal.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. チェック・削除

- [ ] **チェックのトグルと進捗ピル**: 行左端の円形チェックボックスのタップ、またはアイテム行の右スワイプでチェック状態がトグルされ、左下の進捗ピル（done/total）が更新される。maestro/flows/add_and_check_item.yaml で確認。
- [ ] **左スワイプ削除とUndo**: アイテム行を左スワイプすると削除され、「元に戻す」のSnackBarから削除前の状態に復元できる。maestro/flows/swipe_delete_item.yaml で確認。
- [ ] **詳細シートからの削除**: アイテム行末尾の「…」→詳細シート右上のゴミ箱アイコン→確認ダイアログ「このアイテムを削除しますか？」→削除で、アイテムが一覧から消える。maestro/flows/item_detail_and_delete.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **チェックのトグルと進捗ピル**: 行左端の円形チェックボックスのタップ、またはアイテム行の右スワイプでチェック状態がトグルされ、左下の進捗ピル（done/total）が更新される。maestro/flows/add_and_check_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **左スワイプ削除とUndo**: アイテム行を左スワイプすると削除され、「元に戻す」のSnackBarから削除前の状態に復元できる。maestro/flows/swipe_delete_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **詳細シートからの削除**: アイテム行末尾の「…」→詳細シート右上のゴミ箱アイコン→確認ダイアログ「このアイテムを削除しますか？」→削除で、アイテムが一覧から消える。maestro/flows/item_detail_and_delete.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. アイテム詳細・カテゴリ割り当て

- [ ] **詳細シートの表示内容とカテゴリ割当**: 詳細シートにはカテゴリの確認・変更（マッチ時「カテゴリを変更」/未分類時「カテゴリを選択」）と削除のみが表示される（説明・写真・カラー編集は廃止済みで表示されない）。未分類アイテムでカテゴリ選択→一覧からカテゴリをタップすると、そのカテゴリの完全一致キーワードとして追記され、アイテムが買い物リスト上でも該当カテゴリのセクションへ移動する。maestro/flows/item_detail_and_delete.yaml, category_select_from_item.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **詳細シートの表示内容とカテゴリ割当**: 詳細シートにはカテゴリの確認・変更（マッチ時「カテゴリを変更」/未分類時「カテゴリを選択」）と削除のみが表示される（説明・写真・カラー編集は廃止済みで表示されない）。未分類アイテムでカテゴリ選択→一覧からカテゴリをタップすると、そのカテゴリの完全一致キーワードとして追記され、アイテムが買い物リスト上でも該当カテゴリのセクションへ移動する。maestro/flows/item_detail_and_delete.yaml, category_select_from_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

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

</details>

### **URLから追加・テキスト貼り付け**: FAB長押し→「URLから追加」でHTTPS URLを入力するとAI抽出→レビューシートに候補が表示される。不正なURL（https以外・空）はトーストでエラー表示される。「テキスト貼り付け」ではクリップボードの複数行テキストから、既存アイテムと重複しない行だけが一括で追加される。maestro/flows/design_v2_ai_review.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 6. AIカテゴリ分けとセクション並び替え

- [ ] **自動カテゴリ分けボタン**: 未分類アイテムが1件以上あるとリスト上部に「自動でカテゴリ分け（N件）」ボタンが表示され、タップ→AI分類→プレビューシートでカテゴリ確認・調整・除外→登録すると、各アイテムが該当カテゴリの完全一致キーワードとして永続化される。
- [ ] **カテゴリセクションの並び替え**: カテゴリ別グルーピング表示で、セクションヘッダーを長押しドラッグするとセクション単位で並び替えでき、順序はアプリ再起動後も保持される。「未分類」セクションは末尾固定でドラッグできない。maestro/flows/category_section_reorder.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **自動カテゴリ分けボタン**: 未分類アイテムが1件以上あるとリスト上部に「自動でカテゴリ分け（N件）」ボタンが表示され、タップ→AI分類→プレビューシートでカテゴリ確認・調整・除外→登録すると、各アイテムが該当カテゴリの完全一致キーワードとして永続化される。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **カテゴリセクションの並び替え**: カテゴリ別グルーピング表示で、セクションヘッダーを長押しドラッグするとセクション単位で並び替えでき、順序はアプリ再起動後も保持される。「未分類」セクションは末尾固定でドラッグできない。maestro/flows/category_section_reorder.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 7. リストの追加・切替・複製

- [ ] **リスト切替と新規追加**: 上部バーのリスト名タップでリスト切替シートが開き選択で表示を切り替えられる。「リストを追加」→「今日の日付でリストを追加」で日付名のリストが作成され、同日に複数作成すると (1)(2)…の連番が付く。無料プランの上限に達すると作成できずアップグレード導線付きのSnackBarが表示される。maestro/flows/shopping_list_crud.yaml, shopping_list_name_sequence.yaml で確認。
- [ ] **リストの複製**: 「現在のリストを複製」/「未チェックのみ引き継いで複製」で複製リストが作成され、複製先リストの本体上部に複製元へ戻れるリンクが表示される。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **リスト切替と新規追加**: 上部バーのリスト名タップでリスト切替シートが開き選択で表示を切り替えられる。「リストを追加」→「今日の日付でリストを追加」で日付名のリストが作成され、同日に複数作成すると (1)(2)…の連番が付く。無料プランの上限に達すると作成できずアップグレード導線付きのSnackBarが表示される。maestro/flows/shopping_list_crud.yaml, shopping_list_name_sequence.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **リストの複製**: 「現在のリストを複製」/「未チェックのみ引き継いで複製」で複製リストが作成され、複製先リストの本体上部に複製元へ戻れるリンクが表示される。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 8. グループへの通知

- [ ] **通知ボタンの表示条件と送信**: グループに自分以外のメンバーがいるときのみ通知アイコンが表示され、ソロ運用では非表示になる。初回タップ時のみ機能説明ダイアログが表示され、「通知を送る」で他メンバー全員へプッシュ通知が送信される。2回目以降はダイアログなしで即送信され、送信中は連打しても多重送信されない。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **通知ボタンの表示条件と送信**: グループに自分以外のメンバーがいるときのみ通知アイコンが表示され、ソロ運用では非表示になる。初回タップ時のみ機能説明ダイアログが表示され、「通知を送る」で他メンバー全員へプッシュ通知が送信される。2回目以降はダイアログなしで即送信され、送信中は連打しても多重送信されない。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---
