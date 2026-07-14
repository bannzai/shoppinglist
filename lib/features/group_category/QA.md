---
feature: group_category
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# group_category QA

## 1. 一覧表示・空状態

- [ ] **軸0件の初回空状態**: カテゴリ軸（axes）が0件のとき、価値訴求カード CategoryEmptyState を表示し、カード内に「カテゴリを追加」ボタン（OutlinedButton）を出す
- [ ] **カテゴリ0件の空状態**: 軸はあるがカテゴリが0件のとき、CategoryEmptyState を表示するがカード内ボタンは出さず、追加導線は右下の FloatingActionButton が担う
- [ ] **カテゴリ一覧の行表示**: カテゴリが1件以上あるとき、各カテゴリを行（ListTile）で表示し、先頭にアイコン、タイトルにカテゴリ名、サブタイトルに「キーワード: N件」を表示する（既存 E2E: maestro/flows/category_crud.yaml）
- [ ] **uid 未取得時のローディング**: ログアウト・ユーザー切替直後で currentUserID が null の間は CircularProgressIndicator を表示し、追加操作をさせない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **軸0件の初回空状態**: カテゴリ軸（axes）が0件のとき、価値訴求カード CategoryEmptyState を表示し、カード内に「カテゴリを追加」ボタン（OutlinedButton）を出す

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **カテゴリ0件の空状態**: 軸はあるがカテゴリが0件のとき、CategoryEmptyState を表示するがカード内ボタンは出さず、追加導線は右下の FloatingActionButton が担う

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **カテゴリ一覧の行表示**: カテゴリが1件以上あるとき、各カテゴリを行（ListTile）で表示し、先頭にアイコン、タイトルにカテゴリ名、サブタイトルに「キーワード: N件」を表示する（既存 E2E: maestro/flows/category_crud.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **uid 未取得時のローディング**: ログアウト・ユーザー切替直後で currentUserID が null の間は CircularProgressIndicator を表示し、追加操作をさせない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. カテゴリ追加

- [ ] **空状態ボタンからの追加**: 軸0件の空状態でカード内「カテゴリを追加」をタップすると、軸が無ければ「デフォルト」軸を自動作成し、空名カテゴリを作成して GroupCategoryEditPage へ遷移する（既存 E2E: maestro/flows/category_crud.yaml）
- [ ] **FAB からの追加**: 一覧表示中に右下 FAB（＋）をタップすると、名前入力ダイアログを挟まず空名カテゴリを作成し、GroupCategoryEditPage へ直接遷移する（既存 E2E: maestro/flows/category_matching_test.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **空状態ボタンからの追加**: 軸0件の空状態でカード内「カテゴリを追加」をタップすると、軸が無ければ「デフォルト」軸を自動作成し、空名カテゴリを作成して GroupCategoryEditPage へ遷移する（既存 E2E: maestro/flows/category_crud.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **FAB からの追加**: 一覧表示中に右下 FAB（＋）をタップすると、名前入力ダイアログを挟まず空名カテゴリを作成し、GroupCategoryEditPage へ直接遷移する（既存 E2E: maestro/flows/category_matching_test.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. カテゴリの並び替え

- [ ] **ドラッグ&ドロップでの並び替え**: 一覧の行を長押しドラッグして並び替えると、デフォルト順序（order フィールド）を更新して保存する（長押し D&D は maestro の duration 10000ms swipe で再現、または widget test での検証を検討）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ドラッグ&ドロップでの並び替え**: 一覧の行を長押しドラッグして並び替えると、デフォルト順序（order フィールド）を更新して保存する（長押し D&D は maestro の duration 10000ms swipe で再現、または widget test での検証を検討）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. カテゴリの編集・削除

- [ ] **編集ボタンからの遷移**: カテゴリ行の編集アイコンをタップすると、そのカテゴリの GroupCategoryEditPage へ遷移する
- [ ] **削除確認ダイアログ**: カテゴリ行の削除アイコンをタップすると「「<カテゴリ名>」を削除しますか？」ダイアログと「このカテゴリに設定されたキーワードも削除されます」の説明を表示する
- [ ] **削除の実行とキャンセル**: 削除ダイアログで「削除」をタップするとカテゴリを削除し、「キャンセル」ではダイアログを閉じるだけで削除しない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **編集ボタンからの遷移**: カテゴリ行の編集アイコンをタップすると、そのカテゴリの GroupCategoryEditPage へ遷移する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **削除確認ダイアログ**: カテゴリ行の削除アイコンをタップすると「「<カテゴリ名>」を削除しますか？」ダイアログと「このカテゴリに設定されたキーワードも削除されます」の説明を表示する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **削除の実行とキャンセル**: 削除ダイアログで「削除」をタップするとカテゴリを削除し、「キャンセル」ではダイアログを閉じるだけで削除しない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. カテゴリ選択モード（アイテムからの割り当て）

- [ ] **選択モードのタイトル**: selectionForItem 指定で開いた場合、AppBar タイトルが「カテゴリを選択」になる（通常時は「カテゴリ」）（既存 E2E: maestro/flows/category_select_from_item.yaml）
- [ ] **行タップでカテゴリ付け替え**: 選択モードでカテゴリ行をタップすると、対象アイテム名（message）を移動先カテゴリの完全一致キーワードに追記し、他カテゴリから同名の完全一致キーワードを削除して画面を pop する（既存 E2E: maestro/flows/category_select_from_item.yaml）
- [ ] **通常モードでは行タップ無効**: selectionForItem が null のとき、行タップではカテゴリ付け替えは発生せず、編集/削除ボタンのみ反応する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **選択モードのタイトル**: selectionForItem 指定で開いた場合、AppBar タイトルが「カテゴリを選択」になる（通常時は「カテゴリ」）（既存 E2E: maestro/flows/category_select_from_item.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **行タップでカテゴリ付け替え**: 選択モードでカテゴリ行をタップすると、対象アイテム名（message）を移動先カテゴリの完全一致キーワードに追記し、他カテゴリから同名の完全一致キーワードを削除して画面を pop する（既存 E2E: maestro/flows/category_select_from_item.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **通常モードでは行タップ無効**: selectionForItem が null のとき、行タップではカテゴリ付け替えは発生せず、編集/削除ボタンのみ反応する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---
