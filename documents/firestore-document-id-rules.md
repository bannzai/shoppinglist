# Firestore Document ID ルール

## 基本方針
基本的にはFirestoreの自動生成IDを使用する。

通常のサブコレクション（例: `/groups/{groupID}/shoppingLocations/{id}`、`/groups/{groupID}/shoppingLists/{id}`）ではFirestoreの自動生成IDで十分。

## Composite ID
Composite IDは、特定のリレーションを明示する必要がある場合にのみ使用する。

### 使用するケース
- Userと紐づく1:1の情報を、mapではなくcollection/documentとして格納したい場合
- 例: UserProfileはUser:Group間で1:1の関係 → `group_{groupID}_userProfile_{userID}`

### 使用しないケース
- 1:N の通常のサブコレクション（場所、買い物リスト、アイテム等）
- 親のパス自体で親子関係が明確な場合

### フォーマット
```
{parentCollection}_{parentDocID}_{childCollection}_{childDocID}
```

### 例
- `group_{groupID}_userProfile_{userID}`

### 理由
- ドキュメントIDだけで親子関係が一意に特定できる
- デバッグ時にIDから所属グループを即座に判別できる
- 将来的にcollectionGroup queryを使う際にIDの衝突を防げる

### 実装
Composite IDを使用する場合、エンティティクラスにstaticメソッドとしてID生成ロジックを集約する。

```dart
class GroupUserProfile {
  static String documentID({required String groupID, required String userID}) =>
      'group_${groupID}_userProfile_$userID';
}
```

Firebase Functions側でも同じフォーマットを使用すること。
