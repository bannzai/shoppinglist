---
feature: group_list
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-04
---

# group_list QA

## 1. グループ一覧表示

- [x] **グループカードの表示**: 所属グループがカード形式で一覧表示され、アバター（メンバー最大3人分の頭文字丸アイコン）、グループ名、「メンバー N人」が表示される
- [ ] **空状態の表示**: 所属グループが0件の場合、中央に「所属しているグループはありません」と表示される
- [x] **デフォルトグループバッジ**: 自分の `defaultGroupID` と一致するグループのカードに「デフォルト」バッジが表示される
- [x] **名前未設定グループの表示**: グループ名が未設定（null）の場合、カードに「名前未設定」と表示される
- [x] **グループカードタップで設定画面へ遷移**: カードをタップするとグループ設定画面（GroupSettingPage）に遷移する。maestro/flows/group_setting.yaml で作成直後のカードタップ遷移を確認できる

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **グループカードの表示**: 所属グループがカード形式で一覧表示され、アバター（メンバー最大3人分の頭文字丸アイコン）、グループ名、「メンバー N人」が表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/group_creation_limit_non_premium.yaml` 実行。匿名サインイン直後の初期グループ（メンバー1人）のカードがアバター（?アイコン）・グループ名・「メンバー 1人」で表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/a34dc764-1e63-42f8-a909-adaf43af9656.png" width="320">

</details>

### **空状態の表示**: 所属グループが0件の場合、中央に「所属しているグループはありません」と表示される

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 匿名サインイン後は必ず `GroupJoinOrCreatePage`（招待コード参加 or 「自分のリストを作る」でソログループ作成）を経由するため、通常のユーザー操作でグループ0件の状態には到達しない。また `group_setting/page.dart` にはオーナー自身がグループを離脱・削除する導線がなく（他メンバー削除の `removeGroupMember` のみ存在）、ユーザー自らグループ数を0にする手段も無い。唯一到達しうるのは「自分が参加している唯一のグループから他オーナーに `removeGroupMember` される」ケースだが、その場合も次回起動時のresolverで新規デフォルトグループが自動作成されるため空状態は再起動を挟まない一瞬のみで、開発者オプションにも該当デバッグ機能が無い。ロジックは静的検証で確認済み: `page.dart` の `groups.isEmpty ? Center(Text('所属しているグループはありません')) : ListView.builder(...)` の分岐。

</details>

### **デフォルトグループバッジ**: 自分の `defaultGroupID` と一致するグループのカードに「デフォルト」バッジが表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

上記と同じスクショで、初期グループ（自分の `defaultGroupID` と一致）に「デフォルト」バッジが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/a34dc764-1e63-42f8-a909-adaf43af9656.png" width="320">

</details>

### **名前未設定グループの表示**: グループ名が未設定（null）の場合、カードに「名前未設定」と表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

上記と同じスクショで、匿名サインイン直後に自動作成されるソログループ（`group_join_or_create/page.dart` で `name: null` で作成）のカードに「名前未設定」と表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/a34dc764-1e63-42f8-a909-adaf43af9656.png" width="320">

</details>

### **グループカードタップで設定画面へ遷移**: カードをタップするとグループ設定画面（GroupSettingPage）に遷移する。maestro/flows/group_setting.yaml で作成直後のカードタップ遷移を確認できる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/group_setting.yaml` 実行。作成した「テストグループ」のカードをタップし、グループ設定画面（GroupSettingPage）に遷移することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/d516ccd6-db2c-4a5a-a3d2-7fcba3bb4663.png" width="320">

</details>

</details>

---

## 2. グループ作成導線

- [x] **FABからグループ作成画面へ遷移**: 右下FAB「グループ作成」タップでグループ作成画面に遷移する。maestro/flows/group_setting.yaml、maestro/flows/group_creation_limit_non_premium.yaml で確認できる
- [x] **無料プラン上限到達時にFABが非表示になる**: 無料プランで追加グループ作成が上限（`freeAdditionalGroupCreationLimit` = 1件）に達すると、FAB自体が非表示になり新規作成できなくなる。maestro/flows/group_creation_limit_non_premium.yaml で確認できる
- [x] **上限案内バナーの表示**: 上限到達時、一覧末尾に「無料プランは追加1グループまで」バナーが表示される
- [x] **上限案内バナーからペイウォール表示**: バナーの「解除」タップでペイウォールが表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **FABからグループ作成画面へ遷移**: 右下FAB「グループ作成」タップでグループ作成画面に遷移する。maestro/flows/group_setting.yaml、maestro/flows/group_creation_limit_non_premium.yaml で確認できる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/group_setting.yaml`・`maestro/flows/group_creation_limit_non_premium.yaml` の両方でFABタップ→グループ作成画面（「グループ名」入力欄）表示を確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/11f5b141-059d-4f81-b5fe-2ff1e9b022ec.png" width="320">

</details>

### **無料プラン上限到達時にFABが非表示になる**: 無料プランで追加グループ作成が上限（`freeAdditionalGroupCreationLimit` = 1件）に達すると、FAB自体が非表示になり新規作成できなくなる。maestro/flows/group_creation_limit_non_premium.yaml で確認できる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/group_creation_limit_non_premium.yaml` 実行。2つ目のグループ（オーナーとして作成済みグループ数2件 = `freeAdditionalGroupCreationLimit`(1) + 1）に到達後、FABが非表示になり「グループ名」入力画面を開けなくなることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/6b885684-c61c-49f0-b5be-c113df96c077.png" width="320">

</details>

### **上限案内バナーの表示**: 上限到達時、一覧末尾に「無料プランは追加1グループまで」バナーが表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

上限到達後の一覧末尾に「無料プランは追加 1 グループまで」バナー（「解除」ボタン付き）が表示されることを確認した（実装上はコード（`page.dart` の `_FreeLimitBanner`）を確認したところ非プレミアムユーザーには上限到達前から常時表示される仕様だが、上限到達時に表示されることは本スクショで確認済み）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/6b885684-c61c-49f0-b5be-c113df96c077.png" width="320">

</details>

### **上限案内バナーからペイウォール表示**: バナーの「解除」タップでペイウォールが表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

mobile-mcpでバナーの「解除」をタップし、ペイウォール画面（「プレミアムにアップグレード」/ Monthly・Yearly・Lifetime プラン一覧）が表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/0dbd316a-4acb-48cd-9202-d33ac7e0fa93.png" width="320">

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

⏭️ スキップ: `appUserProvider` / `userGroupsProvider` を意図的にエラーにする開発者オプション機能が無く、dev環境のFirestoreは正常稼働中のため通常操作ではエラーを再現できない（オフラインにしてもFirestore SDKはローカルキャッシュに自動フォールバックしエラーにならない）。ロジックは静的検証で確認済み: `page.dart` の `switch ((appUserAsync, groupsAsync))` の `AsyncError` パターンで `ErrorView(error:, stackTrace:)` を返す分岐（他機能のAsyncError分岐と同一パターンで、root QA.md「起動・認証」等でも同種の構造を確認済み）。

</details>

### **ローディング中の表示**: データ取得中は中央にCircularProgressIndicatorが表示される

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: mobile-mcp・maestro双方でグループ管理画面への遷移直後に即撮影を試みたが（2回試行）、匿名サインイン時に作成済みのFirestoreローカルキャッシュへ即座にヒットするため、ローディング中のフレームを捕捉できなかった（`userGroupsProvider`/`appUserProvider` の解決が撮影より速い）。ロジックは静的検証で確認済み: `page.dart` の `switch` 文の `_ => const Center(child: CircularProgressIndicator())` フォールバック分岐。

</details>

</details>
