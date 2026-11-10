---
scope: cross-repository
recorded: 2026-11-10
---
# バックグラウンドで実行した flutter build・Maestro の成否は、完了の通知やログではなく JUnit のレポートで決める

2026-06-10 にローカルで Maestro の E2E を実行した時に実測した。

- Bash のバックグラウンド実行の「完了」の通知が先に届き、子プロセス (`xcodebuild`・Maestro の java) が動き続けていることがあった。通知を信じて同じコマンドをもう一度実行すると、`flutter build ios` が `Xcode build failed due to concurrent builds, will retry` を繰り返した
- バックグラウンドのタスクとメインの Bash で、同じパスのログファイルの内容・有無が一致しないことがあった
- 並行する別のセッションが simulator を停止し、`Device not connected` で失敗したことがあった

**なぜ:** 完了の通知は親のシェルの終了で出るため、子プロセスの終了を示さない。ログの grep は、読んだ時点のファイルが実行の結果と一致している保証が無い。

**どう使う:**

- やり直す前に、残っているプロセスを確かめる: `pgrep -f "xcodebuild -configuration"` と `pgrep -f maestro.cli.AppKt`
- 成否は `maestro test <flow> --device <UDID> --format junit --output tmp/maestro_report.xml` の JUnit のレポートで決める (`failures="0"` か)
- 画面は `xcrun simctl io <UDID> screenshot <パス>` で撮って確かめる
- 実行の直前に `xcrun simctl list devices booted` で自分の simulator が起動しているかを確かめる
