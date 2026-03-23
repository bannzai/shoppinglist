# 0004. FCMプッシュ通知のアーキテクチャ

## Status

Accepted

## Context

買い物リストの更新をグループメンバーに通知するプッシュ通知機能を実装する。
通知の仕組みとして、FCMトークンの保存先、通知送信の経路、手動/自動通知の2パターンの設計を決定する必要がある。

検討事項:
1. FCMトークンをどこに保存するか
2. 通知送信をクライアント直接 vs Firebase Function経由のどちらで行うか
3. Firestoreトリガー（onDocumentUpdated）を使うか、クライアントから明示的に呼ぶか

## Decision

### FCMトークンの保存先: `AppUserPrivate`

FCMトークンは `/users/{uid}/privates/{id}` の `fcmTokens: List<String>` フィールドに保存する。

- `privates` サブコレクションはセキュリティルールで `allow read: if false` のため、他ユーザーのトークンがクライアントから読めない
- Firebase Functions（Admin SDK）からは読み取り可能
- 1ユーザーが複数デバイスを持つケースに対応（配列で管理）

### 通知送信: GenKit Function経由

`sendShoppingListUpdateNotification` GenKit関数をクライアントから呼び出す。

- プロジェクトの規約として `onDocumentCreated` / `onDocumentUpdated` トリガーは禁止（コードがトレースしにくく、思わぬタイミングで発動するため）
- クライアントから明示的に呼ぶことで、通知タイミングをユーザーがコントロールできる
- GenKit定義によりAPIコンソールで検証可能

### 手動/自動の2パターン

- **手動通知**: アイテム変更後にSnackBarでメンバーアイコンを表示し、タップで個別/一括送信
- **自動通知**: 設定画面のトグルで有効化。アプリがバックグラウンドに移行した時、変更があれば全メンバーに自動送信

## Consequences

- トークンの無効化（デバイス変更、アプリ削除）時は、送信失敗したトークンをFunction側で `arrayRemove` してクリーンアップする
- 通知の重複送信（手動送信後にバックグラウンド移行で自動送信）は、UIの送信済み状態管理で部分的に防止するが、完全な重複防止は行わない（通知の取りこぼしより多少の重複が許容される）
