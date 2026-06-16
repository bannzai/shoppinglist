# ADR 0027: レシート画像をサブコレクションで管理する

## ステータス
採用

## コンテキスト
買い物リストごとにレシート（画像 + 金額・メモ）を登録できるプレミアム機能を追加する。
1リストに複数枚のレシートを登録可能にする必要がある。

## 決定
レシートを `groups/{groupID}/shoppingLists/{shoppingListID}/receipts/{receiptID}` のサブコレクションとして管理する。

### データ設計
- Firestore: `receipts` サブコレクション（Entity: `GroupShoppingListReceipt`）に `storagePath`・`amount`・`memo` と親IDを保持
- Storage: `groups/{groupID}/shoppingLists/{shoppingListID}/receipts/{receiptID}.jpeg`（receiptID から決定的に決まるパス）に画像を保存
- 書き込みは `uploadReceiptImage` Function（Admin SDK）経由のみ。**download URL は Firestore に保存せず**、Function は storage path を返す（永続 bearer URL の流出を避けるため）
- 読み取りは `storage.rules` で認証済みグループメンバーに read 許可し、クライアントが storagePath から都度 `getDownloadURL` で取得する
- レシートは登録・編集のみで削除機能は提供しない（`firestore.rules` も `create` / `update` のみ許可）
- 画像配信の将来的な Cloudflare R2 移行（custom claim + Worker による path ベース認可）は別 issue で検討する

### 代替案
- `GroupShoppingList` Entity に `receiptImageURL` フィールドを1つ追加する案 → 複数枚に対応できないため不採用
- `GroupShoppingList` に `List<ReceiptData>` を埋め込む案 → ドキュメントサイズ制限・部分更新の複雑さから不採用

## 影響
- `firestore.rules` に `receipts` サブコレクションの read/write ルール（`isGroupMember()`）を追加
- `storage.rules` に `receipts` パスのクライアント直アクセス禁止ルールを追加
- `GroupDatabase` に `receiptsReference` / `receiptReference` / `newReceiptReference` を追加
