---
feature: shopping_list_setting
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# shopping_list_setting QA

## 1. リスト名編集

- [x] **リスト名の変更**: リスト名フィールドを編集しEnterで確定すると、買い物リストの名前が更新され上部バー・リスト切替シートにも反映される。maestro/flows/shopping_list_crud.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **リスト名の変更**: リスト名フィールドを編集しEnterで確定すると、買い物リストの名前が更新され上部バー・リスト切替シートにも反映される。maestro/flows/shopping_list_crud.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/shopping_list_crud.yaml` は全ステップ COMPLETED したが、リネーム操作の tap 座標 `point: "50%, 18%"` が実際の TextField（y≈190-217pt）ではなく「リスト名」ラベル（y≈157pt）を指しており、リネームが反映されないまま次に進んでいた（flow内にリネーム後の文言 assert が無いため未検知）。mobile-mcp で TextField（座標 x=32,y=190,width=338,height=27）を直接タップし Select All → 入力 → Enter でリネームしたところ、上部バー・リスト切替シートの両方に正しく反映されることを確認した。アプリ本体の不具合ではなく maestro flow 側の座標ずれ。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/92c09dad-913d-4c42-b580-857c8de48e3b.png" width="320">

</details>

</details>

---

## 2. 表示されないセクションの確認

- [x] **「買い物する場所」セクションの非表示**: `shoppingLocationFeatureEnabled=false`（issue #465）のため、「買い物する場所」セクションはリスト設定画面に表示されない。maestro/flows/design_v2_list_settings.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **「買い物する場所」セクションの非表示**: `shoppingLocationFeatureEnabled=false`（issue #465）のため、「買い物する場所」セクションはリスト設定画面に表示されない。maestro/flows/design_v2_list_settings.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcp で「リスト名」の直後に「カテゴリ」セクションが続き、「買い物する場所」セクションが存在しないことを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/33634b64-f997-4f4c-957d-bf1f4d0c986d.png" width="320">

</details>

</details>

---

## 3. カテゴリ管理への導線

- [x] **カテゴリCellタップでの遷移**: 「カテゴリ」Cell（サブタイトル「自動分類のキーワード管理」）をタップすると GroupCategoryPage に遷移する。maestro/flows/design_v2_list_settings.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **カテゴリCellタップでの遷移**: 「カテゴリ」Cell（サブタイトル「自動分類のキーワード管理」）をタップすると GroupCategoryPage に遷移する。maestro/flows/design_v2_list_settings.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/design_v2_list_settings.yaml` 実行時、「自動分類のキーワード管理」テキストの visible/tap assertion が WARNED になった（AppCell の icon+title+subtitle が iOS accessibility 上 1つの意味論ノード「カテゴリ\n自動分類のキーワード管理」に統合されるため、単純な部分一致で拾えなかったとみられる。アプリの不具合ではなく flow 側の検出漏れ）。mobile-mcp で該当 Cell を直接タップし、GroupCategoryPage（「買ったものを自動でグループ分け」画面）へ正しく遷移することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/baa381f0-f76a-40dd-ae85-d0e629ba260b.png" width="320">

</details>

</details>

---

## 4. 保存期間表示

- [x] **非プレミアムの保存期間表示**: 非プレミアムでは「作成から30日間」の説明とアップグレードPillが表示され、Pillタップでpaywallが開く。maestro/flows/shopping_list_display_period_non_premium.yaml で確認。
- [x] **プレミアムの保存期間表示**: プレミアムでは「プレミアム: 無制限」が表示され、アップグレードPillは表示されない。maestro/flows/premium_shopping_list_display_period.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **非プレミアムの保存期間表示**: 非プレミアムでは「作成から30日間」の説明とアップグレードPillが表示され、Pillタップでpaywallが開く。maestro/flows/shopping_list_display_period_non_premium.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/shopping_list_display_period_non_premium.yaml` 実行、全ステップ COMPLETED。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/6328f384-a4d9-4806-994a-d6ead52cf2f9.png" width="320">

</details>

### **プレミアムの保存期間表示**: プレミアムでは「プレミアム: 無制限」が表示され、アップグレードPillは表示されない。maestro/flows/premium_shopping_list_display_period.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/premium_shopping_list_display_period.yaml` 実行（開発者オプションでプレミアム付与後）、全ステップ COMPLETED。「作成から30日間」非表示・「プレミアム: 無制限」表示を確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/2bb33c8b-778b-4342-b9a3-fbdd86b9bb93.png" width="320">

</details>

</details>

---

## 5. 共有

- [ ] **招待コードの送付**: 「グループに招待コードを送る」タップで招待コード・有効期限（7日間）が表示され、コピー・共有ができる。グループ名が未設定の場合は招待を作成せず、グループ設定画面へ誘導するトーストが表示される。maestro/flows/design_v2_list_settings.yaml で確認。
  - ❌ 失敗: 招待コード・有効期限の表示、グループ名未設定時のトースト誘導は正常。ただし招待コードダイアログ（`InvitationCodeDialog`）に閉じるボタンが無く、`showGeneralDialog(barrierDismissible: true)` にもかかわらず背景タップでも閉じられない。アプリ強制終了以外に画面から抜けられない。issue: https://github.com/bannzai/shoppinglist/issues/473
- [x] **グループ設定への遷移**: 「グループ設定」Cellタップで GroupSettingPage に遷移する。maestro/flows/design_v2_list_settings.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **招待コードの送付**: 「グループに招待コードを送る」タップで招待コード・有効期限（7日間）が表示され、コピー・共有ができる。グループ名が未設定の場合は招待を作成せず、グループ設定画面へ誘導するトーストが表示される。maestro/flows/design_v2_list_settings.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

グループ名未設定時のトースト誘導:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/92c09dad-913d-4c42-b580-857c8de48e3b.png" width="320">

グループ名設定後の招待コードダイアログ（コード・有効期限は正常表示。閉じる手段がない不具合は issue #473 参照）:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/96d04f42-c130-40bb-823f-35f6475c1170.png" width="320">

</details>

### **グループ設定への遷移**: 「グループ設定」Cellタップで GroupSettingPage に遷移する。maestro/flows/design_v2_list_settings.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/1d94fc0a-a048-41fb-96ab-cf2f563bd9dc.png" width="320">

</details>

</details>

---

## 6. リストの操作（複製）

- [x] **現在のリストを複製**: 「リストの操作」の「現在のリストを複製」タップで、全アイテムを引き継いだ複製リストが作成される。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **現在のリストを複製**: 「リストの操作」の「現在のリストを複製」タップで、全アイテムを引き継いだ複製リストが作成される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

対応する maestro flow は無いため mobile-mcp で検証。「2026-07-05」に「牛乳」「パン」の2件を追加し、リスト設定の「現在のリストを複製」をタップ。「2026-07-05 (1)」（「2026-07-05から複製」表示付き）が作成され、両アイテムが引き継がれていることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/2e2df3ce-8ba2-4853-beee-fb17d2eb67e3.png" width="320">

</details>

</details>

---

## 7. リストの削除

- [x] **削除確認ダイアログと削除実行**: 「このリストを削除」タップで、リスト名とアイテム件数を含む確認ダイアログが表示され、「削除」確定でリストとその中のアイテムがすべて削除される。maestro/flows/design_v2_list_settings.yaml, shopping_list_crud.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **削除確認ダイアログと削除実行**: 「このリストを削除」タップで、リスト名とアイテム件数を含む確認ダイアログが表示され、「削除」確定でリストとその中のアイテムがすべて削除される。maestro/flows/design_v2_list_settings.yaml, shopping_list_crud.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/shopping_list_crud.yaml` 実行、全ステップ COMPLETED。削除確認ダイアログ表示 → 「削除」確定 → 対象リストが一覧から消え、残りのリストに切り替わることを確認。`maestro/flows/design_v2_list_settings.yaml` でも削除ダイアログの文言（「このリストを削除しますか?」）表示と「キャンセル」動作を確認済み。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/b2b84470-f80a-49f7-8b26-10a1d32475fa.png" width="320">

</details>

</details>

---
