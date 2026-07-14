---
feature: group_list
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# group_list QA

## 1. グループ一覧の表示

- [ ] **ローディング・エラー表示**: appUser / userGroups の取得中は CircularProgressIndicator、いずれかが取得失敗のときは ErrorView を表示する
- [ ] **グループ0件の表示**: 所属グループが0件のとき「所属しているグループはありません」を表示する
- [ ] **グループカードの一覧表示**: 所属グループを card 一覧（ListView）で表示する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ローディング・エラー表示**: appUser / userGroups の取得中は CircularProgressIndicator、いずれかが取得失敗のときは ErrorView を表示する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **グループ0件の表示**: 所属グループが0件のとき「所属しているグループはありません」を表示する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **グループカードの一覧表示**: 所属グループを card 一覧（ListView）で表示する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. グループカードの内容

- [ ] **メンバーアバターの表示**: カード左端にメンバーの頭文字アバターを最大3人分（displayName 先頭1文字、無ければ「?」）重ねて表示する。メンバー0人時は人型アイコンを表示する
- [ ] **グループ名とデフォルトバッジ**: グループ名（未設定時は「名前未設定」）を表示し、デフォルトグループ（appUser.defaultGroupID 一致）には「デフォルト」バッジを付ける
- [ ] **メンバー数の表示**: 「メンバー N人」（N = memberUserIDs の数）を表示する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **メンバーアバターの表示**: カード左端にメンバーの頭文字アバターを最大3人分（displayName 先頭1文字、無ければ「?」）重ねて表示する。メンバー0人時は人型アイコンを表示する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **グループ名とデフォルトバッジ**: グループ名（未設定時は「名前未設定」）を表示し、デフォルトグループ（appUser.defaultGroupID 一致）には「デフォルト」バッジを付ける

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **メンバー数の表示**: 「メンバー N人」（N = memberUserIDs の数）を表示する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. グループの選択

- [ ] **カードタップで設定画面へ**: グループカードをタップすると、そのグループの GroupSettingPage へ遷移する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **カードタップで設定画面へ**: グループカードをタップすると、そのグループの GroupSettingPage へ遷移する

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. 無料プランの上限バナーと FAB

- [ ] **上限バナーの表示（無料）**: 無料プランのとき一覧末尾に「無料プランは追加 1 グループまで」バナーを表示し、「解除」でペイウォールを開く
- [ ] **FAB からグループ作成**: 上限未到達のとき右下 FAB「グループ作成」をタップすると GroupCreatePage へ遷移する（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）
- [ ] **上限到達で FAB 非表示（無料）**: 無料プランで自分がオーナーのグループが2個（ソログループ+1）に達すると FAB が非表示になり、作成画面を開けない（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **上限バナーの表示（無料）**: 無料プランのとき一覧末尾に「無料プランは追加 1 グループまで」バナーを表示し、「解除」でペイウォールを開く

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **FAB からグループ作成**: 上限未到達のとき右下 FAB「グループ作成」をタップすると GroupCreatePage へ遷移する（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **上限到達で FAB 非表示（無料）**: 無料プランで自分がオーナーのグループが2個（ソログループ+1）に達すると FAB が非表示になり、作成画面を開けない（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. プレミアム時の挙動

- [ ] **バナー非表示・FAB常時表示**: プレミアム状態では上限バナーを表示せず、FAB を常に表示して2個目以降も作成できる（開発者オプション →「プレミアム付与（1日）」で付与して確認）（既存 E2E: maestro/flows/premium_group_creation.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **バナー非表示・FAB常時表示**: プレミアム状態では上限バナーを表示せず、FAB を常に表示して2個目以降も作成できる（開発者オプション →「プレミアム付与（1日）」で付与して確認）（既存 E2E: maestro/flows/premium_group_creation.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---
