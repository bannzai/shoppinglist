---
scope: repository
recorded: 2026-11-10
---
# widget test では文言ではなく Widget の型で存在を確かめる

PR #371 のレビューで、owner から `find.text(...)` / `find.textContaining(...)` の文言の一致で UI の存在を検証しないよう指摘された。

**なぜ:** 文言は実装のたびに変わるため、文言の一致で書いたテストは、挙動が変わっていなくても文言の変更だけで壊れる。

**どう使う:**

- 一致させたい文言を含む Widget を 1 つの部品にし、`expect(find.byType(<部品>), findsOneWidget)` で存在を確かめる
- 件数などの中身は `tester.widget<<部品>>(find.byType(<部品>))` で取り出したプロパティで確かめる (例: `AICategorizeButton` の `uncategorizedItems.length`)
- `test/` には `find.text` を使う既存のテストが残っている (2026-11-10 時点で 26 ファイル。`grep -rlE "find\.text|find\.textContaining" test`)。新しく書くテストでは増やさない。既存のテストの書き換えは依頼された時だけ行う
