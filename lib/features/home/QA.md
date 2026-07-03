---
feature: home
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# home QA

`HomePage` は `ShoppingListPage` をそのまま返す薄いラッパで、実体は起動時の Resolver chain
（`RootPage` → `AppResolvers` → `AppUserCreateResolver` → `ForceUpdateResolver` →
`AppEntityPrepareResolver` → `CurrentGroupResolver` → `HomeWidgetSync` → `HomePage`）が
どの画面へ到達させるかにある。買い物リスト自体の操作は `shopping_list` の QA.md でカバーする。

## 1. 起動〜ホーム画面表示

- [ ] **匿名サインイン後にホームが表示される**: オンボーディングをスキップ→匿名サインイン→（グループ未参加時）「自分のリストを作る」を経て、買い物リスト画面（「タップで入力開始」等）が表示される。maestro/flows/home_page_test.yaml で確認。
- [ ] **既存ユーザーの再起動でホームへ直行**: グループとデフォルトの買い物リストが既にあるユーザーがアプリを再起動すると、オンボーディングやグループ選択を経由せず買い物リスト画面へ直接遷移する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 2. 新規ユーザーの初回グループ選択

- [ ] **グループ未参加時はグループ選択画面へ**: `defaultGroupID` が未設定のユーザーは、ホーム(買い物リスト)の代わりに「招待コードで参加/自分のリストを作る」の選択画面（`GroupJoinOrCreatePage`）が表示される（`AppEntityPrepareResolver`）。maestro/flows/home_page_test.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 3. ホーム上部バーからの画面遷移

- [ ] **設定アイコンでSettingPageへpush遷移**: ヘッダー右上の設定アイコンをタップするとSettingPage（プロフィール等）がpushで開く。maestro/flows/home_page_test.yaml で確認。
- [ ] **閉じるボタンでホームに戻る**: SettingPage左上の閉じる(×)をタップするとホーム(買い物リスト画面)に戻る。maestro/flows/home_page_test.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 4. エッジケース

- [ ] **強制アップデート時の表示**: アプリバージョンが強制アップデート対象の場合、ホームの代わりに「アプリをアップデートしてください」ダイアログが表示されストアへ誘導する（`ForceUpdateResolver`）。
  - ⏭️ スキップ: リモートの強制アップデート判定を切り替える必要があり、Simulator単体では再現できない。該当設定を有効化できる検証環境で確認する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---
