---
feature: group_setting
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# group_setting QA

## 1. 画面表示

- [ ] **画面表示**: 「グループ設定」タイトルでグループ設定画面が表示される。maestro/flows/group_setting.yaml で確認できる
- [ ] **メンバー一覧表示**: `/groups/{groupID}/userProfiles` のプロフィールがメンバー一覧に表示され、オーナーには「オーナー」、自分自身には「自分」のサブタイトルが付く
- [ ] **表示名未設定メンバーの表示**: displayNameが未設定のメンバーは「名前未設定」と表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **画面表示**: 「グループ設定」タイトルでグループ設定画面が表示される。maestro/flows/group_setting.yaml で確認できる

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **メンバー一覧表示**: `/groups/{groupID}/userProfiles` のプロフィールがメンバー一覧に表示され、オーナーには「オーナー」、自分自身には「自分」のサブタイトルが付く

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **表示名未設定メンバーの表示**: displayNameが未設定のメンバーは「名前未設定」と表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. グループ名編集

- [ ] **オーナーはグループ名を編集できる**: オーナーがグループ名入力欄を編集しEnter（onSubmitted）で確定すると保存される。maestro/flows/group_setting.yaml で確認できる
- [ ] **非オーナーは読み取り専用**: オーナー以外のメンバーが開いた場合、グループ名欄は読み取り専用（readOnly）で編集できない
- [ ] **空文字や変更なしでは更新されない**: 入力を空文字にする、または既存と同じ値でsubmitした場合は更新処理が呼ばれない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **オーナーはグループ名を編集できる**: オーナーがグループ名入力欄を編集しEnter（onSubmitted）で確定すると保存される。maestro/flows/group_setting.yaml で確認できる

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **非オーナーは読み取り専用**: オーナー以外のメンバーが開いた場合、グループ名欄は読み取り専用（readOnly）で編集できない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **空文字や変更なしでは更新されない**: 入力を空文字にする、または既存と同じ値でsubmitした場合は更新処理が呼ばれない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. メンバー削除

- [ ] **オーナーはメンバーを削除できる**: オーナーが自分以外のメンバーの削除アイコン（赤色）をタップすると確認ダイアログが表示され、「削除」で `removeGroupMember` Functionが呼ばれメンバーが一覧から消える
- [ ] **削除確認ダイアログのキャンセル**: 確認ダイアログの「キャンセル」でメンバーは削除されない
- [ ] **非オーナー・オーナー自身の行には削除ボタンが出ない**: 非オーナーが開いた画面、およびオーナー自身の行には削除アイコンが表示されない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **オーナーはメンバーを削除できる**: オーナーが自分以外のメンバーの削除アイコン（赤色）をタップすると確認ダイアログが表示され、「削除」で `removeGroupMember` Functionが呼ばれメンバーが一覧から消える

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **削除確認ダイアログのキャンセル**: 確認ダイアログの「キャンセル」でメンバーは削除されない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **非オーナー・オーナー自身の行には削除ボタンが出ない**: 非オーナーが開いた画面、およびオーナー自身の行には削除アイコンが表示されない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. グループ招待

- [ ] **招待コード発行**: 「招待コードを発行」ボタンをタップすると招待コードダイアログが表示される。maestro/flows/group_setting.yaml で確認できる
- [ ] **グループ名未設定時は発行をブロック**: グループ名が未入力（空・空白のみ）の状態で招待コード発行を試みると、「招待する前にグループ名を設定してください」とトースト表示され発行されない
- [ ] **未保存の入力中グループ名も招待時に保存される**: グループ名入力欄に未確定（onSubmitted前）の入力があっても、招待コード発行時にその値が先に保存されてから発行される
- [ ] **招待コードのコピー**: 招待コードダイアログの「コピー」タップでクリップボードにコードがコピーされ「招待コードをコピーしました」とトースト表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **招待コード発行**: 「招待コードを発行」ボタンをタップすると招待コードダイアログが表示される。maestro/flows/group_setting.yaml で確認できる

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **グループ名未設定時は発行をブロック**: グループ名が未入力（空・空白のみ）の状態で招待コード発行を試みると、「招待する前にグループ名を設定してください」とトースト表示され発行されない

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **未保存の入力中グループ名も招待時に保存される**: グループ名入力欄に未確定（onSubmitted前）の入力があっても、招待コード発行時にその値が先に保存されてから発行される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **招待コードのコピー**: 招待コードダイアログの「コピー」タップでクリップボードにコードがコピーされ「招待コードをコピーしました」とトースト表示される

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. 関連機能への導線

- [ ] **カテゴリ画面への遷移**: 「カテゴリ」セルタップでGroupCategoryPageに遷移する。maestro/flows/group_setting.yaml で確認できる
- [ ] **買い物する場所セルは非表示（feature flag無効時）**: 現行リリースでは `shoppingLocationFeatureEnabled` がfalse（issue #465）のため「買い物する場所」セルは表示されない。maestro/flows/group_setting.yaml の assertNotVisible で確認できる

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **カテゴリ画面への遷移**: 「カテゴリ」セルタップでGroupCategoryPageに遷移する。maestro/flows/group_setting.yaml で確認できる

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **買い物する場所セルは非表示（feature flag無効時）**: 現行リリースでは `shoppingLocationFeatureEnabled` がfalse（issue #465）のため「買い物する場所」セルは表示されない。maestro/flows/group_setting.yaml の assertNotVisible で確認できる

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>
