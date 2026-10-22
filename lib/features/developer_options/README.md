# 開発者オプション（仮想ペアリング）

## 概要

デバッグビルド時のみ有効な開発者オプション機能。
シェイクジェスチャーでモーダルを表示し、「別ユーザーの操作」をシミュレーションする。

## 背景

iOS・Android 2台のデバイスでMaestro E2Eテストを実行する方式にはAndroid側に多数の問題がある（API 36 inputText不具合、debugビルド起動タイムアウト等）。
そのため1台のiOS Simulatorで「仮想ペアリング」として別ユーザーの操作をシミュレーションする方針に転換した。

## 仕組み

1. **デバッグユーザーID**: `{実UID}_debug_1` 形式のIDでFirestoreにドキュメントを作成
2. **Firestoreセキュリティルール**: `isDebugUserOf()` ヘルパーで `{uid}_debug_[0-9]+` パターンをマッチ。実ユーザーがデバッグユーザーのドキュメントを読み書きできる
3. **グループ参加**: デバッグユーザーIDをグループの `memberUserIDs` に追加。既存の `isGroupMember()` ルールで共有リソースにアクセス可能。`memberUserIDs` は firestore.rules がクライアントからの書き換えを拒否するため、開発者限定の Function `updateDebugUserGroupMembership`（呼び出し元本人の `{uid}_debug_{数字}` のみ追加・除去できる）を経由する（Issue #676）
4. **アイテム追加**: 既存の `AddShoppingListItem` を再利用し、`userID` にデバッグユーザーIDを指定
5. **カテゴリ設定作成**: カテゴリ共有E2E用に、デバッグユーザー所有の「デバッグ売り場 / 共有野菜」を決定的IDで作成

## ファイル構成

- `shake_detector.dart` — `sensors_plus` でシェイクジェスチャーを検出するウィジェット
- `page.dart` — 開発者オプションモーダルUI
- `provider.dart` — デバッグ操作用クラス群（`DebugUserCreate`, `DebugUserAddToGroup`, `DebugUserCleanup`）

## 操作

| 操作 | 説明 |
|---|---|
| デバッグユーザー作成 | `/users/{uid}_debug_1` ドキュメントを作成 |
| グループに追加 | `memberUserIDs` に追加 + プロフィール作成 |
| FCMトークン登録 | この端末のFCMトークンをデバッグユーザーの `privates` に登録。グループ通知（NotifyGroupButton）のプッシュが自端末に届くようになり、1台でプッシュ通知の実受信（Functions → FCM → APNs → 端末）を検証できる |
| アイテム追加 | 遅延実行で指定メッセージのアイテムを追加（Firestoreリアルタイム同期で画面に反映） |
| カテゴリ設定作成 | デバッグユーザー所有のカテゴリ軸とカテゴリを冪等に作成 |
| クリーンアップ | デバッグユーザーのプロフィール・カテゴリ・ユーザーデータと、実ユーザー側へ取り込んだデバッグカテゴリのコピーを削除 |

## Maestro E2Eテストでの使い方

1. iOS SimulatorでDevice > Shakeを実行（Maestroからは `runScript` で `xcrun simctl io booted shake`）
2. 開発者オプションモーダルが表示される
3. 各操作ボタンをタップ
4. 遅延後に操作が実行され、リアルタイム同期で画面に反映
