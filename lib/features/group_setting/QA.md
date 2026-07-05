---
feature: group_setting
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# group_setting QA

## 1. 画面表示

- [x] **画面表示**: 「グループ設定」タイトルでグループ設定画面が表示される。maestro/flows/group_setting.yaml で確認できる
- [x] **メンバー一覧表示**: `/groups/{groupID}/userProfiles` のプロフィールがメンバー一覧に表示され、オーナーには「オーナー」、自分自身には「自分」のサブタイトルが付く
- [x] **表示名未設定メンバーの表示**: displayNameが未設定のメンバーは「名前未設定」と表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **画面表示**: 「グループ設定」タイトルでグループ設定画面が表示される。maestro/flows/group_setting.yaml で確認できる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/group_setting.yaml` 実行。「グループ設定」タイトルで画面が表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/6d8803e6-6ad4-4e4b-ac01-6ca9a6ac6aa2.png" width="320">

</details>

### **メンバー一覧表示**: `/groups/{groupID}/userProfiles` のプロフィールがメンバー一覧に表示され、オーナーには「オーナー」、自分自身には「自分」のサブタイトルが付く

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで検証。開発者オプションの「デバッグユーザー作成」「グループにデバッグユーザーを追加」で2人目のメンバーを追加後、別の匿名アカウント（サインアウト→再サインイン）で招待コードから同グループに参加し、非オーナー視点でメンバー一覧を確認。オーナーの行に「オーナー」、自分の行に「自分」のサブタイトルが正しく付くことを確認した（オーナー自身が閲覧する場合はオーナー=自分のため「オーナー」のみ表示され、これは実装通り）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/e3c5ac8e-cb89-4813-b4c5-9479e9e198b2.png" width="320">

</details>

### **表示名未設定メンバーの表示**: displayNameが未設定のメンバーは「名前未設定」と表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

匿名サインインは displayName が未設定のため、メンバー一覧に「名前未設定」と表示されることを確認した（上記2スクショいずれでも確認できる）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/6d8803e6-6ad4-4e4b-ac01-6ca9a6ac6aa2.png" width="320">

</details>

</details>

---

## 2. グループ名編集

- [x] **オーナーはグループ名を編集できる**: オーナーがグループ名入力欄を編集しEnter（onSubmitted）で確定すると保存される。maestro/flows/group_setting.yaml で確認できる
- [x] **非オーナーは読み取り専用**: オーナー以外のメンバーが開いた場合、グループ名欄は読み取り専用（readOnly）で編集できない
- [x] **空文字や変更なしでは更新されない**: 入力を空文字にする、または既存と同じ値でsubmitした場合は更新処理が呼ばれない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **オーナーはグループ名を編集できる**: オーナーがグループ名入力欄を編集しEnter（onSubmitted）で確定すると保存される。maestro/flows/group_setting.yaml で確認できる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/group_setting.yaml` 実行。「テストグループ」を「更新グループ」に編集しEnterで確定後、画面に反映されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/dca0cc5b-b03e-43a1-a1dc-9b98c1029b95.png" width="320">

</details>

### **非オーナーは読み取り専用**: オーナー以外のメンバーが開いた場合、グループ名欄は読み取り専用（readOnly）で編集できない

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで検証。非オーナーアカウントで招待コードから参加後、グループ設定画面でグループ名欄をタップしてもキーボードが表示されず、readOnlyであることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/c1264455-f2c2-4199-807a-8fbb9a9149ff.png" width="320">

</details>

### **空文字や変更なしでは更新されない**: 入力を空文字にする、または既存と同じ値でsubmitした場合は更新処理が呼ばれない

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで検証。オーナーがグループ名欄を空にしてEnterで確定後、グループ管理一覧へ戻って再度グループ設定画面を開くと、グループ名が「更新グループ」のまま（空文字で更新されていない）ことを確認した。また、変更なしで同じ値をEnter確定してもクラッシュ・エラーなく画面に変化がないことも確認した（コード上も `newName.isEmpty || newName == (group.name ?? '')` で更新処理をスキップする実装）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/4cac685e-3391-40fe-a7e1-6d2ce9389677.png" width="320">

</details>

</details>

---

## 3. メンバー削除

- [x] **オーナーはメンバーを削除できる**: オーナーが自分以外のメンバーの削除アイコン（赤色）をタップすると確認ダイアログが表示され、「削除」で `removeGroupMember` Functionが呼ばれメンバーが一覧から消える
- [x] **削除確認ダイアログのキャンセル**: 確認ダイアログの「キャンセル」でメンバーは削除されない
- [x] **非オーナー・オーナー自身の行には削除ボタンが出ない**: 非オーナーが開いた画面、およびオーナー自身の行には削除アイコンが表示されない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **オーナーはメンバーを削除できる**: オーナーが自分以外のメンバーの削除アイコン（赤色）をタップすると確認ダイアログが表示され、「削除」で `removeGroupMember` Functionが呼ばれメンバーが一覧から消える

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで検証。開発者オプションでデバッグユーザーをグループに追加後、オーナーが削除アイコンをタップ→確認ダイアログで「削除」をタップすると、Debug Userがメンバー一覧から消えることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/ea04fa6b-0dc8-41d0-b97a-c8514275bf75.png" width="320">

</details>

### **削除確認ダイアログのキャンセル**: 確認ダイアログの「キャンセル」でメンバーは削除されない

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで検証。削除アイコンタップ後の確認ダイアログで「キャンセル」をタップすると、Debug Userがメンバー一覧に残ったままであることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/50e6bb3b-6244-49c6-bfca-96c1f1ce30c7.png" width="320">

</details>

### **非オーナー・オーナー自身の行には削除ボタンが出ない**: 非オーナーが開いた画面、およびオーナー自身の行には削除アイコンが表示されない

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで検証。オーナー視点ではオーナー自身の行に削除アイコンが表示されず、非オーナー（Debug User）の行にのみ表示されることを確認した。さらに非オーナーアカウントで開いた場合は、オーナー行・自分の行いずれにも削除アイコンが表示されないことを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/040258fc-5469-4b26-9d85-b89d87b8c94f.png" width="320">

</details>

</details>

---

## 4. グループ招待

- [x] **招待コード発行**: 「招待コードを発行」ボタンをタップすると招待コードダイアログが表示される。maestro/flows/group_setting.yaml で確認できる
- [x] **グループ名未設定時は発行をブロック**: グループ名が未入力（空・空白のみ）の状態で招待コード発行を試みると、「招待する前にグループ名を設定してください」とトースト表示され発行されない
- [x] **未保存の入力中グループ名も招待時に保存される**: グループ名入力欄に未確定（onSubmitted前）の入力があっても、招待コード発行時にその値が先に保存されてから発行される
- [x] **招待コードのコピー**: 招待コードダイアログの「コピー」タップでクリップボードにコードがコピーされ「招待コードをコピーしました」とトースト表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **招待コード発行**: 「招待コードを発行」ボタンをタップすると招待コードダイアログが表示される。maestro/flows/group_setting.yaml で確認できる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/group_setting.yaml` でボタン表示を確認、また mobile-mcp で実際にタップして招待コードダイアログ（8桁コード）が表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/4abf1cdb-e13b-4d19-9f8e-01aeb03bd6ad.png" width="320">

</details>

### **グループ名未設定時は発行をブロック**: グループ名が未入力（空・空白のみ）の状態で招待コード発行を試みると、「招待する前にグループ名を設定してください」とトースト表示され発行されない

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで検証。グループ名欄を空にした状態で「招待コードを発行」をタップすると、「招待する前にグループ名を設定してください」とトースト表示され、招待コードダイアログは表示されないことを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/41b81c80-6493-4f61-a599-7f5ee4d1605e.png" width="320">

</details>

### **未保存の入力中グループ名も招待時に保存される**: グループ名入力欄に未確定（onSubmitted前）の入力があっても、招待コード発行時にその値が先に保存されてから発行される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで検証。グループ名欄に「未保存グループ」と入力しEnterで確定せずに「招待コードを発行」をタップすると、招待コードダイアログが表示され、ダイアログを閉じた後もグループ名が「未保存グループ」として保存されていることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/840bec49-80af-4667-aa02-c37a9c35d0e6.png" width="320">

</details>

### **招待コードのコピー**: 招待コードダイアログの「コピー」タップでクリップボードにコードがコピーされ「招待コードをコピーしました」とトースト表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

mobile-mcpで検証。「コピー」タップ後、`xcrun simctl pbpaste` でシミュレータのクリップボードに招待コードがコピーされていることを確認し、また画面下部に「招待コードをコピーしました」というトーストが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/4abf1cdb-e13b-4d19-9f8e-01aeb03bd6ad.png" width="320">

</details>

</details>

---

## 5. 関連機能への導線

- [x] **カテゴリ画面への遷移**: 「カテゴリ」セルタップでGroupCategoryPageに遷移する。maestro/flows/group_setting.yaml で確認できる
- [x] **買い物する場所セルは非表示（feature flag無効時）**: 現行リリースでは `shoppingLocationFeatureEnabled` がfalse（issue #465）のため「買い物する場所」セルは表示されない。maestro/flows/group_setting.yaml の assertNotVisible で確認できる

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **カテゴリ画面への遷移**: 「カテゴリ」セルタップでGroupCategoryPageに遷移する。maestro/flows/group_setting.yaml で確認できる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/group_setting.yaml` 実行。「カテゴリ」セルタップでGroupCategoryPage（「買ったものを自動でグループ分け」空状態カード）に遷移することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/da037c8c-f63e-402c-8b6f-e405a95cb117.png" width="320">

</details>

### **買い物する場所セルは非表示（feature flag無効時）**: 現行リリースでは `shoppingLocationFeatureEnabled` がfalse（issue #465）のため「買い物する場所」セルは表示されない。maestro/flows/group_setting.yaml の assertNotVisible で確認できる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`maestro/flows/group_setting.yaml` の `assertNotVisible: "(?s).*買い物する場所.*"` ステップが成功し、「買い物する場所」セルが表示されないことを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/b15dada1-0a6d-432d-bddb-322e4ef7c248.png" width="320">

</details>

</details>
