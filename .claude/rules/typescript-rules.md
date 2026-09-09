---
paths:
  - "firebase/functions/**/*.ts"
---

# TypeScript コーディング規約

Firestore の `doc.data()` 等、`any` を返す API の戻り値には `interface` を定義して `as` で型アサーションし、以降は型付きでアクセスする。
