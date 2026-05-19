# 0012. Firestore Rules を JWT 本人認証とメンバーシップ判定のみに簡略化

## Status
Accepted

## Context
Issue #239 (Premium 動作確認を Promotional Entitlement + デバッグ機能経由に切替) の動作確認時、新規 anonymous user で Maestro E2E (`shared/anonymous_sign_in.yaml`) を実行したところ、ホーム画面で `[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.` が継続発生し「アイテムを追加」表示前にタイムアウトする現象に遭遇した。

当時の `firestore.rules` は以下のような複合判定を多用していた:

- `shoppingLists/{id}` の read: `isGroupMember() && (isPremiumFromClaim() || isReadableFreeShoppingList())`
  - `isPremiumFromClaim()` は `request.auth.token.isPremium == true` を要求
  - `isReadableFreeShoppingList()` は `createdDateTime` が 30日以内であることを要求
- `categories/{id}` の update: `locationOrders` 変更時のみ `isPremiumFromClaim()` を要求 (`diff().changedKeys().hasAny([...])`)
- `shoppingLists/{id}/items/{id}` の create/update: `imageURL` キー存在時のみ `isPremiumFromClaim()` を要求
- `shoppingLists/{id}` の create/update: `groupID == groupID` / `createUserID == request.auth.uid` の重ね掛けチェック
- `userProfiles/{id}` の create/update: `userID == request.auth.uid` の重ね掛けチェック (グループメンバーシップ判定済みなのに)

これらの判定が積み重なり、permission-denied 発生時の原因特定がスクリーンショット + 推測に頼らざるを得ず、Issue #239 動作確認の本筋（Promotional Entitlement 経路）の検証が長時間ブロックされた。

また、本アプリは「同居家族・同居者」が共通の買い物リストを共有するユースケースで、グループメンバー間の信頼が前提。「グループメンバーが他人の userProfile を不正書き換え」のような脅威は実害が小さく、Rules で二重に防ぐ必要性が薄い。プレミアム機能の制限はクライアント UI と Cloud Functions 側のガードで既に行われている。

## Decision
Firestore Security Rules は **JWT (Firebase Auth) の本人認証 + リソース所有判定 (メンバーシップ判定) のみ** を行うことに統一する。データ内容に踏み込むガード（プレミアム判定・期間判定・特定フィールドの diff チェック・所有者の重ね掛け）は Rules から全削除する。

採用する判定パターン:
- `request.auth != null` (認証済みか)
- `request.auth.uid == <id>` (本人か)
- `request.auth.uid in <memberUserIDs>` (グループメンバーか)
- `<id>.matches(request.auth.uid + '_debug_[0-9]+')` (debug user か)

各パスは原則 `allow read, write: if <上記いずれか>` の単純形に揃える。クライアントから直接触らせないドキュメント (`groupInvitations/{}` 等) のみ `allow read, write: if false` を明示する。

詳細方針は `.claude/rules/firestore-rules-simplicity.md` に文書化し、今後の Rules 変更時に踏襲する。

## Consequences

### 良い点
- Rules のトラブルシュートが容易になる。permission-denied 発生時に「認証されているか / メンバーシップが成立しているか」だけ確認すれば良い
- 新機能追加時に Rules 変更が不要になるケースが増える (`imageURL` 追加・新フィールド追加で Rules を弄る必要がない)
- Maestro E2E や手動検証のブロッカーを根本除去できる (Issue #239 で実際に再現)
- Custom Claims の `isPremium` 同期タイミングに UI / E2E が依存しない

### 悪い点 / トレードオフ
- グループメンバー全員が信頼できる前提の設計になる。悪意あるグループメンバーが他人の `userProfile` や `shoppingLists` を書き換える可能性は Rules では防げない (UI 側の操作導線で抑止する)
- プレミアム機能制限を Rules で二重に防ぐ層がなくなる。Cloud Functions ガードと UI ガードのみで担保することになる
- `shoppingLists` の 30日表示期限を Rules で強制できなくなる (UI 側の表示判定で実装する)

### 関連
- Issue #239 (Promotional Entitlement 動作確認時に問題判明)
- ADR 0008 (Promotional Premium grant の意思決定)
- ADR 0011 (developer token によるユーザー単位 Functions ガード — プレミアム判定とは別レイヤー)
- 旧 Rules で参照していた Custom Claims `isPremium` の付与経路は、現状 Cloud Functions 側のロジックで利用していないため Rules 削除と同時に依存先がなくなる
