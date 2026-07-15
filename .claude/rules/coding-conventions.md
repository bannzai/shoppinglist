---
paths:
  - "lib/**/*.dart"
---

# コーディング規約

- Entityのフィールド名は省略せず、長くても実態がわかる名前をつける（例: `categoryID` ではなく `groupCategoryID`）
- FirestoreのDBに対して変更（書き込み・更新・削除）を行う場合は、`call` メソッドを持ったclassを提供するProviderを用意し、そのProvider経由で操作すること（例: `AddShoppingListItem`, `ToggleShoppingListItemCheck` など）
- 関数の引数は原則 `{required}` でラベルが呼び出し元につくようにする
- コンストラクタの引数も nullable であっても `required` をつける。ただしtimestamp等のメタデータフィールドは除く
- Providerの取得は状態・機能を問わずbuild内で`ref.watch`しローカル変数にキャプチャし、コールバックはその変数を参照する（詳細: `.claude/rules/riverpod-rules.md`）
- エラーメッセージについては、基本的にそのまま表示する（`e.toString()` の加工・プレフィックス除去等はしない）
- Firestoreのサブコレクションに保存されるEntityは、親ドキュメントのIDをフィールドとして保持する
