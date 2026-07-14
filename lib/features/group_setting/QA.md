---
feature: group_setting
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# group_setting QA

## 1. 画面表示

- [ ] **グループ設定画面の表示**: 設定 →「グループ管理」→ グループカードから `GroupSettingPage` に遷移し、AppBar タイトル「グループ設定」、「グループ名」「メンバー一覧」「カテゴリ」「グループ招待」の各セクションが表示されること（既存 E2E: maestro/flows/group_setting.yaml）
- [ ] **loading / error 表示**: グループ・プロフィール取得中は `CircularProgressIndicator`、取得失敗時は `ErrorView` が paper 背景の Scaffold 内に表示されること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **グループ設定画面の表示**: 設定 →「グループ管理」→ グループカードから `GroupSettingPage` に遷移し、AppBar タイトル「グループ設定」、「グループ名」「メンバー一覧」「カテゴリ」「グループ招待」の各セクションが表示されること（既存 E2E: maestro/flows/group_setting.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **loading / error 表示**: グループ・プロフィール取得中は `CircularProgressIndicator`、取得失敗時は `ErrorView` が paper 背景の Scaffold 内に表示されること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 2. グループ名編集

- [ ] **オーナーは編集可・保存**: オーナー（`group.ownerUserID == currentUserID`）はグループ名入力欄を編集でき、`onSubmitted`（Enter）で `groupNameUpdate.call` により保存されること（既存 E2E: maestro/flows/group_setting.yaml）
- [ ] **空・同名は保存しない**: トリム後が空、または現在の `group.name` と同一の場合は保存処理を行わないこと
- [ ] **非オーナーは読み取り専用**: 非オーナー（`ownerUserID` が null のレガシーグループ含む）では入力欄が `readOnly` で `onSubmitted` が無効になること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **オーナーは編集可・保存**: オーナー（`group.ownerUserID == currentUserID`）はグループ名入力欄を編集でき、`onSubmitted`（Enter）で `groupNameUpdate.call` により保存されること（既存 E2E: maestro/flows/group_setting.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **空・同名は保存しない**: トリム後が空、または現在の `group.name` と同一の場合は保存処理を行わないこと

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **非オーナーは読み取り専用**: 非オーナー（`ownerUserID` が null のレガシーグループ含む）では入力欄が `readOnly` で `onSubmitted` が無効になること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 3. メンバー一覧・削除

- [ ] **メンバー一覧と役割表示**: `groupUserProfiles` の各メンバーが表示され、`displayName` 未設定は「名前未設定」、オーナーは subtitle「オーナー」、自分は「自分」と表示されること
- [ ] **削除アイコンの表示条件**: 削除アイコン（`remove_circle`）はオーナーが閲覧中かつ対象がオーナー以外のメンバーの行にのみ表示されること（自分・オーナー行には出ない）
- [ ] **メンバー削除の確認ダイアログ**: 削除アイコンタップで「〜をグループから削除しますか？」ダイアログが開き、「削除」で `functions.removeGroupMember` が実行され「〜を削除しました」SnackBar が出ること。「キャンセル」で閉じること（別ユーザーは開発者オプションの「デバッグユーザー作成」→「グループにデバッグユーザーを追加」で用意。maestro/flows/virtual_pairing/02・03）
- [ ] **削除失敗時のエラー表示**: 削除に失敗した場合は `showErrorSnackBar` でエラーをそのまま表示すること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **メンバー一覧と役割表示**: `groupUserProfiles` の各メンバーが表示され、`displayName` 未設定は「名前未設定」、オーナーは subtitle「オーナー」、自分は「自分」と表示されること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **削除アイコンの表示条件**: 削除アイコン（`remove_circle`）はオーナーが閲覧中かつ対象がオーナー以外のメンバーの行にのみ表示されること（自分・オーナー行には出ない）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **メンバー削除の確認ダイアログ**: 削除アイコンタップで「〜をグループから削除しますか？」ダイアログが開き、「削除」で `functions.removeGroupMember` が実行され「〜を削除しました」SnackBar が出ること。「キャンセル」で閉じること（別ユーザーは開発者オプションの「デバッグユーザー作成」→「グループにデバッグユーザーを追加」で用意。maestro/flows/virtual_pairing/02・03）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **削除失敗時のエラー表示**: 削除に失敗した場合は `showErrorSnackBar` でエラーをそのまま表示すること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 4. カテゴリ / 買い物する場所

- [ ] **カテゴリ画面へ遷移**: 「カテゴリ」セル（`自動分類のキーワード管理`）タップで `GroupCategoryPage` に遷移すること（既存 E2E: maestro/flows/group_setting.yaml）
- [ ] **買い物する場所は非表示**: 「買い物する場所」セルは feature flag（`shoppingLocationFeatureEnabled == false`, issue #465）により表示されないこと（既存 E2E: maestro/flows/group_setting.yaml の `assertNotVisible`）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **カテゴリ画面へ遷移**: 「カテゴリ」セル（`自動分類のキーワード管理`）タップで `GroupCategoryPage` に遷移すること（既存 E2E: maestro/flows/group_setting.yaml）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **買い物する場所は非表示**: 「買い物する場所」セルは feature flag（`shoppingLocationFeatureEnabled == false`, issue #465）により表示されないこと（既存 E2E: maestro/flows/group_setting.yaml の `assertNotVisible`）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---

## 5. グループ招待コード発行

- [ ] **グループ名未設定時のトースト**: グループ名入力欄が空のまま「招待コードを発行」をタップすると「招待する前にグループ名を設定してください」トーストが出て、招待コードは発行されないこと（Issue #432）
- [ ] **名前入力ありで発行**: 入力欄に名前があれば（onSubmitted 未確定でも）現在の `group.name` と異なる場合は先に `groupNameUpdate.call` で保存し、`createGroupInvitation.call` で招待コードを発行して招待コードダイアログを表示すること（発行中はラベルが「招待コードを発行中...」）
- [ ] **招待コードダイアログ**: ダイアログに8桁コードと「有効期限: 7日間」が表示され、「コピー」で `Clipboard` にコピーして「招待コードをコピーしました」トーストが出ること。「閉じる」で閉じること
- [ ] **発行失敗時のエラー表示**: 招待コード発行に失敗した場合は `showErrorSnackBar` でエラーをそのまま表示すること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **グループ名未設定時のトースト**: グループ名入力欄が空のまま「招待コードを発行」をタップすると「招待する前にグループ名を設定してください」トーストが出て、招待コードは発行されないこと（Issue #432）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **名前入力ありで発行**: 入力欄に名前があれば（onSubmitted 未確定でも）現在の `group.name` と異なる場合は先に `groupNameUpdate.call` で保存し、`createGroupInvitation.call` で招待コードを発行して招待コードダイアログを表示すること（発行中はラベルが「招待コードを発行中...」）

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **招待コードダイアログ**: ダイアログに8桁コードと「有効期限: 7日間」が表示され、「コピー」で `Clipboard` にコピーして「招待コードをコピーしました」トーストが出ること。「閉じる」で閉じること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

### **発行失敗時のエラー表示**: 招待コード発行に失敗した場合は `showErrorSnackBar` でエラーをそのまま表示すること

<details><summary>動作確認スクショ</summary>

（未実行）

</details>

</details>

---
