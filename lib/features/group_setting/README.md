# グループ設定 (GroupSetting)

## 概要
グループのメンバー管理、グループ名編集、メンバー招待を行う画面。

## 導線
`ShoppingListSettingPage` →「グループ設定」ボタン → `GroupSettingPage`

## 機能
- **グループ名編集**: オーナーのみ編集可能。非オーナーは読み取り専用表示
- **メンバー一覧表示**: `/groups/{groupID}/userProfiles` からプロフィールを取得して表示。displayName未設定の場合は「名前未設定」と表示
- **メンバー削除**: オーナーのみ、自分以外のメンバーを削除可能。Firebase Function `removeGroupMember` を呼び出す。削除されたメンバーの `defaultGroupID` はnullに設定され、次回起動時に新グループが自動作成される
- **グループ招待**: 招待コードを発行してメンバーを招待。`ShoppingListSettingPage` と同じ `createGroupInvitation` を使用

## 権限
- オーナー: グループ名編集、メンバー削除、招待コード発行
- メンバー: メンバー一覧閲覧、招待コード発行
- `ownerUserID` がnullのレガシーグループ: グループ名編集・メンバー削除は不可

## 関連ファイル
- `lib/provider/group.dart` - Groupのリアルタイム監視
- `lib/provider/group_user_profile.dart` - プロフィール一覧・更新
- `lib/provider/group_member_remove.dart` - メンバー削除
- `lib/provider/group_name_update.dart` - グループ名更新
- `lib/entity/group_user_profile.dart` - GroupUserProfileエンティティ
- `firebase/functions/src/functions/removeGroupMember/` - メンバー削除Function
- `firebase/functions/src/functions/updateGroupName/` - グループ名更新Function
