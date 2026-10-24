# Firestore Rules はシンプルに保つ

## 原則
Firestore Security Rules は **JWT (Firebase Auth) 本人認証 + リソース所有判定のみ** を行う。
それ以外のデータ内容に踏み込んだガード（プレミアム判定・期間判定・特定フィールドの diff チェック等）は実装しない。

## 許可される判定パターン
- `request.auth != null` (認証済みか)
- `request.auth.uid == <id>` (本人か)
- `request.auth.uid in <memberUserIDs>` (グループメンバーか)
- `<id>.matches(request.auth.uid + '_debug_[0-9]+')` (debug user か)

## 実装してはいけない判定
- Custom Claims に基づく機能ガード (`request.auth.token.isPremium == true` 等)
- `resource.data.createdDateTime >= request.time - duration.value(N, 'd')` のような期間判定
- `request.resource.data.diff(resource.data).changedKeys().hasAny([...])` のような特定フィールド変更ガード
- `request.resource.data.<field> == request.auth.uid` のような所有者判定の重ね掛け（`isGroupMember()` 等で十分）
- `getAfter()` / `get()` を多用したクロスドキュメント参照（必要最小限に）

## 理由
- Rules が複雑化すると `permission-denied` の根本原因切り分けに時間がかかり、Maestro E2E や手動検証のブロッカーになる
- プレミアム機能制限などはクライアント UI と Cloud Functions 側のガードで制御する。Rules で二重に防ぐ必要はない（このアプリのデータはセンシティブではないため）
- データ所有者の不正書き換え等はグループメンバー全員を信頼する設計（同居家族・同居者向けアプリ）で許容する

## 例外
- クライアントからの直接 read/write を完全に禁止し Functions Admin SDK 経由のみとするケースは `allow read, write: if false` を明示する（例: `groupInvitations/`）。
- `groups/{groupID}` の `ownerUserID` / `memberUserIDs` は、書き込み前後の値を比べて変更を拒否する（自分の脱退だけ許可）。サーバーがオーナー判定・グループ数上限・通知の宛先の認可に使う権限境界で、メンバーへの信頼では塞げないため（オーナーの乗っ取り・上限の回避・任意のユーザーへの通知。Issue #676）。このフィールドを変える処理は Functions に置く。他のフィールドにこの例外を広げない

## 参照
- `firebase/firestore.rules` (本ルールに従って簡略化済み)
- Issue #239 動作確認時に検出した permission-denied の経緯
