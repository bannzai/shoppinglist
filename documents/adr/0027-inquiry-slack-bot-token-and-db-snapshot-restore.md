# 0027. お問い合わせ機能の Slack Bot Token 通知 と DB スナップショット復元

## Status
Accepted

## Context
これまでお問い合わせ導線は Google Forms へのリンク（`lib/components/button/inquiry.dart` の `inquiry()`）だった。アプリ内で完結する内製フォームに置き換え、運用チームが Slack で受け取れるようにする要件が出た。さらに、不具合報告の調査時に「問い合わせユーザーの DB 状態」を再現したいという要件があった。

設計上、以下の選択肢があった。

1. **Slack への通知方式**: Incoming Webhook か Bot Token + Web API（`chat.postMessage`）か
2. **DB 状態を復元する仕組み**: 何を・どこに保存し、どう復元するか

参考にした Riamo（`Sukidayo-app/Riamo`）のお問い合わせ実装は Bot Token + Web API を使い、Slack スレッドにスナップショット JSON とスクリーンショットを添付、復元は Slack 添付 JSON をダウンロードして dev へ流し込む方式だった。

本アプリ側の制約・前提:
- Firebase Functions は全て GenKit（`onCallGenkit`）で定義する規約。Slack ライブラリは未導入だが `fetch` での外部 POST 実績あり
- 「変更は必要最低限」の方針
- スクリーンショット添付は今回スコープ外（メール＋カテゴリ＋内容のみ）

## Decision

### 1. Slack 通知は Bot Token + chat.postMessage を採用
Incoming Webhook ではなく Bot Token（`SLACK_BOT_TOKEN`）+ Web API（`chat.postMessage`）を採用する。理由は、Webhook では原理的にできない**スレッド返信・ファイル添付**という将来拡張の余地を残すため。`chat.postMessage` の戻り値 `ts`（スレッド親）を保持できる形にしておく。

- Secret は `defineSecret` で `SLACK_BOT_TOKEN` / `SLACK_INQUIRY_CHANNEL_ID` を管理し、`onCallGenkit` の `secrets` に渡す
- メッセージは Block Kit で組み立て、問い合わせ ID・ユーザー情報・内容・端末情報・**復元コマンド例**を載せる
- 今回のスコープ（添付なし・スナップショットは Firestore 保存）では実際にはスレッド/添付を使わないが、方式として Bot Token に倒す

検討した代替案: **Incoming Webhook**（最小構成・ライブラリ不要）。今回のスコープでは機能的に十分だったが、将来のスレッド/添付ができないため不採用。

### 2. DB スナップショットは問い合わせドキュメントに保存し、ID で復元
お問い合わせ送信時に、送信ユーザーに紐づく Firestore ドキュメント（`users/{uid}` とサブコレクション、ユーザーがメンバーの `groups` と全サブコレクション）を収集し、JSON 文字列として `inquiries/{id}.snapshotJson` に格納する。

- Timestamp はマーカー化してシリアライズし、復元時に `admin.firestore.Timestamp` へ戻す（`firebase/functions/src/entity/snapshot.ts` を submit/restore で共有）
- ドキュメント上限（約 1MiB）対策として、JSON が 900KB を超える場合は `snapshotJson=null` + `snapshotOmittedReason` を記録し、お問い合わせ送信自体は成立させる（best-effort）
- 復元は npm スクリプト `script-restore-inquiry-snapshot`（`firebase/functions/src/script/restoreInquirySnapshot.ts`）で行う。**問い合わせ ID を引数**にとり、接続中プロジェクトの `inquiries/{id}` を読み、スナップショットのパスへ `set(merge:true)` で書き戻す（冪等）
- 既定はドライラン（対象一覧の表示のみ）。`--apply` で実書き込み。本番プロジェクトへの `--apply` は `ALLOW_PROD_RESTORE=true` がない限り拒否する

検討した代替案:
1. **Riamo 方式（Slack スレッドに JSON 添付 → DL して復元）**: Slack 添付運用が前提になり手数が増えるため不採用。Firestore 保存ならコマンド単体で完結する
2. **Firestore 全体の export/import バックアップ**: 問い合わせ機能と独立した汎用バックアップになり、要件（その問い合わせユーザーの状態再現）に対して過剰

### 3. inquiries はクライアント直接アクセス禁止
`inquiries` コレクションは `firestore.rules` で `allow read, write: if false` とし、`submitInquiry` Function（Admin SDK）経由のみで作成する。ユーザーデータのスナップショットを含むため、本人にも直接読ませない。`.claude/rules/firestore-rules-simplicity.md` の「Functions Admin SDK 経由のみ」の例外パターンに従う。

## Consequences
- アプリ内でお問い合わせが完結し、運用チームは Slack で即座に受け取れる。問い合わせ ID から該当ユーザーの DB 状態をコマンド一発で再現できる
- Slack を Bot Token に倒したことで、将来スレッド返信・ファイル添付（スクショ/スナップショット JSON）へ拡張できる。一方、運用開始には Slack App 作成・`chat:write` スコープ付与・Bot のチャンネル招待・Secret 設定が必要になる
- スナップショットは送信ユーザーの全 group サブコレクションを読むため、データ量の多いユーザーでは Function の read が増える。1MiB 超過時は省略され復元不可になる（その場合は理由を記録）
- 復元コマンドは「接続中プロジェクトの問い合わせを同プロジェクトへ復元」する単一プロジェクト方式。本番の問い合わせを別の dev プロジェクトに読み込んで再現する（読み元≠書き先）には、別途クロスプロジェクト対応の拡張が必要
- 旧 Google Forms 方式（`lib/components/button/inquiry.dart`）は削除した
