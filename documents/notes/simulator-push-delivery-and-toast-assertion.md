---
scope: repository
recorded: 2026-11-10
---
# simulator への実際のプッシュ通知は届く。届くまでの時間がばらつくため、トーストの assert は 2 つの文言のどちらでも通す

2026-08-01 に Apple Silicon の Mac のローカルの simulator で実測した (issue #528、PR #527・#529)。

- **FCM → APNs の Sandbox → simulator の配送は動く**。届くまで 30〜90 秒のことが多いが、速い時は送信の結果の前後 40 ms 以内に `onMessage` が呼ばれた
- **1 台で受信を確かめる** には、開発者オプションの「デバッグユーザーにFCMトークン登録」を使う
- **届いたかどうか** は、スクリーンショットの連続撮影・通知センター・apsd のログ (`xcrun simctl spawn <UDID> log show --predicate 'process == "apsd"'` の `receivedPushWithTopic`) で確かめる
- **アプリが前面の時にトーストが出なかった不具合 (#528) の原因は、通知の受信ではなくトーストの表示だった**。`onMessage` は呼ばれていたが、操作の無い画面では次のフレームが予定されず、トーストが描かれなかった。`lib/components/toast/toast_overlay.dart` の `scheduleFrame` で直してある。同じ症状を見た時に、通知の delegate の競合を先に疑わない
- **起動直後は最初の画面が出るまで 60〜90 秒かかった**。`clearState` の直後は、`main()` が `runApp` の前に Remote Config の取得 (`lib/utils/remote_config/remote_config.dart` の `fetchTimeout` は 1 分) などを待つ。`maestro/flows/shared/anonymous_sign_in.yaml` は 180 秒待つ

**なぜ:** トーストは 1 つしか表示されず、新しい表示が前の表示を置き換える。配送が速いと、送信した側の「グループに通知しました」と、届いた通知のトーストのどちらが残るかが実行のたびに変わる。

**どう使う:** Maestro で通知のトーストを assert する時は、`maestro/flows/notify_group_button_test.yaml` の形で書く。

- タイトルと本文の 2 行のトーストは 1 つの要素になるため、正規表現に `(?s)` を付ける
- 2 つの文言のどちらでも通す: `"(?s).*(グループに通知しました|さんが買い物リストを更新しました).*"`
- この assert は送信した側の文言でも通るため、通知が届いたことの確認にはならない。届いたことは、上の「届いたかどうか」の方法 (apsd のログ等) で別に確かめる
