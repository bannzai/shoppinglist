# Firebase Functions 呼び出しルール

## クライアント側の呼び出し方式

Firebase Functionsの呼び出しは、`lib/utils/functions/firebase_function.dart` に定義された `functions` インスタンスの拡張メソッドを直接呼ぶ。

### NG: Provider + Classでラップする
```dart
// 不要なラッパー
class RemoveGroupMember {
  Future<void> call({required String groupID, required String targetUserID}) async {
    await functions.removeGroupMember(groupID: groupID, targetUserID: targetUserID);
  }
}

@Riverpod(dependencies: [])
RemoveGroupMember removeGroupMember(RemoveGroupMemberRef ref) {
  return RemoveGroupMember();
}

// 呼び出し
await ref.read(removeGroupMemberProvider).call(groupID: groupID, targetUserID: targetUserID);
```

### OK: 直接呼ぶ
```dart
import 'package:shoppinglist/utils/functions/firebase_function.dart';

await functions.removeGroupMember(groupID: groupID, targetUserID: targetUserID);
```

### 理由
- Firebase Functions呼び出しは状態を持たないため、Riverpod Providerで管理する必要がない
- `functions` はグローバルインスタンスで、拡張メソッドとして定義済み
- 余分な間接層を排除し、コードをシンプルに保つ

### 例外
Firestoreへの直接読み書き（Functions経由でないもの）は、引き続き `call` メソッドを持つclassとProviderで定義する。これはDBアクセスに必要なコンテキスト（groupID等）を注入する必要があるため。
