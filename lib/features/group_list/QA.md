---
feature: group_list
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# group_list QA

## 1. グループ一覧表示

- [ ] **グループカードの表示**: 所属グループがカード形式で一覧表示され、アバター（メンバー最大3人分の頭文字丸アイコン）、グループ名、「メンバー N人」が表示される
- [ ] **空状態の表示**: 所属グループが0件の場合、中央に「所属しているグループはありません」と表示される
- [ ] **デフォルトグループバッジ**: 自分の `defaultGroupID` と一致するグループのカードに「デフォルト」バッジが表示される
- [ ] **名前未設定グループの表示**: グループ名が未設定（null）の場合、カードに「名前未設定」と表示される
- [ ] **グループカードタップで設定画面へ遷移**: カードをタップするとグループ設定画面（GroupSettingPage）に遷移する。maestro/flows/group_setting.yaml で作成直後のカードタップ遷移を確認できる

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **グループカードの表示**: 所属グループがカード形式で一覧表示され、アバター（メンバー最大3人分の頭文字丸アイコン）、グループ名、「メンバー N人」が表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **空状態の表示**: 所属グループが0件の場合、中央に「所属しているグループはありません」と表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **デフォルトグループバッジ**: 自分の `defaultGroupID` と一致するグループのカードに「デフォルト」バッジが表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **名前未設定グループの表示**: グループ名が未設定（null）の場合、カードに「名前未設定」と表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **グループカードタップで設定画面へ遷移**: カードをタップするとグループ設定画面（GroupSettingPage）に遷移する。maestro/flows/group_setting.yaml で作成直後のカードタップ遷移を確認できる

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. グループ作成導線

- [ ] **FABからグループ作成画面へ遷移**: 右下FAB「グループ作成」タップでグループ作成画面に遷移する。maestro/flows/group_setting.yaml、maestro/flows/group_creation_limit_non_premium.yaml で確認できる
- [ ] **無料プラン上限到達時にFABが非表示になる**: 無料プランで追加グループ作成が上限（`freeAdditionalGroupCreationLimit` = 1件）に達すると、FAB自体が非表示になり新規作成できなくなる。maestro/flows/group_creation_limit_non_premium.yaml で確認できる
- [ ] **上限案内バナーの表示**: 上限到達時、一覧末尾に「無料プランは追加1グループまで」バナーが表示される
- [ ] **上限案内バナーからペイウォール表示**: バナーの「解除」タップでペイウォールが表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **FABからグループ作成画面へ遷移**: 右下FAB「グループ作成」タップでグループ作成画面に遷移する。maestro/flows/group_setting.yaml、maestro/flows/group_creation_limit_non_premium.yaml で確認できる

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **無料プラン上限到達時にFABが非表示になる**: 無料プランで追加グループ作成が上限（`freeAdditionalGroupCreationLimit` = 1件）に達すると、FAB自体が非表示になり新規作成できなくなる。maestro/flows/group_creation_limit_non_premium.yaml で確認できる

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **上限案内バナーの表示**: 上限到達時、一覧末尾に「無料プランは追加1グループまで」バナーが表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **上限案内バナーからペイウォール表示**: バナーの「解除」タップでペイウォールが表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. エッジケース

- [ ] **エラー時の表示**: グループ一覧またはユーザー情報の取得に失敗した場合、エラービュー（ErrorView）が表示される
- [ ] **ローディング中の表示**: データ取得中は中央にCircularProgressIndicatorが表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **エラー時の表示**: グループ一覧またはユーザー情報の取得に失敗した場合、エラービュー（ErrorView）が表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **ローディング中の表示**: データ取得中は中央にCircularProgressIndicatorが表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
