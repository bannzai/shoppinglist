---
feature: group_list
verification: mobile-mcp, maestro
last_verified_commit: 272db0ce414922e3eb1d7de51253b64e88ab8798
last_verified_at: 2026-07-15
---

# group_list QA

## 1. グループ一覧の表示

- [ ] **ローディング・エラー表示**: appUser / userGroups の取得中は CircularProgressIndicator、いずれかが取得失敗のときは ErrorView を表示する
  - ⏭️ スキップ: `page.dart` の `switch ((appUserAsync, groupsAsync))` によるガードはコードレビューで確認できるが、UI操作で再現する手段がない。GroupListPage に到達する時点で `appUserProvider` は AppEntityPrepareResolver によって、`userGroupsProvider` は Home（shopping_list）ページによって既に watch・res解決済みのため、Settings 経由でこのページへ遷移してもローディング/エラー状態を観測できない
- [ ] **グループ0件の表示**: 所属グループが0件のとき「所属しているグループはありません」を表示する
  - ⏭️ スキップ: `AppEntityPrepareResolver`（`lib/features/resolver/app_entntiy_prepare.dart`）は `appUser.defaultGroupID == null` の間 `GroupJoinOrCreatePage` を表示し続け、ユーザーは「招待コードで参加」か「自分のリストを作る」のいずれかで最低1グループに所属するまで通常のホーム画面（および GroupListPage への導線）に到達できない。さらにアプリにグループの脱退・削除機能が存在しない（`grep -rn "leaveGroup\|deleteGroup" lib/` で0件）ため、一度グループに所属したユーザーが0件に戻ることもない。通常操作でこの空状態を再現する手段がない
- [x] **グループカードの一覧表示**: 所属グループを card 一覧（ListView）で表示する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ローディング・エラー表示**: appUser / userGroups の取得中は CircularProgressIndicator、いずれかが取得失敗のときは ErrorView を表示する

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: 上記チェックリストの理由を参照。

</details>

### **グループ0件の表示**: 所属グループが0件のとき「所属しているグループはありません」を表示する

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: 上記チェックリストの理由を参照。

</details>

### **グループカードの一覧表示**: 所属グループを card 一覧（ListView）で表示する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/3a678e48-6cc7-428c-81d9-7955510f1986.png" width="320">

</details>

</details>

---

## 2. グループカードの内容

- [x] **メンバーアバターの表示**: カード左端にメンバーの頭文字アバターを最大3人分（displayName 先頭1文字、無ければ「?」）重ねて表示する。メンバー0人時は人型アイコンを表示する
  - ⏭️ 一部スキップ: 「最大3人分」の切り詰め（`profiles.take(3)`）と「メンバー0人時の人型アイコン」（`shown.isEmpty` 分岐）はコードレビューで確認。実機では開発者オプションのデバッグユーザーを1名追加し2人（自分「?」+ Debug User「D」）の重ね表示・イニシャルフォールバックまで確認した。3人目の追加手段（別アカウントでの招待コード参加）と、メンバー0人（プロフィール未作成)状態の再現は本セッションでは行っていない
- [x] **グループ名とデフォルトバッジ**: グループ名（未設定時は「名前未設定」）を表示し、デフォルトグループ（appUser.defaultGroupID 一致）には「デフォルト」バッジを付ける
- [x] **メンバー数の表示**: 「メンバー N人」（N = memberUserIDs の数）を表示する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **メンバーアバターの表示**: カード左端にメンバーの頭文字アバターを最大3人分（displayName 先頭1文字、無ければ「?」）重ねて表示する。メンバー0人時は人型アイコンを表示する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

開発者オプション →「デバッグユーザー作成」→「グループにデバッグユーザーを追加」で2人目（displayName「Debug User」）を追加し、自分（displayName未設定=「?」）と重ねて表示されることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/b1d51416-8d78-4358-931a-73222c275990.png" width="320">

</details>

### **グループ名とデフォルトバッジ**: グループ名（未設定時は「名前未設定」）を表示し、デフォルトグループ（appUser.defaultGroupID 一致）には「デフォルト」バッジを付ける

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/3a678e48-6cc7-428c-81d9-7955510f1986.png" width="320">

</details>

### **メンバー数の表示**: 「メンバー N人」（N = memberUserIDs の数）を表示する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/b1d51416-8d78-4358-931a-73222c275990.png" width="320">

</details>

</details>

---

## 3. グループの選択

- [x] **カードタップで設定画面へ**: グループカードをタップすると、そのグループの GroupSettingPage へ遷移する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **カードタップで設定画面へ**: グループカードをタップすると、そのグループの GroupSettingPage へ遷移する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/058cffb7-7f52-4bc6-9c62-cef364e6f468.png" width="320">

</details>

</details>

---

## 4. 無料プランの上限バナーと FAB

- [x] **上限バナーの表示（無料）**: 無料プランのとき一覧末尾に「無料プランは追加 1 グループまで」バナーを表示し、「解除」でペイウォールを開く
- [x] **FAB からグループ作成**: 上限未到達のとき右下 FAB「グループ作成」をタップすると GroupCreatePage へ遷移する（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）
- [x] **上限到達で FAB 非表示（無料）**: 無料プランで自分がオーナーのグループが2個（ソログループ+1）に達すると FAB が非表示になり、作成画面を開けない（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **上限バナーの表示（無料）**: 無料プランのとき一覧末尾に「無料プランは追加 1 グループまで」バナーを表示し、「解除」でペイウォールを開く

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

maestro/flows/group_creation_limit_non_premium.yaml 実行時点（新規匿名ユーザー・追加グループ作成前）のグループ管理画面。バナーと「解除」リンクが表示されている。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/bff1d70d-00f0-439c-8b1e-90f4830bdab5.png" width="320">

「解除」タップでペイウォールが開くことを実機で確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/073c78d0-4e5b-422c-8a9e-be09ae294b58.png" width="320">

</details>

### **FAB からグループ作成**: 上限未到達のとき右下 FAB「グループ作成」をタップすると GroupCreatePage へ遷移する（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

maestro/flows/group_creation_limit_non_premium.yaml が全ステップ COMPLETED（FABタップ→グループ名入力画面遷移→作成）。加えてプレミアムアカウントでも手動で FAB→GroupCreatePage 遷移を確認済み（セクション5参照）。

</details>

### **上限到達で FAB 非表示（無料）**: 無料プランで自分がオーナーのグループが2個（ソログループ+1）に達すると FAB が非表示になり、作成画面を開けない（既存 E2E: maestro/flows/group_creation_limit_non_premium.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

2個目のグループ作成後、FAB が非表示になり「グループ作成」を再タップしても（optional・WARNED＝要素なし）グループ名画面が開かないことを maestro flow で確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/27922f92-61ca-425c-ad6e-0b627ff2907e.png" width="320">

</details>

</details>

---

## 5. プレミアム時の挙動

- [x] **バナー非表示・FAB常時表示**: プレミアム状態では上限バナーを表示せず、FAB を常に表示して2個目以降も作成できる（開発者オプション →「プレミアム付与（1日）」で付与して確認）（既存 E2E: maestro/flows/premium_group_creation.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **バナー非表示・FAB常時表示**: プレミアム状態では上限バナーを表示せず、FAB を常に表示して2個目以降も作成できる（開発者オプション →「プレミアム付与（1日）」で付与して確認）（既存 E2E: maestro/flows/premium_group_creation.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

プレミアムアカウントで1グループ目のみの状態（バナー非表示・FAB表示、`gl_01_list`と同一画面）から FAB→GroupCreatePage→「プレミアムテスト用」を作成し、2グループ目作成後もバナーが表示されず FAB が引き続き表示されることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/56abb7ce-4bf4-4cdf-a324-ecd197444e9f.png" width="320">

</details>

</details>

---
