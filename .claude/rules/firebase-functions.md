---
paths:
  - "firebase/**/*.ts"
---

# Firebase Functions 規約

- 原則: onDocumentCreated,onDocumentUpdated によるトリガーによる処理を禁止します。コードがトレースしにくくなり、思わぬタイミングで発動してしまうのでコントロールがむず痒いためです
- 原則: クライアントから呼ぶ Functions は GenKit を使用して定義します
- 原則: group配下のドキュメントでユーザーの同時書き込みによりデータが消える可能性がある場合は、`runTransaction` を使用する（batchではなくトランザクションでアトミック性を保証する）
- Deployはユーザーが行うので禁止
- GenKitのFunctionsの検証のために引数は、Functionsの定義位置に記載する
