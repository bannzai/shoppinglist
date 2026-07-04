---
feature: group_category
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# group_category QA

## 1. 表示（一覧・空状態）

- [ ] **軸0件時の空状態**: カテゴリ軸が1件もない状態（グループ作成直後等）でカテゴリ画面を開くと、「買ったものを自動でグループ分け」の価値訴求カードと「カテゴリを追加」ボタンが表示される。maestro/flows/category_crud.yaml (category_crud_01_empty) で確認。
- [ ] **カテゴリ0件時の空状態**: 軸はあるがカテゴリが0件の状態では価値訴求カードのみ表示され、カード内の「カテゴリを追加」ボタンは表示されない（追加導線はFloatingActionButtonのみ）。
- [ ] **一覧のキーワード件数表示**: カテゴリ一覧の各行に「キーワード: N件」がそのカテゴリのキーワード数で表示される。
- [ ] **選択モードのタイトル切り替え**: 未分類アイテムの「カテゴリを管理」から開くとAppBarタイトルが「カテゴリ」ではなく「カテゴリを選択」になる。maestro/flows/category_select_from_item.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **軸0件時の空状態**: カテゴリ軸が1件もない状態（グループ作成直後等）でカテゴリ画面を開くと、「買ったものを自動でグループ分け」の価値訴求カードと「カテゴリを追加」ボタンが表示される。maestro/flows/category_crud.yaml (category_crud_01_empty) で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **カテゴリ0件時の空状態**: 軸はあるがカテゴリが0件の状態では価値訴求カードのみ表示され、カード内の「カテゴリを追加」ボタンは表示されない（追加導線はFloatingActionButtonのみ）。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **一覧のキーワード件数表示**: カテゴリ一覧の各行に「キーワード: N件」がそのカテゴリのキーワード数で表示される。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **選択モードのタイトル切り替え**: 未分類アイテムの「カテゴリを管理」から開くとAppBarタイトルが「カテゴリ」ではなく「カテゴリを選択」になる。maestro/flows/category_select_from_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. カテゴリ追加

- [ ] **空名カテゴリの即時作成**: 空状態の「カテゴリを追加」ボタン、またはFloatingActionButtonをタップすると、名前入力ダイアログを挟まず空名のカテゴリが即座に作成され「カテゴリ編集」画面へ自動遷移する。maestro/flows/category_crud.yaml で確認。
- [ ] **作成直後の編集画面表示**: 作成直後のカテゴリ編集画面ではカテゴリ名TextFieldが空で、hint「カテゴリ名を入力」のみが表示される。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **空名カテゴリの即時作成**: 空状態の「カテゴリを追加」ボタン、またはFloatingActionButtonをタップすると、名前入力ダイアログを挟まず空名のカテゴリが即座に作成され「カテゴリ編集」画面へ自動遷移する。maestro/flows/category_crud.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **作成直後の編集画面表示**: 作成直後のカテゴリ編集画面ではカテゴリ名TextFieldが空で、hint「カテゴリ名を入力」のみが表示される。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. カテゴリ並び替え

- [ ] **ドラッグ&ドロップ並び替え**: カテゴリ一覧の行を長押ししてドラッグし順序を入れ替えると、並び順が保存され画面を再表示しても維持される。maestro/flows/category_section_reorder.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ドラッグ&ドロップ並び替え**: カテゴリ一覧の行を長押ししてドラッグし順序を入れ替えると、並び順が保存され画面を再表示しても維持される。maestro/flows/category_section_reorder.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. カテゴリ選択モード（アイテムからの割当）

- [ ] **選択モードでのカテゴリ割当**: 未分類アイテムの詳細シートから「カテゴリを管理」→カテゴリ選択モードの行をタップすると、アイテム名がそのカテゴリの完全一致キーワードとして追加され、自動で前の画面に戻る。maestro/flows/category_select_from_item.yaml で確認。
- [ ] **非選択モードでの行タップ無効**: 通常モード（グループ設定等から直接開いた場合）ではカテゴリ行のタップは無反応で、編集・削除の各アイコンのみが反応する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **選択モードでのカテゴリ割当**: 未分類アイテムの詳細シートから「カテゴリを管理」→カテゴリ選択モードの行をタップすると、アイテム名がそのカテゴリの完全一致キーワードとして追加され、自動で前の画面に戻る。maestro/flows/category_select_from_item.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **非選択モードでの行タップ無効**: 通常モード（グループ設定等から直接開いた場合）ではカテゴリ行のタップは無反応で、編集・削除の各アイコンのみが反応する。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. カテゴリ削除

- [ ] **削除確認ダイアログ**: 削除アイコンをタップすると「『<カテゴリ名>』を削除しますか？」および「このカテゴリに設定されたキーワードも削除されます」の確認ダイアログが表示される。
- [ ] **削除確定**: ダイアログで「削除」をタップするとカテゴリが一覧から消える。
- [ ] **削除キャンセル**: ダイアログで「キャンセル」をタップするとカテゴリは削除されず一覧に残る。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **削除確認ダイアログ**: 削除アイコンをタップすると「『<カテゴリ名>』を削除しますか？」および「このカテゴリに設定されたキーワードも削除されます」の確認ダイアログが表示される。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **削除確定**: ダイアログで「削除」をタップするとカテゴリが一覧から消える。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **削除キャンセル**: ダイアログで「キャンセル」をタップするとカテゴリは削除されず一覧に残る。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---
