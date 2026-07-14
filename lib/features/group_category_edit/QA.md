---
feature: group_category_edit
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# group_category_edit QA

## 1. カテゴリ名の編集と自動保存

- [ ] **名前入力欄の表示**: カテゴリ名 TextField を表示し、未入力時は hint「カテゴリ名を入力」を表示する
- [ ] **画面離脱時の自動保存**: 名前を変更して back で戻る（pop）と、変更後の名前が Firestore に保存され、一覧の行に反映される（既存 E2E: maestro/flows/category_edit_test.yaml）
- [ ] **変更なし・空名では保存しない**: 名前を変更していない、または trim 後が空の場合、離脱時に保存を行わない
- [ ] **バックグラウンド移行時の自動保存**: 名前変更後にアプリがバックグラウンドへ移行した場合も、変更後の名前を自動保存する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **名前入力欄の表示**: カテゴリ名 TextField を表示し、未入力時は hint「カテゴリ名を入力」を表示する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **画面離脱時の自動保存**: 名前を変更して back で戻る（pop）と、変更後の名前が Firestore に保存され、一覧の行に反映される（既存 E2E: maestro/flows/category_edit_test.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **変更なし・空名では保存しない**: 名前を変更していない、または trim 後が空の場合、離脱時に保存を行わない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **バックグラウンド移行時の自動保存**: 名前変更後にアプリがバックグラウンドへ移行した場合も、変更後の名前を自動保存する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. カテゴリカラーの設定・解除

- [ ] **プリセットカラーの選択**: カラーサークルをタップすると即座にそのカラーを保存する（選択中は枠が強調され、一覧行のアイコン色にも反映される）（既存 E2E: maestro/flows/category_edit_test.yaml）
- [ ] **カラー解除**: 先頭の「色なし」（⊘ アイコン）をタップすると color を null にして保存する（既存 E2E: maestro/flows/category_edit_test.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **プリセットカラーの選択**: カラーサークルをタップすると即座にそのカラーを保存する（選択中は枠が強調され、一覧行のアイコン色にも反映される）（既存 E2E: maestro/flows/category_edit_test.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **カラー解除**: 先頭の「色なし」（⊘ アイコン）をタップすると color を null にして保存する（既存 E2E: maestro/flows/category_edit_test.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. カテゴリアイコンの設定・解除

- [ ] **プリセットアイコンの選択**: アイコンをタップすると即座にそのアイコンを保存する（選択中は枠とアイコン色が強調される）（既存 E2E: maestro/flows/category_edit_test.yaml）
- [ ] **アイコン解除**: 先頭の「アイコンなし」（⊘）をタップすると iconName を null にして保存する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **プリセットアイコンの選択**: アイコンをタップすると即座にそのアイコンを保存する（選択中は枠とアイコン色が強調される）（既存 E2E: maestro/flows/category_edit_test.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **アイコン解除**: 先頭の「アイコンなし」（⊘）をタップすると iconName を null にして保存する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. キーワードの追加

- [ ] **追加ダイアログの表示**: 「キーワード」セクションの＋ボタンで「キーワードを追加」ダイアログを開き、キーワード入力欄とマッチング種別（部分一致/完全一致/正規表現）の SegmentedButton を表示する。既定は部分一致（既存 E2E: maestro/flows/category_crud.yaml）
- [ ] **キーワードの確定**: 入力して「追加」をタップすると、選択したマッチング種別でキーワードを category に追加保存する。入力が空（trim 後）の場合は何もしない（既存 E2E: maestro/flows/category_matching_test.yaml）
- [ ] **追加のキャンセル**: 「キャンセル」でダイアログを閉じ、キーワードを追加しない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **追加ダイアログの表示**: 「キーワード」セクションの＋ボタンで「キーワードを追加」ダイアログを開き、キーワード入力欄とマッチング種別（部分一致/完全一致/正規表現）の SegmentedButton を表示する。既定は部分一致（既存 E2E: maestro/flows/category_crud.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **キーワードの確定**: 入力して「追加」をタップすると、選択したマッチング種別でキーワードを category に追加保存する。入力が空（trim 後）の場合は何もしない（既存 E2E: maestro/flows/category_matching_test.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **追加のキャンセル**: 「キャンセル」でダイアログを閉じ、キーワードを追加しない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. キーワードの一覧表示・削除

- [ ] **キーワード一覧の表示**: 登録済みキーワードを行で表示し、サブタイトルにマッチング種別（完全一致/部分一致/正規表現）を表示する。0件時は「キーワードがまだありません」を表示する
- [ ] **キーワードの削除**: 各行の削除アイコンをタップすると、そのキーワードを即座に削除保存する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **キーワード一覧の表示**: 登録済みキーワードを行で表示し、サブタイトルにマッチング種別（完全一致/部分一致/正規表現）を表示する。0件時は「キーワードがまだありません」を表示する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **キーワードの削除**: 各行の削除アイコンをタップすると、そのキーワードを即座に削除保存する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---
