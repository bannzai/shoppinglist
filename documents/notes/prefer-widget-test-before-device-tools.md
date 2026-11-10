---
scope: repository
recorded: 2026-11-10
---
# UI の操作の検証は、mobile-mcp・Maestro の前に widget test で書けないかを先に検討する

買い物リストの長押しドラッグの並べ替えを検証した時、owner から「mobile-mcp や maestro に限らず dart コードで検証する方法があるなら、そちらを先に書いてほしい」と求められた。

`WidgetTester` は `tester.startGesture` → 長押しの時間だけ `pump` → `moveBy` → `up` で実際のジェスチャを駆動でき、Provider を記録用の実装で override すれば、並べ替えのコールバックから保存の `call` までを assert できる (実例: `test/features/shopping_list/components/shopping_list_items/shopping_list_items_cross_category_test.dart`)。

**なぜ:** widget test は速く、結果が毎回同じで、CI で実行され、回帰の検出にもなる。simulator を使う検証は時間がかかり、結果が環境に左右される。

**どう使う:** UI の挙動の検証を求められたら、(1) 判定のロジックを純粋関数に切り出して単体テストにする、(2) Widget の配線を widget test で実際のジェスチャを使って検証する、の順に用意する。これは用意する順番の決まりで、`AGENTS.md`「テスト方針」が求める Maestro の E2E と simulator での動作確認は省かない。simulator は最後の確認に回す。
