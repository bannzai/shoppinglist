# グループ作成 (GroupCreate)

## 概要
新しいグループを作成する画面。グループ名（必須）とアイコンを設定して作成し、作成成功後にそのまま招待コードを発行してメンバーを招待できる。

## 画面
- `GroupCreatePage`: グループ作成画面
  - `GroupListPage` の FAB「+」から遷移
  - グループ名入力（`TextField`、autofocus）
  - アイコン選択（`home` / `cart` / `fork` / `cookie` / `pets` / `bag` の 6 種、3x2 グリッド）
  - 「作成する」ボタンで `CreateGroup` を呼び出してグループを作成

## フロー
1. グループ名を入力し、アイコンを選択する
2. 「作成する」ボタンをタップ（`CreateGroup` 実行）
3. 作成成功後、`CreateGroupInvitation` で招待コードを自動発行し、共有ダイアログ（`_PostCreateInvitationDialog`）を表示
4. 招待コードを共有して画面を閉じる

## グループ名の必須化 (Issue #432)
名称未設定のグループ同士の混同を防ぐため、グループ作成時に名前を必須とする。

- グループ名が空（空白のみを含む）の場合、「作成する」ボタンは無効（`onPressed: null`）。
- これにより「作成 → 作成直後の自動招待」の導線では常にグループ名が確定済みになる。
- 入力監視は `useListenable(nameController)` で行い、`name.trim()` が非空のときのみ作成可能とする。

> 補足: 初回に自動作成されるソログループ（`lib/features/resolver/app_entntiy_prepare.dart`）は `name: null` で作成され、本画面の必須化の対象外。招待しようとしたときに名前が要求される（[グループ招待機能の README](../group_invitation/README.md) 参照）。

## 関連ファイル
- `lib/provider/group_create.dart` - `CreateGroup`（Firebase Function `createGroup` 呼び出し）
- `lib/provider/group_invitation.dart` - `CreateGroupInvitation`（作成直後の招待コード発行）
- `lib/entity/group.dart` - `Group` エンティティ・`Group.hasRegisteredName`
