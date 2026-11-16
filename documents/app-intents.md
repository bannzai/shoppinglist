# App Intents (Siri・ショートカット)

iOS のアプリ本体 (Runner) が Siri・ショートカットアプリ・Spotlight に公開している操作と、その制約。実装は `ios/Runner/AddShoppingListItemIntent.swift`。

## 公開している操作

- `AddShoppingListItemIntent`: アプリを開かずに買い物リストへアイテムを 1 件追加する。発話は `ShoppinglistAppShortcuts` が日本語と英語で登録している

ウィジェット用の intent (`ShoppingListConfigurationIntent`・`ToggleItemIntent`) は利用者が声やショートカットで頼む操作ではないため、ここには含めない。

## `@AppIntent(.tool)` を付けていない理由

Siri AI (iOS 27.3 のベータで開発者向けの先行プレビューが始まった新しい Siri) がアプリの intent を呼ぶには `@AppIntent(.tool)` マクロが要る。今は付けていない。

- 付けるとコンパイルできない: bannzai/Focus の PR #1327 ( https://github.com/bannzai/Focus/pull/1327 ) の調査で、Xcode 27.1 の iPhoneOS27.1.sdk にも Xcode 27.2 beta の iPhoneOS27.2.sdk にもこのマクロが無いと分かっている (このリポジトリでは実測していない)
- 先行プレビューは App Store 版と外部 TestFlight では動かない (出典: https://developer.apple.com/documentation/appintents/siri-ai-developer-preview )

付けられるようになる条件は、iOS 27.3 の SDK を含む Xcode で出荷用のビルドを作れること。その時は `AddShoppingListItemIntent` にマクロを足す。

## Simulator での確認の制約

bannzai/Focus の実測 (同リポジトリの `API_LIMITATION_MEMO.md`「App Shortcuts のタイルは Simulator では実行できない」、2026-11-08) では、Simulator のショートカットアプリで App Shortcut のタイルをタップすると「Unable to run App Shortcut」になり、アクションの検索から intent をショートカットに追加して実行する経路は動く。Siri への発話で intent が動くことは実機でしか確かめられない。
