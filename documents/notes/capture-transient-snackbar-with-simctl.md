---
scope: cross-repository
recorded: 2026-11-10
---
# 数秒で消える SnackBar・トーストは、mobile-mcp のスクリーンショットでは撮れない。`simctl io screenshot` の連続撮影で撮る

ローカルの simulator で実測した。mobile-mcp の `mobile_take_screenshot` (WebDriverAgent 経由) で、4 秒で自動で消える SnackBar を撮ろうとすると、消えた後の画面だけが撮れた。消えない設定の SnackBar は撮れた。

**なぜ:** WebDriverAgent は画面の動きが止まるまで待ってから撮影するため、アニメーションやタイマーが進んでいる間は撮影されない。

**どう使う:**

- 待たずにその時点の画面を取る `xcrun simctl io <UDID> screenshot <パス>` を使う (ローカルの simulator だけで使える)
- タップと撮影の間に時間が空くと表示の時間を過ぎるため、タップの操作と撮影のコマンドを同じ応答の中で続けて実行する
- 「表示された → 消えた」を確かめるには、0.4 秒間隔で十数枚を続けて撮り、最初の数枚 (表示中) と最後の数枚 (消えた後) を比べる
- タップでハンドラが動いたかは、`flutter run` のログの `logEvent name: ...` で確かめられる
