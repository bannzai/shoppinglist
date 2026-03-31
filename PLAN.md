# ファーストリリース QA テストプラン

## 前提
- DB確認: 開発者オプションのFirestoreダンプ機能で確認
- リアルタイム同期: 仮想ペアリング（デバッグユーザー）で確認
- セキュリティルール: Firebase Emulator or Firestore Console で確認

## スコープ外（ファーストリリース後に対応）
- TTL自動削除バッチ（Scheduled Function）
- URL形式のDeep Link招待
- linkタイプアイテム（URLリンクカード表示）

---

## 1. 認証 (AuthPage)

### サインイン
- [ ] **Apple サインイン**: Apple IDでサインイン完了 → ホーム画面遷移。DB: `/users/{uid}` 作成、`defaultGroupID` 設定、ソログループ + 初期リスト自動作成
  - スキップ: OAuth認証フローをiOS Simulatorで自動実行不可
- [ ] **Google サインイン**: Googleアカウントでサインイン完了 → ホーム画面遷移。DB: 上記と同様
  - スキップ: OAuth認証フローをiOS Simulatorで自動実行不可
- [x] **匿名サインイン（デバッグのみ）**: デバッグビルドで匿名サインインボタン表示 → タップでサインイン
- [ ] **リリースビルドで匿名サインインボタン非表示**: `kDebugMode=false` 時にApple/Googleのみ表示
  - スキップ: kDebugMode=false のリリースビルドが必要

### 初回ログインフロー
- [x] **自動エンティティ作成**: 新規ユーザー → AppUser、ソログループ、初期買い物リスト（名前=`yyyy-MM-dd`、TTL=30日後）が自動作成。DB: `/users/{uid}`, `/groups/{defaultGroupID}`, shoppingLists 確認
- [x] **2回目以降のログインで二重作成されない**: 既存ユーザー再ログイン → データ数変わらない（冪等性）

### 外部リンク
- [x] **プライバシーポリシー**: タップ → 外部ブラウザで開く
- [x] **利用規約**: タップ → 外部ブラウザで開く


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

**テスト環境**: iPhone 16 Plus (iOS 18.5) / デバッグビルド / mobile-mcp

**事前チェック結果**:
- `dart run build_runner build`: ✅ 成功（0 outputs）
- `flutter analyze`: ⚠️ `group_setting/page.dart` の既存エラー15件（カテゴリ機能リネーム不整合、認証無関係）→ 本PR内で修正済み
- `flutter test`: ✅ 全35テスト通過
- `maestro test`: ⚠️ `clearState`/`clearKeychain` による通知許可ダイアログが認証画面より先に表示され「サインイン」アサーション失敗。mobile-mcpで代替検証
- `flutter build ios`: ⚠️ `group_setting/page.dart` のエラーで失敗 → 本PR内で修正済み
- `flutter build apk`: 同上の理由でスキップ

**1. 認証画面表示確認**
- デバッグビルドで匿名サインインボタン（「匿名サインイン（デバッグ用）」）が表示されている
- Apple/Googleサインインボタンも表示
- プライバシーポリシー・利用規約のリンクテキストが画面下部に表示

![認証画面](https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260325/54dae020-0d4e-4f6b-bca7-bf805b90bee8.png)

**2. プライバシーポリシー**
- 「プライバシーポリシー」テキストタップ → Safari で `bannzai.github.io/shoppinglist/PrivacyPolicy` が開いた (https)
- 「プライバシーポリシー」のタイトルと本文が正常表示

![プライバシーポリシー](https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260325/44389ff7-8fb7-4597-9578-2590c588d811.png)

**3. 利用規約**
- 「利用規約」テキストタップ → Safari で `bannzai.github.io/shoppinglist/Terms` が開いた (https)
- 「買い物リスト利用規約」のタイトルと本文が正常表示

![利用規約](https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260325/99e9bef3-f600-484e-ab10-8e9106838857.png)

**4. 匿名サインイン → ホーム画面遷移**
- 「匿名サインイン（デバッグ用）」タップ → ホーム画面に遷移
- 初期買い物リスト「2026-03-25」(yyyy-MM-dd形式) が自動作成されて表示
- 「買い物リストが空です」「アイテムを追加」が表示

![ホーム画面](https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260325/c63a722d-1fd3-4f04-9654-a8c778f35faa.png)

**5. 自動エンティティ作成の確認 (Firestoreデータダンプ)**
- AppUser: `id`, `defaultGroupID` が設定済み、`createdDateTime` = `2026-03-25T23:09:43`
- Groups: ソログループ `bT1hG1NE5AxzsX1AUsEr` が作成済み
- ShoppingLists: 初期買い物リスト `2026-03-25` が作成済み
  - `ttlExpiresAt` = `2026-04-24T23:09:43`（約30日後 ✓）

![AppUser データ](https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260325/5d39e567-ca3c-47ec-b8ed-1e0b1a799fcf.png)
![Groups 構造](https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260325/65a5d198-50d4-4830-9f07-c2d388f8706c.png)
![ShoppingList データ](https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260325/35e19744-f22c-4cd3-b048-fd164f2bf032.png)

**6. 冪等性確認（2回目ログイン）**
- アプリ再起動後（state保持）、自動ログイン → ホーム画面表示
- 買い物リストが「2026-03-25」の1つのみ（二重作成なし）
- 開発者オプションでUID/defaultGroupIDが初回と同一

![再起動後ホーム](https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260325/cfb10cdb-5fc5-4fb5-b9e4-fb28a2017456.png)
![再起動後開発者オプション](https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260325/7f29f55e-8921-4ed5-8b90-3bdc47a912f0.png)

**コードレビューで発見した問題（リリース前に修正必要）**
1. **[Critical] Apple Sign-In nonce未対策** (`lib/components/auth/apple.dart`): `generateNonce()` が `getAppleIDCredential` の後に呼ばれており、ハッシュ化したnonceが Apple に渡されていない。本番で認証失敗する。修正: 事前にrawNonce生成 → SHA-256ハッシュ → `getAppleIDCredential(nonce: hashedNonce)` → Firebase credential に rawNonce を渡す
2. **[Critical] Google Sign-In v7 initialize() 未呼び出し** (`lib/components/auth/google.dart`, `lib/main.dart`): `google_sign_in: ^7.2.0` を使用しているが `GoogleSignIn.instance.initialize()` がプロジェクト全体で呼ばれていない。v7必須の初期化処理が不足

**修正したバグ（本PR内）**
- `group_setting/page.dart`: カテゴリEntityリネーム（`GroupShoppingListItemCategory` → `GroupCategory`）後のimport/参照不整合を修正
- `firestore_viewer_page.dart`: `_JsonText` の `JsonEncoder` が `Timestamp` オブジェクトをシリアライズできないエラーを修正（カスタムエンコーダーでISO8601文字列に変換）

</details>

---

## 2. ホーム画面 (HomePage)

- [ ] **買い物リストタブがデフォルト選択**: 起動後ShoppingListPage表示
- [ ] **設定タブ遷移**: 下部ナビバーで「設定」タップ → SettingPage表示
- [ ] **タブ間スワイプ無効**: 横スワイプでタブ切り替わらない（NeverScrollableScrollPhysics）


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 3. 買い物リスト (ShoppingListPage)

### リスト表示
- [ ] **リスト一覧表示**: AppBarドロップダウンにリストが`createdDateTime`降順で表示。DB: shoppingLists数と一致
- [ ] **リスト切り替え**: ドロップダウンで別リスト選択 → そのリストのアイテム表示
- [ ] **空リスト状態**: リスト0件 → 「買い物リストがありません」メッセージ + 「買い物リストを作成」ボタン
- [ ] **空状態からリスト作成**: 「買い物リストを作成」ボタン → 新リスト作成・表示。DB: shoppingList作成確認

### アイテムCRUD
- [ ] **アイテム追加（FAB+）**: フローティングボタンタップ → 空行追加、テキスト入力可能。DB: item作成（message空、status=unchecked）
- [ ] **テキスト入力・保存**: テキスト入力 → submit → 保存され新しい空行追加。DB: message更新
- [ ] **チェック/アンチェック**: チェックボックスタップ → 取り消し線+薄表示 ↔ 元に戻る。DB: status切り替え
- [ ] **スワイプ削除**: 右スワイプ → 赤背景表示 → アイテム削除。DB: itemドキュメント削除
- [ ] **空テキストsubmitで削除**: テキスト空のままsubmit → アイテム削除。DB: ドキュメント削除
- [ ] **バックスペースで空アイテム削除**: 空アイテムでBS → 削除
- [ ] **ドラッグ&ドロップ並べ替え**: 長押し+ドラッグ → 順序変更。DB: 各itemのorder更新
- [ ] **進捗表示**: チェック済み数/全数とプログレスバー表示。全完了時「5/5 完了!」太字+プライマリカラー

### アイテム詳細（BottomSheet）
- [ ] **詳細ボトムシート表示**: infoアイコンタップ → アイテム名、メモ、カラー選択、保存、削除ボタン表示
- [ ] **補足説明（メモ）追加**: メモ入力→保存。リスト画面でアイテム名下にメモ表示。DB: description更新
- [ ] **カラー設定**: 8色プリセットから選択→保存。背景色反映。DB: color更新（hex値）
- [ ] **カラー解除**: 色なしボタンタップ → デフォルト背景に戻る。DB: color=null
- [ ] **ボトムシートからアイテム削除**: 削除ボタン → 確認ダイアログ → 削除。DB: ドキュメント削除

### リスト追加・複製
- [ ] **新しいリスト追加**: メニュー(...)>「買い物リストを追加」→ 新リスト作成。DB: name連番（例: `2025-01-01 (1)`）
- [ ] **リスト複製**: 「現在の買い物リストを複製」→ 全アイテムコピーされた新リスト作成。DB: `duplicatedFromGroupShoppingListID`設定、items全コピー
- [ ] **複製元リンクタップ**: 複製リスト上部リンクタップ → 元リストに切り替え。削除済みなら「複製元の買い物リストは削除されています」SnackBar
- [ ] **別グループへのリスト追加**: グループ選択→別グループに新リスト作成。DB: 選択グループのshoppingLists確認

### 画像からアイテム追加
- [ ] **カメラから追加**: メニュー>「画像から追加」>「カメラ」→ Gemini解析 → アイテム一括追加。重複メッセージはスキップ
- [ ] **フォトライブラリから追加**: メニュー>「画像から追加」>「フォトライブラリ」→ 同上

### テキスト貼り付けから追加
- [ ] **クリップボード複数行テキスト**: メニュー>「テキスト貼り付け」→ 各行が個別アイテムとして追加。重複行スキップ

### フィルター/ソート
- [ ] **チェック済み表示切り替え**: FilterChip ON/OFF → チェック済みアイテムの表示/非表示切り替え
- [ ] **カテゴリ順表示切り替え**: FilterChip ON → カテゴリヘッダー付きグルーピング表示、OFF → フラットリスト
- [ ] **カテゴリ順表示時ドラッグ無効**: カテゴリ順ON → ドラッグ&ドロップ不可
- [ ] **未分類アイテム**: どのカテゴリにもマッチしないアイテム → 「未分類」グループに表示
- [ ] **カテゴリ未設定時FilterChip無効化**: カテゴリが存在しない場合、FilterChipが無効（onSelected=null）

### TTL表示
- [ ] **TTL期限表示**: ttlExpiresDateTimeありのリスト → 「{M/d}になるとこのリストは削除されます」表示


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 4. 買い物リスト設定 (ShoppingListSettingPage)

- [ ] **リスト名編集**: テキスト変更→submit→保存。AppBarドロップダウンにも反映。DB: name更新
- [ ] **買い物場所選択**: ドロップダウンで場所選択→リストに紐付け。DB: shoppingLocationID更新
- [ ] **場所を「なし」に変更**: 「なし」選択→紐付け解除。DB: shoppingLocationID=null
- [ ] **TTL設定**: 日付ピッカーで日付選択。DB: ttlExpiresDateTime更新
- [ ] **リスト削除**: 削除ボタン→確認ダイアログ→削除→ホーム画面に戻る。DB: shoppingListドキュメント削除
- [ ] **削除キャンセル**: 確認ダイアログ「キャンセル」→リスト残る
- [ ] **グループ招待コード生成**: 「グループに招待」→8桁コード表示（有効期限7日間）。DB: `/groupInvitations/{id}` 作成確認
- [ ] **招待コードコピー**: 「コピー」ボタン→SnackBar「招待コードをコピーしました」
- [ ] **グループ設定遷移**: 「グループ設定」ボタン→GroupSettingPage遷移


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 5. グループ切り替え (GroupSwitcher)

- [ ] **グループ1つの場合非表示**: ソログループのみ→ChoiceChip非表示
- [ ] **複数グループ切り替え**: ChoiceChipでグループ切り替え→そのグループのリスト表示。DB: defaultGroupID更新


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 6. グループ機能

### グループ一覧 (GroupListPage)
- [ ] **グループ一覧表示**: 設定>グループ管理→グループ名+メンバー数表示。デフォルトグループにチェックマーク
- [ ] **グループ設定遷移**: グループタップ→GroupSettingPage遷移

### グループ作成 (GroupCreatePage)
- [ ] **グループ新規作成**: FAB(+)→名前入力→「作成する」→グループ作成。DB: memberUserIDs=[自UID], ownerUserID=自UID, userProfile作成
- [ ] **空名でグループ作成**: 空のまま「作成する」→name=nullで保存（一覧では「名前未設定」表示）

### グループ設定 (GroupSettingPage)
- [ ] **グループ名編集（オーナー）**: 名前変更→「変更を保存」→SnackBar表示。DB: name更新（updateGroupName Function経由）
- [ ] **グループ名編集不可（非オーナー）**: TextField disabled、「変更を保存」ボタン非表示
- [ ] **メンバー一覧表示**: displayName表示。オーナーに「オーナー」、自分に「自分」のサブタイトル
- [ ] **メンバー削除（オーナーのみ）**: 削除アイコン→確認ダイアログ→削除。DB: memberUserIDsから除去（removeGroupMember Function経由）
- [ ] **自分自身は削除不可**: オーナーの行に削除アイコンなし
- [ ] **場所管理遷移**: 「場所を管理」→ShoppingLocationPage
- [ ] **カテゴリ管理遷移**: 「カテゴリを管理」→GroupCategoryPage
- [ ] **グループ招待コード生成**: 「グループに招待」→招待コードダイアログ

### グループ招待 (GroupInvitationAcceptPage)
- [ ] **招待コード入力画面表示**: 設定>「招待コードでグループに参加」→8桁入力フィールド+「参加する」ボタン
- [ ] **無効コードでボタン無効化**: 8桁未満→ボタンdisabled
- [ ] **有効コードでグループ参加**: 8桁入力→「参加する」→ホーム画面に戻る。DB: memberUserIDsに自UID追加、userProfile作成
- [ ] **期限切れコード**: 7日超過コード入力→エラーメッセージ赤文字表示
- [ ] **既に参加済みコード**: 参加済みグループのコード→エラーまたは冪等処理
- [ ] **招待コード大文字自動変換**: 小文字入力→toUpperCase()で変換して送信


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 7. 買い物する場所 (ShoppingLocationPage)

- [ ] **場所一覧表示**: グループ設定>「場所を管理」→場所名リスト。0件時「買い物する場所がまだありません」
- [ ] **場所追加**: FAB(+)→ダイアログでテキスト入力→「追加」。DB: shoppingLocation作成
- [ ] **空文字で追加無効**: 空文字で「追加」→何も起こらない
- [ ] **場所編集**: 編集アイコン→ダイアログでテキスト変更→「保存」。DB: name更新
- [ ] **場所削除**: 削除アイコン→確認ダイアログ→削除。DB: ドキュメント削除、紐付きshoppingListのshoppingLocationIDは変更されない


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 8. カテゴリ機能

### カテゴリ一覧 (GroupCategoryPage)
- [ ] **カテゴリ一覧表示**: グループ設定>「カテゴリを管理」→カテゴリ名、アイコン、カラー、キーワード件数表示
- [ ] **初回カテゴリ追加（Axis自動作成）**: 0件→「カテゴリを追加」→ダイアログ→Axis+カテゴリ自動作成→カテゴリ編集画面遷移。DB: userCategoryAxes+categories作成
- [ ] **カテゴリ追加**: FAB(+)→名前入力→「追加」→カテゴリ編集画面遷移。DB: category作成（order=リスト最後）
- [ ] **デフォルト順ドラッグ&ドロップ**: ロケーション「デフォルト」選択時→ドラッグで順序変更。DB: order更新
- [ ] **ロケーション別並べ替え**: ロケーションドロップダウンで場所選択→その場所用の並び順でドラッグ&ドロップ。DB: locationOrdersマップ更新
- [ ] **カテゴリ削除**: 削除アイコン→確認ダイアログ「このカテゴリに設定されたキーワードも削除されます」→削除。DB: ドキュメント削除

### カテゴリ編集 (GroupCategoryEditPage)
- [ ] **カテゴリ名編集**: 名前変更→submit→SnackBar「保存しました」。DB: name更新
- [ ] **カラー設定**: プリセットカラー選択→即保存。DB: color更新（hex値）
- [ ] **カラー解除**: 色なしボタン→DB: color=null
- [ ] **アイコン設定**: プリセットアイコン選択→即保存。DB: iconName更新
- [ ] **キーワード追加（部分一致）**: 「+」→キーワード入力→「部分一致」→「追加」。DB: keywords配列にmatchingType=partialエントリ追加
- [ ] **キーワード追加（完全一致）**: 「+」→キーワード入力→「完全一致」→「追加」。DB: matchingType=exact
- [ ] **キーワード削除**: 削除アイコン→キーワード消える。DB: keywords配列からエントリ削除

### カテゴリキーワードマッチング
- [ ] **部分一致**: キーワード「牛」（部分一致）→「牛乳」「牛肉」がそのカテゴリに分類
- [ ] **完全一致**: キーワード「牛乳」（完全一致）→「牛乳」のみマッチ、「牛肉」はマッチしない
- [ ] **大文字小文字無視**: キーワード「Milk」→「milk」「MILK」にもマッチ
- [ ] **複数カテゴリマッチ時の優先度**: リスト順で最初にマッチしたカテゴリに分類


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 9. 設定画面 (SettingPage)

- [ ] **プロフィール表示名編集**: 表示名入力→「保存」→SnackBar「表示名を更新しました」。DB: userProfile.displayName更新
- [ ] **グループ管理遷移**: 「グループ管理」→GroupListPage
- [ ] **招待コード入力画面遷移**: 「招待コードでグループに参加」→GroupInvitationAcceptPage
- [ ] **利用規約リンク**: タップ→外部ブラウザ
- [ ] **プライバシーポリシーリンク**: タップ→外部ブラウザ
- [ ] **特定商法取引法に基づく表記リンク**: タップ→外部ブラウザ
- [ ] **お問い合わせ**: タップ→問い合わせ機能起動
- [ ] **アカウント削除**: 「アカウントを削除する」→確認ダイアログ→「削除する」→Firebase Authユーザー削除→「アプリを終了しますか？」ダイアログ
- [ ] **アカウント削除キャンセル**: 確認ダイアログ「キャンセル」→削除されない
- [ ] **アカウント削除時の再認証要求**: セッション古い場合→requires-recent-login→再認証ダイアログ→再認証後削除完了
- [ ] **デバッグモードで開発者オプション表示**: デバッグビルド→「開発者オプション」ListTile表示→タップでDeveloperOptionsPage遷移


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 10. プッシュ通知（FCM）

### 手動通知
- [ ] **更新時スナックバー表示**: 買い物リスト更新時に画面下部にスナックバー表示。グループメンバーのアイコンが並ぶ
- [ ] **メンバーアイコンタップで通知送信**: アイコンタップ→「Aさんが買い物リストを更新しました」通知が対象メンバーに送信
- [ ] **通知受信**: 受信側デバイスでプッシュ通知が正しく表示されること
- [ ] **通知タップでアプリ起動**: 通知タップ→アプリが開く

### 自動通知設定
- [ ] **設定画面に「買い物リストの更新を通知する」トグル**: 設定画面に通知設定トグル表示
- [ ] **設定ON時の自動通知（画面離脱時）**: 設定ON→画面onDismissまたはアプリがバックグラウンド→グループメンバーへ自動通知
- [ ] **設定OFF時の自動通知無効**: 設定OFF→自動通知が送られない

### FCM基盤
- [ ] **FCMトークン登録**: ログイン後にFCMトークンがFirestoreに保存されること
- [ ] **FCMトークン更新**: トークンリフレッシュ時にFirestoreが更新されること
- [ ] **通知権限リクエスト**: iOS/Androidで通知権限リクエストダイアログが表示されること


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 11. 強制アップデートチェック

- [ ] **不要な場合**: Remote Configで強制アップデートなし→通常起動
- [ ] **必要な場合**: Remote Configで有効→「アプリをアップデートしてください」ダイアログ→OKでストア遷移


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 12. Firebase Functions

### generateShoppingListItemsFromImage
- [ ] **正常系**: base64画像+mimeType送信→文字列配列が返る
- [ ] **異常系: 画像なし**: 必須パラメータ欠落→エラーレスポンス
- [ ] **異常系: 未認証**: 認証なし→認証エラー

### createGroupInvitation
- [ ] **正常系**: groupID指定→8桁招待コード。DB: groupInvitation作成（token, expiresDateTime=7日後, status=pending）
- [ ] **正常系: 複数回生成**: 同一グループで複数回→毎回異なるコード
- [ ] **異常系: 未認証**: 認証なし→エラー
- [ ] **異常系: 非メンバー**: 非所属ユーザー→エラー

### acceptGroupInvitation
- [ ] **正常系**: 有効コード→グループ参加。DB: memberUserIDs追加、userProfile作成
- [ ] **異常系: 無効コード**: 存在しないコード→エラー
- [ ] **異常系: 期限切れ**: 7日超過→エラー
- [ ] **異常系: 既に参加済み**: 冪等処理またはエラー
- [ ] **異常系: 未認証**: 認証なし→エラー

### removeGroupMember
- [ ] **正常系**: オーナーがgroupID+targetUserID指定→メンバー削除。DB: memberUserIDsから除去
- [ ] **異常系: 非オーナー**: 非オーナー→エラー
- [ ] **異常系: 自分自身削除**: オーナーが自分→エラー
- [ ] **異常系: 存在しないユーザー**: memberUserIDsにないUID→冪等処理
- [ ] **異常系: 未認証**: 認証なし→エラー
- [ ] **異常系: 存在しないグループ**: 無効groupID→エラー

### updateGroupName
- [ ] **正常系**: オーナーがgroupID+name→グループ名更新。DB: name更新
- [ ] **異常系: 非オーナー**: 非オーナー→エラー
- [ ] **異常系: 未認証**: 認証なし→エラー
- [ ] **異常系: 存在しないグループ**: 無効groupID→エラー


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 13. Firestoreセキュリティルール

### usersコレクション
- [ ] **本人のみread/write**: 別ユーザーの`/users/{otherUID}`を読み書き→permission-denied
- [ ] **デバッグユーザー操作**: `{uid}_debug_[0-9]+`形式ドキュメントを本体ユーザーが操作→許可
- [ ] **users/privatesはクライアントからread不可**: `/users/{uid}/privates/{id}`→permission-denied

### groupInvitationsコレクション
- [ ] **クライアントから完全アクセス不可**: read/write→permission-denied

### groupsコレクション
- [ ] **メンバーのみread**: 非メンバーがread→permission-denied
- [ ] **メンバーのみupdate**: 非メンバーがupdate→permission-denied
- [ ] **create時memberUserIDsに自分含む検証**: 自分のUID含まないgroup作成→permission-denied

### groups/userProfiles
- [ ] **メンバーならread可能**: グループメンバーが全プロフィール読み取り→許可
- [ ] **自分のプロフィールのみcreate/update**: 他メンバーのプロフィール更新→permission-denied

### groups/userCategoryAxes
- [ ] **メンバーならread可能**: 許可
- [ ] **自分のaxis/categoryのみcreate/update/delete**: 他メンバーのカテゴリ操作→permission-denied

### groups/shoppingLists
- [ ] **メンバーならCRUD全操作可能**: リスト+アイテムの全CRUD→許可
- [ ] **非メンバーはアクセス不可**: 非メンバー→permission-denied

### groups/shoppingLocations
- [ ] **メンバーならCRUD全操作可能**: 許可


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 14. リアルタイム同期

- [ ] **アイテム追加の同期**: 端末A追加→端末Bにリアルタイム反映
- [ ] **アイテムチェックの同期**: 端末Aチェック→端末Bに即座反映
- [ ] **リスト削除の同期**: 端末Aリスト削除→端末Bのドロップダウンから消える
- [ ] **グループメンバー変更の同期**: メンバー追加/削除→リアルタイム反映


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 15. ホーム画面ウィジェット

### iOS
- [ ] **ウィジェット表示**: ホーム画面に現在のリストアイテム表示
- [ ] **ウィジェットからチェック**: アイテムタップ→チェック/アンチェック切り替え。DB: item status更新
- [ ] **リアルタイム同期**: アプリ内データ変更→ウィジェット反映

### Android
- [ ] **ウィジェット表示**: ホーム画面に現在のリストアイテム表示
- [ ] **ウィジェットからチェック**: アイテムタップ→チェック/アンチェック切り替え
- [ ] **リアルタイム同期**: アプリ内データ変更→ウィジェット反映


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 16. エッジケース/異常系

### 入力バリデーション
- [ ] **極端に長いリスト名（100文字以上）**: UI崩れない、保存成功
- [ ] **極端に長いアイテムメッセージ**: maxLines:7で表示収まる、保存成功
- [ ] **特殊文字・絵文字**: リスト名、アイテム名、カテゴリ名、場所名に絵文字→正常保存・表示

### ネットワーク/エラー
- [ ] **オフライン時のデータ閲覧**: キャッシュ済みデータ表示（Firestoreオフラインキャッシュ）
- [ ] **オフライン時のデータ変更**: オフライン操作→オンライン復帰後にFirestoreに反映
- [ ] **Functions呼び出し失敗時**: SnackBarに`e.toString()`表示

### 同時操作
- [ ] **同一リストへの同時アイテム追加**: 2端末から同時追加→両方正しく追加（ドキュメントID異なるため競合なし）
- [ ] **同一アイテムの同時編集**: 2端末から同時編集→後勝ちで更新

### データ整合性
- [ ] **削除済み場所のリスト設定**: 紐付き場所削除後→ドロップダウンが「なし」にフォールバック
- [ ] **削除済み複製元リストへのリンク**: 複製元削除後→SnackBar「複製元の買い物リストは削除されています」、リンクテキスト「削除済みリスト」


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 17. 実装漏れチェック

### 未使用スタブ画面
- [x] **CheckListPageがスタブ**: ユーザーがアクセスできない状態であること（ナビゲーションパスなし）
  - `lib/features/checlist/page.dart`: スタブ実装（テキスト表示のみ）、他ファイルからの参照なし
  - `lib/features/home/page.dart`: TabBarViewにはShoppingListPageとSettingPageのみ → アクセス不可
- [x] **ECItemsPageが全コメントアウト**: HomePageTabTypeからecItemsが除外されていること
  - `lib/features/ec_items/page.dart`: 全行コメントアウト
  - `lib/features/home/page.dart:12-16`: `HomePageTabType`でecItemsはコメントアウト、NavigationDestinationsは2つのみ

### PROJECT.md記載機能の実装確認
- [x] リスト作成 → 実装済み（`ShoppingListAdd` in `lib/provider/shopping_list.dart`）
- [x] アイテム追加（テキスト） → 実装済み（`AddShoppingListItem` in `lib/provider/shopping_list_item.dart`）
- [x] チェック → 実装済み（`ToggleShoppingListItemCheck` in `lib/provider/shopping_list_item.dart`）
- [x] 並べ替え（ドラッグ&ドロップ） → 実装済み（`ReorderableList` in `lib/features/shopping_list/components/shopping_list_items/shopping_list_items.dart`）
- [x] 複製 → 実装済み（`ShoppingListDuplicate` in `lib/provider/shopping_list.dart`）
- [x] 補足説明 → 実装済み（メモセクション in `text_shopping_list_item_detail_bottom_sheet.dart`）
- [x] 色分け → 実装済み（カラー選択 in `text_shopping_list_item_detail_bottom_sheet.dart`）
- [x] ソログループ → 実装済み（`AppEntityPrepareResolver` in `lib/features/resolver/app_entntiy_prepare.dart:47-53` でdefaultGroupID未設定時に自動作成）
- [x] グループ作成 → 実装済み（`GroupCreatePage` in `lib/features/group_create/page.dart`）
- [x] 招待（コード方式） → 実装済み（`CreateGroupInvitation` in `lib/provider/group_invitation.dart` + Firebase Function）
- [x] メンバー管理 → 実装済み（`lib/features/group_setting/page.dart` + `removeGroupMember` Function）
- [x] デフォルトグループ → 実装済み（`DefaultGroupUpdate` in `lib/provider/default_group_update.dart`）
- [x] 買い物する場所 → 実装済み（`lib/features/shopping_location/page.dart`）
- [x] 商品カテゴリ → 実装済み（`lib/features/group_category/page.dart`）
- [x] カテゴリソート → 実装済み（ドラッグ&ドロップ in `GroupCategoryPage`）
- [x] プッシュ通知 → 実装済み
  - Firebase Function: `sendShoppingListUpdateNotification` in `firebase/functions/src/functions/sendShoppingListUpdateNotification/function.ts`
  - クライアント: `NotificationMemberBar`（手動）+ `AppLifecycleListener`（自動）
  - FCMトークン管理: `FcmTokenRegistration` in `lib/provider/fcm_token.dart`
  - 受信ハンドリング: `FcmNotificationHandler` in `lib/provider/fcm_notification.dart`
  - 自動通知設定: `AutoNotifyShoppingListUpdate` in `lib/provider/notification_setting.dart`

### 潜在的リスク（確認事項）
- [x] **groupのdeleteルール未定義**: セキュリティルールでgroup削除が許可されていない → グループ削除機能がスコープ外であることの確認
  - `firebase/firestore.rules:37-39`: groupsコレクションはread/update/createのみ、deleteルールなし → OK
- [x] **userCategoryAxes/categoriesのuserIDベースルール**: 各ユーザーが独自のカテゴリ軸を持つ設計であることの確認（グループ共有ではない）
  - `firebase/firestore.rules:64-73`: create/update/deleteは`request.resource.data.userID == request.auth.uid`（create）/ `resource.data.userID == request.auth.uid`（update/delete）で制御 → OK


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

コード確認（grep、ファイル読み取り）による静的検証で全20項目を確認。UIテスト不要。

</details>

---

## 18. 既存テスト実行確認

### Flutter
- [ ] `flutter test test/category_matcher_test.dart` pass
- [ ] `flutter test test/sort_categories_by_location_test.dart` pass
- [ ] `flutter test test/widget_test.dart` pass
- [ ] `flutter test test/utils/` pass
- [ ] `flutter analyze` warning/error 0件

### Firebase Functions
- [ ] `npm test` 全テスト pass（20件）
- [ ] `npm run lint` warning/error 0件
- [ ] `npm run build` 成功

### Maestro E2E
- [ ] `maestro test maestro/flows/add_and_check_item.yaml` pass
- [ ] `maestro test maestro/flows/shopping_list_crud.yaml` pass
- [ ] `maestro test maestro/flows/item_detail_and_delete.yaml` pass
- [ ] `maestro test maestro/flows/swipe_delete_item.yaml` pass
- [ ] `maestro test maestro/flows/empty_shopping_list_create.yaml` pass
- [ ] `maestro test maestro/flows/category_crud.yaml` pass
- [ ] `maestro test maestro/flows/category_location_order.yaml` pass
- [ ] `maestro test maestro/flows/settings_profile.yaml` pass
- [ ] `maestro test maestro/flows/virtual_pairing/` 全6フロー pass

### ビルド確認
- [ ] `flutter build ios` 成功
- [ ] `flutter build apk` 成功
- [ ] `dart run build_runner build` 差分なし


#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>

---

## 19. プラットフォーム固有

### iOS
- [ ] iOS実機で全画面の表示確認
- [ ] SafeAreaがノッチ/ダイナミックアイランドで正しく機能
- [ ] Appleサインイン正常動作
- [ ] ホーム画面ウィジェットの追加・表示・操作

### Android
- [ ] Android実機で全画面の表示確認
- [ ] 戻るボタンで正しくナビゲーション
- [ ] Googleサインイン正常動作
- [ ] ホーム画面ウィジェットの追加・表示・操作



#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

（スクリーンショット・結果をここに埋め込む）

</details>
