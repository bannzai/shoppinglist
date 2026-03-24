# Firestore Composite ID 規約

Composite IDのフォーマットは `{EntityName}_{parentCollectionName}_{parentDocID}` を使用する。複数キーが必要な場合は `_{collectionName}_{docID}` を連結する。

- `EntityName` はPascalCase
- 基本は自動生成IDを使い、1:1リレーションのシングルトンドキュメント等にのみComposite IDを使用する
- Flutter側: Entityクラスの `static String documentID()` メソッドで定義
- Firebase Functions側: `entity/` ディレクトリのヘルパー関数で定義し、Flutter側と同じフォーマットを維持する

詳細: `documents/firestore-document-id-rules.md`
