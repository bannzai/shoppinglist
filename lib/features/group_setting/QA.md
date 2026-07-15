---
feature: group_setting
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-15
---

# group_setting QA

## 1. 画面表示

- [x] **グループ設定画面の表示**: 設定 →「グループ管理」→ グループカードから `GroupSettingPage` に遷移し、AppBar タイトル「グループ設定」、「グループ名」「メンバー一覧」「カテゴリ」「グループ招待」の各セクションが表示されること（既存 E2E: maestro/flows/group_setting.yaml）
- [ ] **loading / error 表示**: グループ・プロフィール取得中は `CircularProgressIndicator`、取得失敗時は `ErrorView` が paper 背景の Scaffold 内に表示されること
  - ⏭️ スキップ: dev 環境の Firestore ストリームは応答が速く、未訪問グループへの遷移直後にスクリーンショットを撮ってもローディング表示は撮り逃した（1回試行）。エラー表示は正規操作では到達不可（ネットワーク遮断は非対話セッションの許可コマンド範囲外）。コードレビューで `page.dart:36-59`（`groupAsync`/`groupUserProfilesAsync` の `when` 分岐）に loading→`CircularProgressIndicator`、error→`ErrorView` の実装があることを確認済み

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **グループ設定画面の表示**: 設定 →「グループ管理」→ グループカードから `GroupSettingPage` に遷移し、AppBar タイトル「グループ設定」、「グループ名」「メンバー一覧」「カテゴリ」「グループ招待」の各セクションが表示されること（既存 E2E: maestro/flows/group_setting.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/c536e39a-edd1-408f-92f9-394cbb51d8e4.png" width="320">

</details>

### **loading / error 表示**: グループ・プロフィール取得中は `CircularProgressIndicator`、取得失敗時は `ErrorView` が paper 背景の Scaffold 内に表示されること

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: dev 環境の Firestore ストリームが速く、未訪問グループへの遷移直後にスクリーンショットしてもローディング状態は撮り逃した。エラー表示は正規操作では到達不可。コードレビューで `page.dart:36-59` の `when` 分岐（loading→`CircularProgressIndicator`、error→`ErrorView`、両方 `_PaperScaffold` でラップ）を確認済み。

</details>

</details>

---

## 2. グループ名編集

- [x] **オーナーは編集可・保存**: オーナー（`group.ownerUserID == currentUserID`）はグループ名入力欄を編集でき、`onSubmitted`（Enter）で `groupNameUpdate.call` により保存されること（既存 E2E: maestro/flows/group_setting.yaml）
- [x] **空・同名は保存しない**: トリム後が空、または現在の `group.name` と同一の場合は保存処理を行わないこと
- [x] **非オーナーは読み取り専用**: 非オーナー（`ownerUserID` が null のレガシーグループ含む）では入力欄が `readOnly` で `onSubmitted` が無効になること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **オーナーは編集可・保存**: オーナー（`group.ownerUserID == currentUserID`）はグループ名入力欄を編集でき、`onSubmitted`（Enter）で `groupNameUpdate.call` により保存されること（既存 E2E: maestro/flows/group_setting.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/a9bb7a60-47ed-486a-bcfd-7331833e64f4.png" width="320">

maestro/flows/group_setting.yaml 実行。「テストグループ」→「更新グループ」に変更・保存が反映されることを確認。

</details>

### **空・同名は保存しない**: トリム後が空、または現在の `group.name` と同一の場合は保存処理を行わないこと

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/bc7f34f4-edda-4f26-ba83-21a46df240bf.png" width="320">

グループ名入力欄を全選択してスペースのみに置換し Enter で確定。グループ一覧に戻ると「更新グループ」のまま変化なし（トリム後空文字のため保存されない）。同名時の分岐（`newName == group.name`）は同一コードパスのためコードレビューで確認済み。

</details>

### **非オーナーは読み取り専用**: 非オーナー（`ownerUserID` が null のレガシーグループ含む）では入力欄が `readOnly` で `onSubmitted` が無効になること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/e6d0cccb-b739-4107-9771-a5ff3ed4ce99.png" width="320">

サインアウト→新規匿名サインイン→「招待コードで参加」（CPPS3AKV）で別ユーザーとして「招待テストグループ」に非オーナーとして参加。GroupSettingPage のグループ名欄をタップしてもキーボードが開かず、文字入力を試みても「招待テストグループ」のまま変化しないことを確認（readOnly + onSubmitted 無効）。メンバー一覧にも自分の行に削除アイコンが無いことを確認（オーナーのみが削除操作可能という表示条件とも整合）。

</details>

</details>

---

## 3. メンバー一覧・削除

- [x] **メンバー一覧と役割表示**: `groupUserProfiles` の各メンバーが表示され、`displayName` 未設定は「名前未設定」、オーナーは subtitle「オーナー」、自分は「自分」と表示されること
- [x] **削除アイコンの表示条件**: 削除アイコン（`remove_circle`）はオーナーが閲覧中かつ対象がオーナー以外のメンバーの行にのみ表示されること（自分・オーナー行には出ない）
- [x] **メンバー削除の確認ダイアログ**: 削除アイコンタップで「〜をグループから削除しますか？」ダイアログが開き、「削除」で `functions.removeGroupMember` が実行され「〜を削除しました」SnackBar が出ること。「キャンセル」で閉じること（別ユーザーは開発者オプションの「デバッグユーザー作成」→「グループにデバッグユーザーを追加」で用意。maestro/flows/virtual_pairing/02・03）
- [ ] **削除失敗時のエラー表示**: 削除に失敗した場合は `showErrorSnackBar` でエラーをそのまま表示すること
  - ⏭️ スキップ: UI 上の削除アイコンは `isOwner && !isProfileOwner` の時のみ表示されるため、非オーナー操作・オーナー自身の削除といったクライアント側の失敗条件には到達できない。`firebase/functions/src/functions/removeGroupMember/function.ts` のサーバー側失敗条件（未認証・グループ不存在・オーナー未設定・非オーナー・自分自身）も同様に正規UI操作では到達不可で、意図的な再現には実ネットワーク障害かFunctions抜きEmulator起動が必要（group_join_or_create QA と同じ理由で非対話セッションの許可コマンド範囲外のため断念）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **メンバー一覧と役割表示**: `groupUserProfiles` の各メンバーが表示され、`displayName` 未設定は「名前未設定」、オーナーは subtitle「オーナー」、自分は「自分」と表示されること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/9da08b58-24e2-412c-8953-d0e1072baec5.png" width="320">

開発者オプションの「デバッグユーザー作成」→「グループにデバッグユーザーを追加」で2人目のメンバーを追加。オーナー（自分・displayName未設定）は「名前未設定 / オーナー」、非オーナーは「Debug User」（subtitle なし）と表示。

</details>

### **削除アイコンの表示条件**: 削除アイコン（`remove_circle`）はオーナーが閲覧中かつ対象がオーナー以外のメンバーの行にのみ表示されること（自分・オーナー行には出ない）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/9da08b58-24e2-412c-8953-d0e1072baec5.png" width="320">

自分（オーナー）の行には削除アイコンが無く、Debug User（非オーナー）の行にのみ `remove_circle` が表示されることを確認。

</details>

### **メンバー削除の確認ダイアログ**: 削除アイコンタップで「〜をグループから削除しますか？」ダイアログが開き、「削除」で `functions.removeGroupMember` が実行され「〜を削除しました」SnackBar が出ること。「キャンセル」で閉じること（別ユーザーは開発者オプションの「デバッグユーザー作成」→「グループにデバッグユーザーを追加」で用意。maestro/flows/virtual_pairing/02・03）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/4e234d67-a65d-4a76-95a8-b289f6a5aef5.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/18031158-af08-4e31-a9fe-a56a09900b1c.png" width="320">

「キャンセル」でダイアログが閉じメンバーは残ることを確認後、再度削除アイコンをタップし「削除」を実行。「Debug Userを削除しました」SnackBar が表示され、メンバー一覧から Debug User が消えたことを確認。

</details>

### **削除失敗時のエラー表示**: 削除に失敗した場合は `showErrorSnackBar` でエラーをそのまま表示すること

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: 削除アイコンは `isOwner && !isProfileOwner`（page.dart:171-172）の時のみ表示されるため、正規UI操作では非オーナー操作・オーナー自身の削除といった失敗条件に到達できない。`removeGroupMember/function.ts` のサーバー側失敗条件（未認証・グループ不存在・オーナー未設定・非オーナー・自分自身の削除）も同様に到達不可。コードレビューでは `page.dart:366-370` の catch 節で `showErrorSnackBar(context, e, st)` を呼び `isRemovingMember.value = false` にリセットすることを確認済み。実ネットワーク障害の意図的発生やFunctions抜きEmulator起動は、`lib/features/group_join_or_create/QA.md` セクション4と同じ理由（非対話QAセッションの許可コマンド範囲外）で断念した。

</details>

</details>

---

## 4. カテゴリ / 買い物する場所

- [x] **カテゴリ画面へ遷移**: 「カテゴリ」セル（`自動分類のキーワード管理`）タップで `GroupCategoryPage` に遷移すること（既存 E2E: maestro/flows/group_setting.yaml）
- [x] **買い物する場所は非表示**: 「買い物する場所」セルは feature flag（`shoppingLocationFeatureEnabled == false`, issue #465）により表示されないこと（既存 E2E: maestro/flows/group_setting.yaml の `assertNotVisible`）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **カテゴリ画面へ遷移**: 「カテゴリ」セル（`自動分類のキーワード管理`）タップで `GroupCategoryPage` に遷移すること（既存 E2E: maestro/flows/group_setting.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/62e66e5d-aeae-492a-8c0b-4ff38981be99.png" width="320">

</details>

### **買い物する場所は非表示**: 「買い物する場所」セルは feature flag（`shoppingLocationFeatureEnabled == false`, issue #465）により表示されないこと（既存 E2E: maestro/flows/group_setting.yaml の `assertNotVisible`）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/a9bb7a60-47ed-486a-bcfd-7331833e64f4.png" width="320">

maestro flow で `assertNotVisible: "(?s).*買い物する場所.*"` が COMPLETED。上記スクショにもセルが存在しないことを確認。

</details>

</details>

---

## 5. グループ招待コード発行

- [x] **グループ名未設定時のトースト**: グループ名入力欄が空のまま「招待コードを発行」をタップすると「招待する前にグループ名を設定してください」トーストが出て、招待コードは発行されないこと（Issue #432）
- [x] **名前入力ありで発行**: 入力欄に名前があれば（onSubmitted 未確定でも）現在の `group.name` と異なる場合は先に `groupNameUpdate.call` で保存し、`createGroupInvitation.call` で招待コードを発行して招待コードダイアログを表示すること（発行中はラベルが「招待コードを発行中...」）
- [x] **招待コードダイアログ**: ダイアログに8桁コードと「有効期限: 7日間」が表示され、「コピー」で `Clipboard` にコピーして「招待コードをコピーしました」トーストが出ること。「閉じる」で閉じること
- [ ] **発行失敗時のエラー表示**: 招待コード発行に失敗した場合は `showErrorSnackBar` でエラーをそのまま表示すること
  - ⏭️ スキップ: `firebase/functions/src/functions/createGroupInvitation/function.ts` の失敗条件（未認証・グループ不存在・非メンバー・コード生成10回失敗）は、正規サインイン済みグループメンバーの通常UI操作では到達不可。group_join_or_create QA・本ファイルの削除失敗時エラー表示と同じ理由（実ネットワーク障害やFunctions抜きEmulator起動が非対話セッションの許可コマンド範囲外）で再現を断念

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **グループ名未設定時のトースト**: グループ名入力欄が空のまま「招待コードを発行」をタップすると「招待する前にグループ名を設定してください」トーストが出て、招待コードは発行されないこと（Issue #432）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/bbfba379-7556-4ab4-8608-c687d7e134af.png" width="320">

グループ名が空のグループで「招待コードを発行」をタップ。「招待する前にグループ名を設定してください」トーストが表示され、招待ダイアログは開かないことを確認。

</details>

### **名前入力ありで発行**: 入力欄に名前があれば（onSubmitted 未確定でも）現在の `group.name` と異なる場合は先に `groupNameUpdate.call` で保存し、`createGroupInvitation.call` で招待コードを発行して招待コードダイアログを表示すること（発行中はラベルが「招待コードを発行中...」）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/01eb62a8-7cf2-4b3c-95cb-d149ceec1886.png" width="320">

グループ名欄に「招待テストグループ」を入力（Enter未確定）した状態で「招待コードを発行」をタップ。onSubmitted を経由せずに招待コードダイアログが表示され、名前が先行保存されたことを確認（発行できたこと自体が groupNameUpdate.call 成功の証跡）。

</details>

### **招待コードダイアログ**: ダイアログに8桁コードと「有効期限: 7日間」が表示され、「コピー」で `Clipboard` にコピーして「招待コードをコピーしました」トーストが出ること。「閉じる」で閉じること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/462e59c2-3e25-4b4b-888a-b18629e11040.png" width="320">

8桁コード「CPPS3AKV」と「有効期限: 7日間」を確認。「コピー」タップで「招待コードをコピーしました」トーストを確認。「閉じる」タップでダイアログが閉じることを確認。

</details>

### **発行失敗時のエラー表示**: 招待コード発行に失敗した場合は `showErrorSnackBar` でエラーをそのまま表示すること

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: `createGroupInvitation/function.ts` の失敗条件（未認証・グループ不存在・非メンバー・コード生成失敗）は正規サインイン済みグループメンバーの通常UI操作では到達不可。コードレビューでは `page.dart:308-311` の catch 節で `showErrorSnackBar(context, e, st)` を呼び `isCreatingInvitation.value = false` にリセットすることを確認済み。実ネットワーク障害の意図的発生は非対話QAセッションの許可コマンド範囲外のため断念（`lib/features/group_join_or_create/QA.md` セクション4と同じ理由）。

</details>

</details>

---
