---
feature: home
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-04
---

# home QA

`HomePage` は `ShoppingListPage` をそのまま返す薄いラッパで、実体は起動時の Resolver chain
（`RootPage` → `AppResolvers` → `AppUserCreateResolver` → `ForceUpdateResolver` →
`AppEntityPrepareResolver` → `CurrentGroupResolver` → `HomeWidgetSync` → `HomePage`）が
どの画面へ到達させるかにある。買い物リスト自体の操作は `shopping_list` の QA.md でカバーする。

## 1. 起動〜ホーム画面表示

- [x] **匿名サインイン後にホームが表示される**: オンボーディングをスキップ→匿名サインイン→（グループ未参加時）「自分のリストを作る」を経て、買い物リスト画面（「タップで入力開始」等）が表示される。maestro/flows/home_page_test.yaml で確認。
- [x] **既存ユーザーの再起動でホームへ直行**: グループとデフォルトの買い物リストが既にあるユーザーがアプリを再起動すると、オンボーディングやグループ選択を経由せず買い物リスト画面へ直接遷移する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **匿名サインイン後にホームが表示される**: オンボーディングをスキップ→匿名サインイン→（グループ未参加時）「自分のリストを作る」を経て、買い物リスト画面（「タップで入力開始」等）が表示される。maestro/flows/home_page_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

`maestro/flows/home_page_test.yaml` 実行（`clearState: true` で未サインイン状態から起動 → オンボーディングスキップ → 匿名サインイン → 「自分のリストを作る」→ 買い物リスト画面「タップで入力開始」表示まで確認）

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/b5be2cd1-bfbb-40a5-be02-150052967321.png" width="320">

</details>

### **既存ユーザーの再起動でホームへ直行**: グループとデフォルトの買い物リストが既にあるユーザーがアプリを再起動すると、オンボーディングやグループ選択を経由せず買い物リスト画面へ直接遷移する。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

匿名サインイン→「自分のリストを作る」でグループ・デフォルトリストを作成した状態からアプリを再起動（`launchApp: clearState:false`）し、オンボーディング・グループ選択を経由せず買い物リスト画面「タップで入力開始」へ直接遷移することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/58d3d33a-0ed1-43a0-9891-eaf5356cff77.png" width="320">

</details>

</details>

---

## 2. 新規ユーザーの初回グループ選択

- [x] **グループ未参加時はグループ選択画面へ**: `defaultGroupID` が未設定のユーザーは、ホーム(買い物リスト)の代わりに「招待コードで参加/自分のリストを作る」の選択画面（`GroupJoinOrCreatePage`）が表示される（`AppEntityPrepareResolver`）。maestro/flows/home_page_test.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **グループ未参加時はグループ選択画面へ**: `defaultGroupID` が未設定のユーザーは、ホーム(買い物リスト)の代わりに「招待コードで参加/自分のリストを作る」の選択画面（`GroupJoinOrCreatePage`）が表示される（`AppEntityPrepareResolver`）。maestro/flows/home_page_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

未サインイン状態から匿名サインイン直後、`AppEntityPrepareResolver` が `appUserDefaultGroupID == null` を検出して `GroupJoinOrCreatePage`（「はじめましょう」「招待コードで参加」「自分のリストを作る」）を表示することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/0732fe3c-bed0-4b1c-9f13-2e2f6b0db34c.png" width="320">

</details>

</details>

---

## 3. ホーム上部バーからの画面遷移

- [x] **設定アイコンでSettingPageへpush遷移**: ヘッダー右上の設定アイコンをタップするとSettingPage（プロフィール等）がpushで開く。maestro/flows/home_page_test.yaml で確認。
- [x] **閉じるボタンでホームに戻る**: SettingPage左上の閉じる(×)をタップするとホーム(買い物リスト画面)に戻る。maestro/flows/home_page_test.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **設定アイコンでSettingPageへpush遷移**: ヘッダー右上の設定アイコンをタップするとSettingPage（プロフィール等）がpushで開く。maestro/flows/home_page_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

買い物リスト画面ヘッダー右上の設定アイコンをタップし、SettingPage（プロフィール・グループ・外観・アプリについて等）がpushで開くことを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/dfebd368-cf3c-4fd6-8450-43ba092a4b5a.png" width="320">

</details>

### **閉じるボタンでホームに戻る**: SettingPage左上の閉じる(×)をタップするとホーム(買い物リスト画面)に戻る。maestro/flows/home_page_test.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**

SettingPage左上の閉じる(×)をタップし、買い物リスト画面「タップで入力開始」へ戻ることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/216a5325-429c-4318-8dc6-39922ba1442b.png" width="320">

</details>

</details>

---

## 4. エッジケース

- [ ] **強制アップデート時の表示**: アプリバージョンが強制アップデート対象の場合、ホームの代わりに「アプリをアップデートしてください」ダイアログが表示されストアへ誘導する（`ForceUpdateResolver`）。
  - ⏭️ スキップ: リモートの強制アップデート判定を切り替える必要があり、Simulator単体では再現できない。該当設定を有効化できる検証環境で確認する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **強制アップデート時の表示**: アプリバージョンが強制アップデート対象の場合、ホームの代わりに「アプリをアップデートしてください」ダイアログが表示されストアへ誘導する（`ForceUpdateResolver`）。

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 実機トリガーには dev project の Remote Config `minimumAppVersion` を現在のアプリバージョンより高い値に変更する必要があるが、dev project は共有インフラであり、他の feature QA が同一 dev 環境に対して連続実行されるため、ここで変更すると後続の全 QA が強制アップデート画面でブロックされる（root QA.md の同項目と同じ理由）。ロジックは静的検証で確認済み: `lib/provider/force_update.dart` の `CheckForceUpdate.call()` が `Version.fromPackage()` と `config.minimumAppVersion` を比較し、`lib/features/resolver/force_update.dart` の `ForceUpdateResolver` が該当時に `showOKDialog` でストア誘導する。

</details>

</details>

---
