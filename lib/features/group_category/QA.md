---
feature: group_category
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# group_category QA

## 1. 表示（一覧・空状態）

- [x] **軸0件時の空状態**: カテゴリ軸が1件もない状態（グループ作成直後等）でカテゴリ画面を開くと、「買ったものを自動でグループ分け」の価値訴求カードと「カテゴリを追加」ボタンが表示される。maestro/flows/category_crud.yaml (category_crud_01_empty) で確認。
- [x] **カテゴリ0件時の空状態**: 軸はあるがカテゴリが0件の状態では価値訴求カードのみ表示され、カード内の「カテゴリを追加」ボタンは表示されない（追加導線はFloatingActionButtonのみ）。
- [x] **一覧のキーワード件数表示**: カテゴリ一覧の各行に「キーワード: N件」がそのカテゴリのキーワード数で表示される。
- [x] **選択モードのタイトル切り替え**: 未分類アイテムの「カテゴリを管理」から開くとAppBarタイトルが「カテゴリ」ではなく「カテゴリを選択」になる。maestro/flows/category_select_from_item.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **軸0件時の空状態**: カテゴリ軸が1件もない状態（グループ作成直後等）でカテゴリ画面を開くと、「買ったものを自動でグループ分け」の価値訴求カードと「カテゴリを追加」ボタンが表示される。maestro/flows/category_crud.yaml (category_crud_01_empty) で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/category_crud.yaml` 実行。カテゴリ軸が0件の状態でカテゴリ画面を開くと「買ったものを自動でグループ分け」カードと「カテゴリを追加」ボタンが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/c393871e-2692-4b33-a484-33ccbad3ce68.png" width="320">

</details>

### **カテゴリ0件時の空状態**: 軸はあるがカテゴリが0件の状態では価値訴求カードのみ表示され、カード内の「カテゴリを追加」ボタンは表示されない（追加導線はFloatingActionButtonのみ）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで軸ありカテゴリ1件（「野菜」）の状態から削除確定し、カテゴリ0件（軸は残存）の状態にした。価値訴求カードのみ表示され、カード内に「カテゴリを追加」ボタンは表示されず、右下FloatingActionButton(+)のみが追加導線として表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/09b03b90-0020-48a7-a595-7390192bb436.png" width="320">

</details>

### **一覧のキーワード件数表示**: カテゴリ一覧の各行に「キーワード: N件」がそのカテゴリのキーワード数で表示される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpでカテゴリ「野菜」にキーワード「にんじん」を1件追加後、カテゴリ一覧に戻ると行のサブタイトルに「キーワード: 1件」と表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/8103ba3d-d637-47f6-a2c0-7bd666ed1f06.png" width="320">

</details>

### **選択モードのタイトル切り替え**: 未分類アイテムの「カテゴリを管理」から開くとAppBarタイトルが「カテゴリ」ではなく「カテゴリを選択」になる。maestro/flows/category_select_from_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/category_select_from_item.yaml` 実行。未分類アイテムの詳細シートから「カテゴリを選択」をタップして開いた一覧のAppBarタイトルが「カテゴリを選択」になっていることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/dafff4c8-394e-4d40-9cc7-6f3faed5162d.png" width="320">

</details>

</details>

---

## 2. カテゴリ追加

- [x] **空名カテゴリの即時作成**: 空状態の「カテゴリを追加」ボタン、またはFloatingActionButtonをタップすると、名前入力ダイアログを挟まず空名のカテゴリが即座に作成され「カテゴリ編集」画面へ自動遷移する。maestro/flows/category_crud.yaml で確認。
- [x] **作成直後の編集画面表示**: 作成直後のカテゴリ編集画面ではカテゴリ名TextFieldが空で、hint「カテゴリ名を入力」のみが表示される。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **空名カテゴリの即時作成**: 空状態の「カテゴリを追加」ボタン、またはFloatingActionButtonをタップすると、名前入力ダイアログを挟まず空名のカテゴリが即座に作成され「カテゴリ編集」画面へ自動遷移する。maestro/flows/category_crud.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/category_crud.yaml` 実行。空状態の「カテゴリを追加」ボタンをタップすると、名前入力ダイアログを挟まず「カテゴリ編集」画面へ自動遷移することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/d7e70aba-ce15-47b5-a894-224fa39ae8ef.png" width="320">

</details>

### **作成直後の編集画面表示**: 作成直後のカテゴリ編集画面ではカテゴリ名TextFieldが空で、hint「カテゴリ名を入力」のみが表示される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpでFloatingActionButtonからカテゴリを新規作成し、遷移直後の編集画面をスクリーンショット。カテゴリ名TextFieldは空で、hint「カテゴリ名を入力」のみが表示されていることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/5b1466c1-280c-49ef-bf54-d8ff0d759e08.png" width="320">

</details>

</details>

---

## 3. カテゴリ並び替え

- [x] **ドラッグ&ドロップ並び替え**: カテゴリ一覧の行を長押ししてドラッグし順序を入れ替えると、並び順が保存され画面を再表示しても維持される。maestro/flows/zz_adhoc_category_list_reorder.yaml で確認（旧記載の category_section_reorder.yaml はHome画面のセクションヘッダー並び替えを検証するフローで、本画面(GroupCategoryPage)の行D&Dとは別物のため参照を修正した）。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ドラッグ&ドロップ並び替え**: カテゴリ一覧の行を長押ししてドラッグし順序を入れ替えると、並び順が保存され画面を再表示しても維持される。maestro/flows/zz_adhoc_category_list_reorder.yaml で確認（旧記載の category_section_reorder.yaml はHome画面のセクションヘッダー並び替えを検証するフローで、本画面(GroupCategoryPage)の行D&Dとは別物のため参照を修正した）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/zz_adhoc_category_list_reorder.yaml`（本QAで新規作成したアドホックフロー）を実行。カテゴリ「乳製品」「肉」を作成後、カテゴリ一覧画面で「乳製品」行を長押し相当の超低速swipe(duration 10000ms)でドラッグし「肉」の下まで移動すると順序が入れ替わることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/f7e18336-e8ac-4241-8d15-fb2a4b75e356.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/a282a611-34ad-41aa-b04c-a08c9140ab03.png" width="320">

さらにアプリを完全再起動(`simctl launch`)後もカテゴリ一覧画面を開き直し、並び順「肉→乳製品」が維持されていることを確認した（永続化の確認）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/b03a3840-d6b8-494d-af85-09bd2752975b.png" width="320">

</details>

</details>

---

## 4. カテゴリ選択モード（アイテムからの割当）

- [x] **選択モードでのカテゴリ割当**: 未分類アイテムの詳細シートから「カテゴリを管理」→カテゴリ選択モードの行をタップすると、アイテム名がそのカテゴリの完全一致キーワードとして追加され、自動で前の画面に戻る。maestro/flows/category_select_from_item.yaml で確認。
- [x] **非選択モードでの行タップ無効**: 通常モード（グループ設定等から直接開いた場合）ではカテゴリ行のタップは無反応で、編集・削除の各アイコンのみが反応する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **選択モードでのカテゴリ割当**: 未分類アイテムの詳細シートから「カテゴリを管理」→カテゴリ選択モードの行をタップすると、アイテム名がそのカテゴリの完全一致キーワードとして追加され、自動で前の画面に戻る。maestro/flows/category_select_from_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/category_select_from_item.yaml` 実行。未分類アイテム「juice」の詳細シートから選択モードで「飲料」カテゴリをタップすると、完全一致キーワードとして追加されシートに戻り「カテゴリを変更」表示に更新、買い物リスト上でも「飲料」セクションへ移動することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/01c1dcd4-b583-42de-a437-72bb617f51a2.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/af7485a2-deab-45e5-80d0-654abaab8f3b.png" width="320">

</details>

### **非選択モードでの行タップ無効**: 通常モード（グループ設定等から直接開いた場合）ではカテゴリ行のタップは無反応で、編集・削除の各アイコンのみが反応する。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpでリスト設定→自動分類のキーワード管理から通常モード（選択モードでない）でカテゴリ画面を開き、「飲料」行本体をタップしても画面遷移・変化がないことを確認した。続けて編集アイコンをタップすると「カテゴリ編集」画面へ正しく遷移することも確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/8d38cabd-846a-4baa-ab1a-41452e114071.png" width="320">

</details>

</details>

---

## 5. カテゴリ削除

- [x] **削除確認ダイアログ**: 削除アイコンをタップすると「『<カテゴリ名>』を削除しますか？」および「このカテゴリに設定されたキーワードも削除されます」の確認ダイアログが表示される。
- [x] **削除確定**: ダイアログで「削除」をタップするとカテゴリが一覧から消える。
- [x] **削除キャンセル**: ダイアログで「キャンセル」をタップするとカテゴリは削除されず一覧に残る。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **削除確認ダイアログ**: 削除アイコンをタップすると「『<カテゴリ名>』を削除しますか？」および「このカテゴリに設定されたキーワードも削除されます」の確認ダイアログが表示される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpでカテゴリ「野菜」の削除アイコンをタップすると「『野菜』を削除しますか？」+「このカテゴリに設定されたキーワードも削除されます」のダイアログが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/487c3364-1f90-4083-8bcd-2357afdff500.png" width="320">

</details>

### **削除確定**: ダイアログで「削除」をタップするとカテゴリが一覧から消える。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで削除確認ダイアログの「削除」をタップすると「野菜」が一覧から消え、カテゴリ0件の空状態になることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/09b03b90-0020-48a7-a595-7390192bb436.png" width="320">

</details>

### **削除キャンセル**: ダイアログで「キャンセル」をタップするとカテゴリは削除されず一覧に残る。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで削除確認ダイアログの「キャンセル」をタップするとダイアログが閉じ、「野菜」が一覧に残ったままであることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/6f1b9c83-9037-40c2-97c7-61ab4b46cfc1.png" width="320">

</details>

</details>

---
