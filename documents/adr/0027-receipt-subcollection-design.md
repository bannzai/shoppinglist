# ADR 0027: レシート画像をサブコレクションで管理する

## ステータス
採用

## コンテキスト
買い物リストごとにレシート（画像 + 金額・メモ）を登録できるプレミアム機能を追加する。
1リストに複数枚のレシートを登録可能にする必要がある。

## 決定
レシートを `groups/{groupID}/shoppingLists/{shoppingListID}/receipts/{receiptID}` のサブコレクションとして管理する。

### データ設計
- Firestore: `receipts` サブコレクション（Entity: `GroupShoppingListReceipt`）に `imageURL`・`amount`・`memo` と親IDを保持
- Storage: `groups/{groupID}/shoppingLists/{shoppingListID}/receipts/{receiptID}/photo` に画像を保存
- Storage アクセスは `uploadReceiptImage` Function（Admin SDK）経由のみ（既存の商品写真添付と同じ方式）
- レシートは登録・編集のみで削除機能は提供しない（`firestore.rules` も `create` / `update` のみ許可）

### 代替案
- `GroupShoppingList` Entity に `receiptImageURL` フィールドを1つ追加する案 → 複数枚に対応できないため不採用
- `GroupShoppingList` に `List<ReceiptData>` を埋め込む案 → ドキュメントサイズ制限・部分更新の複雑さから不採用

## 影響
- `firestore.rules` に `receipts` サブコレクションの read/write ルール（`isGroupMember()`）を追加
- `storage.rules` に `receipts` パスのクライアント直アクセス禁止ルールを追加
- `GroupDatabase` に `receiptsReference` / `receiptReference` / `newReceiptReference` を追加
