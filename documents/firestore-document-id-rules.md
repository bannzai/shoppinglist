# Firestore Document ID ルール

## 基本方針
基本的にはFirestoreの自動生成IDを使用する。

通常のサブコレクション（例: `/groups/{groupID}/shoppingLocations/{id}`、`/groups/{groupID}/shoppingLists/{id}`）ではFirestoreの自動生成IDで十分。

## Composite ID
Composite IDは、特定のリレーションを明示する必要がある場合にのみ使用する。

### 使用するケース
- Userと紐づく1:1の情報を、mapではなくcollection/documentとして格納したい場合
- 例: GroupUserProfileはUser:Group間で1:1の関係 → `GroupUserProfile_groups_{groupID}_users_{userID}`

### 使用しないケース
- 1:N の通常のサブコレクション（場所、買い物リスト、アイテム等）
- 親のパス自体で親子関係が明確な場合

### フォーマット
```
{EntityName}_{parentCollectionName}_{parentDocID}[_{additionalCollectionName}_{additionalDocID}]
```

- `{EntityName}`: PascalCaseのエンティティ名（先頭に来ることでIDの種類が一目で分かる）
- `{parentCollectionName}_{parentDocID}`: 親コレクション名とドキュメントIDのペア
- 複数キーが必要な場合は `_{collectionName}_{docID}` を連結

### 例
- `UserPrivate_users_{userID}` — `/users/{userID}/privates/` 内のシングルトン
- `GroupUserProfile_groups_{groupID}_users_{userID}` — `/groups/{groupID}/userProfiles/` 内のUser別ドキュメント

### 理由
- エンティティ名が先頭にあるため、IDだけで何のエンティティか判別できる
- collectionGroup queryでIDの衝突を防げる
- デバッグ時にIDから所属リソースを即座に判別できる

### 実装
Composite IDを使用する場合、エンティティクラスにstaticメソッドとしてID生成ロジックを集約する。

```dart
class GroupUserProfile {
  static String documentID({required String groupID, required String userID}) =>
      'GroupUserProfile_groups_${groupID}_users_$userID';
}
```

Firebase Functions側でも同じフォーマットを使用すること。
