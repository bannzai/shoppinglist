---
scope: cross-repository
recorded: 2026-11-10
---
# mobile-mcp の最初の呼び出しで WebDriverAgent が起動すると、検証中のアプリがホーム画面の後ろに回る

2026-06-11 のローカルの simulator での検証で実測した。mobile-mcp の最初のツール呼び出しで WebDriverAgent が起動した直後、前面にあったアプリがホーム画面に戻った。アプリのプロセスと画面の状態は残っていた。simulator が 13 台起動している状態でも、mobile-mcp の `device` 引数に UDID を渡せば指定した simulator を操作できた。

**なぜ:** WebDriverAgent (XCTest のランナー) の起動が SpringBoard を前面にするためと見ている (実測からの推測で、出典は無い)。

**どう使う:** ローカルの simulator で mobile-mcp を使う時は、最初の呼び出しの後に `xcrun simctl launch <UDID> <bundle ID>` でアプリを前面に戻してから操作を続ける。このリポジトリの bundle ID は、debug ビルドが `com.bannzai.shoppinglist.dev` (`ios/Flutter/Debug.xcconfig`)、release ビルドが `com.bannzai.shoppinglist` (`ios/Flutter/Release.xcconfig`)。アプリが落ちたと判断しない。
