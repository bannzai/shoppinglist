# ログイン後グループ参加/作成機能

## 概要
ログイン直後・グループ未参加(`defaultGroupID == null`)のユーザーに表示する初期セットアップ画面。
「招待コードで参加」か「自分のリストを作る(ソログループ作成)」を選ばせる。

## 画面
- `GroupJoinOrCreatePage`
  - 表示条件: `AppEntityPrepareResolver` が `appUserDefaultGroupID == null` を検知した時
  - 「招待コードで参加」: `GroupInvitationAcceptPage` を push（参加成功で `AcceptGroupInvitation` が `defaultGroupID` をセット）
  - 「自分のリストを作る」: `createGroup(setAsDefault: true, iconName: 'home')` でソログループを作成

## フロー
1. 新規ユーザーがサインイン
2. `AppUserCreateResolver` が AppUser ドキュメントを作成
3. `AppEntityPrepareResolver` が `defaultGroupID == null` を検知 → 本画面を表示
4. ユーザーが2択のいずれかを選択
5. `defaultGroupID` がセットされ、`AppEntityPrepareResolver` が再ビルドされてホームへ遷移

## 設計上のポイント
- 本画面は Navigator のルートではなく `AppEntityPrepareResolver` の直接の子。`defaultGroupID` がセットされると親が再ビルドし、明示的な pop なしで画面が置き換わる。
- 表示ゲートは `defaultGroupID == null` のみ。参加/作成いずれでも値がセットされ二度と表示されないため、表示済みフラグは持たない。
- 招待コードで参加した場合、参加元グループには既存リストがあるため、`AppEntityPrepareResolver` の初期リスト自動作成は発火しない。
