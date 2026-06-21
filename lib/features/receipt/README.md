# receipt（レシート）

買い物リストごとにレシート（画像 + 金額・メモ）を複数枚登録できるプレミアム機能。

## 概要
- 1つの買い物リスト（`GroupShoppingList`）に対し、レシートを複数枚登録できる。
- レシートは画像（Firebase Storage）と、金額・メモのメタデータ（Firestore）で構成される。
- 最初から全体がプレミアム機能。非プレミアムユーザーはタップで Paywall に誘導される。

## 画面・表示条件
- 表示場所: 買い物リスト詳細画面（ホームのアイテム一覧）。導線は1つ（`ReceiptAddButton`）に集約する。
  - `ReceiptAddButton`: アイテム一覧の上部、AIカテゴリ分けボタンの直上に控えめな pill で表示する。リストが長いと最下部の導線に気づきにくいため上部に出す。AIカテゴリ分けボタン（accent 塗りつぶし）より主張を抑えるため soft（accent 薄塗り）トーンにする。
  - ラベルはレシートの有無で出し分ける: 未登録なら「レシートを追加」、登録済み（`receipts.isEmpty == false`）なら「レシートを編集」。データ上は複数枚保持できるが、UI では先頭（最新）の1枚を編集対象にする。
  - 以前は最下部に登録済みサムネ一覧（`ReceiptThumbnails`）を併設していたが廃止した。レシートの有無はボタンのラベルで表現する。
- 表示条件: チェック済みアイテムが1件以上ある（`shoppingListItemMetrics(items).checkedCount > 0`）とき。
- `receipt_section.dart` に定義する。FAB のような一等地は使わない。

## フロー
1. 買い物リストのアイテムを1つ以上チェックすると、リスト上部に「レシートを追加」ボタンが現れる。
2. 「レシートを追加」をタップ（非プレミアムなら Paywall を表示して終了）。
3. `showReceiptEditSheet`（`receipt_edit_sheet.dart`）で写真を撮影/選択し、金額・メモを入力して保存する。
   - 新規は写真必須。`receiptID` を採番 → `uploadReceiptImage` で画像アップロード → Firestore にドキュメント作成、の順で実行する（画像アップロード失敗時はドキュメントを作らないため孤児が残らない）。
4. レシート登録後はボタンが「レシートを編集」に変わり、タップすると同じ編集シートが開いて金額・メモ・画像を編集できる（削除は行わない）。

## データ形式
- Firestore: `groups/{groupID}/shoppingLists/{shoppingListID}/receipts/{receiptID}`（Entity: `GroupShoppingListReceipt`）。
  - `amount`（int? 円）、`memo`（String?）、`storagePath`（String? Storage パス）、親IDの `groupID` / `shoppingListID`。
- Storage: `groups/{groupID}/shoppingLists/{shoppingListID}/receipts/{receiptID}.jpeg`（receiptID から決定的に決まるパス）。
  - 書き込みは `uploadReceiptImage` Function（Admin SDK）経由のみ（`storage.rules` で write 禁止）。Admin SDK の `file.save()` はダウンロードトークンを生成しないため、`uploadReceiptImage` は保存後に `getDownloadURL(file)` を呼んで `firebaseStorageDownloadTokens` を生成する（これを省くとクライアントの `getDownloadURL` がトークン無し URL を返し画像が表示できない）。
  - 読み取りは `storage.rules` で認証済みユーザーに許可。クライアントは `storagePath` から `getDownloadURL`（`ReceiptImage` widget）で取得し表示する。download URL は Firestore に保存しない。グループメンバー判定（`firestore.get` クロスサービス参照）は permission-denied 切り分けを難しくするため行わない（`.claude/rules/firestore-rules-simplicity.md`）。

## 制約
- プレミアムユーザーのみ登録可能（UI ゲート + `uploadReceiptImage` のサーバーゲート `hasPremiumEntitlement`）。非プレミアムには「レシートを編集」を出さず常に「レシートを追加」（→ Paywall）にする。
- 画像は JPEG に圧縮して保存（`base64CompressImage`、最大 10MB）。
- レシートの削除機能は提供しない（登録・編集のみ。firestore.rules も `create` / `update` のみ許可）。

## 関連ファイル
- `lib/features/receipt/receipt_section.dart` — 上部の追加/編集ボタン（`ReceiptAddButton`、ラベルをレシート有無で出し分け）
- `lib/features/receipt/receipt_edit_sheet.dart` — 登録/編集シート
- `lib/features/receipt/receipt_image.dart` — storagePath から getDownloadURL で画像を表示する widget
- `lib/entity/group_shopping_list_receipt.dart` — Entity
- `lib/provider/receipt.dart` — 一覧 Stream / `AddReceipt` / `UpdateReceipt`
- `lib/utils/functions/firebase_function.dart` — `uploadReceiptImage` の呼び出し
- `firebase/functions/src/functions/uploadReceiptImage/` — Functions 本体
