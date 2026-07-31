# shopping_list 機能

買い物リストのメイン画面（`page.dart`）と、アイテム表示・追加・AI連携の各コンポーネント。

## カテゴリ分類の仕組み（前提）
アイテム（`GroupShoppingListItem`）は **カテゴリIDを持たない**。表示時に各アイテムの `message` と
カテゴリ（`GroupCategory`）の `keywords` を `category_matcher.dart` の `groupItemsByCategory` で
マッチングし、グルーピングして表示する。どのキーワードにもマッチしないアイテムは「未分類」になる。

## AIによるカテゴリ分け

未分類アイテムを AI が「野菜」「肉」などのコーナーに分類し、プレビューで確認・調整して一括登録する機能。

### 画面・コンポーネント
- `components/ai_categorize_button.dart` (`AICategorizeButton`): 未分類アイテムがあるとき
  リスト上部に表示する「自動でカテゴリ分け（N件）」ボタン。
- `components/ai_categorize_preview_sheet.dart` (`showAICategorizePreviewSheet`): 分類結果を
  カテゴリ別に表示し、各候補のカテゴリ変更・除外ができる確認シート。

### 表示条件
`shopping_list_items.dart` で、未分類アイテムが1件以上あるときボタンを表示する。
- 入力中の空行（`message` が空のアイテム）は表示条件・件数カウントから除外する。
- カテゴリ未作成（フラット表示）でも表示する（AIがカテゴリ自体を新規作成）。

### フロー
1. ボタンをタップ。当月の残回数が0なら SnackBar（無料ユーザーはアップグレード導線）を出して終了。
2. `functions.categorizeShoppingListItems(itemNames, existingCategoryNames)` を呼ぶ
   （AI処理中バナーを表示）。サーバーは「アイテム名→カテゴリ名」の対応のみ返す。
3. プレビューシートで確認・調整（カテゴリ変更／除外）し「N件を登録」。
4. `aiCategorizeApplyProvider`（`AICategorizeApply`）で永続化:
   - 軸（`GroupCategoryAxis`）が無ければ「デフォルト」軸を作成
   - カテゴリ名に一致する既存カテゴリが無ければ作成
   - 各アイテム名を該当カテゴリの **完全一致キーワード** として追記（重複は無視）
5. Firestore のストリーム更新で、未分類アイテムが各カテゴリに移動して表示される。

### 登録方式
分類結果はアイテム名を **完全一致（`GroupCategoryKeywordMatchingType.exact`）キーワード** として
カテゴリに追記して永続化する。これにより既存のキーワード分類エンジンにそのまま乗り、今後同じ品名も
自動分類される。カテゴリ軸はユーザーごと（`groupCategoryAxes` が `userID` で絞り込み）のため、
登録結果は実行ユーザーのカテゴリ表示に反映される。

### 制約
- 認証必須。
- 月次利用上限: 無料5回 / プレミアム50回（UTC基準）。`aiUsage.categorizeCount` でカウント。
- 1リクエスト最大100アイテム、各100文字以下（サーバー側で制限）。

### 関連
- バックエンド: `firebase/functions/src/functions/categorizeShoppingListItems/`
- 利用回数: `lib/entity/ai_usage.dart` / `lib/provider/ai_usage.dart`（`remainingCategorizeCount`）
- プレビュー（UI検証）: `lib/features/previews/screens/ai_categorize_preview_sheet_preview.dart`

## アイテム追加 FAB とリスト追加メニュー
- 右下 FAB（accent 塗り・add_task アイコン）: `expandable_fab.dart`（`ExpandableFab`）。
  タップで空行を 1 件追加する（最頻操作をワンタップにする。Issue #462）。長押しで
  「写真から追加 / URL から追加 / テキスト貼り付け」のメニューを上方向に展開する
  （展開中はタップ・長押しとも閉じる）。展開メニュー（ラベルピル + 円形アイコンの行）は
  `fab_action_menu.dart`（`FabActionMenu` / `FabMenuAction`）。
- 上部バー（`ListTopBar`）右の「リストを追加」ボタン（リスト+バッジの合成アイコン）:
  `create_list_menu_button.dart`（`CreateListMenuButton`）。右下ダブル FAB の上側
  （旧 `CreateListFab`）から Issue #461 で移動した。タップで
  「今日の日付でリストを追加 / 現在のリストを複製 / 未チェックのみ引き継いで複製」の
  3 アクションのメニュー（PopupMenu）を開く。
  「今日の日付でリストを追加」は「リスト作成（日付名で自動命名）→ 作成リストへ切替 →
  空アイテム追加→auto-focus」まで連鎖し、新しい買い物の開始につなげる。無料プランの上限超過時は
  SnackBar（アップグレード導線付き）を表示する。複製は `ShoppingListDuplicate` に委譲し、
  完了後は複製先リストへ表示を切り替える。

## リスト追加スポットライト（Issue #494, #508）
`ListTopBar` 右の「リストを追加」ボタン（`CreateListMenuButton`）にユーザーが気づけるよう、
背景をディム（黒半透明）で覆いボタン部分だけを切り抜いて強調し、説明バブルを出すスポットライト
（コーチマーク）。パッケージは使わず自作する。

- 汎用の表示コンポーネント: `components/spotlight/spotlight_view.dart`（`SpotlightView`）。
  対象の global Rect を `CustomPainter` + `Path.combine(difference)` で切り抜き、フェードインで表示する。
  切り抜き形状は `SpotlightOval` / `SpotlightRoundedRect` の 2 種。**アプリ非依存**の presentation で、
  将来のパッケージ切り出し（TsukiAkari 構想）を意識して機能ロジックを持たない。
- 機能側のホスト: `components/create_list_spotlight.dart`（`CreateListSpotlightHost`）。
  `build` は `SizedBox.shrink` を返し、`toast_overlay.dart` と同様に `appNavigatorKey` 経由で
  root Overlay へ命令的に挿入する（route push はシートの pop 乗っ取りになるため使わない）。

### 表示条件
表示判定は純粋関数 `shouldShowCreateListSpotlight`（同ファイル）に切り出す。

- 条件1（日次ナッジ）: 最後の買い物リスト作成日が、ローカルタイムで「日付が変わった」
  （24 時間経過ではない。昨日 23:59 作成 → 今日 00:01 で成立）。
- 条件2（チェック後の再訪ナッジ）: アイテムを最後にチェックしてから 1 時間以上経過。
  アプリのライフサイクルに沿って評価する（初回データ到達後 1 回 + foreground 復帰時 `useOnResumed`。
  アプリ内タイマーは持たない）。
- 条件3（生涯1回のみ）: 一度でも表示済み（最終表示日時が記録済み）なら以後は表示しない。
  当初（Issue #494）は日次・チェック機会ごとに再表示していたが、日を跨ぐたびに毎回出て
  煩わしいため、1 回までに変更した（Issue #508）。

判定式: `!表示済み && (cond1 || cond2)`。

### 評価タイミング・ガード
- 評価は「初回にアイテム一覧が到達した後の post-frame で 1 回」と「foreground 復帰時」のみ。
  連続 rebuild では評価しない。
- 上にシート/ダイアログがある時（`ModalRoute.of(context).isCurrent != true`）・対象の
  `RenderBox` が取れない時は表示しない。二重 insert もしない。
- **表示した時点で**最終表示日時を記録する（dismiss 時ではない。アプリ kill でも再表示しないため）。

### フラグの保存先
最終表示日時は `SharedPreferences`（キー: `StringKey.createListSpotlightLastShownDateTime`、
ISO8601 文字列）に保存する。読み書きは `provider/string_shared_preferences.dart`
（`StringSharedPreferences`、`bool_shared_preferences.dart` と対称）経由。

### analytics
表示時に `show_create_list_spotlight`、タップで閉じた時に `tap_dismiss_create_list_spotlight`
（いずれも parameters に `groupID`）。

### デバッグ方法（開発者オプション）
- 「リスト追加スポットライトを強制表示」: `debugForceCreateListSpotlightProvider` を ON にする。
  買い物リスト画面へ戻ると条件を無視して表示する（強制表示時は履歴を書かず本番状態を汚さない）。
- 「リスト追加スポットライト履歴をリセット」: 最終表示日時を削除し、条件を満たせば再表示できるようにする。

## 入力行と空行のライフサイクル
入力行は `message=''` の `GroupShoppingListItem` ドキュメント。テキストはローカルの
`TextEditingController` に保持し、Enter（改行）で確定して別アイテムに保存する。

- 空行はフォーカスが外れた時に削除する（`text_shopping_list_item.dart` の FocusNode listener）。
  常駐する空入力行は残さない。
- フォーカス喪失時、入力途中のテキストがあれば確定保存する（空なら行を削除）。
- 連続入力（Enter連打）中は入力行にフォーカスが残るためキーボードは閉じず、空行も消えない
  （キーボード維持は fix-350 の設計を踏襲）。
- 再入力は FAB（`expandable_fab.dart`：タップで空行追加→auto-focus）
  または空状態のスターター行から。

## チェック済み・カテゴリ表示の固定（Issue #373）
チェック済みアイテムは常に表示し、カテゴリ軸があれば常にカテゴリ順で表示する。
切り替えUI（`FilterChipsBar` / フィルター画面）は Issue #373 で廃止した。
`textShoppingListItemsProvider` は常に全件（チェック済み含む）を返す。

## カテゴリ表示の並び替え・カテゴリ間移動
カテゴリ表示時は、ヘッダーとアイテムを 1 つの `ReorderableListView`（`buildDefaultDragHandles: false`、
アイテム行のみ `ReorderableDelayedDragStartListener` でラップ）にフラットに並べ、長押しドラッグで
**同一カテゴリ内の並び替え** と **別カテゴリへの移動** の両方を行える。ヘッダーはドラッグ対象外、
入力行（空行）もドラッグ対象外。行モデル・ドロップ先カテゴリ判定・order 正規化は
`category_matcher.dart` の `buildGroupedRows` / `categoryIDForDropPosition` / `dropIndexInTarget` /
`itemsAfterMove` に切り出している。

- **order**: 移動のたびに、移動後の表示順（カテゴリ順 → カテゴリ内順）で全アイテムの `order` を
  0..N-1 に正規化し、`shoppingListItemBatchUpdateProvider` で永続化する。
- **カテゴリ間移動の永続化**: アイテムはカテゴリIDを持たない（`message` × キーワードで分類）ため、
  別カテゴリへ移したら `MoveItemCategoryKeyword`（`provider/group_category.dart`）で移動先カテゴリに
  `message` を完全一致(exact)キーワードとして追加し、移動先以外のカテゴリから同 exact を削除する
  （`keywordsAfterItemMove` が 1 カテゴリ分の付け替えを担う、transaction で read-modify-write）。
- **楽観的ローカル状態（ドロップ後のチラつき防止）**: `ReorderableListView` は `onReorder` 内で表示元
  データを同期更新する前提だが、本実装は永続化を Firestore stream 反映に委ねるため、そのままだと
  ドロップ後に一旦古い並びへ戻り（さらにカテゴリ間移動では order=batch とキーワード=transaction が
  二段で反映され）チラつく。これを防ぐため `_GroupedListView`（`HookConsumerWidget`）が `onReorder`
  時に楽観状態（`_OptimisticReorder`: 全アイテムの新 order と移動アイテムの分類上書き）を同期セットして
  即座に新しい並び・分類で描画し、stream が同じ状態に追いついたら（`_optimisticReflected`）破棄する。
  書き込み失敗時は破棄して永続化された実状態を表示する（ロールバック）。

### 既知の限界・副作用
- 同名（`message` が同じ）アイテムは一緒に移動する（キーワードは message 単位）。
- 手動の部分一致/正規表現でマッチしているアイテムは、移動先に exact を足しても元カテゴリの order が
  小さいと残るため、移動が効かない場合がある（分類エンジン `findMatchingCategoryID` は変更しない方針）。
- 表示されていない（アイテム 0 件の）カテゴリへはドラッグで移動できない（ヘッダーが無いため）。

フラット表示（`_FlatShoppingListItems`、カテゴリ軸なし）は従来どおり全体を `ReorderableList`
で並び替える（`reorderedSectionItems` を使用）。

### 検証
カテゴリ間ドラッグは widget test（`shopping_list_items_cross_category_test.dart`）で、実際に長押し
ドラッグを駆動して `onReorder` → カテゴリ判定 → `MoveItemCategoryKeyword` 呼び出しまでを検証する
（行中央は TextField のため、ドラッグ開始は行の左端を掴む）。判定・order・キーワード付け替えの各純粋
関数は単体テストで担保する。

## セクション（カテゴリ）単位の並び替え（Issue #386）
カテゴリ別グルーピング表示では、セクションヘッダー（`CategorySectionHeader`）を **長押しドラッグ**
するとセクション単位で並び替えできる。アイテム単位の D&D と同じ統合 `ReorderableListView` 上で、
掴んだ行がヘッダーならセクション並び替え、アイテムならアイテム移動として扱う。

- 並び順は `GroupCategory.order`（買い物場所選択時は `locationOrders`、プレミアム限定）へ
  `groupCategoryBatchUpdateProvider` で永続化され、カテゴリ管理画面（`group_category/page.dart`）の
  並び順と共有される。
- アイテムが0件で非表示のカテゴリは、元の相対順序を保ったまま並び直す
  （`category_matcher.dart` の `reorderCategorySections`。ヘッダーのドロップ位置→挿入先 index の
  変換は `sectionInsertIndexForHeaderDrop`）。
- 「未分類」セクションはカテゴリ実体が無いため常に末尾固定でドラッグ不可。カテゴリを未分類の
  下へドロップしても未分類の直前に収まる。
- ドロップ直後はアイテム移動と同様に楽観の表示順（カテゴリID列）を同期適用し、stream が
  追いついたら破棄する（チラつき防止）。失敗時は破棄してロールバック。
- ドラッグ中の proxy はヘッダー + 先頭アイテム（最大2件、`IgnorePointer` の表示専用プレビュー）で
  「セクションごと持ち上げた」見た目にする（`proxyDecorator`）。掴んだ瞬間（`onReorderStart`）に
  そのセクションのアイテム行はリストから畳み、proxy との二重表示を防ぐ。畳みの解除は、移動を
  伴うドロップは `onReorder` で楽観順の適用と同一フレーム、同位置ドロップ（`onReorder` が
  呼ばれない）は `onReorderEnd`、ポインタキャンセル（どちらも呼ばれない）は外側の
  `Listener(onPointerCancel)` が保険として行う。proxy のプレビューは別インスタンスのため、
  入力行の GlobalKey（fix-350）はセクションドラッグ中も二重化しない。
- E2E: `maestro/flows/category_section_reorder.yaml`（長押しドラッグは超低速 swipe で再現）。

## アイテム詳細からのカテゴリ確認・編集
アイテム詳細シート（`text_shopping_list_item_detail_bottom_sheet.dart`）に、先頭軸
（`groupCategoryAxes.first`）で `findMatchingCategoryID`（`category_matcher.dart`）により判定した
現在の分類カテゴリを表示する。シートでできる操作はカテゴリの確認・変更とアイテムの削除。
以前あった説明（`description`）・商品写真（`imageURL`）・カラー（`color`）の編集と一覧表示は
Issue #464 で一旦削除した（データフィールドと Functions は温存。名前マッチによる再設計は #463）。

- マッチ時:「カテゴリを変更」/ 未分類時:「カテゴリを選択」→ いずれも `GroupCategoryPage`
  （カテゴリ選択モード `selectionForItem != null`）へ遷移する。
- 一覧で行をタップすると、このアイテムを選んだカテゴリへ移す（`MoveItemCategoryKeyword` で
  移動先へ完全一致キーワードを追加し、他カテゴリから同名の完全一致キーワードを削除する付け替え）。
  一覧で新規カテゴリを追加してそのまま選ぶこともできる。選択後は pop して詳細シートへ戻る。
- 軸が無い（カテゴリ機能未使用）ときはカテゴリ行を表示しない。

## グループへの更新通知（Issue #449）
買い物リストを更新したことを、グループの他メンバーへプッシュ通知で知らせる機能。
上部バー（`ListTopBar`）に置いた手動ボタン `NotifyGroupButton`
（`components/notify_group_button.dart`）から送信する。

- **表示条件**: グループに他メンバーが居るときだけボタンを表示する（ソロでは非表示）。
  `groupUserProfilesProvider` と `currentUserIDProvider` で「自分以外のメンバーが居るか」を判定する。
- **初回タップ**: `BoolKey.hasSeenManualNotifyGuide` が false の初回のみ、機能説明ダイアログ
  （`AppDialogShell`）を出す。[通知を送る] で確定したら送信し、フラグを true にする。以降は
  ダイアログを出さず、タップで直接送信する。
- **送信**: 他メンバー全員へ `functions.sendShoppingListUpdateNotification` を1回呼ぶ。
  成功で「グループに通知しました」トースト、失敗は `showGlobalErrorToast` で生エラーを表示する。

### 背景（自動検知の廃止）
以前は、自分がリストを変更したことを `hasPendingWrites` で検知し、通知バー
（`NotificationMemberBar`）を自動表示する `FamilyNotificationTrigger` を常駐させていた
（Issue #430）。しかし通知バーが FAB・入力欄・キーボードと重なり編集の妨げになったため
（Issue #445）、自動検知・通知バー・バックグラウンド自動送信・設定トグルを全廃し、手動ボタンへ
一本化した（Issue #449）。

### 検証
`test/features/shopping_list/components/notify_group_button_test.dart` で、ボタンの表示条件
（ソロでは非表示・他メンバー居れば表示）と初回説明ダイアログのゲート（初回タップでダイアログ表示・
キャンセルで送信しない）を widget test で検証する。送信（Firebase Functions 呼び出し）と2回目以降の
直接送信は、シミュレータ + 開発者オプション「グループにデバッグユーザーを追加」で確認する。

## Native 広告の固定表示と広告削除（Issue #77, #150）
一覧の上部（`ListTopBar` 直下・白カード領域の先頭）に AdMob の Native 広告
（`components/banners/admob_native_ad_banner.dart` の `AdMobNativeAdBanner`）を固定表示する。
Google 公式の Native Templates(small) で描画し、読み込み完了までは高さ 0 で場所を取らない。

- **表示条件**: 非プレミアムユーザーのみ（プレミアム機能: 広告削除、Issue #150）。
  判定は UI 表示用途のため `customerInfoProvider` の `isPremium` を使う（`provider/auth_claim.dart` 参照）。
  キーボード表示中は入力領域を優先して隠す（`RetentionBanner` と同じ扱い）。
- **広告ユニット ID**: `lib/secret/secret.dart` の `iOSAdmobNativeAdvanceIdentifier` /
  `androidAdmobNativeAdvanceIdentifier`。AdMob の App ID は iOS が
  `ios/Flutter/{Debug,Release}.xcconfig` の `ADMOB_APP_ID`、Android が
  `android/app/build.gradle` の `manifestPlaceholders["ADMOB_APP_ID"]`。
  いずれも現在は Google 公式のテスト用 ID で、本番リリース前に実 ID への差し替えが必要。
- **SDK 初期化**: `main.dart` で `MobileAds.instance.initialize()` を起動時に済ませる。
- **ATT (App Tracking Transparency)**: iOS では広告ロード前に `app_tracking_transparency`
  パッケージで許可ダイアログを出す（広告を表示する非プレミアムユーザーのみ・初回のみ）。
  拒否されても広告は配信される（パーソナライズされないだけ）。文言は
  `ios/Runner/Info.plist` の `NSUserTrackingUsageDescription`。

### 検証
`test/features/shopping_list/page_ad_visibility_test.dart` で、プレミアム状態による表示切り替えと
キーボード表示中の非表示を widget test で検証する。実際の広告描画はシミュレータ + テスト広告で確認する。
