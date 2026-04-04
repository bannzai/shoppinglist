# コーディング規約チェックリスト

差分コードに対して以下の観点をチェックする。

## Dart (.dart) ファイル

### Entity 命名
- フィールド名が省略されていないか
- 例: `categoryID` ではなく `groupShoppingListItemCategoryID`

### Firestore 操作
- DB への書き込み・更新・削除が `call` メソッドを持つ class の Provider 経由か
- 直接 Firestore を操作していないか

### 引数の required
- 関数の引数に `{required}` がついているか
- コンストラクタの引数に `required` がついているか（nullable でも）
- 例外: timestamp 等のメタデータフィールド

### ref の使い分け
- `build()` メソッド内では `ref.watch` を使っているか
- コールバック・操作では `ref.read` を使っているか
- Firestore 書き込み Provider では `ref.read` を Closure 内で使っているか

### Analytics
- ユーザーインタラクションのコールバック先頭で `analytics.logEvent` を呼んでいるか

### Hooks / Widget
- `HookConsumerWidget` を使っているのに hooks を使っていない場合は `ConsumerWidget` で十分
- `useState` に外部データ（Provider の値、親からの引数）を渡していないか

### サブコレクション Entity
- 親ドキュメントの ID をフィールドとして保持しているか

### Composite ID
- `{EntityName}_{parentCollectionName}_{parentDocID}` フォーマットに従っているか

### エラーメッセージ
- `e.toString()` の加工・プレフィックス除去をしていないか

### Firestore Timestamp / FieldValue
- `documents/firestore-timestamp-rules.md` の規約に従っているか
- `documents/firestore-fieldvalue-rules.md` の規約に従っているか

## TypeScript (.ts) ファイル

### Firebase Functions
- GenKit で定義しているか
- `onDocumentCreated` / `onDocumentUpdated` トリガーを使っていないか

### トランザクション
- group 配下のドキュメント操作で `runTransaction` を使っているか（batch ではなく）

### Composite ID (Functions 側)
- Flutter 側と同じフォーマットを維持しているか

## 共通

### Single Source of Truth
- 同じ情報を 2 度書いていないか
- 中間表現の構造を作っていないか
- コメントに「何をしているか」を書いていないか（「これは何を表現しているものか」のみ可）
