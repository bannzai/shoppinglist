---
paths:
  - "*.ts"
  - "lib/provider/*.dart"
---

# Firestore トランザクションルール

- 原則: group配下のドキュメントでユーザーの同時書き込みによりデータが消える可能性があるので、`runTransaction` を使用する（batchではなくトランザクションでアトミック性を保証する）
