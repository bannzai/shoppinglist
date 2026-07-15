---
feature: shopping_list_setting
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-15
---

# shopping_list_setting QA

買い物リスト設定画面は、リスト上部バー右のリスト設定アイコン（tooltip「リスト設定」）からボトムシートで開く。

## 1. リスト名の編集

- [x] **リスト名の保存**: 「リスト名」欄を編集し確定キー（onSubmitted）で保存する。保存後、上部バーのリスト名とリスト切替シートに反映される（既存 E2E: maestro/flows/shopping_list_crud.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **リスト名の保存**: 「リスト名」欄を編集し確定キー（onSubmitted）で保存する。保存後、上部バーのリスト名とリスト切替シートに反映される（既存 E2E: maestro/flows/shopping_list_crud.yaml）

「リスト名」欄を全選択→「週末の買い物」に変更し return で確定（`submit_list_name` イベント発火）。シートを閉じると上部バーのリスト名が「週末の買い物」に反映された。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/5ba860bd-7e68-41d3-b4cd-c25d9098ca19.png" width="320">

</details>

</details>

---

## 2. カテゴリへの遷移

- [x] **カテゴリ画面へ遷移**: 「カテゴリ」セル（サブタイトル「自動分類のキーワード管理」）タップで GroupCategoryPage へ遷移する（既存 E2E: maestro/flows/design_v2_list_settings.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **カテゴリ画面へ遷移**: 「カテゴリ」セル（サブタイトル「自動分類のキーワード管理」）タップで GroupCategoryPage へ遷移する（既存 E2E: maestro/flows/design_v2_list_settings.yaml）

「カテゴリ」セルタップで GroupCategoryPage（タイトル「カテゴリ」・空状態「買ったものを自動でグループ分け」）へ遷移した（`navigate_category_from_list_setting` イベント発火）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/d0105032-0c82-4f43-be25-bb6ffa920ffe.png" width="320">

</details>

</details>

---

## 3. 保存期間

- [x] **保存期間の表示とアップグレード**: 非プレミアムは「作成から30日間」+「アップグレード」Pill、プレミアムは「プレミアム: 無制限」を表示する。Pill タップでペイウォールを開く（プレミアムは開発者オプション →「プレミアム付与（1 日）」で付与して確認）（既存 E2E: maestro/flows/shopping_list_display_period_non_premium.yaml, maestro/flows/premium_shopping_list_display_period.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **保存期間の表示とアップグレード**: 非プレミアムは「作成から30日間」+「アップグレード」Pill、プレミアムは「プレミアム: 無制限」を表示する。Pill タップでペイウォールを開く（プレミアムは開発者オプション →「プレミアム付与（1 日）」で付与して確認）（既存 E2E: maestro/flows/shopping_list_display_period_non_premium.yaml, maestro/flows/premium_shopping_list_display_period.yaml）

- 非プレミアム: 保存期間に「作成から30日間」+「プレミアムなら期限なしで残せます」+「アップグレード」Pill を表示（1枚目）。
- 「アップグレード」Pill タップでペイウォール（プレミアムにアップグレード）が開いた（`tap_storage_period_upgrade` イベント発火、2枚目）。
- 開発者オプション →「プレミアム付与（1 日）」で付与（`grantPromotionalPremium` OK / Premium(RC): true）後、保存期間が「プレミアム: 無制限」（無限アイコン、アップグレード Pill 非表示）に変わった（3枚目）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

非プレミアム表示（作成から30日間 + アップグレード Pill）:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/49a517ef-1e08-43bc-8df4-a048dc5e3038.png" width="320">

アップグレード Pill タップ → ペイウォール:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/9dc08f4f-bbe3-4174-9dc8-f480af9b735e.png" width="320">

プレミアム付与後（プレミアム: 無制限）:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/880c266a-159d-49db-813c-9d6069dea076.png" width="320">

</details>

</details>

---

## 4. 共有（招待・グループ設定）

- [x] **招待コード作成**: 「グループに招待コードを送る」タップで招待コードを作成し、コード・残り有効期限を表示するダイアログを開く（既存 E2E: maestro/flows/design_v2_list_settings.yaml）
- [x] **グループ名未設定ガード**: グループ名が未設定のとき、招待前に「招待する前にグループ名を設定してください」トースト +「グループ設定」導線を出し、招待コードを作成しない
  - グループ名を持つ既存グループでは本ガードは発火しない（name=null のグループが前提）。再現には匿名サインイン →「自分のリストを作る」（`createGroup(name: null)`）で name=null のソログループを作る必要がある。専用 flow を新規作成した: `maestro --device <UDID> test -e APP_ID=com.bannzai.shoppinglist.dev maestro/flows/shopping_list_setting_group_name_guard.yaml`（全アサート pass。「招待する前にグループ名を設定してください」トースト表示 + 招待ダイアログ非表示を確認）
- [x] **コードのコピー・共有**: 招待コードダイアログの「コピー」でクリップボードへコピー（「招待コードをコピーしました」トースト）、「共有」で OS 共有シートを開く
- [x] **グループ設定へ遷移**: 「グループ設定」セルタップで GroupSettingPage へ遷移する（既存 E2E: maestro/flows/design_v2_list_settings.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **招待コード作成**: 「グループに招待コードを送る」タップで招待コードを作成し、コード・残り有効期限を表示するダイアログを開く（既存 E2E: maestro/flows/design_v2_list_settings.yaml）

「グループに招待コードを送る」タップで招待コード（7NFHFQQN）+「有効期限: 7日間 ・ 残り 6日23時間」+「コピー」/「共有」を表示するダイアログが開いた（`createGroupInvitation` OK）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/d0e5b2ce-0c45-4395-b5eb-d3c341ae964c.png" width="320">

</details>

### **グループ名未設定ガード**: グループ名が未設定のとき、招待前に「招待する前にグループ名を設定してください」トースト +「グループ設定」導線を出し、招待コードを作成しない

匿名サインイン →「自分のリストを作る」で name=null のソログループを作成した状態で「グループに招待コードを送る」をタップ。「招待する前にグループ名を設定してください」+「グループ設定」導線のトーストが表示され、招待コードダイアログ（有効期限表示）は開かなかった（maestro flow の assertVisible / assertNotVisible が両方 pass）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/7d8ab0d5-4211-49cd-8894-c0890339ddb6.png" width="320">

</details>

### **コードのコピー・共有**: 招待コードダイアログの「コピー」でクリップボードへコピー（「招待コードをコピーしました」トースト）、「共有」で OS 共有シートを開く

- 「コピー」タップで「招待コードをコピーしました」グローバルトースト表示（1枚目）。
- 「共有」タップで OS 共有シート（「買い物リストの招待コード: 7NFHFQQN」）が開いた（2枚目）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

コピートースト:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/37b07a27-f9b2-44ba-b050-cd06b7404b98.png" width="320">

OS 共有シート:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/e0a58624-1f06-4c48-80a4-c82abde2f334.png" width="320">

</details>

### **グループ設定へ遷移**: 「グループ設定」セルタップで GroupSettingPage へ遷移する（既存 E2E: maestro/flows/design_v2_list_settings.yaml）

「グループ設定」セルタップで GroupSettingPage（グループ名・メンバー一覧・カテゴリ・グループ招待）へ遷移した（`tap_navigate_grp_setting` イベント発火）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/f4391400-c8f6-4824-ac5a-371412097da6.png" width="320">

</details>

</details>

---

## 5. リストの複製

- [x] **リスト複製**: 「現在のリストを複製」で全アイテムを引き継いだリストを作成し「リストを複製しました」トーストを出す。無料上限超過時は上限トースト（アップグレード導線）を出す

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **リスト複製**: 「現在のリストを複製」で全アイテムを引き継いだリストを作成し「リストを複製しました」トーストを出す。無料上限超過時は上限トースト（アップグレード導線）を出す

「現在のリストを複製」タップで複製リストを作成し「リストを複製しました」グローバルトーストを表示（`tap_duplicate_list` イベント発火、上部バーに複製リストが増えたことを確認）。無料上限超過時の上限トーストは、上限（リスト数）に達する状況を用意できなかったため未確認（コード上は `ShoppingListLimitExceededException` を catch し `showGlobalActionToast`（アップグレード導線）を表示、`lib/features/shopping_list_setting/page.dart` L601-606）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/f28d63f2-c748-47be-a529-d75e02db476c.png" width="320">

</details>

</details>

---

## 6. リストの削除

- [x] **削除確認ダイアログ**: 「このリストを削除」タップで「このリストを削除しますか?」+「『リスト名』とその中の N件 のアイテムが削除されます。元に戻せません。」を表示する（既存 E2E: maestro/flows/design_v2_list_settings.yaml）
- [x] **削除実行 / キャンセル**: 「削除」でリストを削除して先頭画面まで戻る。「キャンセル」でダイアログを閉じる（既存 E2E: maestro/flows/shopping_list_crud.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **削除確認ダイアログ**: 「このリストを削除」タップで「このリストを削除しますか?」+「『リスト名』とその中の N件 のアイテムが削除されます。元に戻せません。」を表示する（既存 E2E: maestro/flows/design_v2_list_settings.yaml）

「このリストを削除」タップで「このリストを削除しますか?」+「『週末の買い物』とその中の 0件 のアイテムが削除されます。元に戻せません。」+「キャンセル」/「削除」ダイアログを表示（`tap_delete_list` イベント発火）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/5a47e814-c3b4-41a2-abdf-2943a5306892.png" width="320">

</details>

### **削除実行 / キャンセル**: 「削除」でリストを削除して先頭画面まで戻る。「キャンセル」でダイアログを閉じる（既存 E2E: maestro/flows/shopping_list_crud.yaml）

- 「キャンセル」でダイアログが閉じてリスト設定シートに戻った（`cancel_delete_list` イベント発火、1枚目）。
- 別リストで「削除」を実行するとリストが削除され、シートが閉じて先頭のリスト画面（残った「週末の買い物」リスト）に戻った（`tap_confirm_delete_list` イベント発火、2枚目）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

キャンセル（シートに戻る）:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/627baa10-03a8-462a-b149-bd1a39cafdff.png" width="320">

削除実行（先頭画面まで戻る）:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/c73d68b0-6d6b-432c-ae9c-efef782dad4f.png" width="320">

</details>

</details>
