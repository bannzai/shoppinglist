---
scope: cross-repository
recorded: 2026-11-10
---
# Firebase Console の APNs 認証キーは「開発用」と「本番環境用」の 2 か所に登録する。開発用が無いと debug ビルドへの通知がすべて `THIRD_PARTY_AUTH_ERROR` になる

2026-08-01 の検証 (issue #500) で実測した。Firebase Console の Cloud Messaging の設定にある「APNs 認証キー」には「開発用」と「本番環境用」の 2 つの登録先がある。本番環境用にだけ .p8 を登録した状態では、debug ビルド・simulator (APNs の Sandbox) あての送信がすべて `THIRD_PARTY_AUTH_ERROR` で失敗した。同じ .p8 を両方に登録すると解消した。

**なぜ:** debug ビルドと simulator は APNs の Sandbox に登録され、Sandbox あての送信には開発用の登録先のキーが使われる。

**どう使う:**

- 新しい Firebase プロジェクトで通知を設定する時は、dev・prod のプロジェクトそれぞれで、開発用と本番環境用の両方にキーを登録する (このリポジトリのプロジェクト ID は `firebase/.firebaserc`)
- 原因の切り分けは、FCM の HTTP v1 (`https://fcm.googleapis.com/v1/projects/<プロジェクト ID>/messages:send`、認証は `gcloud auth print-access-token`) で直接送って行う。`validate_only: true` は APNs への配送を行わないため、`validate_only` が成功し、実際の送信が `THIRD_PARTY_AUTH_ERROR` になるなら、原因は APNs の認証情報だけと決まる
- このリポジトリの `sendShoppingListUpdateNotification` は、送信の失敗のエラーコードを warn のログに出す (`firebase/functions/src/functions/sendShoppingListUpdateNotification/function.ts`)
