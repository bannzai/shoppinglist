# Firebase Functions 規約

## serverUpdatedDateTime の付与
Firestoreのドキュメントを更新（update/set）する際は、必ず `serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp()` を含めること。新規作成時は `serverCreatedDateTime` も付与する。

クライアント側の `updatedDateTime` はユーザー端末の時刻に依存するため、サーバー側で信頼できるタイムスタンプを別途記録する目的である。
