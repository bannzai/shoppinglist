---
feature: group_create
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# group_create QA

## 1. グループ名の入力とボタン活性

- [ ] **名前入力欄のオートフォーカス**: 画面表示時にグループ名 TextField が autofocus され、hint「グループ名を入力」を表示する
- [ ] **空名では作成ボタン無効**: グループ名が空、または空白のみのとき「作成する」ボタンは無効（onPressed: null）（Issue #432）
- [ ] **入力で作成ボタン有効化**: グループ名に非空の文字（trim 後）を入力すると「作成する」ボタンが有効になる（Issue #432）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **名前入力欄のオートフォーカス**: 画面表示時にグループ名 TextField が autofocus され、hint「グループ名を入力」を表示する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **空名では作成ボタン無効**: グループ名が空、または空白のみのとき「作成する」ボタンは無効（onPressed: null）（Issue #432）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **入力で作成ボタン有効化**: グループ名に非空の文字（trim 後）を入力すると「作成する」ボタンが有効になる（Issue #432）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. アイコン選択

- [ ] **6種アイコンの表示**: home/cart/fork/cookie/pets/bag の6アイコンを3x2グリッドで表示する（既定選択は home）
- [ ] **アイコン選択の切替**: アイコンをタップすると選択状態がそのアイコンに切り替わり、選択中のアイコンが accentSoft 背景・accent 枠で強調表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **6種アイコンの表示**: home/cart/fork/cookie/pets/bag の6アイコンを3x2グリッドで表示する（既定選択は home）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **アイコン選択の切替**: アイコンをタップすると選択状態がそのアイコンに切り替わり、選択中のアイコンが accentSoft 背景・accent 枠で強調表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. グループ作成

- [ ] **作成の実行**: 「作成する」をタップすると createGroup を実行し、実行中はボタン表示が「作成中...」に変わる（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）
- [ ] **作成エラー表示**: 作成に失敗した場合、名前入力欄の下に赤いエラーコンテナでエラーメッセージ（そのまま表示）を出す
- [ ] **プレミアム時の2個目作成**: プレミアム状態では2個目以降のグループも作成でき、上限 SnackBar は出ない（開発者オプション →「プレミアム付与（1日）」で付与して確認）（既存 E2E: maestro/flows/premium_group_creation.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **作成の実行**: 「作成する」をタップすると createGroup を実行し、実行中はボタン表示が「作成中...」に変わる（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **作成エラー表示**: 作成に失敗した場合、名前入力欄の下に赤いエラーコンテナでエラーメッセージ（そのまま表示）を出す

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **プレミアム時の2個目作成**: プレミアム状態では2個目以降のグループも作成でき、上限 SnackBar は出ない（開発者オプション →「プレミアム付与（1日）」で付与して確認）（既存 E2E: maestro/flows/premium_group_creation.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. 作成後の招待ダイアログ

- [ ] **招待コードの表示**: グループ作成成功後、招待コードを自動発行して「メンバーを招待」ダイアログに招待コードを表示する（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）
- [ ] **招待コードのコピー**: 「コピー」でクリップボードにコピーし、「招待コードをコピーしました」のグローバルトーストを前面に表示する
- [ ] **招待コードの共有**: 「共有」で OS の共有シートを開く
- [ ] **閉じて画面終了**: 「閉じる」でダイアログを閉じ、グループ作成画面も pop してグループ一覧へ戻る（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **招待コードの表示**: グループ作成成功後、招待コードを自動発行して「メンバーを招待」ダイアログに招待コードを表示する（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **招待コードのコピー**: 「コピー」でクリップボードにコピーし、「招待コードをコピーしました」のグローバルトーストを前面に表示する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **招待コードの共有**: 「共有」で OS の共有シートを開く

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **閉じて画面終了**: 「閉じる」でダイアログを閉じ、グループ作成画面も pop してグループ一覧へ戻る（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---
