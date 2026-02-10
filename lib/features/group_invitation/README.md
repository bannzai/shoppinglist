# グループ招待機能

## 概要
URLベースのグループ招待機能。招待URLを生成→共有→受信者がリンクを開いてグループに参加する。

## 画面
- `GroupInvitationAcceptPage`: 招待受け入れ確認画面
  - ディープリンク経由で表示される
  - 「参加する」ボタンで `AcceptGroupInvitation` を呼び出してグループに参加
  - 成功時はホーム画面に遷移
  - エラー時（期限切れ等）はエラーメッセージを表示

## 招待フロー
1. 既存メンバーが `ShoppingListSettingPage` の「グループに招待」ボタンをタップ
2. `CreateGroupInvitation` で招待URLを生成
3. OS標準シェアシートで招待URLを共有
4. 受信者がURLを開くとアプリが起動し `DeepLinkResolver` が検知
5. `GroupInvitationAcceptPage` が表示され「参加する」で完了

## 招待URL形式
`https://shopping-list-prod-a615c.web.app/invite?token={token}`

## 有効期限
招待リンクの有効期限は7日間。期限切れ後はエラーメッセージが表示される。
