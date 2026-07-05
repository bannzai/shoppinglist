---
feature: group_create
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-04
---

# group_create QA

## 1. グループ名入力とバリデーション

- [x] **作成ボタンの活性化**: グループ名が未入力の間は「作成する」ボタンが非活性で、1文字でも入力すると活性化する。
- [x] **空白のみの名前は非活性のまま**: 空白文字のみを入力した場合はtrimされ空文字列扱いとなり「作成する」は非活性のまま。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **作成ボタンの活性化**: グループ名が未入力の間は「作成する」ボタンが非活性で、1文字でも入力すると活性化する。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/group_create_full.yaml` 実行。空文字の状態で「作成する」をタップしても画面遷移せず（`AppPill` は `onPressed: null` で `Opacity(0.5)` の非活性表示）、`グループ名` 入力欄のあるGroupCreatePageに留まることを確認。その後実名を入力してタップすると正しく作成が成功しグループ作成→招待ダイアログまで進むことも確認した（下記「作成成功」項目のスクショ参照）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/d7054130-dc1a-4a21-9e2f-fb387bad2f49.png" width="320">

</details>

### **空白のみの名前は非活性のまま**: 空白文字のみを入力した場合はtrimされ空文字列扱いとなり「作成する」は非活性のまま。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/group_create_full.yaml` 実行。半角スペース3文字のみ入力した状態で「作成する」をタップしても画面遷移しない（非活性のまま）ことを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/b7d20784-a487-45dd-a8f0-d771127ebb86.png" width="320">

</details>

</details>

---

## 2. アイコン選択

- [x] **アイコンプリセット選択**: 6種（いえ/カート/たべる/おかし/ペット/バッグ）のいずれかをタップすると選択状態（背景色・枠線がアクセントカラー）に変わる。初期選択は「いえ」。maestro/flows/group_create_full.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **アイコンプリセット選択**: 6種（いえ/カート/たべる/おかし/ペット/バッグ）のいずれかをタップすると選択状態（背景色・枠線がアクセントカラー）に変わる。初期選択は「いえ」。maestro/flows/group_create_full.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/design_v2_groups.yaml` は design v2 UI 未追従の古い要素（`popup_menu_button` 等）を参照しており実質何も検証できていなかったため、`maestro/flows/group_create_full.yaml` に置き換えて検証した。6種のアイコンラベルが表示され、初期選択が「いえ」（アクセントカラーの背景・枠線）であること、「カート」をタップすると選択状態が「カート」に切り替わる（背景色・枠線がアクセントカラーに変わり、「いえ」は非選択の白背景に戻る）ことを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/f3397241-1cbb-49f7-a236-47f307267ccb.png" width="320">

</details>

</details>

---

## 3. グループ作成

- [x] **作成成功→招待コードダイアログ表示**: グループ名入力後「作成する」をタップするとグループが作成され、直後に8桁の招待コードを表示する「メンバーを招待」ダイアログが自動的に表示される。maestro/flows/group_setting.yaml, maestro/flows/group_creation_limit_non_premium.yaml, maestro/flows/group_create_full.yaml で確認。
- [x] **招待コードのコピー**: ダイアログの「コピー」をタップするとクリップボードに招待コードがコピーされ、「招待コードをコピーしました」というトーストが表示される。
- [ ] **招待コードの共有**: 「共有」をタップするとOS標準の共有シートが開き、招待コードを含むテキストが渡される。
  - ❌ 失敗: 「共有」をタップしても何も起きず、OS標準の共有シートが開かない。`lib/features/group_create/page.dart` の `_PostCreateInvitationDialog` で `SharePlus.instance.share()` に `sharePositionOrigin` を渡していないことが原因（`share_plus: ^11.1.0` はiOSで必須引数）。シミュレータログで `PlatformException(error, sharePositionOrigin: argument must be set, ...)` を確認済み。同じ招待コード共有機能の `lib/features/shopping_list_setting/invitation_code_dialog.dart` は `sharePositionOrigin` を正しく指定しており参考実装として使える。再現手順: グループ作成→「メンバーを招待」ダイアログ→「共有」タップ。https://github.com/bannzai/shoppinglist/issues/471
- [x] **ダイアログを閉じる**: 「閉じる」をタップするとダイアログが閉じ、グループ作成画面自体もpopされて前の画面（グループ管理等）に戻る。maestro/flows/group_setting.yaml, maestro/flows/group_create_full.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **作成成功→招待コードダイアログ表示**: グループ名入力後「作成する」をタップするとグループが作成され、直後に8桁の招待コードを表示する「メンバーを招待」ダイアログが自動的に表示される。maestro/flows/group_setting.yaml, maestro/flows/group_creation_limit_non_premium.yaml, maestro/flows/group_create_full.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/group_create_full.yaml` 実行。グループ名「検証用グループ」を入力し「作成する」をタップすると、8桁の招待コードを表示する「メンバーを招待」ダイアログが自動表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/17a38d3d-80f7-4210-8a27-e42e14f25caf.png" width="320">

</details>

### **招待コードのコピー**: ダイアログの「コピー」をタップするとクリップボードに招待コードがコピーされ、「招待コードをコピーしました」というトーストが表示される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/group_create_full.yaml` 実行。「コピー」タップ後に「招待コードをコピーしました」というグローバルトーストが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/c7414281-819f-4b1f-a24d-6a86f9f4b26e.png" width="320">

</details>

### **招待コードの共有**: 「共有」をタップするとOS標準の共有シートが開き、招待コードを含むテキストが渡される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/zz_adhoc_share_sheet_check.yaml` で「共有」タップ後5秒待って撮影。共有シートは表示されずダイアログ表示のまま変化がない（失敗の証跡）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/4b6a6892-d5cc-4875-90a5-418323101550.png" width="320">

</details>

### **ダイアログを閉じる**: 「閉じる」をタップするとダイアログが閉じ、グループ作成画面自体もpopされて前の画面（グループ管理等）に戻る。maestro/flows/group_setting.yaml, maestro/flows/group_create_full.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/group_create_full.yaml` 実行。「閉じる」タップでダイアログが閉じ、GroupCreatePage自体もpopされてグループ管理画面に戻り、作成した「検証用グループ」が一覧に表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/83684350-3e82-48a6-8a17-d04ebfaa2709.png" width="320">

</details>

</details>

---

## 4. 非プレミアムの作成上限（エッジケース）

- [x] **上限到達時はFAB非表示+バナー案内**: 非プレミアムユーザーがソログループ+1グループ（計2グループ）作成済みの場合、グループ管理画面のFAB（グループ作成）自体が非表示になり作成画面に遷移できない。代わりに一覧下部に「無料プランは追加1グループまで」のバナーが表示され、「解除」タップでPaywallへ誘導される。maestro/flows/group_creation_limit_non_premium.yaml で確認。（旧仕様は「作成する」タップ後に赤背景のエラーメッセージを画面内表示する方式だったが、`72c25ba fix(group): 無料プラン上限到達時にグループ作成FABを非表示にする` でFAB非表示方式に変更されたため項目文言を更新）
- [x] **プレミアムでは上限なく作成可能**: プレミアム状態では2個目以降のグループも上限なく作成できる。maestro/flows/premium_group_creation.yaml で確認。課金必須の検証のため、実際の購入の代わりに developer_options の「プレミアム権限を付与」機能（grant_premium_via_debug.yaml）で代替する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **上限到達時はFAB非表示+バナー案内**: 非プレミアムユーザーがソログループ+1グループ（計2グループ）作成済みの場合、グループ管理画面のFAB（グループ作成）自体が非表示になり作成画面に遷移できない。代わりに一覧下部に「無料プランは追加1グループまで」のバナーが表示され、「解除」タップでPaywallへ誘導される。maestro/flows/group_creation_limit_non_premium.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/group_creation_limit_non_premium.yaml` 実行。2グループ目作成後、グループ管理画面のFABが消え「グループ作成」に遷移できず（`グループ名` ラベルが表示されない）、一覧下部に「無料プランは追加1グループまで」バナーが表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/68dd7df1-4bee-47c7-958a-55cbc3f167f7.png" width="320">

</details>

### **プレミアムでは上限なく作成可能**: プレミアム状態では2個目以降のグループも上限なく作成できる。maestro/flows/premium_group_creation.yaml で確認。課金必須の検証のため、実際の購入の代わりに developer_options の「プレミアム権限を付与」機能（grant_premium_via_debug.yaml）で代替する。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/premium_group_creation.yaml` 実行。開発者オプションでプレミアム付与後、2個目のグループ「Extra Group」を作成しても無料プラン上限のSnackBarが出ず、正常に作成→招待ダイアログ表示まで進むことを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/30a466cb-fd73-44ff-8407-b1655c499f06.png" width="320">

</details>

</details>

---
