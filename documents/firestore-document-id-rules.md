# Firestore Document ID ルール

## Composite ID
サブコレクション内のドキュメントIDは、親ドキュメントのIDを含むcomposite形式を使用する。

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
エンティティクラスにstaticメソッドとしてID生成ロジックを集約する。

```dart
class GroupUserProfile {
  static String documentID({required String groupID, required String userID}) =>
      'group_${groupID}_userProfile_$userID';
}
```

Firebase Functions側でも同じフォーマットを使用すること。
