---
paths:
  - "lib/**/*.dart"
---

# コーディング規約

- Entityのフィールド名は省略せず、長くても実態がわかる名前をつける（例: `categoryID` ではなく `groupShoppingListItemCategoryID`）
- FirestoreのDBをクライアントから操作する場合は、`call` 関数を定義したclassを通じて行う（例: `ShoppingListAdd`, `CreateGroup` など。Providerからそのclassのインスタンスを返却する）
- 関数の引数は原則 `{required}` でラベルが呼び出し元につくようにする
- コンストラクタの引数も nullable であっても `required` をつける。ただしtimestamp等のメタデータフィールドは除く
- firestoreのDBに書き込むProviderでは、ref.readを使用してClosureの中で呼ぶ
- エラーメッセージについては、基本的にそのまま表示する（`e.toString()` の加工・プレフィックス除去等はしない）
- Firestoreのサブコレクションに保存されるEntityは、親ドキュメントのIDをフィールドとして保持する（詳細: `documents/entity-parent-id-rules.md`）
