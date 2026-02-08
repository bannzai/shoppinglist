# Styleguide
このファイルはGeminiがこのリポジトリで作業する際のガイダンスを提供します。

## Rule
返信は日本語でしてください


## Firebase Firestore

- **group配下の同時書き込み対策**: group配下のドキュメントでユーザーの同時書き込みによりデータが消える可能性がある場合は、`runTransaction` を使用すること

### セキュリティについてチェックする
- Firebase Functions onCall で req.auth のチェックを行なっている
- Firebase Functions onCall でクライアント側は httpsCallable が使用されている

### Entityの命名規則
- /users から始まるpathのcollection,subCollectionのEntityには `User` プレフィックスをつける
- /groups から始まるpathのcollection,subCollectionのEntityには `Group` プレフィックスをつける

### onDocumentCreated,onDocumentUpdated トリガーの禁止
- コードのトレースが難しくなる
- 意図しないタイミングで実行される問題が常に付きまとう

### Document Reference の更新は、{ merge: true }  をつける
- つけてないと指定したフィールド以外消える。ちょっとしたコードの移動で意識せずに消える

