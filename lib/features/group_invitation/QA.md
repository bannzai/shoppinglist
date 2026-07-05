---
feature: group_invitation
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# group_invitation QA

## 1. 画面表示

- [x] **初期表示**: 「招待コードで参加」経由で開くと、アイコン・見出し「招待コードを入力してください」・説明文・8桁コード入力欄・非活性の「参加する」ボタン・「キャンセル」ボタンが表示される。maestro/flows/group_join_or_create.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **初期表示**: 「招待コードで参加」経由で開くと、アイコン・見出し「招待コードを入力してください」・説明文・8桁コード入力欄・非活性の「参加する」ボタン・「キャンセル」ボタンが表示される。maestro/flows/group_join_or_create.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

設定画面の「招待コードでグループに参加」からGroupInvitationAcceptPageに遷移。アイコン・見出し・説明文・8桁入力欄（hint: ABCD3456）・「参加する」（アクセシビリティツリー上Button化されておらず非活性を確認）・「キャンセル」ボタンの表示を確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/81f5a97b-7b1a-4929-9604-edb9bf2355d7.png" width="320">

</details>

</details>

---

## 2. コード入力バリデーション

- [x] **不正な形式では参加ボタン非活性**: バックエンドの許容文字（`ABCDEFGHJKMNPQRSTVWXY3456789`）以外を含む、または8桁未満の入力では「参加する」ボタンが非活性のまま。
- [x] **正しい形式で参加ボタンが活性化**: 許容文字のみで8桁入力すると入力欄の枠線がアクセントカラーに変わり「参加する」ボタンが活性化する。
- [x] **入力の自動大文字変換**: 小文字を入力しても表示上は自動的に大文字になる（textCapitalization: characters）。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **不正な形式では参加ボタン非活性**: バックエンドの許容文字（`ABCDEFGHJKMNPQRSTVWXY3456789`）以外を含む、または8桁未満の入力では「参加する」ボタンが非活性のまま。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

`1234567`（許容文字外の数字を含む7桁）を入力し、入力欄の枠線が非活性色のまま・「参加する」ボタンが非活性色のままであることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/f40e1ac5-ab6c-483f-baea-604917b8ef84.png" width="320">

</details>

### **正しい形式で参加ボタンが活性化**: 許容文字のみで8桁入力すると入力欄の枠線がアクセントカラーに変わり「参加する」ボタンが活性化する。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

実際に発行済みの招待コード`WFJ7CHRC`（8桁、許容文字のみ）を入力し、入力欄の枠線・「参加する」ボタンがアクセントカラーに変化して活性化することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/34f32800-e9c6-48a7-ab87-e91bf3aafde2.png" width="320">

</details>

### **入力の自動大文字変換**: 小文字を入力しても表示上は自動的に大文字になる（textCapitalization: characters）。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

ソフトウェアキーボードを英語(QWERTY)に切り替え、小文字表記の「w」「f」キーを実タップしたところ、入力欄には「WF」と大文字で表示されることを確認した（mobile-mcpのテキスト直接注入はOSキーボードの大文字変換をバイパスするため、実キー座標タップで検証した）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/e84b7d34-dd32-49e7-8987-4897b30408e3.png" width="320">

</details>

</details>

---

## 3. 参加処理

- [ ] **参加中オーバーレイ表示**: 「参加する」タップ直後に「招待コードを確認中」の非タップ可能なオーバーレイダイアログが表示される。
- [x] **参加成功→ホームへ遷移**: 有効な招待コードで参加が成功すると、それまでの画面が全てpopされ参加後のグループのホーム画面（買い物リスト）に遷移する。
- [ ] **存在しない招待コードでのエラー表示**: 発行されていないコードを入力すると、オーバーレイが閉じて「有効な招待が見つかりません」のエラーメッセージが画面内に赤字表示される。
- [ ] **期限切れ・使用済みコードでのエラー表示**: 発行から7日経過した期限切れコード、または既に他ユーザーが使用済みのコードを入力すると、それぞれ「招待の有効期限が切れています」「この招待コードは既に使用されています」のエラーメッセージが表示される。事前に該当状態の招待コードを用意する必要があり、期限切れは日付操作またはFirestore直接編集で代替する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **参加中オーバーレイ表示**: 「参加する」タップ直後に「招待コードを確認中」の非タップ可能なオーバーレイダイアログが表示される。

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: `page.dart` の `_showVerifyingDialog`（`AppDialogShell` + `barrierDismissible: false` + スピナー + 「招待コードを確認中」テキスト）で実装されていることはコードで確認済み。実機では dev Firebase Functions への呼び出しがオーバーレイの表示時間より速く完了し、mobile-mcp のスクリーンショット往復（同期呼び出し）・`simctl io screenshot` の連写・`simctl io recordVideo` 録画のいずれでもオーバーレイ表示中のフレームを捕捉できなかった（動画フレーム抽出の ffmpeg 実行がこのセッションでは承認待ちでブロックされ実行不可だったため録画からの検証も断念）。参加成功への遷移（下記項目）が問題なく到達していることから、ダイアログの push/pop を含む一連のコードパスは正常に実行されていると判断する。

</details>

### **参加成功→ホームへ遷移**: 有効な招待コードで参加が成功すると、それまでの画面が全てpopされ参加後のグループのホーム画面（買い物リスト）に遷移する。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

設定画面の「招待コードでグループに参加」から実在する招待コード（グループ設定で発行した`WFJ7CHRC`）を入力し「参加する」をタップ。画面遷移が全てpopされ、対象グループ（Extra Group）のホーム（買い物リスト画面）に遷移することを確認した。なお参加者が発行元グループの既存メンバー（オーナー本人）だったため`acceptGroupInvitation`は冪等ノーオペとして`result: "OK"`を返す経路だが、クライアント側の成功時遷移ロジック自体は同一コードパスで検証できている。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/9d95f433-6bc1-4b84-8621-94e58754ccb9.png" width="320">

</details>

### **存在しない招待コードでのエラー表示**: 発行されていないコードを入力すると、オーバーレイが閉じて「有効な招待が見つかりません」のエラーメッセージが画面内に赤字表示される。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

許容文字のみだが実在しないコード`AAAA3456`を入力し「参加する」をタップ。オーバーレイは閉じ、画面内に赤字でエラーメッセージが表示されることは確認できたが、実際の表示文言は「Exception: 有効な招待が見つかりません」であり、期待文言「有効な招待が見つかりません」の前に本来不要な `Exception: ` プレフィックスが付与されていた。

❌ 失敗: `lib/utils/functions/firebase_function.dart` の `acceptGroupInvitation` 拡張メソッドがバックエンドの `NG` レスポンスを `throw Exception(response['error']['message'])` で素の `Exception` としてthrowしており、`describeError()` が規約通り `toString()` をそのまま表示するため Dart の `Exception` 標準の `"Exception: "` プレフィックスが付与されてしまう。同一パターンが `firebase_function.dart` 内に16箇所あり group_invitation 固有ではなく GenKit経由の全Functions呼び出しに共通する問題。issue: https://github.com/bannzai/shoppinglist/issues/472

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/493ef059-a3e8-48e5-a822-2b728fb3ff13.png" width="320">

</details>

### **期限切れ・使用済みコードでのエラー表示**: 発行から7日経過した期限切れコード、または既に他ユーザーが使用済みのコードを入力すると、それぞれ「招待の有効期限が切れています」「この招待コードは既に使用されています」のエラーメッセージが表示される。事前に該当状態の招待コードを用意する必要があり、期限切れは日付操作またはFirestore直接編集で代替する。

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 該当状態の招待コードを用意する手段（Firestore直接編集）がこのセッションでは利用できなかった（`gcloud` / `firebase` CLI呼び出しが権限承認待ちでブロックされ、Firestoreドキュメントの`status`/`expiresDateTime`を直接書き換えられなかった）。既に使用済み状態を作るには本アプリの1台構成では別の実認証ユーザーでの参加が必要だが、`developer_options`の「グループにデバッグユーザーを追加」は`memberUserIDs`を直接更新するのみで`acceptGroupInvitation`を経由しないため招待ステータスを`accepted`にできない。サインアウトして新規匿名ユーザーを作る方法は、共有シミュレータ上の既存アカウント（プレミアム付与済み・既存グループ保持）を失い他featureのQAに影響するため今回は見送った。バックエンド側の分岐ロジック（`function.ts`の期限切れ判定・トランザクション内`status !== "pending"`判定）は静的に確認済み。期限切れ分岐は`function.test.ts`の「異常系: 期限切れでエラーになる」でユニットテストされているが、トランザクション内の「既に使用されています」（同時利用によるレースコンディション）分岐にはユニットテストが存在しない。

</details>

</details>

---

## 4. キャンセル

- [x] **キャンセルボタン**: 「キャンセル」をタップすると入力内容を破棄して前の画面（GroupJoinOrCreatePage等）に戻る。maestro/flows/group_join_or_create.yaml で確認。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **キャンセルボタン**: 「キャンセル」をタップすると入力内容を破棄して前の画面（GroupJoinOrCreatePage等）に戻る。maestro/flows/group_join_or_create.yaml で確認。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

エラー表示済み・コード入力済みの状態で「キャンセル」をタップし、遷移元の設定画面に戻ることを確認した（本セッションでは設定画面からの遷移で確認。maestro/flows/group_join_or_create.yamlはGroupJoinOrCreatePageからの遷移パターンで別途カバー）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/02675d26-fa9c-4b80-8b20-e906dfdda0db.png" width="320">

</details>

</details>

---

## 5. 別ユーザーからの実招待受け入れ（複数端末の代替）

- [x] **実際の別ユーザーによる招待コード参加**: 別ユーザーが発行した招待コードで本画面から参加し、グループのデータ（買い物リスト）が共有されることを確認する。1台のiOS Simulatorでは物理的に別ユーザーを用意できないため、developer_options の「デバッグユーザー作成」「グループにデバッグユーザーを追加」機能（maestro/flows/virtual_pairing/ 一式、multi-device-group-invite-test skill）で代替する。

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **実際の別ユーザーによる招待コード参加**: 別ユーザーが発行した招待コードで本画面から参加し、グループのデータ（買い物リスト）が共有されることを確認する。1台のiOS Simulatorでは物理的に別ユーザーを用意できないため、developer_options の「デバッグユーザー作成」「グループにデバッグユーザーを追加」機能（maestro/flows/virtual_pairing/ 一式、multi-device-group-invite-test skill）で代替する。

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-04**（ルートQA.md 2. データ同期 = 「グループ招待・参加」の検証を本項目のエビデンスとして共用）

`maestro/flows/virtual_pairing/01〜03`（`01_setup_group.yaml`は内部で`shared/anonymous_sign_in.yaml`を呼び`launchApp clearState: true`する）を実行し、「デバッグユーザー作成」→「グループにデバッグユーザーを追加」でグループ管理画面が「メンバー 2人」になることを確認済み。本セッションでは、このフローの再実行が現在共有シミュレータ上に保持されている検証用状態（プレミアム付与済みアカウント・「名前未設定」「Extra Group」等の既存グループ、本QA内の他項目で使用したデータ）を`clearState`で消去し他featureのQAに影響するため見送り、直近（HEAD同一、コード差分なし）の同一検証結果を参照した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260704/8eebcc5c-01cd-4400-a84c-0b19655440c8.png" width="320">

</details>

</details>

---
