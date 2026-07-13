---
paths:
  - "lib/**/*.dart"
  - "firebase/functions/**/*.ts"
---

# Firestore タイムスタンプ更新ルール

## サーバータイムスタンプ
Firestoreのドキュメントを更新する際は、サーバー側のタイムスタンプフィールドを必ず付与する。

### フィールド一覧
| フィールド | 用途 | 付与タイミング |
|---|---|---|
| `serverCreatedDateTime` | サーバー側の作成日時 | ドキュメント新規作成時 |
| `serverUpdatedDateTime` | サーバー側の更新日時 | ドキュメント作成時・更新時の両方 |

### 理由
- クライアント側の `createdDateTime` / `updatedDateTime` はユーザー端末の時刻に依存する
- サーバータイムスタンプにより、正確な時系列の把握が可能になる

### 実装例

**Firebase Functions（TypeScript）:**

`FieldValue` / `Timestamp` の static は必ず `firebase-admin/firestore` からのモジュラー import で参照する。
`admin.firestore.FieldValue` 形式（名前空間 import の static 参照）は Functions Emulator ランタイム上で
undefined になり emulator で動作しないため使用しない（bannzai/shoppinglist#501 参照）。

```typescript
import { FieldValue } from "firebase-admin/firestore";

// 更新時
transaction.update(ref, {
  updatedDateTime: FieldValue.serverTimestamp(),
  serverUpdatedDateTime: FieldValue.serverTimestamp(),
});

// 新規作成時
transaction.set(ref, {
  createdDateTime: FieldValue.serverTimestamp(),
  updatedDateTime: FieldValue.serverTimestamp(),
  serverCreatedDateTime: FieldValue.serverTimestamp(),
  serverUpdatedDateTime: FieldValue.serverTimestamp(),
});
```

**Flutter（Dart）:**
```dart
// 更新時
await docRef.update({
  'updatedDateTime': FieldValue.serverTimestamp(),
  'serverUpdatedDateTime': FieldValue.serverTimestamp(),
});
```
