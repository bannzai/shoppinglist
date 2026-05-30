---
paths:
  - "firebase/functions/**/*.ts"
---

# TypeScript コーディング規約

## any 型の回避
Firestoreの `doc.data()` 等、`any` を返すAPIの戻り値はそのまま使用しない。`interface` を定義して `as` で型アサーションし、以降の処理で型安全にアクセスする。

```typescript
// NG: any のまま使用
const data = doc.data();
const name = data?.name; // any

// OK: interface を定義して型アサーション
interface GroupData {
  memberUserIDs: string[];
  ownerUserID: string | null;
  name: string | null;
}
const data = doc.data() as GroupData | undefined;
const name = data?.name; // string | null | undefined
```
