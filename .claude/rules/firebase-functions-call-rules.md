---
paths:
  - "lib/**/*.dart"
---

# Firebase Functions 呼び出しルール

- Firebase Functions は `lib/utils/functions/firebase_function.dart` の `functions` インスタンスの拡張メソッドを直接呼ぶ。状態を持たない呼び出しに Provider・class のラッパーは不要。
- Firestore の直接読み書き（Functions 経由でないもの）は、コンテキスト（groupID 等）を注入するため、`call` メソッドを持つclassとProviderで定義する。
