# Entity 親IDルール

## ルール
Firestoreのサブコレクションに保存されるEntityは、親ドキュメントのIDをフィールドとして保持する。

## 理由
- Firestoreのドキュメントパスからしか親IDを取得できない場合、ドキュメント単体で扱う際に親情報が失われる
- Entity単体で完結した情報を持つことで、UIやロジックでの取り回しが容易になる

## 例
`groups/{groupID}/categoryAxes/{axisID}` に保存される `GroupShoppingListItemCategoryAxis` は `groupID` フィールドを持つ。

## 対象
- `GroupShoppingListItemCategoryAxis`: `groupID`
- `GroupShoppingListItemCategory`: `groupID`
- 今後追加されるサブコレクションEntityも同様に親IDを保持すること
