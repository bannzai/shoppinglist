---
feature: shopping_list_setting
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# shopping_list_setting QA

## 1. リスト名編集

- [ ] **リスト名の変更**: リスト名フィールドを編集しEnterで確定すると、買い物リストの名前が更新され上部バー・リスト切替シートにも反映される。maestro/flows/shopping_list_crud.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 2. 表示されないセクションの確認

- [ ] **「買い物する場所」セクションの非表示**: `shoppingLocationFeatureEnabled=false`（issue #465）のため、「買い物する場所」セクションはリスト設定画面に表示されない。maestro/flows/design_v2_list_settings.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 3. カテゴリ管理への導線

- [ ] **カテゴリCellタップでの遷移**: 「カテゴリ」Cell（サブタイトル「自動分類のキーワード管理」）をタップすると GroupCategoryPage に遷移する。maestro/flows/design_v2_list_settings.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 4. 保存期間表示

- [ ] **非プレミアムの保存期間表示**: 非プレミアムでは「作成から30日間」の説明とアップグレードPillが表示され、Pillタップでpaywallが開く。maestro/flows/shopping_list_display_period_non_premium.yaml で確認。
- [ ] **プレミアムの保存期間表示**: プレミアムでは「プレミアム: 無制限」が表示され、アップグレードPillは表示されない。maestro/flows/premium_shopping_list_display_period.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 5. 共有

- [ ] **招待コードの送付**: 「グループに招待コードを送る」タップで招待コード・有効期限（7日間）が表示され、コピー・共有ができる。グループ名が未設定の場合は招待を作成せず、グループ設定画面へ誘導するトーストが表示される。maestro/flows/design_v2_list_settings.yaml で確認。
- [ ] **グループ設定への遷移**: 「グループ設定」Cellタップで GroupSettingPage に遷移する。maestro/flows/design_v2_list_settings.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 6. リストの操作（複製）

- [ ] **現在のリストを複製**: 「リストの操作」の「現在のリストを複製」タップで、全アイテムを引き継いだ複製リストが作成される。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 7. リストの削除

- [ ] **削除確認ダイアログと削除実行**: 「このリストを削除」タップで、リスト名とアイテム件数を含む確認ダイアログが表示され、「削除」確定でリストとその中のアイテムがすべて削除される。maestro/flows/design_v2_list_settings.yaml, shopping_list_crud.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---
