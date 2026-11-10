---
scope: cross-repository
recorded: 2026-11-10
---
# ホームウィジェットの `Button(intent:)` は、simulator の WebDriverAgent・mobile-mcp のタップでは AppIntent が実行されない

2026-06-13 の E2E の検証 (issue #404) で実測した。ホームウィジェットのチェックボックス (`ios/ShoppingListWidget/ShoppingListWidgetView.swift` の `Button(intent: ToggleItemIntent(...))`) を simulator 上で WebDriverAgent・mobile-mcp からタップしても、`ToggleItemIntent` は実行されなかった。実装の配線は正しく、アプリで行った変更がウィジェットに反映されることはスクリーンショットで確認できた。

**なぜ:** WidgetKit の操作できるウィジェットは、自動操作のツールが送るタップを通常のボタンと同じには扱わず、タップが届いても Intent の実行に至らないと見ている (実測からの推測で、出典は無い)。

**どう使う:**

- ウィジェットからアプリへの同期 (ウィジェットのチェックボックスの操作) は、自動の E2E の対象にしない。人の手のタップか実機で確認する項目として扱う
- アプリからウィジェットへの反映は、スクリーンショットで自動で確認できる
