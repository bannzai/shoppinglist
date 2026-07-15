---
feature: group_category_edit
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-15
---

# group_category_edit QA

## 1. カテゴリ名の編集と自動保存

- [x] **名前入力欄の表示**: カテゴリ名 TextField を表示し、未入力時は hint「カテゴリ名を入力」を表示する
- [x] **画面離脱時の自動保存**: 名前を変更して back で戻る（pop）と、変更後の名前が Firestore に保存され、一覧の行に反映される（既存 E2E: maestro/flows/category_edit_test.yaml）
- [x] **変更なし・空名では保存しない**: 名前を変更していない、または trim 後が空の場合、離脱時に保存を行わない
- [x] **バックグラウンド移行時の自動保存**: 名前変更後にアプリがバックグラウンドへ移行した場合も、変更後の名前を自動保存する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **名前入力欄の表示**: カテゴリ名 TextField を表示し、未入力時は hint「カテゴリ名を入力」を表示する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

新規カテゴリ作成直後（未入力）の編集画面で、名前 TextField に hint「カテゴリ名を入力」が表示された。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/ebf6e5e9-ddf9-4b0d-8a55-13420f457511.png" width="320">

</details>

### **画面離脱時の自動保存**: 名前を変更して back で戻る（pop）と、変更後の名前が Firestore に保存され、一覧の行に反映される（既存 E2E: maestro/flows/category_edit_test.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

maestro/flows/category_edit_test.yaml を実行。名前「テスト用」入力後、back シェブロンで離脱すると一覧に「テスト用」が反映された。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/fc0eb7da-919a-4eb1-8c9d-b32eead81e51.png" width="320">

</details>

### **変更なし・空名では保存しない**: 名前を変更していない、または trim 後が空の場合、離脱時に保存を行わない

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

新規カテゴリ（空名で作成）で名前を入力せずに back シェブロンで離脱すると、一覧の2件目行は名前欄が空のまま表示された（クラッシュ・不正な値での上書きなし）。コード上も `if (name.isEmpty || name == category.name) return;`（lib/features/group_category_edit/page.dart:104）で保存自体をスキップするガードを確認済み。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/624d6bcb-4f5b-40b9-a784-8ebe53a016ea.png" width="320">

</details>

### **バックグラウンド移行時の自動保存**: 名前変更後にアプリがバックグラウンドへ移行した場合も、変更後の名前を自動保存する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

新規カテゴリの名前欄に「バックグラウンドテスト」を入力後、maestro `pressKey: Home` でバックグラウンドへ移行 → `xcrun simctl launch <udid> com.bannzai.shoppinglist.dev` で前面復帰 → 編集画面から戻ると一覧に「バックグラウンドテスト」が反映されていた（Firestore への保存を確認）。手順の詳細は root QA.md の「再現が難しい操作の手順」を参照。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/b73f9429-3770-4209-b040-4c3aa891fad9.png" width="320">

</details>

</details>

---

## 2. カテゴリカラーの設定・解除

- [x] **プリセットカラーの選択**: カラーサークルをタップすると即座にそのカラーを保存する（選択中は枠が強調され、一覧行のアイコン色にも反映される）（既存 E2E: maestro/flows/category_edit_test.yaml）
- [x] **カラー解除**: 先頭の「色なし」（⊘ アイコン）をタップすると color を null にして保存する（既存 E2E: maestro/flows/category_edit_test.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **プリセットカラーの選択**: カラーサークルをタップすると即座にそのカラーを保存する（選択中は枠が強調され、一覧行のアイコン色にも反映される）（既存 E2E: maestro/flows/category_edit_test.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

赤いカラーサークルをタップすると即座にチェックマーク付きで強調表示された。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/91cb78b8-89fb-44fa-83a9-6cff36abb11d.png" width="320">

</details>

### **カラー解除**: 先頭の「色なし」（⊘ アイコン）をタップすると color を null にして保存する（既存 E2E: maestro/flows/category_edit_test.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

「色なし」（⊘）をタップするとそちらが強調表示され、色サークルの選択は解除された。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/9e40d497-32c7-40ec-9670-7dc44adadb06.png" width="320">

</details>

</details>

---

## 3. カテゴリアイコンの設定・解除

- [x] **プリセットアイコンの選択**: アイコンをタップすると即座にそのアイコンを保存する（選択中は枠とアイコン色が強調される）（既存 E2E: maestro/flows/category_edit_test.yaml）
- [x] **アイコン解除**: 先頭の「アイコンなし」（⊘）をタップすると iconName を null にして保存する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **プリセットアイコンの選択**: アイコンをタップすると即座にそのアイコンを保存する（選択中は枠とアイコン色が強調される）（既存 E2E: maestro/flows/category_edit_test.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

カートアイコンをタップすると即座に枠とアイコン色が強調表示された。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/f9b27342-4a4e-49c6-9165-2cbf06a2c520.png" width="320">

</details>

### **アイコン解除**: 先頭の「アイコンなし」（⊘）をタップすると iconName を null にして保存する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

カート選択済みの状態から「アイコンなし」（⊘）をタップすると即座に⊘側が強調表示された。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/3f20e583-5475-412d-a7f9-db9a5d41e9cd.png" width="320">

</details>

</details>

---

## 4. キーワードの追加

- [x] **追加ダイアログの表示**: 「キーワード」セクションの＋ボタンで「キーワードを追加」ダイアログを開き、キーワード入力欄とマッチング種別（部分一致/完全一致/正規表現）の SegmentedButton を表示する。既定は部分一致（既存 E2E: maestro/flows/category_crud.yaml）
- [x] **キーワードの確定**: 入力して「追加」をタップすると、選択したマッチング種別でキーワードを category に追加保存する。入力が空（trim 後）の場合は何もしない（既存 E2E: maestro/flows/category_matching_test.yaml）
- [x] **追加のキャンセル**: 「キャンセル」でダイアログを閉じ、キーワードを追加しない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **追加ダイアログの表示**: 「キーワード」セクションの＋ボタンで「キーワードを追加」ダイアログを開き、キーワード入力欄とマッチング種別（部分一致/完全一致/正規表現）の SegmentedButton を表示する。既定は部分一致（既存 E2E: maestro/flows/category_crud.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

「キーワードを追加」ボタンでダイアログが開き、入力欄と部分一致/完全一致/正規表現の SegmentedButton（既定: 部分一致）が表示された。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/fbee5fc7-6159-4bd3-9215-2b17fd80e14a.png" width="320">

</details>

### **キーワードの確定**: 入力して「追加」をタップすると、選択したマッチング種別でキーワードを category に追加保存する。入力が空（trim 後）の場合は何もしない（既存 E2E: maestro/flows/category_matching_test.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

「テストキーワード」を入力し部分一致のまま「追加」をタップすると、一覧に「テストキーワード」（部分一致）が反映された。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/27f8ec37-3b8d-4a29-a550-0ac9b93057e4.png" width="320">

</details>

### **追加のキャンセル**: 「キャンセル」でダイアログを閉じ、キーワードを追加しない

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

「キャンセルテスト」を入力後「キャンセル」をタップすると、ダイアログが閉じてキーワードは追加されず「キーワードがまだありません」のままだった。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/0c05ba53-8d2d-4882-b995-14e4ddbcb9b5.png" width="320">

</details>

</details>

---

## 5. キーワードの一覧表示・削除

- [x] **キーワード一覧の表示**: 登録済みキーワードを行で表示し、サブタイトルにマッチング種別（完全一致/部分一致/正規表現）を表示する。0件時は「キーワードがまだありません」を表示する
- [x] **キーワードの削除**: 各行の削除アイコンをタップすると、そのキーワードを即座に削除保存する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **キーワード一覧の表示**: 登録済みキーワードを行で表示し、サブタイトルにマッチング種別（完全一致/部分一致/正規表現）を表示する。0件時は「キーワードがまだありません」を表示する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

0件時は「キーワードがまだありません」を表示（下記スクショ上部の他項目でも同一状態を確認済み）。キーワード追加後は「テストキーワード」行にサブタイトル「部分一致」が表示された。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/27f8ec37-3b8d-4a29-a550-0ac9b93057e4.png" width="320">

</details>

### **キーワードの削除**: 各行の削除アイコンをタップすると、そのキーワードを即座に削除保存する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

「テストキーワード」行の削除アイコンをタップすると即座に削除され、「キーワードがまだありません」の空状態に戻った。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/6a99f412-f473-43dd-834f-095f975af20b.png" width="320">

</details>

</details>

---
