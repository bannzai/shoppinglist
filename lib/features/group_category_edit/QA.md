---
feature: group_category_edit
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# group_category_edit QA

## 1. カテゴリ名編集（自動保存）

- [ ] **名前入力→画面離脱で自動保存**: カテゴリ名TextFieldに入力後、戻るシェブロンで画面を離脱すると、未保存の名前が自動的に保存される（useOnDisappear）。maestro/flows/category_edit_test.yaml で確認。
- [ ] **Enterキーで確定**: TextFieldでEnter(onSubmitted)を押すとキーボードが閉じ、その後の離脱でも入力した名前が保持・保存される。maestro/flows/category_crud.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **名前入力→画面離脱で自動保存**: カテゴリ名TextFieldに入力後、戻るシェブロンで画面を離脱すると、未保存の名前が自動的に保存される（useOnDisappear）。maestro/flows/category_edit_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **Enterキーで確定**: TextFieldでEnter(onSubmitted)を押すとキーボードが閉じ、その後の離脱でも入力した名前が保持・保存される。maestro/flows/category_crud.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. カラー設定

- [ ] **カラー選択**: プリセットカラーの1つをタップすると即座に保存され、選択中の色にチェックマークと太枠が表示される。maestro/flows/category_edit_test.yaml で確認。
- [ ] **カラー解除**: 「色なし」オプション（⊘アイコン）をタップするとカラーがクリアされ、選択枠が「色なし」側に移動する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **カラー選択**: プリセットカラーの1つをタップすると即座に保存され、選択中の色にチェックマークと太枠が表示される。maestro/flows/category_edit_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **カラー解除**: 「色なし」オプション（⊘アイコン）をタップするとカラーがクリアされ、選択枠が「色なし」側に移動する。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. アイコン設定

- [ ] **アイコン選択**: アイコンプリセットの1つをタップすると即座に保存され、選択中のタイルの背景色・枠線がアクセントカラー（カテゴリカラー優先）に変わる。maestro/flows/category_edit_test.yaml で確認。
- [ ] **アイコン解除**: 「アイコンなし」オプション（⊘アイコン）をタップするとアイコンがクリアされる。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **アイコン選択**: アイコンプリセットの1つをタップすると即座に保存され、選択中のタイルの背景色・枠線がアクセントカラー（カテゴリカラー優先）に変わる。maestro/flows/category_edit_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **アイコン解除**: 「アイコンなし」オプション（⊘アイコン）をタップするとアイコンがクリアされる。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. キーワード管理

- [ ] **キーワード追加**: 「キーワード」セクション右の＋アイコンからダイアログを開き、キーワードを入力してSegmentedButtonで「部分一致/完全一致/正規表現」を選択し「追加」をタップすると、一覧に選んだマッチング種別のラベル付きで反映される。maestro/flows/category_matching_test.yaml で確認。
- [ ] **キーワード削除**: キーワード行の削除アイコンをタップすると確認ダイアログなしで即座に一覧から消える。
- [ ] **キーワード追加キャンセル**: 追加ダイアログで「キャンセル」をタップすると何も追加されない。
- [ ] **キーワード0件時の表示**: キーワードが1件もない場合「キーワードがまだありません」というグレーのテキストが表示される。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **キーワード追加**: 「キーワード」セクション右の＋アイコンからダイアログを開き、キーワードを入力してSegmentedButtonで「部分一致/完全一致/正規表現」を選択し「追加」をタップすると、一覧に選んだマッチング種別のラベル付きで反映される。maestro/flows/category_matching_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **キーワード削除**: キーワード行の削除アイコンをタップすると確認ダイアログなしで即座に一覧から消える。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **キーワード追加キャンセル**: 追加ダイアログで「キャンセル」をタップすると何も追加されない。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **キーワード0件時の表示**: キーワードが1件もない場合「キーワードがまだありません」というグレーのテキストが表示される。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. マッチング判定（エッジケース）

- [ ] **完全一致は完全一致のみマッチ**: 完全一致キーワード「牛乳」を登録した場合、買い物リストで「牛乳」は該当カテゴリに分類されるが「牛肉」は分類されない。maestro/flows/category_matching_test.yaml で確認。
- [ ] **部分一致は大文字小文字を無視**: 部分一致キーワード「Milk」を登録した場合、買い物リストの「milk」「MILK」のどちらも該当カテゴリにマッチする。maestro/flows/category_matching_test.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **完全一致は完全一致のみマッチ**: 完全一致キーワード「牛乳」を登録した場合、買い物リストで「牛乳」は該当カテゴリに分類されるが「牛肉」は分類されない。maestro/flows/category_matching_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **部分一致は大文字小文字を無視**: 部分一致キーワード「Milk」を登録した場合、買い物リストの「milk」「MILK」のどちらも該当カテゴリにマッチする。maestro/flows/category_matching_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---
