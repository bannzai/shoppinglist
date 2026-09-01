---
feature: group_category
verification: mobile-mcp, maestro
last_verified_commit: 7a80d422104e296bf88c924758138696bb82b220
last_verified_at: 2026-09-01
---

# group_category QA

## 1. 一覧表示・空状態

- [x] **軸0件の初回空状態**: カテゴリ軸（axes）が0件のとき、価値訴求カード CategoryEmptyState を表示し、カード内に「カテゴリを追加」ボタン（OutlinedButton）を出す
- [x] **カテゴリ0件の空状態**: 軸はあるがカテゴリが0件のとき、CategoryEmptyState を表示するがカード内ボタンは出さず、追加導線は右下の FloatingActionButton が担う
- [x] **カテゴリ一覧の行表示**: カテゴリが1件以上あるとき、各カテゴリを行（ListTile）で表示し、先頭にアイコン、タイトルにカテゴリ名、サブタイトルに「キーワード: N件」を表示する（既存 E2E: maestro/flows/category_crud.yaml）
- [ ] **uid 未取得時のローディング**: ログアウト・ユーザー切替直後で currentUserID が null の間は CircularProgressIndicator を表示し、追加操作をさせない
  - ⏭️ スキップ: `page.dart` の `currentUserID == null` ガードはコードレビューで確認できるが、UI操作でこの状態を再現する手段がない。サインアウトは通常アプリ全体のルートが切り替わり GroupCategoryPage を含むナビゲーションスタック自体が破棄されるため、「このページがマウントされたまま uid が null になる」狭い競合状態を通常操作で意図的に発生させられない（詳細は下記動作確認エビデンス参照）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **軸0件の初回空状態**: カテゴリ軸（axes）が0件のとき、価値訴求カード CategoryEmptyState を表示し、カード内に「カテゴリを追加」ボタン（OutlinedButton）を出す

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/fd1ba84c-0772-41c1-8b05-06a4a57765ed.png" width="320">

</details>

### **カテゴリ0件の空状態**: 軸はあるがカテゴリが0件のとき、CategoryEmptyState を表示するがカード内ボタンは出さず、追加導線は右下の FloatingActionButton が担う

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

軸に紐づく最後のカテゴリを削除した直後の画面。カード内に「カテゴリを追加」ボタンは出ず、右下の FAB のみが追加導線になっている（カード本文中の「野菜」はコピー文言の例示であり実データではない）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/358e5af3-c712-4214-b55f-4b6671ac3085.png" width="320">

</details>

### **カテゴリ一覧の行表示**: カテゴリが1件以上あるとき、各カテゴリを行（ListTile）で表示し、先頭にアイコン、タイトルにカテゴリ名、サブタイトルに「キーワード: N件」を表示する（既存 E2E: maestro/flows/category_crud.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/d5112f20-36e1-4a37-8bb1-0892b4ce6d41.png" width="320">

</details>

### **uid 未取得時のローディング**: ログアウト・ユーザー切替直後で currentUserID が null の間は CircularProgressIndicator を表示し、追加操作をさせない

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: `page.dart` の `currentUserID == null` ガード（GroupCategoryPage.build / _CategoryListBody.build 双方）はコードレビューで確認できるが、UI操作でこの状態を再現する手段がない。サインアウトは通常アプリ全体のルート（AuthGate 相当）が切り替わり、GroupCategoryPage を含むナビゲーションスタック自体が破棄されるため、「このページがマウントされたまま uid が null になる」という狭い競合状態（ログアウト・ユーザー切替の遷移中の一瞬）を通常操作で意図的に発生させられない。

</details>

</details>

---

## 2. 別メンバーのカテゴリ設定取り込み

- [ ] **取り込み元の選択**: 通常モードのAppBarから取り込みダイアログを開くと、同じグループの別メンバーが所有するカテゴリ軸だけを表示する（E2E: `maestro/flows/category_import_from_member.yaml`、Widget Test: `test/features/group_category/group_category_import_action_test.dart`）
  - ⏭️ スキップ: iOS 18.5の専用シミュレータでE2Eを実行したが、`clearState: true` + `clearKeychain: true` 後に既知のLaunchLoading白画面が再発し、オンボーディングの「スキップ」へ到達できなかった。Widget Testでは自分の軸を除外し、別メンバーの軸だけを表示することを確認済み
- [ ] **カテゴリと店舗別順序のコピー**: 取り込み元を選ぶと、カテゴリ・キーワード・店舗ごとの並び順を自分所有の設定としてコピーし、完了メッセージと取り込んだカテゴリを表示する（E2E: `maestro/flows/category_import_from_member.yaml`、Unit Test: `test/provider/group_category_import_test.dart`）
  - ⏭️ スキップ: 上記の起動障害により画面操作は未到達。Unit Testではコピー後の所有者、キーワード、既存カテゴリの後ろへの配置、店舗ごとの相対順序を確認済み
- [ ] **再取り込みによる更新**: 同じカテゴリ軸を再度取り込んでも重複せず、決定的IDの同じ文書を更新する（E2E: `maestro/flows/category_import_from_member.yaml`、Unit Test: `test/provider/group_category_import_test.dart`）
  - ⏭️ スキップ: 上記の起動障害により画面操作は未到達。Unit Testでは同じ入力から同じIDを生成し、再取り込みでも順序がずれないことを確認済み

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **取り込み元の選択**: 通常モードのAppBarから取り込みダイアログを開くと、同じグループの別メンバーが所有するカテゴリ軸だけを表示する（E2E: `maestro/flows/category_import_from_member.yaml`、Widget Test: `test/features/group_category/group_category_import_action_test.dart`）

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: 2026-09-01、iOS 18.5の専用シミュレータで `maestro/flows/category_import_from_member.yaml` を実行した。アプリのFirebase・Remote Config初期化までは通過したが、既知の `clearState: true` + `clearKeychain: true` 後のLaunchLoading白画面が再発し、オンボーディングの「スキップ」表示待ちで失敗したため、取り込み画面の有効なスクリーンショットは取得できなかった。

</details>

### **カテゴリと店舗別順序のコピー**: 取り込み元を選ぶと、カテゴリ・キーワード・店舗ごとの並び順を自分所有の設定としてコピーし、完了メッセージと取り込んだカテゴリを表示する（E2E: `maestro/flows/category_import_from_member.yaml`、Unit Test: `test/provider/group_category_import_test.dart`）

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: 同じ起動障害により機能画面へ未到達。代替のUnit TestとWidget Testは成功したが、画面を確認したことにはしない。

</details>

### **再取り込みによる更新**: 同じカテゴリ軸を再度取り込んでも重複せず、決定的IDの同じ文書を更新する（E2E: `maestro/flows/category_import_from_member.yaml`、Unit Test: `test/provider/group_category_import_test.dart`）

<details><summary>動作確認スクショ</summary>

⏭️ スキップ: 同じ起動障害により機能画面へ未到達。決定的IDと再取り込み時の順序安定性はUnit Testで確認済み。

</details>

</details>

---

## 3. カテゴリ追加

- [x] **空状態ボタンからの追加**: 軸0件の空状態でカード内「カテゴリを追加」をタップすると、軸が無ければ「デフォルト」軸を自動作成し、空名カテゴリを作成して GroupCategoryEditPage へ遷移する（既存 E2E: maestro/flows/category_crud.yaml）
- [x] **FAB からの追加**: 一覧表示中に右下 FAB（＋）をタップすると、名前入力ダイアログを挟まず空名カテゴリを作成し、GroupCategoryEditPage へ直接遷移する（既存 E2E: maestro/flows/category_matching_test.yaml）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **空状態ボタンからの追加**: 軸0件の空状態でカード内「カテゴリを追加」をタップすると、軸が無ければ「デフォルト」軸を自動作成し、空名カテゴリを作成して GroupCategoryEditPage へ遷移する（既存 E2E: maestro/flows/category_crud.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

ダイアログを挟まず空名カテゴリが作成され GroupCategoryEditPage へ遷移した直後（名前入力前）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/e552aa1a-2ff6-472d-8718-a1f04340ff1c.png" width="320">

</details>

### **FAB からの追加**: 一覧表示中に右下 FAB（＋）をタップすると、名前入力ダイアログを挟まず空名カテゴリを作成し、GroupCategoryEditPage へ直接遷移する（既存 E2E: maestro/flows/category_matching_test.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

FAB タップ直後にダイアログなしで GroupCategoryEditPage が開くことを確認した上で「衣類」を作成した結果（一覧に2件目として追加）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/bc49e41b-8b14-4636-9ce5-443a381978fa.png" width="320">

</details>

</details>

---

## 4. カテゴリの並び替え

- [x] **ドラッグ&ドロップでの並び替え**: 一覧の行を長押しドラッグして並び替えると、デフォルト順序（order フィールド）を更新して保存する（長押し D&D は maestro の duration 10000ms swipe で再現、または widget test での検証を検討）

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **ドラッグ&ドロップでの並び替え**: 一覧の行を長押しドラッグして並び替えると、デフォルト順序（order フィールド）を更新して保存する（長押し D&D は maestro の duration 10000ms swipe で再現、または widget test での検証を検討）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

maestro の低速 swipe（duration 10000ms、`category_section_reorder.yaml` と同技法）で「野菜」行を「衣類」行の下までドラッグし、順序が入れ替わることを確認（並び替え前: 野菜→衣類 / 並び替え後: 衣類→野菜）。

並び替え前:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/20d8871a-79c9-4a46-8779-9db988ef1190.png" width="320">

並び替え後:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/1c0ba5b8-253f-47cd-9482-f3ab17895c19.png" width="320">

</details>

</details>

---

## 5. カテゴリの編集・削除

- [x] **編集ボタンからの遷移**: カテゴリ行の編集アイコンをタップすると、そのカテゴリの GroupCategoryEditPage へ遷移する
- [x] **削除確認ダイアログ**: カテゴリ行の削除アイコンをタップすると「「<カテゴリ名>」を削除しますか？」ダイアログと「このカテゴリに設定されたキーワードも削除されます」の説明を表示する
- [x] **削除の実行とキャンセル**: 削除ダイアログで「削除」をタップするとカテゴリを削除し、「キャンセル」ではダイアログを閉じるだけで削除しない

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **編集ボタンからの遷移**: カテゴリ行の編集アイコンをタップすると、そのカテゴリの GroupCategoryEditPage へ遷移する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

「野菜」行の編集アイコンをタップし、そのカテゴリ（名前・キーワード「にんじん」）の編集画面に遷移することを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/1c9b9f54-172d-487a-8386-dfb24218c548.png" width="320">

</details>

### **削除確認ダイアログ**: カテゴリ行の削除アイコンをタップすると「「<カテゴリ名>」を削除しますか？」ダイアログと「このカテゴリに設定されたキーワードも削除されます」の説明を表示する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/3bfc87b1-f12e-4c22-a018-b9267053295e.png" width="320">

</details>

### **削除の実行とキャンセル**: 削除ダイアログで「削除」をタップするとカテゴリを削除し、「キャンセル」ではダイアログを閉じるだけで削除しない

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

「キャンセル」タップ後、ダイアログが閉じて「衣類」行が削除されずに残っていることを確認:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/690df625-3fea-4b9d-a505-befc2e2c409f.png" width="320">

同じ行で改めて「削除」をタップした結果、「衣類」行が削除され「野菜」のみ残ることを確認:

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/bf8c563c-b3f5-4e51-bc42-b49a23359c63.png" width="320">

</details>

</details>

---

## 6. カテゴリ選択モード（アイテムからの割り当て）

- [x] **選択モードのタイトル**: selectionForItem 指定で開いた場合、AppBar タイトルが「カテゴリを選択」になる（通常時は「カテゴリ」）（既存 E2E: maestro/flows/category_select_from_item.yaml）
- [x] **行タップでカテゴリ付け替え**: 選択モードでカテゴリ行をタップすると、対象アイテム名（message）を移動先カテゴリの完全一致キーワードに追記し、他カテゴリから同名の完全一致キーワードを削除して画面を pop する（既存 E2E: maestro/flows/category_select_from_item.yaml）
- [x] **通常モードでは行タップ無効**: selectionForItem が null のとき、行タップではカテゴリ付け替えは発生せず、編集/削除ボタンのみ反応する

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **選択モードのタイトル**: selectionForItem 指定で開いた場合、AppBar タイトルが「カテゴリを選択」になる（通常時は「カテゴリ」）（既存 E2E: maestro/flows/category_select_from_item.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/0820a553-4fa5-43bc-a0da-7118b96be55d.png" width="320">

</details>

### **行タップでカテゴリ付け替え**: 選択モードでカテゴリ行をタップすると、対象アイテム名（message）を移動先カテゴリの完全一致キーワードに追記し、他カテゴリから同名の完全一致キーワードを削除して画面を pop する（既存 E2E: maestro/flows/category_select_from_item.yaml）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

未分類アイテム「juice」を「飲料」カテゴリ選択モードでタップ割り当てした結果。買い物リスト上のセクションが「未分類」→「飲料」に変わり、アイテム詳細シートのボタンも「カテゴリを選択」→「カテゴリを変更」に更新される。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/8011a3d2-8bfc-49e7-9554-0cea9fa34c8a.png" width="320">

</details>

### **通常モードでは行タップ無効**: selectionForItem が null のとき、行タップではカテゴリ付け替えは発生せず、編集/削除ボタンのみ反応する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-15**

通常モード（グループ設定からの通常遷移）で「野菜」行本体をタップしても画面遷移が起きず、AppBar タイトルが「カテゴリ」のまま、一覧もそのまま表示され続けることを確認。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260715/b7be6b67-588b-4bb1-bac9-15a195107026.png" width="320">

</details>

</details>

---
