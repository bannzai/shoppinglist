---
feature: group_category_edit
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# group_category_edit QA

## 1. カテゴリ名編集（自動保存）

- [x] **名前入力→画面離脱で自動保存**: カテゴリ名TextFieldに入力後、戻るシェブロンで画面を離脱すると、未保存の名前が自動的に保存される（useOnDisappear）。maestro/flows/category_edit_test.yaml で確認。
- [x] **Enterキーで確定**: TextFieldでEnter(onSubmitted)を押すとキーボードが閉じ、その後の離脱でも入力した名前が保持・保存される。maestro/flows/category_crud.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **名前入力→画面離脱で自動保存**: カテゴリ名TextFieldに入力後、戻るシェブロンで画面を離脱すると、未保存の名前が自動的に保存される（useOnDisappear）。maestro/flows/category_edit_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/category_edit_test.yaml` 実行。カテゴリ名「テスト用」を入力しEnterでキーボードを閉じた後、「完了」を押さず戻るシェブロンで離脱→カテゴリ一覧に「テスト用」が反映されていることを確認した（useOnDisappearによる自動保存）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/a87b58ef-f8e7-47a0-adc7-00db75e3edd1.png" width="320">

</details>

### **Enterキーで確定**: TextFieldでEnter(onSubmitted)を押すとキーボードが閉じ、その後の離脱でも入力した名前が保持・保存される。maestro/flows/category_crud.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/category_crud.yaml` 実行。カテゴリ名「野菜」入力→Enterでキーボードを閉じ→戻るシェブロンで離脱後、一覧に「野菜」が保存されていることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/2408ee4e-b4f1-4b5f-aeff-1202b3fe27d9.png" width="320">

</details>

</details>

---

## 2. カラー設定

- [x] **カラー選択**: プリセットカラーの1つをタップすると即座に保存され、選択中の色にチェックマークと太枠が表示される。maestro/flows/category_edit_test.yaml で確認。
- [x] **カラー解除**: 「色なし」オプション（⊘アイコン）をタップするとカラーがクリアされ、選択枠が「色なし」側に移動する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **カラー選択**: プリセットカラーの1つをタップすると即座に保存され、選択中の色にチェックマークと太枠が表示される。maestro/flows/category_edit_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/category_edit_test.yaml` 実行。赤色をタップすると即座に選択され、チェックマークと太枠が表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/b60cfc69-67a7-446b-87de-4d73dc68ee4b.png" width="320">

</details>

### **カラー解除**: 「色なし」オプション（⊘アイコン）をタップするとカラーがクリアされ、選択枠が「色なし」側に移動する。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

同フローで「色なし」（⊘アイコン）をタップすると赤色の選択が解除され、太枠が「色なし」側に移動することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/fa3b3174-925a-46f3-be10-ac9d03f71356.png" width="320">

</details>

</details>

---

## 3. アイコン設定

- [x] **アイコン選択**: アイコンプリセットの1つをタップすると即座に保存され、選択中のタイルの背景色・枠線がアクセントカラー（カテゴリカラー優先）に変わる。maestro/flows/category_edit_test.yaml で確認。
- [x] **アイコン解除**: 「アイコンなし」オプション（⊘アイコン）をタップするとアイコンがクリアされる。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **アイコン選択**: アイコンプリセットの1つをタップすると即座に保存され、選択中のタイルの背景色・枠線がアクセントカラー（カテゴリカラー優先）に変わる。maestro/flows/category_edit_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/category_edit_test.yaml` 実行。カートアイコンをタップすると即座に選択され、タイルの背景色・枠線がアクセントカラー（選択中のカテゴリカラー）に変わることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/d8a69626-438e-496e-b83c-24bd11df4647.png" width="320">

</details>

### **アイコン解除**: 「アイコンなし」オプション（⊘アイコン）をタップするとアイコンがクリアされる。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで「肉」カテゴリの編集画面にてカートアイコンを選択後（1枚目）、「アイコンなし」（⊘アイコン）をタップするとカートの選択枠が消え、「アイコンなし」側の枠線がアクセントカラーに変わることを確認した（2枚目）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/02e6f42b-8224-42b8-9b0d-3d2a6b319376.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/b4c8d7b2-2bdd-4470-8c4e-645be96d721b.png" width="320">

</details>

</details>

---

## 4. キーワード管理

- [x] **キーワード追加**: 「キーワード」セクション右の＋アイコンからダイアログを開き、キーワードを入力してSegmentedButtonで「部分一致/完全一致/正規表現」を選択し「追加」をタップすると、一覧に選んだマッチング種別のラベル付きで反映される。maestro/flows/category_matching_test.yaml で確認。
- [x] **キーワード削除**: キーワード行の削除アイコンをタップすると確認ダイアログなしで即座に一覧から消える。
- [x] **キーワード追加キャンセル**: 追加ダイアログで「キャンセル」をタップすると何も追加されない。
- [x] **キーワード0件時の表示**: キーワードが1件もない場合「キーワードがまだありません」というグレーのテキストが表示される。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **キーワード追加**: 「キーワード」セクション右の＋アイコンからダイアログを開き、キーワードを入力してSegmentedButtonで「部分一致/完全一致/正規表現」を選択し「追加」をタップすると、一覧に選んだマッチング種別のラベル付きで反映される。maestro/flows/category_matching_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/category_crud.yaml` 実行。「にんじん」を部分一致で追加すると、一覧に「にんじん / 部分一致」のラベル付きで反映されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/ee9e541f-6854-419b-a13f-6d20575015ae.png" width="320">

</details>

### **キーワード削除**: キーワード行の削除アイコンをタップすると確認ダイアログなしで即座に一覧から消える。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで「肉」カテゴリ編集画面にてキーワード「牛」（部分一致、1枚目）の削除アイコンをタップすると、確認ダイアログなしで即座に一覧から消え「キーワードがまだありません」表示に変わることを確認した（2枚目）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/b4c8d7b2-2bdd-4470-8c4e-645be96d721b.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/a720bd5f-ae93-4a67-bc4f-00f2cfe2bc6f.png" width="320">

</details>

### **キーワード追加キャンセル**: 追加ダイアログで「キャンセル」をタップすると何も追加されない。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpでキーワード追加ダイアログに「テスト」を入力後（1枚目）、「キャンセル」をタップするとダイアログが閉じ、キーワード一覧は追加前と変わらず0件のままであることを確認した（2枚目）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/effb07f4-4321-4cde-a2ae-1dba54453174.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/e911ced5-91d8-4916-8941-4b821475dd86.png" width="320">

</details>

### **キーワード0件時の表示**: キーワードが1件もない場合「キーワードがまだありません」というグレーのテキストが表示される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpでキーワードを全削除した「肉」カテゴリの編集画面にて「キーワードがまだありません」というグレーのテキストが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/a720bd5f-ae93-4a67-bc4f-00f2cfe2bc6f.png" width="320">

</details>

</details>

---

## 5. マッチング判定（エッジケース）

- [x] **完全一致は完全一致のみマッチ**: 完全一致キーワード「牛乳」を登録した場合、買い物リストで「牛乳」は該当カテゴリに分類されるが「牛肉」は分類されない。maestro/flows/category_matching_test.yaml で確認。
- [x] **部分一致は大文字小文字を無視**: 部分一致キーワード「Milk」を登録した場合、買い物リストの「milk」「MILK」のどちらも該当カテゴリにマッチする。maestro/flows/category_matching_test.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **完全一致は完全一致のみマッチ**: 完全一致キーワード「牛乳」を登録した場合、買い物リストで「牛乳」は該当カテゴリに分類されるが「牛肉」は分類されない。maestro/flows/category_matching_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/category_matching_test.yaml` 実行。「乳製品」に完全一致キーワード「牛乳」、「肉」に部分一致キーワード「牛」を登録した状態でアイテム「牛乳」「牛肉」「milk」「MILK」を追加。「牛乳」は乳製品セクションに、「牛肉」は完全一致に一致しないため乳製品には入らず肉セクションに分類されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/0aedb103-2517-427d-9ff2-86f5967d4a70.png" width="320">

</details>

### **部分一致は大文字小文字を無視**: 部分一致キーワード「Milk」を登録した場合、買い物リストの「milk」「MILK」のどちらも該当カテゴリにマッチする。maestro/flows/category_matching_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

同フローで部分一致キーワード「Milk」を登録した「乳製品」カテゴリに、大文字小文字違いの「milk」「MILK」の両方が正しくマッチして乳製品セクションに分類されることを確認した（牛乳 / milk / MILK の3件が乳製品セクションに表示）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/0aedb103-2517-427d-9ff2-86f5967d4a70.png" width="320">

</details>

</details>

---
