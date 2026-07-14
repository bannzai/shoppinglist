---
feature: shopping_list_setting
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# shopping_list_setting QA

買い物リスト設定画面は、リスト上部バー右のリスト設定アイコン（tooltip「リスト設定」）からボトムシートで開く。

## 1. リスト名の編集

- [ ] **リスト名の保存**: 「リスト名」欄を編集し確定キー（onSubmitted）で保存する。保存後、上部バーのリスト名とリスト切替シートに反映される（既存 E2E: maestro/flows/shopping_list_crud.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **リスト名の保存**: 「リスト名」欄を編集し確定キー（onSubmitted）で保存する。保存後、上部バーのリスト名とリスト切替シートに反映される（既存 E2E: maestro/flows/shopping_list_crud.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. カテゴリへの遷移

- [ ] **カテゴリ画面へ遷移**: 「カテゴリ」セル（サブタイトル「自動分類のキーワード管理」）タップで GroupCategoryPage へ遷移する（既存 E2E: maestro/flows/design_v2_list_settings.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **カテゴリ画面へ遷移**: 「カテゴリ」セル（サブタイトル「自動分類のキーワード管理」）タップで GroupCategoryPage へ遷移する（既存 E2E: maestro/flows/design_v2_list_settings.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. 保存期間

- [ ] **保存期間の表示とアップグレード**: 非プレミアムは「作成から30日間」+「アップグレード」Pill、プレミアムは「プレミアム: 無制限」を表示する。Pill タップでペイウォールを開く（プレミアムは開発者オプション →「プレミアム付与（1 日）」で付与して確認）（既存 E2E: maestro/flows/shopping_list_display_period_non_premium.yaml, maestro/flows/premium_shopping_list_display_period.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **保存期間の表示とアップグレード**: 非プレミアムは「作成から30日間」+「アップグレード」Pill、プレミアムは「プレミアム: 無制限」を表示する。Pill タップでペイウォールを開く（プレミアムは開発者オプション →「プレミアム付与（1 日）」で付与して確認）（既存 E2E: maestro/flows/shopping_list_display_period_non_premium.yaml, maestro/flows/premium_shopping_list_display_period.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. 共有（招待・グループ設定）

- [ ] **招待コード作成**: 「グループに招待コードを送る」タップで招待コードを作成し、コード・残り有効期限を表示するダイアログを開く（既存 E2E: maestro/flows/design_v2_list_settings.yaml）
- [ ] **グループ名未設定ガード**: グループ名が未設定のとき、招待前に「招待する前にグループ名を設定してください」トースト +「グループ設定」導線を出し、招待コードを作成しない
- [ ] **コードのコピー・共有**: 招待コードダイアログの「コピー」でクリップボードへコピー（「招待コードをコピーしました」トースト）、「共有」で OS 共有シートを開く
- [ ] **グループ設定へ遷移**: 「グループ設定」セルタップで GroupSettingPage へ遷移する（既存 E2E: maestro/flows/design_v2_list_settings.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **招待コード作成**: 「グループに招待コードを送る」タップで招待コードを作成し、コード・残り有効期限を表示するダイアログを開く（既存 E2E: maestro/flows/design_v2_list_settings.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **グループ名未設定ガード**: グループ名が未設定のとき、招待前に「招待する前にグループ名を設定してください」トースト +「グループ設定」導線を出し、招待コードを作成しない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **コードのコピー・共有**: 招待コードダイアログの「コピー」でクリップボードへコピー（「招待コードをコピーしました」トースト）、「共有」で OS 共有シートを開く

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **グループ設定へ遷移**: 「グループ設定」セルタップで GroupSettingPage へ遷移する（既存 E2E: maestro/flows/design_v2_list_settings.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. リストの複製

- [ ] **リスト複製**: 「現在のリストを複製」で全アイテムを引き継いだリストを作成し「リストを複製しました」トーストを出す。無料上限超過時は上限トースト（アップグレード導線）を出す

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **リスト複製**: 「現在のリストを複製」で全アイテムを引き継いだリストを作成し「リストを複製しました」トーストを出す。無料上限超過時は上限トースト（アップグレード導線）を出す

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 6. リストの削除

- [ ] **削除確認ダイアログ**: 「このリストを削除」タップで「このリストを削除しますか?」+「『リスト名』とその中の N件 のアイテムが削除されます。元に戻せません。」を表示する（既存 E2E: maestro/flows/design_v2_list_settings.yaml）
- [ ] **削除実行 / キャンセル**: 「削除」でリストを削除して先頭画面まで戻る。「キャンセル」でダイアログを閉じる（既存 E2E: maestro/flows/shopping_list_crud.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **削除確認ダイアログ**: 「このリストを削除」タップで「このリストを削除しますか?」+「『リスト名』とその中の N件 のアイテムが削除されます。元に戻せません。」を表示する（既存 E2E: maestro/flows/design_v2_list_settings.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **削除実行 / キャンセル**: 「削除」でリストを削除して先頭画面まで戻る。「キャンセル」でダイアログを閉じる（既存 E2E: maestro/flows/shopping_list_crud.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
