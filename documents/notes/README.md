# リポジトリのメモ

このリポジトリの作業で分かった、コードや他の文書からは読み取れない事実の索引。読むべき場面に当たるメモの本文を読む。

## 検証・テストの進め方

- [Firebase Functions の修正は単体テストで止めず、デプロイ後に実アプリで結果のログまで確かめる](functions-fix-verify-on-real-app.md) — Firebase Functions を直して動作確認の範囲を決める時
- [UI の操作の検証は、mobile-mcp・Maestro の前に widget test で書けないかを先に検討する](prefer-widget-test-before-device-tools.md) — UI の挙動の検証方法を選ぶ時
- [widget test では文言ではなく Widget の型で存在を確かめる](widget-test-match-by-type-not-text.md) — widget test を書く時
- [買い物リストの行の長押しドラッグを widget test で動かす時は、行の中央ではなく左端をつかむ](drag-widget-test-grab-row-left-edge.md) — 買い物リストの並べ替えの widget test を書く時

## simulator での動作確認

- [simulator で debug ビルドを動かす時は dart-define が要る。無いと起動直後の白い画面で止まる](debug-run-requirements-on-simulator.md) — ローカルの simulator でアプリをビルド・起動する時、白い画面で止まった時
- [オンボーディングは、アプリを削除しても再表示されない。Keychain が空の新しい simulator で再現する](onboarding-needs-fresh-simulator.md) — 新規ユーザーの状態やオンボーディングを確かめる時
- [mobile-mcp の最初の呼び出しで WebDriverAgent が起動すると、検証中のアプリがホーム画面の後ろに回る](wda-first-call-sends-app-to-background.md) — ローカルの simulator で mobile-mcp を使い始めた直後にアプリが消えた時
- [mobile-mcp で Flutter の 1 行の TextField のキーボードを閉じる時は、done の座標ではなく ENTER ボタンを使う](mobile-mcp-flutter-keyboard-dismiss.md) — mobile-mcp で文字を入力した後にキーボードを閉じる時
- [数秒で消える SnackBar・トーストは、mobile-mcp のスクリーンショットでは撮れない。`simctl io screenshot` の連続撮影で撮る](capture-transient-snackbar-with-simctl.md) — 一瞬だけ出る表示をスクリーンショットで確かめる時
- [ホームウィジェットの `Button(intent:)` は、simulator の WebDriverAgent・mobile-mcp のタップでは AppIntent が実行されない](widget-intent-button-not-triggered-by-wda-tap.md) — ホームウィジェットの操作を自動で検証しようとする時
- [simulator への実際のプッシュ通知は届く。届くまでの時間がばらつくため、トーストの assert は 2 つの文言のどちらでも通す](simulator-push-delivery-and-toast-assertion.md) — プッシュ通知の受信や通知のトーストを検証する時

## Maestro

- [このアプリの Maestro flow を書く時に、要素が見つからない・操作が効かない原因になる点](maestro-flow-writing-pitfalls.md) — Maestro の flow を書く時、flow が「要素が見つからない」で失敗した時
- [Maestro で Flutter の長押しドラッグは、`duration: 10000` の遅い swipe で再現できる](maestro-long-press-drag-with-slow-swipe.md) — Maestro で長押しドラッグや並び順を検証する時
- [Maestro でプレミアムを付与する flow は、`SHOPPINGLIST_DEVELOPER_TOKEN` を渡したビルドでないと「開発者のみ」のエラーで失敗する](maestro-premium-grant-needs-developer-token-build.md) — プレミアムの付与・デバッグユーザーの作成を含む flow を流す時
- [バックグラウンドで実行した Maestro の成否は、完了の通知やログではなく JUnit のレポートで決める](maestro-background-run-verdict.md) — ビルドや Maestro をバックグラウンドで実行して結果を判定する時

## ビルド・CI

- [`flutter pub get` の前に `.dart` を編集すると、hook の `dart format ./` がリポジトリ全体を書き換える](dart-format-before-pub-get-reformats-all-files.md) — 新しい worktree で最初に `.dart` を編集する前、差分に覚えのないファイルが大量に出た時
- [flutter-ci の lint・codegen の失敗は、ローカルの build_runner のキャッシュを消してから再現する](flutter-ci-lint-codegen-debugging.md) — flutter-ci の lint・codegen が失敗した時

## 実装で繰り返しやすい不具合

- [`appShowModalBottomSheet` のシートの中で `appUserProvider` を読むと、読み込み中のまま null になる](modal-sheet-app-user-provider-stays-loading.md) — モーダルシートの中でユーザーやプレミアムの状態を使う処理を書く時
- [`ReorderableListView` のドラッグ中に行を消すと GlobalKey の重複でクラッシュする。同じ key のまま中身を `SizedBox.shrink` に替える](reorderable-list-row-removal-during-drag-crash.md) — 並べ替えのリストで、ドラッグ中に行を出し入れする実装をする時
- [GenKit の Functions が `INTERNAL` を返す時は、入力が null でないかと Cloud Logging の実際のエラーを確かめる](genkit-functions-internal-error-investigation.md) — Functions の呼び出しが `INTERNAL` で失敗した時、引数の無い Functions を呼ぶコードを書く時

## 外部サービス

- [Paywall に月額・年額が出ない時は、コードより先に RevenueCat の本番の Offering の設定を確かめる](paywall-plans-missing-check-revenuecat-offering.md) — Paywall にプランが表示されないと報告された時
- [Firebase Console の APNs 認証キーは「開発用」と「本番環境用」の 2 か所に登録する。開発用が無いと debug ビルドへの通知がすべて `THIRD_PARTY_AUTH_ERROR` になる](apns-key-development-slot-required-for-debug-builds.md) — プッシュ通知が `THIRD_PARTY_AUTH_ERROR` で失敗した時、新しい Firebase プロジェクトで通知を設定する時
- [ストアの申請で使う ID と、申請の時に App Store Connect が返したエラー](store-submission-facts.md) — ストアの申請・アプリ名やメタデータの変更をする時

## 依頼の受け方・書き方

- [機能を提案する issue には、参考にしたアプリと根拠の URL を書く](issue-include-source-urls.md) — 機能を提案する issue を作る時
- [調査結果・issue・プランに agent が優先度や順位を付けない](no-agent-assigned-priority.md) — 調査結果・issue・プランを書く時
- [「〜のような箇所を直して」と例で示された修正は、同じ形の箇所をコードベース全体から洗い出して直す](example-based-fix-sweep-codebase.md) — 例を 1 つ挙げた修正の依頼を受けた時
