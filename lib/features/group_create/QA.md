---
feature: group_create
verification: mobile-mcp, maestro
last_verified_commit: null
last_verified_at: null
---

# group_create QA

## 1. グループ名入力とバリデーション

- [ ] **作成ボタンの活性化**: グループ名が未入力の間は「作成する」ボタンが非活性で、1文字でも入力すると活性化する。
- [ ] **空白のみの名前は非活性のまま**: 空白文字のみを入力した場合はtrimされ空文字列扱いとなり「作成する」は非活性のまま。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 2. アイコン選択

- [ ] **アイコンプリセット選択**: 6種（いえ/カート/たべる/おかし/ペット/バッグ）のいずれかをタップすると選択状態（背景色・枠線がアクセントカラー）に変わる。初期選択は「いえ」。maestro/flows/design_v2_groups.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 3. グループ作成

- [ ] **作成成功→招待コードダイアログ表示**: グループ名入力後「作成する」をタップするとグループが作成され、直後に8桁の招待コードを表示する「メンバーを招待」ダイアログが自動的に表示される。maestro/flows/group_setting.yaml, maestro/flows/group_creation_limit_non_premium.yaml で確認。
- [ ] **招待コードのコピー**: ダイアログの「コピー」をタップするとクリップボードに招待コードがコピーされ、「招待コードをコピーしました」というトーストが表示される。
- [ ] **招待コードの共有**: 「共有」をタップするとOS標準の共有シートが開き、招待コードを含むテキストが渡される。
- [ ] **ダイアログを閉じる**: 「閉じる」をタップするとダイアログが閉じ、グループ作成画面自体もpopされて前の画面（グループ管理等）に戻る。maestro/flows/group_setting.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---

## 4. 非プレミアムの作成上限（エッジケース）

- [ ] **上限到達時のエラー表示**: 非プレミアムユーザーがソログループ+1グループを超えて作成しようとすると、「作成する」タップ後にグループは作成されず、赤背景のエラーメッセージ（無料プランの上限を伝える文言）が画面内に表示される。maestro/flows/group_creation_limit_non_premium.yaml で確認。
- [ ] **プレミアムでは上限なく作成可能**: プレミアム状態では2個目以降のグループも上限なく作成できる。maestro/flows/premium_group_creation.yaml で確認。課金必須の検証のため、実際の購入の代わりに developer_options の「プレミアム権限を付与」機能（grant_premium_via_debug.yaml）で代替する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（未実行）

</details>

---
