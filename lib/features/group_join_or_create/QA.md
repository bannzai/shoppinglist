---
feature: group_join_or_create
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-14
---

# group_join_or_create QA

## 1. 画面表示

- [x] **未参加ユーザーへの表示**: 新規サインイン後、`defaultGroupID == null` を `AppEntityPrepareResolver` が検知したときに `GroupJoinOrCreatePage` が表示されること。見出し「はじめましょう」・説明文・「招待コードで参加」・「自分のリストを作る」の2ボタンが表示される（既存 E2E: maestro/flows/group_join_or_create.yaml）
- [x] **`groups` アイコンと訴求文**: `groups` アイコンの丸バッジと「家族やパートナーから招待コードを受け取っていますか？…」の説明文が表示されること

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **未参加ユーザーへの表示**: 新規サインイン後、`defaultGroupID == null` を `AppEntityPrepareResolver` が検知したときに `GroupJoinOrCreatePage` が表示されること。見出し「はじめましょう」・説明文・「招待コードで参加」・「自分のリストを作る」の2ボタンが表示される（既存 E2E: maestro/flows/group_join_or_create.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/22c5c406-1158-4a2a-bf4a-3b4c3d5f9b47.png" width="320">

</details>

### **`groups` アイコンと訴求文**: `groups` アイコンの丸バッジと「家族やパートナーから招待コードを受け取っていますか？…」の説明文が表示されること

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/22c5c406-1158-4a2a-bf4a-3b4c3d5f9b47.png" width="320">

</details>

</details>

---

## 2. 招待コードで参加

- [x] **招待コード入力画面へ遷移**: 「招待コードで参加」タップで `GroupInvitationAcceptPage` が push され「招待コードを入力してください」画面が開くこと（既存 E2E: maestro/flows/group_join_or_create.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **招待コード入力画面へ遷移**: 「招待コードで参加」タップで `GroupInvitationAcceptPage` が push され「招待コードを入力してください」画面が開くこと（既存 E2E: maestro/flows/group_join_or_create.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/b4c2703d-a740-4d58-a7ed-990b614486c0.png" width="320">

</details>

</details>

---

## 3. 自分のリストを作る（ソログループ作成）

- [x] **ソログループ作成でホームへ**: 「自分のリストを作る」タップで `createGroup.call(name: null, setAsDefault: true, iconName: 'home')` が実行され、`defaultGroupID` がセットされて `AppEntityPrepareResolver` の再ビルドにより本画面が置き換わり、空ホーム（「タップで入力開始」）に到達すること（既存 E2E: maestro/flows/group_join_or_create.yaml）
- [x] **作成中の表示**: 作成処理中はボタンラベルが「作成中...」に変わり、両ボタンが非活性になること（`isCreating.value == true`）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ソログループ作成でホームへ**: 「自分のリストを作る」タップで `createGroup.call(name: null, setAsDefault: true, iconName: 'home')` が実行され、`defaultGroupID` がセットされて `AppEntityPrepareResolver` の再ビルドにより本画面が置き換わり、空ホーム（「タップで入力開始」）に到達すること（既存 E2E: maestro/flows/group_join_or_create.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/33732866-f955-4fe3-900c-d53ce534715d.png" width="320">

</details>

### **作成中の表示**: 作成処理中はボタンラベルが「作成中...」に変わり、両ボタンが非活性になること（`isCreating.value == true`）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-14**

タップ直後（`waitForAnimationToEnd` の前）に maestro `takeScreenshot` で撮影。「自分のリストを作る」ボタンのラベルが「作成中...」に変わり、「招待コードで参加」ボタンも含め両方が非活性色（淡色）になっていることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260714/1bbdcdf8-73cc-4dfd-ba16-9366e9304a47.png" width="320">

</details>

</details>

---

## 4. エラー処理

- [ ] **作成失敗時のエラー表示**: ソログループ作成が失敗した場合、説明文の下に `describeError(e, st).message` を danger 色で表示し、`isCreating` を false に戻してボタンを再度操作可能にすること（エラーメッセージは加工せずそのまま表示）
  - ⏭️ スキップ: 「自分のリストを作る」は `name: null` 固定・新規サインイン直後（所有グループ0件）で呼ばれるため、`createGroup` Function 側の失敗条件（name 由来のバリデーション・無料プラン上限）に到達不可。ネットワーク遮断や Functions 抜き Firebase Emulator 起動を検討したが、非対話 QA セッションの許可コマンド範囲外のため実機再現できず、コードレビューでの確認に留めた（詳細は下記動作確認エビデンス参照）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **作成失敗時のエラー表示**: ソログループ作成が失敗した場合、説明文の下に `describeError(e, st).message` を danger 色で表示し、`isCreating` を false に戻してボタンを再度操作可能にすること（エラーメッセージは加工せずそのまま表示）

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: 本画面の「自分のリストを作る」は `name: null` 固定・新規サインイン直後（所有グループ0件）で呼ばれるため、`createGroup` Function 側の失敗条件（`firebase/functions/src/functions/createGroup/function.ts`）のうち name 由来のバリデーション（制御文字・101文字以上）は到達不可、無料プラン上限（所有グループ2件以上）も新規ユーザーでは発生し得ない。残る手段は実際のネットワーク/バックエンド障害の意図的発生のみで、以下を検討したが非対話 QA セッションの許可コマンド範囲内では再現できなかった:
- ホスト側 Wi-Fi 遮断: シミュレータはホストのネットワークスタックを直接共有するため実際の通信断が保証できず、かつセッション自体の接続を切る恐れがあり不採用
- Firebase Emulator を `--only auth,firestore`（Functions 抜き）で起動し `createGroup` 呼び出し自体を失敗させる案: `firebase emulators:start` は `.claude/settings.json` の非対話許可コマンド一覧に無く、実行時に承認待ちで停止するため断念

コードレビューでは `lib/features/group_join_or_create/page.dart:134-138` の catch 節で `errorMessage.value = describeError(e, st).message`（danger 色 Text で表示、`page.dart:66-75`）と `isCreating.value = false` へのリセットを確認済み。実機での動作確認は次回 QA 時に Firebase Emulator 起動コマンドの許可を得た上で再試行する。

</details>

</details>

---
