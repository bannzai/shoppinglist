# 通知パーミッション機能

## 概要
プッシュ通知の許可を、価値を説明するプリパーミッションダイアログ付きで要求する機能。
以前はアプリ起動時 (`main.dart`) に説明なしで OS ダイアログを出していたが、拒否されると
iOS では二度と再要求できないため、通知の価値が伝わるタイミングに移動した (Issue #500)。

## 画面
- `NotificationPrePermissionDialog`: プリパーミッションダイアログ
  - 「グループのメンバーの更新をプッシュ通知で受け取れる」という価値を説明する
  - 「通知を許可」で OS の通知許可ダイアログへ進む
  - 「あとで」/ 背景タップで何もせず閉じる (OS ダイアログは消費されないため、次の機会に再表示される)

## フロー
`maybeRequestNotificationPermission` は OS の許可状態が notDetermined の時だけダイアログを
表示する (許可・拒否済みなら何もしない冪等設計)。以下の導線から呼び出す:

1. 招待する側: 招待コード発行ダイアログを閉じた直後
   - `ShoppingListSettingPage` の「グループに招待」(trigger: `create_list_invitation`)
   - `GroupSettingPage` の「招待コードを発行」(trigger: `create_grp_invitation`)
   - `GroupCreatePage` のグループ作成直後の招待ダイアログ (trigger: `group_create`)
2. 招待された側: `GroupInvitationAcceptPage` で参加成功しホームへ戻る直前 (trigger: `accept_group_invitation`)

## 制約
- OS の通知許可ダイアログは iOS では一度しか表示できない。プリパーミッションで「あとで」を
  選んだ場合は OS ダイアログを消費しないため、別の導線で再度誘導できる
- FCM トークンの取得・保存 (`lib/provider/fcm_token.dart`) は通知許可と独立して動作するため、
  許可前でもトークンは登録される (許可されるまで通知は表示されないだけ)
